//
//  CurrentWeatherViewModel.swift
//  AuraApp
//
//  ViewModel for the main weather screen.
//
//  Uses `@Observable` rather than `ObservableObject`: SwiftUI then tracks reads
//  per-property, so updating one generated image invalidates only the views that
//  read that image instead of re-rendering the whole screen. That matters here
//  because image generation writes to `activities`/`foods` a dozen times while
//  the user is scrolling.
//

import CoreLocation
import Observation
import SwiftUI
import WidgetKit

@MainActor
@Observable
final class CurrentWeatherViewModel {

  // MARK: - Observed State

  var currentWeather: CurrentWeatherData?
  var hourlyForecast: [Forecast] = []
  var activities: [Activity] = []
  var foods: [Food] = []
  var isLoading = false
  var error: Error?
  var authorizationStatus: CLAuthorizationStatus = .notDetermined
  var locationName: String?

  /// Which backend served the data on screen — drives which attribution shows.
  var weatherSource: WeatherSource?

  /// True once a real fetch has completed, so the UI can tell "still loading"
  /// apart from "loaded, but empty".
  var hasLoadedOnce = false

  /// Location is off for Aura, so no weather can load until the user changes it
  /// in Settings. Granting it there re-triggers a fetch via `onAuthChange`.
  var isLocationDenied: Bool {
    authorizationStatus == .denied || authorizationStatus == .restricted
  }

