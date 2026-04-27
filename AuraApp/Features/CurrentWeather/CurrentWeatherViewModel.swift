//
//  CurrentWeatherViewModel.swift
//  AuraApp
//
//  ViewModel for the main weather screen. Follows the MVVM pattern:
//  - Fetches weather data from the service layer
//  - Publishes state updates that the View observes
//  - Generates activity and food recommendations based on weather
//  - Asynchronously generates images via Image Playground after recommendations load
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

  var latLongString: String? {
    guard let location = lastFetchLocation else { return nil }
    return "\(location.coordinate.latitude),\(location.coordinate.longitude)"
  }
  
  private var lastFetchLocation: CLLocation?
  private var imageGenerationTask: Task<Void, Never>?

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
    // Avoid redundant fetches if location hasn't changed significantly (e.g., 500 meters)
    if let lastLocation = lastFetchLocation, location.distance(from: lastLocation) < 500 {
      print("📍 [ViewModel] Skipping weather fetch, location hasn't changed significantly")
      return
    }
    
    isLoading = true
    error = nil
    lastFetchLocation = location
    defer { isLoading = false }

    do {
      // Step 1: Fetch weather data from Open Meteo API
      let weather = try await weatherService.fetchWeatherData(for: location)

      // Step 2: Update current weather state
      currentWeather = weather.current

      // Step 3: Build hourly forecast — include current hour, label it "Now"
      let now = Date()
      let timezone = TimeZone(secondsFromGMT: weather.timezoneOffset) ?? .current
      var calendar = Calendar.current
      calendar.timeZone = timezone
      let startOfHour = calendar.date(from: calendar.dateComponents([.year, .month, .day, .hour], from: now))!
      
      var hourStyle = Date.FormatStyle.dateTime.hour()
      hourStyle.timeZone = timezone
      
      hourlyForecast = weather.hourly.filter { $0.date >= startOfHour }.enumerated().map { index, hour in
        Forecast(
          time: index == 0 ? "Now" : hour.date.formatted(hourStyle),
          systemImage: hour.condition.systemImageName(isDay: weather.current.isDay),
          temperature: "\(Int(hour.temperature.rounded()))°",
          caption: nil
        )
      }

      // Step 4: Fetch text recommendations in parallel (fast, no image generation)
      async let activitiesTask = recommendationService.fetchActivities(weather: weather.current)
      async let foodsTask = recommendationService.fetchFoods(weather: weather.current)

      // Wait for both recommendation calls concurrently
      activities = (try? await activitiesTask) ?? []
      foods = (try? await foodsTask) ?? []

      // Step 5: Reverse geocode for location name
      await reverseGeocode(location)

      // Step 6: Generate images asynchronously in the background
      // Recommendations are already visible with SF Symbol placeholders.
      // Images will appear as they're generated, updating the UI progressively.
      generateImagesInBackground()

    } catch {
      self.error = error
      AppLogger.weatherError(error)
    }
  }

  // MARK: - Private: Background Image Generation

  /// Generates images for all activities and foods that have an imagePrompt.
  /// Each image is generated independently — if one fails, others still succeed.
  /// The UI updates progressively as each image completes.
  private func generateImagesInBackground() {
    // Cancel any previous generation task to avoid overlapping/looping
    imageGenerationTask?.cancel()
    
    let activitiesToGenerate = activities.filter { $0.imagePrompt != nil && $0.generatedImage == nil }
    let foodsToGenerate = foods.filter { $0.imagePrompt != nil && $0.generatedImage == nil }
    
    print("🖼️ [ImageGen] Starting background image generation: \(activitiesToGenerate.count) activities, \(foodsToGenerate.count) foods need images")

    imageGenerationTask = Task(priority: .background) {
      // Generate activity images sequentially to avoid overwhelming the system
      for index in activities.indices {
        if Task.isCancelled { return }
        
        let activity = activities[index]
        guard let prompt = activity.imagePrompt, activity.generatedImage == nil else { continue }
        
        print("🖼️ [ImageGen] Generating Activity[\(index)] '\(activity.title)' with prompt: \"\(prompt)\"")
        
        if let image = await ImagePlaygroundManager.generateImage(prompt: prompt) {
          if !Task.isCancelled {
            await MainActor.run {
              if index < self.activities.count {
                self.activities[index].generatedImage = image
                print("🖼️ [ImageGen] Activity[\(index)] '\(self.activities[index].title)' image updated!")
              }
            }
          }
        } else {
          // If generation failed after retries
          if !Task.isCancelled {
            await MainActor.run {
              if index < self.activities.count {
                self.activities[index].isGenerationFailed = true
                print("🖼️ [ImageGen] Activity[\(index)] '\(self.activities[index].title)' generation failed permanently.")
              }
            }
          }
        }
      }

      // Generate food images sequentially
      for index in foods.indices {
        if Task.isCancelled { return }
        
        let food = foods[index]
        guard let prompt = food.imagePrompt, food.generatedImage == nil else { continue }
        
        print("🖼️ [ImageGen] Generating Food[\(index)] '\(food.title)' with prompt: \"\(prompt)\"")
        
        if let image = await ImagePlaygroundManager.generateImage(prompt: prompt) {
          if !Task.isCancelled {
            await MainActor.run {
              if index < self.foods.count {
                self.foods[index].generatedImage = image
                print("🖼️ [ImageGen] Food[\(index)] '\(self.foods[index].title)' image updated!")
              }
            }
          }
        } else {
          // If generation failed after retries
          if !Task.isCancelled {
            await MainActor.run {
              if index < self.foods.count {
                self.foods[index].isGenerationFailed = true
                print("🖼️ [ImageGen] Food[\(index)] '\(self.foods[index].title)' generation failed permanently.")
              }
            }
          }
        }
      }
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
