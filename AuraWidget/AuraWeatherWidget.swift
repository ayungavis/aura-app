//
//  AuraWeatherWidget.swift
//  AuraWidget
//
//  Home screen weather widget.
//
//  Data flow: the app writes a `WidgetWeatherSnapshot` into the shared App Group
//  after every successful fetch. The widget renders from that. If the snapshot
//  has gone stale (the user has not opened the app in a while) the provider
//  refetches for the *last known coordinate* rather than asking for a location
//  fix — widgets get unreliable location service and this keeps the refresh
//  cheap and permission-free.
//

import SwiftUI
import WidgetKit

// MARK: - Timeline

struct AuraWeatherEntry: TimelineEntry {
  let date: Date
  let snapshot: WidgetWeatherSnapshot
  /// True when we are showing data we could not refresh — the UI dims slightly.
  let isStale: Bool
}

struct AuraWeatherProvider: TimelineProvider {
  /// How often WidgetKit is asked to rebuild. Weather does not move fast enough
  /// to justify more, and the system throttles aggressive widgets anyway.
  private static let refreshInterval: TimeInterval = 30 * 60

  /// Beyond this age we try a network refresh rather than trusting the snapshot.
  private static let staleAfter: TimeInterval = 60 * 60

  func placeholder(in context: Context) -> AuraWeatherEntry {
    AuraWeatherEntry(date: Date(), snapshot: .placeholder, isStale: false)
  }

  func getSnapshot(in context: Context, completion: @escaping (AuraWeatherEntry) -> Void) {
    // The widget gallery preview must render instantly — never hit the network.
    let snapshot = context.isPreview ? .placeholder : (WidgetDataStore.load() ?? .placeholder)
    completion(AuraWeatherEntry(date: Date(), snapshot: snapshot, isStale: false))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<AuraWeatherEntry>) -> Void) {
    Task {
      let entry = await buildEntry()
      let next = Date().addingTimeInterval(Self.refreshInterval)
      completion(Timeline(entries: [entry], policy: .after(next)))
    }
  }

  private func buildEntry() async -> AuraWeatherEntry {
    guard let stored = WidgetDataStore.load() else {
      return AuraWeatherEntry(date: Date(), snapshot: .placeholder, isStale: true)
    }

    let age = Date().timeIntervalSince(stored.updatedAt)
    guard age > Self.staleAfter else {
      return AuraWeatherEntry(date: Date(), snapshot: stored, isStale: false)
    }

    // Stale — refresh for the coordinate the app last saw.
    do {
      let fresh = try await WeatherServiceRouter.shared.fetchWeatherData(for: stored.location)
      WidgetDataStore.save(
        weather: fresh,
        locationName: stored.locationName,
        coordinate: stored.location.coordinate
      )
      let refreshed = WidgetDataStore.load() ?? stored
      return AuraWeatherEntry(date: Date(), snapshot: refreshed, isStale: false)
    } catch {
      AppLogger.weatherError(error)
      return AuraWeatherEntry(date: Date(), snapshot: stored, isStale: true)
    }
  }
}

// MARK: - Widget

