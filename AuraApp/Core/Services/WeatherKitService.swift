//
//  WeatherKitService.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 23/04/26.
//

import CoreLocation
import WeatherKit

@MainActor
class WeatherKitService: WeatherServiceProtocol {
  static let shared = WeatherKitService()

  private let service = WeatherKit.WeatherService.shared

  func fetchWeatherData(for location: CLLocation) async throws -> WeatherResponse {
    let weather = try await service.weather(for: location)
    AppLogger.weatherUpdate(weather.currentWeather.condition.description)

    let current = CurrentWeatherData(
      temperature: weather.currentWeather.temperature.value,
      apparentTemperature: weather.currentWeather.apparentTemperature.value,
      humidity: Int(weather.currentWeather.humidity * 100),
      windSpeed: weather.currentWeather.wind.speed.value,
      windDirection: weather.currentWeather.wind.direction.value,
      condition: Self.mapCondition(weather.currentWeather.condition),
      isDay: weather.currentWeather.isDaylight,
      localTime: {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
      }()
    )

    let hourly: [HourlyWeatherData] = weather.hourlyForecast.forecast.prefix(24).map { hour in
      HourlyWeatherData(
        date: hour.date,
        temperature: hour.temperature.value,
        condition: Self.mapCondition(hour.condition),
        humidity: Int(hour.humidity * 100),
        windSpeed: hour.wind.speed.value,
        precipitationProbability: Int(hour.precipitationChance * 100)
      )
    }

    return WeatherResponse(current: current, hourly: hourly, timezoneOffset: TimeZone.current.secondsFromGMT())
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