  /// Where nearby-place searches are centred.
  var searchCenter: SearchCenter? {
    guard let location = lastFetchLocation else { return nil }
    return SearchCenter(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
  }

  // MARK: - Untracked State
  // Marked ignored so mutating them never invalidates a view.

  @ObservationIgnored private var lastFetchLocation: CLLocation?
  @ObservationIgnored private var imageGenerationTask: Task<Void, Never>?
  @ObservationIgnored private var geocodeCache: [String: GeocodedPlace] = [:]
  /// e.g. "Kuta, Bali, Indonesia" — tells the recommendation prompts where the user is.
  @ObservationIgnored private var placeDescription: String?

  // MARK: - Dependencies

  @ObservationIgnored private let weatherService: WeatherServiceProtocol
  @ObservationIgnored private let locationManager: LocationManagerProtocol
  @ObservationIgnored private let recommendationService: RecommendationServiceProtocol

  init(
    weatherService: WeatherServiceProtocol? = nil,
    locationManager: LocationManagerProtocol? = nil,
    recommendationService: RecommendationServiceProtocol? = nil
  ) {
    // Router = shared cache → WeatherKit → Open-Meteo fallback.
    self.weatherService = weatherService ?? WeatherServiceRouter.shared
    self.locationManager = locationManager ?? LocationManager()
    self.recommendationService = recommendationService ?? RecommendationServiceFactory.create()
    setupCallbacks()
  }

  deinit {
    imageGenerationTask?.cancel()
  }

  // MARK: - Public

  func onAppear() {
    locationManager.requestLocation()
  }

  func retry() {
    error = nil
    // Clear the throttle so an explicit retry always refetches.
    lastFetchLocation = nil
    locationManager.requestLocation()
  }

  // MARK: - Location Callbacks

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

  // MARK: - Weather Fetching

  private func fetchWeather(for location: CLLocation) async {
    // CoreLocation re-delivers near-identical fixes; skip sub-500m churn.
    if let lastLocation = lastFetchLocation, location.distance(from: lastLocation) < 500 {
      return
    }

    isLoading = true
    error = nil
    lastFetchLocation = location
    defer {
      isLoading = false
      hasLoadedOnce = true
    }

    do {
      // The place name is needed by the recommendation prompts; look it up
      // while the weather loads.
      async let geocoding: Void = reverseGeocode(location)
      let weather = try await weatherService.fetchWeatherData(for: location)
      await geocoding

      currentWeather = weather.current
      weatherSource = weather.source
      hourlyForecast = Self.buildForecast(from: weather)

      // Text recommendations run concurrently — neither depends on the other.
      async let activitiesTask = recommendationService.fetchActivities(weather: weather.current, place: placeDescription)
      async let foodsTask = recommendationService.fetchFoods(weather: weather.current, place: placeDescription)
      activities = (try? await activitiesTask) ?? []
      foods = (try? await foodsTask) ?? []

      // Hand the widget the freshest snapshot we have.
      WidgetDataStore.save(
        weather: weather,
        locationName: locationName,
        coordinate: location.coordinate
      )
      WidgetCenter.shared.reloadTimelines(ofKind: WidgetDataStore.widgetKind)

      // Images fill in progressively behind the SF Symbol placeholders.
      generateImagesInBackground()

    } catch {
      self.error = error
      AppLogger.weatherError(error)
    }
  }

  /// Builds the hourly strip, labelling the current hour "Now".
  private static func buildForecast(from weather: WeatherResponse) -> [Forecast] {
    let timezone = TimeZone(secondsFromGMT: weather.timezoneOffset) ?? .current
    var calendar = Calendar.current
    calendar.timeZone = timezone

    guard let startOfHour = calendar.date(
      from: calendar.dateComponents([.year, .month, .day, .hour], from: Date())
    ) else { return [] }

    var hourStyle = Date.FormatStyle.dateTime.hour()
    hourStyle.timeZone = timezone

    return weather.hourly
      .filter { $0.date >= startOfHour }
      .enumerated()
      .map { index, hour in
        Forecast(
          time: index == 0 ? "Now" : hour.date.formatted(hourStyle),
          systemImage: hour.condition.systemImageName(isDay: hour.isDay ?? weather.current.isDay),
          temperature: "\(Int(hour.temperature.rounded()))°",
          caption: nil,
          precipitationPercentage: hour.precipitationProbability
        )
      }
  }

  // MARK: - Background Image Generation

  /// Generates images for every recommendation that asked for one. Each runs
  /// independently — one failure does not block the rest — and the UI updates as
  /// each completes.
  private func generateImagesInBackground() {
    imageGenerationTask?.cancel()

    // iOS 27 deprecated `ImageCreator`; generation now only happens through the
    // user-driven Image Playground sheet, so the cards offer a Generate button.
    guard Self.supportsBackgroundImageGeneration else { return }

    imageGenerationTask = Task(priority: .utility) { [weak self] in
      guard let self else { return }

      for index in await self.activities.indices {
        if Task.isCancelled { return }
        await self.generateActivityImage(at: index)
      }

      for index in await self.foods.indices {
        if Task.isCancelled { return }
        await self.generateFoodImage(at: index)
      }
    }
  }

  /// `ImageCreator` (programmatic generation) is deprecated from iOS 27 and
  /// fails at runtime there.
  static var supportsBackgroundImageGeneration: Bool {
    if #available(iOS 27, *) { false } else { true }
  }

  /// Stores an image the user created via the Image Playground sheet.
  func setGeneratedImage(for id: UUID, image: UIImage) {
    if let index = activities.firstIndex(where: { $0.id == id }) {
      activities[index].generatedImage = image
      activities[index].isGenerationFailed = false
    } else if let index = foods.firstIndex(where: { $0.id == id }) {
      foods[index].generatedImage = image
      foods[index].isGenerationFailed = false
    }
  }

  private func generateActivityImage(at index: Int) async {
    guard index < activities.count,
          let prompt = activities[index].imagePrompt,
          activities[index].generatedImage == nil
    else { return }

    let image = await ImagePlaygroundManager.generateImage(prompt: prompt)
    guard !Task.isCancelled, index < activities.count else { return }

    if let image {
      activities[index].generatedImage = image
    } else {
      activities[index].isGenerationFailed = true
    }
  }

  private func generateFoodImage(at index: Int) async {
    guard index < foods.count,
          let prompt = foods[index].imagePrompt,
          foods[index].generatedImage == nil
    else { return }

    let image = await ImagePlaygroundManager.generateImage(prompt: prompt)
    guard !Task.isCancelled, index < foods.count else { return }

    if let image {
      foods[index].generatedImage = image
    } else {
      foods[index].isGenerationFailed = true
    }
  }

  // MARK: - Reverse Geocoding

  /// CLGeocoder is server-backed and aggressively rate limited, so results are
  /// memoised per ~1km cell for the lifetime of the ViewModel.
  private func reverseGeocode(_ location: CLLocation) async {
    let key = String(
      format: "%.2f,%.2f",
      location.coordinate.latitude,
      location.coordinate.longitude
    )

    if let cached = geocodeCache[key] {
      apply(cached)
      return
    }

    guard let placemark = try? await CLGeocoder().reverseGeocodeLocation(location).first else {
      placeDescription = nil
      return
    }

    // Deduplicated, since locality and area are often the same ("Singapore").
    var parts: [String] = []
    for part in [placemark.locality, placemark.administrativeArea, placemark.country] {
      if let part, !parts.contains(part) { parts.append(part) }
    }

    let place = GeocodedPlace(
      name: placemark.locality ?? placemark.administrativeArea ?? "Unknown",
      description: parts.isEmpty ? nil : parts.joined(separator: ", ")
    )
    geocodeCache[key] = place
    apply(place)
  }

  private func apply(_ place: GeocodedPlace) {
    locationName = place.name
    placeDescription = place.description
  }
}

private struct GeocodedPlace {
  let name: String
  let description: String?
}
