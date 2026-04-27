//
//  RecommendationServiceProtocol.swift
//  AuraApp
//
//  Protocol that defines how recommendation services behave.
//  Both AI-powered and fallback implementations conform to this protocol.
//  This is "dependency inversion" — the ViewModel doesn't know which
//  implementation it's using, making the code testable and flexible.
//
//  Created by Wahyu Kurniawan on 26/04/26.
//

import Foundation

protocol RecommendationServiceProtocol {
  /// Returns activity recommendations based on the current weather conditions.
  /// - Parameter weather: The current weather data to base recommendations on.
  /// - Returns: Array of Activity models with title, subtitle, and image name.
  func fetchActivities(weather: CurrentWeatherData) async throws -> [Activity]

  /// Returns food/drink recommendations based on the current weather conditions.
  /// - Parameter weather: The current weather data to base recommendations on.
  /// - Returns: Array of Food models with title, subtitle, and image name.
  func fetchFoods(weather: CurrentWeatherData) async throws -> [Food]
}
