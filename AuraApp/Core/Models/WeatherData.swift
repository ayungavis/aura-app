//
//  WeatherData.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 23/04/26.
//

import Foundation

enum WeatherCondition: Int, Codable {
  case clearSky = 0
  case mainlyClear = 1
  case partlyCloudy = 2
  case overcast = 3
  case fog = 45
  case depositingRimeFog = 48
  case drizzleLight = 51
  case drizzleModerate = 53
  case drizzleDense = 55
  case freezingDrizzleLight = 56
  case freezingDrizzleDense = 57
  case rainSlight = 61
  case rainModerate = 63
  case rainHeavy = 65
  case freezingRainLight = 66
  case freezingRainHeavy = 67
  case snowFallSlight = 71
  case snowFallModerate = 73
  case snowFallHeavy = 75
  case snowGrains = 77
  case rainShowersSlight = 80
  case rainShowersModerate = 81
  case rainShowersViolent = 82
  case snowShowersSlight = 85
  case snowShowersHeavy = 86
  case thunderstorm = 95
  case thunderstormWithHailSlight = 96
  case thunderstormWithHailHeavy = 99

  init(wmoCode: Int) {
    self = WeatherCondition(rawValue: wmoCode) ?? .clearSky
  }

  var description: String {
    switch self {
    case .clearSky: "Clear Sky"
    case .mainlyClear: "Mainly Clear"
    case .partlyCloudy: "Partly Cloudy"
    case .overcast: "Overcast"
    case .fog, .depositingRimeFog: "Foggy"
    case .drizzleLight, .drizzleModerate, .drizzleDense: "Drizzle"
    case .freezingDrizzleLight, .freezingDrizzleDense: "Freezing Drizzle"
    case .rainSlight: "Light Rain"
    case .rainModerate: "Rain"
    case .rainHeavy: "Heavy Rain"
    case .freezingRainLight, .freezingRainHeavy: "Freezing Rain"
    case .snowFallSlight: "Light Snow"
    case .snowFallModerate: "Snow"
    case .snowFallHeavy: "Heavy Snow"
    case .snowGrains: "Snow Grains"
    case .rainShowersSlight, .rainShowersModerate: "Rain Showers"
    case .rainShowersViolent: "Heavy Rain Showers"
    case .snowShowersSlight, .snowShowersHeavy: "Snow Showers"
    case .thunderstorm: "Thunderstorm"
    case .thunderstormWithHailSlight, .thunderstormWithHailHeavy: "Thunderstorm with Hail"
    }
  }

  func systemImageName(isDay: Bool = true) -> String {
    switch self {
    case .clearSky:
      isDay ? "sun.max.fill" : "moon.stars.fill"
    case .mainlyClear:
      isDay ? "sun.min.fill" : "moon.fill"
    case .partlyCloudy:
      isDay ? "cloud.sun.fill" : "cloud.moon.fill"
    case .overcast:
      "cloud.fill"
    case .fog, .depositingRimeFog:
      "cloud.fog.fill"
    case .drizzleLight, .drizzleModerate, .drizzleDense:
      "cloud.drizzle.fill"
    case .freezingDrizzleLight, .freezingDrizzleDense, .freezingRainLight, .freezingRainHeavy:
      "cloud.sleet.fill"
    case .rainSlight, .rainModerate:
      "cloud.rain.fill"
    case .rainHeavy:
      "cloud.heavyrain.fill"
    case .snowFallSlight, .snowFallModerate, .snowFallHeavy, .snowGrains:
      "cloud.snow.fill"
    case .rainShowersSlight, .rainShowersModerate:
      isDay ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill"
    case .rainShowersViolent:
      "cloud.heavyrain.fill"
    case .snowShowersSlight, .snowShowersHeavy:
      "cloud.snow.fill"
    case .thunderstorm, .thunderstormWithHailSlight, .thunderstormWithHailHeavy:
      "cloud.bolt.rain.fill"
    }
  }
}

struct CurrentWeatherData: Codable {
  let temperature: Double
  let apparentTemperature: Double?
  let humidity: Int?
  let windSpeed: Double?
  let windDirection: Double?
  let condition: WeatherCondition
  let isDay: Bool
}

struct HourlyWeatherData: Codable {
  let date: Date
  let temperature: Double
  let condition: WeatherCondition
  let humidity: Int?
  let windSpeed: Double?
}

struct WeatherResponse: Codable {
  let current: CurrentWeatherData
  let hourly: [HourlyWeatherData]
  let timezoneOffset: Int
}
