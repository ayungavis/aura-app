//
//  CurrentWeatherViewModel.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 23/04/26.
//

import Combine
import CoreLocation
import SwiftUI

@MainActor
class CurrentWeatherViewModel: ObservableObject {
  @Published var currentWeather: CurrentWeatherData?
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
    self.weatherService = weatherService ?? (
      OpenMeteoWeatherService.shared as WeatherServiceProtocol
    )
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
      currentWeather = weather.current
      hourlyForecast = weather.hourly.map { hour in
        Forecast(
          time: hour.date.formatted(.dateTime.hour()),
          systemImage: hour.condition.systemImageName(isDay: weather.current.isDay),
          temperature: "\(Int(hour.temperature.rounded()))°",
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
