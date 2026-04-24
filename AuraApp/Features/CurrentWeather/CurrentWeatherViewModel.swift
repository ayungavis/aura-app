//
//  CurrentWeatherViewModel.swift
//  AuraApp
//

import Combine
import CoreLocation
import SwiftUI
import WeatherKit

@MainActor
class CurrentWeatherViewModel: ObservableObject {
  @Published var currentWeather: CurrentWeather?
  @Published var hourlyForecast: [Forecast] = []
  @Published var isLoading = false
  @Published var error: Error?
  @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
  @Published var locationName: String?

  private let weatherService: WeatherServiceProtocol
  private let locationManager: LocationManagerProtocol

  init(
    weatherService: WeatherServiceProtocol? = nil,
    locationManager: LocationManagerProtocol? = nil
  ) {
    self.weatherService = weatherService ?? (WeatherService.shared as! WeatherServiceProtocol)
    self.locationManager = locationManager ?? LocationManager()
    setupCallbacks()
  }

  func onAppear() {
    locationManager.requestLocation()
  }

  func retry() {
    error = nil
    locationManager.requestLocation()
  }

  private func setupCallbacks() {
    locationManager.onLocationUpdate = { [weak self] location in
      Task { @MainActor in
        await self?.fetchWeather(for: location)
      }
    }
    locationManager.onAuthChange = { [weak self] status in
      self?.authorizationStatus = status
    }
  }

  private func fetchWeather(for location: CLLocation) async {
    isLoading = true
    error = nil
    defer { isLoading = false }

    do {
      let weather = try await weatherService.fetchWeatherData(for: location)
      currentWeather = weather.currentWeather
      hourlyForecast = weather.hourlyForecast.forecast.prefix(24).map { hour in
        Forecast(
          time: hour.date.formatted(.dateTime.hour()),
          systemImage: "",
          temperature: hour.temperature.formatted(
            .measurement(numberFormatStyle: .number.precision(.fractionLength(0)))
          ),
          caption: nil
        )
      }
      reverseGeocode(location)
    } catch {
      self.error = error
      AppLogger.weatherError(error)
    }
  }

  private func reverseGeocode(_ location: CLLocation) {
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
      Task { @MainActor in
        self?.locationName = placemarks?.first?.locality
          ?? placemarks?.first?.administrativeArea
          ?? "Unknown"
      }
    }
  }
}