struct AuraWeatherWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: WidgetDataStore.widgetKind, provider: AuraWeatherProvider()) { entry in
      AuraWeatherWidgetView(entry: entry)
        .containerBackground(for: .widget) {
          AuraWidgetBackground()
        }
    }
    .configurationDisplayName("Aura Weather")
    .description("Current conditions and the hours ahead.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

// MARK: - Views

struct AuraWeatherWidgetView: View {
  @Environment(\.widgetFamily) private var family
  let entry: AuraWeatherEntry

  var body: some View {
    switch family {
    case .systemMedium:
      MediumWidgetView(entry: entry)
    default:
      SmallWidgetView(entry: entry)
    }
  }
}

/// Brand gradient, matching the app's mesh background.
private struct AuraWidgetBackground: View {
  var body: some View {
    LinearGradient(
      colors: [
        Color(red: 0.433, green: 0.283, blue: 0.785),
        Color(red: 0.600, green: 0.469, blue: 0.903),
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
}

private struct SmallWidgetView: View {
  let entry: AuraWeatherEntry

  private var snapshot: WidgetWeatherSnapshot { entry.snapshot }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Image(systemName: snapshot.condition.systemImageName(isDay: snapshot.isDay))
        .font(.system(size: 26))
        .symbolRenderingMode(.multicolor)
        .foregroundStyle(.white)

      Spacer(minLength: 6)

      Text("\(Int(snapshot.temperature.rounded()))°")
        .font(.custom("InstrumentSerif-Regular", size: 44))
        .foregroundStyle(.white)
        .lineLimit(1)
        .minimumScaleFactor(0.6)

      Text(snapshot.conditionDescription)
        .font(.custom("InstrumentSans-Medium", size: 12))
        .foregroundStyle(.white.opacity(0.85))
        .lineLimit(1)
        .minimumScaleFactor(0.8)

      if let name = snapshot.locationName {
        Text(name)
          .font(.custom("InstrumentSans-Regular", size: 11))
          .foregroundStyle(Color(red: 1.0, green: 0.902, blue: 0.804))
          .lineLimit(1)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .opacity(entry.isStale ? 0.7 : 1)
  }
}

private struct MediumWidgetView: View {
  let entry: AuraWeatherEntry

  private var snapshot: WidgetWeatherSnapshot { entry.snapshot }

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      VStack(alignment: .leading, spacing: 0) {
        Image(systemName: snapshot.condition.systemImageName(isDay: snapshot.isDay))
          .font(.system(size: 24))
          .foregroundStyle(.white)

        Spacer(minLength: 4)

        Text("\(Int(snapshot.temperature.rounded()))°")
          .font(.custom("InstrumentSerif-Regular", size: 40))
          .foregroundStyle(.white)
          .lineLimit(1)
          .minimumScaleFactor(0.6)

        Text(snapshot.conditionDescription)
          .font(.custom("InstrumentSans-Medium", size: 12))
          .foregroundStyle(.white.opacity(0.85))
          .lineLimit(1)
          .minimumScaleFactor(0.8)

        if let name = snapshot.locationName {
          Text(name)
            .font(.custom("InstrumentSans-Regular", size: 11))
            .foregroundStyle(Color(red: 1.0, green: 0.902, blue: 0.804))
            .lineLimit(1)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      HStack(alignment: .top, spacing: 10) {
        ForEach(Array(snapshot.hours.prefix(5).enumerated()), id: \.offset) { _, hour in
          HourColumn(hour: hour, isDay: snapshot.isDay)
        }
      }
    }
    .opacity(entry.isStale ? 0.7 : 1)
  }
}

private struct HourColumn: View {
  let hour: WidgetWeatherSnapshot.Hour
  let isDay: Bool

  private var condition: WeatherCondition {
    WeatherCondition(wmoCode: hour.conditionCode)
  }

  var body: some View {
    VStack(spacing: 5) {
      Text(hour.date.formatted(.dateTime.hour()))
        .font(.custom("InstrumentSans-Regular", size: 10))
        .foregroundStyle(.white.opacity(0.7))
        .lineLimit(1)
        .minimumScaleFactor(0.7)

      Image(systemName: condition.systemImageName(isDay: hour.isDay ?? isDay))
        .font(.system(size: 14))
        .foregroundStyle(.white)

      Text("\(Int(hour.temperature.rounded()))°")
        .font(.custom("InstrumentSans-SemiBold", size: 12))
        .foregroundStyle(.white)
        .lineLimit(1)
    }
  }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
  AuraWeatherWidget()
} timeline: {
  AuraWeatherEntry(date: .now, snapshot: .placeholder, isStale: false)
}

#Preview("Medium", as: .systemMedium) {
  AuraWeatherWidget()
} timeline: {
  AuraWeatherEntry(date: .now, snapshot: .placeholder, isStale: false)
}
