//
//  CurrentWeatherViewModel.swift
//  AuraApp
//
//  ViewModel for the main weather screen. Follows the MVVM pattern:
//  - Fetches weather data from the service layer
//  - Publishes state updates that the View observes
//  - Generates activity and food recommendations based on weather
//
//  All @Published properties automatically trigger UI updates when they change.
//  @MainActor ensures everything runs on the main thread (UI thread).
//

import Combine
import CoreLocation
import SwiftUI

@MainActor
class CurrentWeatherViewModel: ObservableObject {

  // MARK: - Published State
  // These properties drive the UI. When any of them change, SwiftUI re-renders
  // the views that read them.

  @Published var currentWeather: CurrentWeatherData?
  @Published var hourlyForecast: [Forecast] = []
  @Published var activities: [Activity] = []
  @Published var foods: [Food] = []
  @Published var isLoading = false
  @Published var error: Error?
  @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
  @Published var locationName: String?

  // MARK: - Dependencies
  // Services are injected via protocols for testability.
  // Default values use the real implementations.

  private let weatherService: WeatherServiceProtocol
  private let locationManager: LocationManagerProtocol
  private let recommendationService: RecommendationServiceProtocol

  init(
    weatherService: WeatherServiceProtocol? = nil,
    locationManager: LocationManagerProtocol? = nil,
    recommendationService: RecommendationServiceProtocol? = nil
  ) {
    self.weatherService = weatherService ?? (
      OpenMeteoWeatherService.shared as WeatherServiceProtocol
    )
    self.locationManager = locationManager ?? LocationManager()
    // Factory picks AI or fallback based on device capabilities
    self.recommendationService = recommendationService ?? RecommendationServiceFactory.create()
    setupCallbacks()
  }

  // MARK: - Public Methods
  // These are the only methods the View calls directly.

  func onAppear() {
    locationManager.requestLocation()
  }

  func retry() {
    error = nil
    locationManager.requestLocation()
  }

  // MARK: - Private: Location Callbacks

  private func setupCallbacks() {
    // When location updates, fetch weather for that location
    locationManager.onLocationUpdate = { [weak self] location in
      Task { @MainActor in
        await self?.fetchWeather(for: location)
      }
    }
    // Track authorization status so the UI can show permission prompts
    locationManager.onAuthChange = { [weak self] status in
      self?.authorizationStatus = status
    }
  }

  // MARK: - Private: Weather Fetching

  private func fetchWeather(for location: CLLocation) async {
    isLoading = true
    error = nil
    defer { isLoading = false }

    do {
      // Step 1: Fetch weather data from Open Meteo API
      let weather = try await weatherService.fetchWeatherData(for: location)

      // Step 2: Update current weather state
      currentWeather = weather.current

      // Step 3: Build hourly forecast — filter out past hours, map to display models
      hourlyForecast = weather.hourly.filter { $0.date > Date() }.map { hour in
        Forecast(
          time: hour.date.formatted(.dateTime.hour()),
          systemImage: hour.condition.systemImageName(isDay: weather.current.isDay),
          temperature: "\(Int(hour.temperature.rounded()))°",
          caption: nil
        )
      }

      // Step 4: Fetch recommendations and geocode in parallel
      async let activitiesTask = recommendationService.fetchActivities(weather: weather.current)
      async let foodsTask = recommendationService.fetchFoods(weather: weather.current)

      // Wait for both recommendation calls and geocode concurrently
      activities = (try? await activitiesTask) ?? []
      foods = (try? await foodsTask) ?? []

      // Step 5: Reverse geocode for location name
      await reverseGeocode(location)

    } catch {
      self.error = error
      AppLogger.weatherError(error)
    }
  }

  // MARK: - Private: Reverse Geocoding
  // Converts GPS coordinates into a human-readable location name.

  private func reverseGeocode(_ location: CLLocation) async {
    let geocoder = CLGeocoder()
    if let placemarks = try? await geocoder.reverseGeocodeLocation(location) {
      locationName = placemarks.first?.locality
        ?? placemarks.first?.administrativeArea
        ?? "Unknown"
    }
  }
}
