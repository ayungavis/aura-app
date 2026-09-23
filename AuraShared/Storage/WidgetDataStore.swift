//
//  WidgetDataStore.swift
//  AuraApp
//
//  The single hand-off point between the app and its widget extension.
//
//  The widget cannot ask for the user's location on its own schedule reliably,
//  and re-running the full fetch in the extension would burn WeatherKit quota,
//  so the app writes a compact snapshot after every successful fetch and the
//  widget renders from that. The widget still refreshes independently when the
//  snapshot goes stale — see `AuraWidgetProvider`.
//
//  This file is a member of BOTH the app and the widget targets.
//

import CoreLocation
import Foundation

/// Compact, render-ready snapshot of what the widget needs.
struct WidgetWeatherSnapshot: Codable, Sendable {
  struct Hour: Codable, Sendable {
    let date: Date
    let temperature: Double
    let conditionCode: Int
    let precipitationProbability: Int
    /// Optional so snapshots written by an older build still decode.
    var isDay: Bool? = nil
  }

  let temperature: Double
  let apparentTemperature: Double?
  let conditionCode: Int
  let conditionDescription: String
  let isDay: Bool
  let locationName: String?
  let latitude: Double
  let longitude: Double
  let hours: [Hour]
  let updatedAt: Date

  var condition: WeatherCondition {
    WeatherCondition(wmoCode: conditionCode)
  }

  var location: CLLocation {
    CLLocation(latitude: latitude, longitude: longitude)
  }

  /// Placeholder used for the widget gallery and before any real fetch lands.
  static let placeholder = WidgetWeatherSnapshot(
    temperature: 24,
    apparentTemperature: 25,
    conditionCode: WeatherCondition.partlyCloudy.rawValue,
    conditionDescription: WeatherCondition.partlyCloudy.description,
    isDay: true,
    locationName: "Bali",
    latitude: -8.65,
    longitude: 115.22,
    hours: (1 ... 5).map { offset in
      Hour(
        date: Date().addingTimeInterval(Double(offset) * 3600),
        temperature: 24 + Double(offset % 3),
        conditionCode: WeatherCondition.partlyCloudy.rawValue,
        precipitationProbability: 10
      )
    },
    updatedAt: Date()
  )
}

nonisolated enum WidgetDataStore {
  /// Must match the `kind` string the widget registers with.
  static let widgetKind = "AuraWeatherWidget"

  private static let cacheKey = "widget_snapshot"

  static func save(weather: WeatherResponse, locationName: String?, coordinate: CLLocationCoordinate2D) {
    let snapshot = WidgetWeatherSnapshot(
      temperature: weather.current.temperature,
      apparentTemperature: weather.current.apparentTemperature,
      conditionCode: weather.current.condition.rawValue,
      conditionDescription: weather.current.condition.description,
      isDay: weather.current.isDay,
      locationName: locationName,
      latitude: coordinate.latitude,
      longitude: coordinate.longitude,
      hours: weather.hourly.prefix(6).map { hour in
        WidgetWeatherSnapshot.Hour(
          date: hour.date,
          temperature: hour.temperature,
          conditionCode: hour.condition.rawValue,
          precipitationProbability: hour.precipitationProbability ?? 0,
          isDay: hour.isDay
        )
      },
      updatedAt: Date()
    )

    // Long TTL: a stale snapshot still beats an empty widget, and the provider
    // decides for itself when to refetch.
    LocalCache.shared.save(snapshot, key: cacheKey)
  }

  static func load() -> WidgetWeatherSnapshot? {
    LocalCache.shared.load(
      key: cacheKey,
      as: WidgetWeatherSnapshot.self,
      expiration: 24 * 60 * 60
    )
  }
}
