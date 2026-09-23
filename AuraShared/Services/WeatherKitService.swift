//
//  WeatherKitService.swift
//  AuraApp
//
//  Apple WeatherKit backed implementation of `WeatherServiceProtocol`.
//
//  Requires the `com.apple.developer.weatherkit` entitlement *and* the WeatherKit
//  capability enabled for the App ID in the developer portal. When either is
//  missing every request throws, which is why `WeatherServiceRouter` keeps
//  Open-Meteo around as a fallback.
//

import CoreLocation
import WeatherKit

nonisolated final class WeatherKitService: WeatherServiceProtocol {
  static let shared = WeatherKitService()

  private let service = WeatherKit.WeatherService.shared

  func fetchWeatherData(for location: CLLocation) async throws -> WeatherResponse {
    AppLogger.networkRequest("weatherKit: \(location.coordinate.latitude), \(location.coordinate.longitude)")

    // Request only the two datasets the UI renders. `weather(for:)` alone pulls
    // daily, alerts and minute-by-minute too — more bytes and more quota for data
    // that is thrown away.
    let (current, hourlyForecast) = try await service.weather(
      for: location,
      including: .current, .hourly
    )

    let currentData = CurrentWeatherData(
      temperature: current.temperature.converted(to: .celsius).value,
      apparentTemperature: current.apparentTemperature.converted(to: .celsius).value,
      humidity: Int((current.humidity * 100).rounded()),
      windSpeed: current.wind.speed.converted(to: .kilometersPerHour).value,
      windDirection: current.wind.direction.converted(to: .degrees).value,
      condition: Self.mapCondition(current.condition),
      isDay: current.isDaylight,
      localTime: Self.localTimeString()
    )

    // WeatherKit returns hours starting at the top of the current day, so drop
    // everything already in the past before taking the next 24.
    let now = Date()
    let hourly: [HourlyWeatherData] = hourlyForecast.forecast
      .filter { $0.date >= now.addingTimeInterval(-3600) }
      .prefix(24)
      .map { hour in
        HourlyWeatherData(
          date: hour.date,
          temperature: hour.temperature.converted(to: .celsius).value,
          condition: Self.mapCondition(hour.condition),
          humidity: Int((hour.humidity * 100).rounded()),
          windSpeed: hour.wind.speed.converted(to: .kilometersPerHour).value,
          precipitationProbability: Int((hour.precipitationChance * 100).rounded()),
          isDay: hour.isDaylight
        )
      }

    AppLogger.weatherUpdate("WeatherKit: \(currentData.condition.description)")

    return WeatherResponse(
      current: currentData,
      hourly: hourly,
      timezoneOffset: TimeZone.current.secondsFromGMT(),
      source: .weatherKit
    )
  }

  private static func localTimeString() -> String {
    let formatter = DateFormatter()
    formatter.timeZone = .current
    formatter.dateFormat = "h:mm a"
    return formatter.string(from: Date())
  }

  private static func mapCondition(_ condition: WeatherKit.WeatherCondition) -> WeatherCondition {
    switch condition {
    case .clear, .hot: .clearSky
    case .mostlyClear: .mainlyClear
    case .partlyCloudy: .partlyCloudy
    case .mostlyCloudy, .cloudy: .overcast
    case .foggy: .fog
    case .haze, .smoky: .fog
    case .drizzle: .drizzleLight
    case .rain: .rainModerate
    case .heavyRain: .rainHeavy
    case .freezingDrizzle: .freezingDrizzleLight
    case .freezingRain: .freezingRainLight
    case .snow, .flurries: .snowFallModerate
    case .heavySnow, .blizzard: .snowFallHeavy
    case .sleet: .freezingRainLight
    case .hail: .thunderstormWithHailSlight
    case .sunShowers: .rainShowersSlight
    case .thunderstorms, .strongStorms, .tropicalStorm, .hurricane: .thunderstorm
    case .isolatedThunderstorms, .scatteredThunderstorms: .thunderstorm
    case .blowingSnow: .snowFallHeavy
    case .frigid: .clearSky
    case .windy, .breezy: .mainlyClear
    case .wintryMix: .freezingRainLight
    case .blowingDust: .fog
    @unknown default: .clearSky
    }
  }
}

// MARK: - Attribution

/// Apple requires the Apple Weather mark and a link to the legal attribution page
/// on any screen showing WeatherKit data. Failing to show it is grounds for
/// App Store rejection.
nonisolated enum WeatherKitAttribution {
  /// Fetches the localised logo + legal page URL Apple hosts for the current locale.
  static func load() async -> (lightLogo: URL, darkLogo: URL, legalPage: URL)? {
    do {
      let attribution = try await WeatherKit.WeatherService.shared.attribution
      return (attribution.combinedMarkLightURL, attribution.combinedMarkDarkURL, attribution.legalPageURL)
    } catch {
      AppLogger.weatherError(error)
      return nil
    }
  }
}
