//
//  WeatherService.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 23/04/26.
//

import Combine
import CoreLocation
import WeatherKit

@MainActor
class WeatherService: ObservableObject {
  static let shared = WeatherService()

  @Published var currentWeather: CurrentWeather?
  @Published var hourlyForecast: [HourWeather] = []
  @Published var isLoading: Bool = false
  @Published var error: Error? = nil

  private let service = WeatherKit.WeatherService.shared

  func fetchWeather(for location: CLLocation) async {
    isLoading = true
    error = nil
    defer { isLoading = false }

    do {
      let weather = try await service.weather(for: location)
      currentWeather = weather.currentWeather
      hourlyForecast = Array(weather.hourlyForecast.forecast.prefix(24))
    } catch {
      self.error = error
    }
  }
}
