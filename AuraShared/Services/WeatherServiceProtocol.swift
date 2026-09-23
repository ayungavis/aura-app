//
//  WeatherServiceProtocol.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 23/04/26.
//

import CoreLocation

/// `nonisolated` so implementations can do their network and decoding work off
/// the main actor — the project otherwise defaults them onto it.
nonisolated protocol WeatherServiceProtocol: AnyObject, Sendable {
  func fetchWeatherData(for location: CLLocation) async throws -> WeatherResponse
}
