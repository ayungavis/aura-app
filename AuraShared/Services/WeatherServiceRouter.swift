//
//  WeatherServiceRouter.swift
//  AuraApp
//
//  Composes the available weather backends behind a single `WeatherServiceProtocol`.
//
//  Order of resolution:
//    1. Shared on-disk cache (also read by the widget) — 15 minute TTL.
//    2. Apple WeatherKit.
//    3. Open-Meteo, if WeatherKit is unavailable or fails.
//
//  Caching lives here rather than in the individual services so both backends
//  share one key and one TTL, and so a cache hit costs no network round trip
//  regardless of which backend produced the entry.
//

import CoreLocation
import Foundation

actor WeatherServiceRouter: WeatherServiceProtocol {
  static let shared = WeatherServiceRouter()

  /// How long a stored forecast stays authoritative.
  static let cacheTTL: TimeInterval = 15 * 60

  private let primary: WeatherServiceProtocol
  private let fallback: WeatherServiceProtocol
  private let cache = LocalCache.shared

  /// Set once WeatherKit has failed in a way that will not fix itself this
  /// launch (missing entitlement, unprovisioned App ID). Avoids paying a failing
  /// round trip on every refresh.
  private var primaryDisabled = false

  /// Coalesces concurrent requests for the same coordinates — the app and a
  /// widget refresh can otherwise fire two identical fetches at once.
  private var inFlight: [String: Task<WeatherResponse, Error>] = [:]

  init(
    primary: WeatherServiceProtocol = WeatherKitService.shared,
    fallback: WeatherServiceProtocol = OpenMeteoWeatherService.shared
  ) {
    self.primary = primary
    self.fallback = fallback
  }

  /// Cache key rounded to ~1km so tiny GPS drift still hits the same entry.
  nonisolated static func cacheKey(for location: CLLocation) -> String {
    let lat = String(format: "%.2f", location.coordinate.latitude)
    let lon = String(format: "%.2f", location.coordinate.longitude)
    return "weather_\(lat)_\(lon)"
  }

  func fetchWeatherData(for location: CLLocation) async throws -> WeatherResponse {
    let key = Self.cacheKey(for: location)

    if let cached = cache.load(key: key, as: WeatherResponse.self, expiration: Self.cacheTTL) {
      return cached
    }

    if let existing = inFlight[key] {
      return try await existing.value
    }

    let task = Task { try await self.performFetch(for: location, key: key) }
    inFlight[key] = task

    defer { inFlight[key] = nil }
    return try await task.value
  }

  // MARK: - Private

  private func performFetch(for location: CLLocation, key: String) async throws -> WeatherResponse {
    let response = try await fetchFromBackend(location)
    cache.save(response, key: key)
    return response
  }

  private func fetchFromBackend(_ location: CLLocation) async throws -> WeatherResponse {
    if !primaryDisabled {
      do {
        return try await primary.fetchWeatherData(for: location)
      } catch {
        AppLogger.weatherError(error)

        // A permanent misconfiguration should stop us retrying WeatherKit on
        // every refresh; a transient network blip should not.
        if Self.isPermanentFailure(error) {
          primaryDisabled = true
          AppLogger.weatherUpdate("WeatherKit unavailable — using Open-Meteo for the rest of this session")
        }
      }
    }

    return try await fallback.fetchWeatherData(for: location)
  }

  /// WeatherKit surfaces provisioning problems as auth/permission errors rather
  /// than a typed case, so treat anything that is not plain connectivity as
  /// permanent.
  private static func isPermanentFailure(_ error: Error) -> Bool {
    (error as NSError).domain != NSURLErrorDomain
  }
}
