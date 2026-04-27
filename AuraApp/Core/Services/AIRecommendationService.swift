//
//  AIRecommendationService.swift
//  AuraApp
//
//  Uses Apple's on-device Foundation Models framework (iOS 26+) to generate
//  personalized activity and food recommendations based on current weather.
//
//  How it works:
//  1. Creates a LanguageModelSession with weather-aware instructions
//  2. Sends a prompt describing the current conditions
//  3. The model generates structured output matching @Generable types
//  4. Converts @Generable output into Activity/Food display models
//  5. Falls back to rule-based recommendations if anything goes wrong
//
//  Privacy: All inference happens on-device. No data leaves the device.
//
//  Created by Wahyu Kurniawan on 26/04/26.
//

import Foundation
import UIKit
import FoundationModels
import ImagePlayground

class AIRecommendationService: RecommendationServiceProtocol {
  // MARK: - Fetch Activities

  // Asks the on-device model to suggest activities that match the weather.

  func fetchActivities(weather: CurrentWeatherData) async throws -> [Activity] {
    let weatherDescription = buildWeatherDescription(weather)

    let session = LanguageModelSession(instructions: """
    You are a weather-aware activity advisor. Given the current weather conditions, \
    suggest exactly 5 activities that would be appropriate. \
    Keep names and subtitles short — 1-3 words each. \
    For each item, provide a detailed 'imagePrompt' that describes a realistic, \
    high-fidelity photo of the activity. Do not include any people or human figures. \
    Focus on equipment, environment, and atmosphere. Do not use words like 'cartoon' or 'drawing'.
    """)

    do {
      let response = try await session.respond(
        to: "Current weather: \(weatherDescription). Suggest 5 activities with image prompts.",
        generating: ActivitiesResponse.self
      )

      let items: [AIActivityItem] = response.content.items

      // Return recommendations immediately without waiting for image generation
      return items.map { item in
        Activity(
          title: item.title,
          subtitle: item.subtitle,
          imageName: item.systemImageName,
          imagePrompt: item.imagePrompt
        )
      }
    } catch {
      AppLogger.placesError("activities_ai", error: error)
      return try await FallbackRecommendationService().fetchActivities(weather: weather)
    }
  }

  // MARK: - Fetch Foods

  // Asks the on-device model to suggest foods/drinks that match the weather.

  func fetchFoods(weather: CurrentWeatherData) async throws -> [Food] {
    let weatherDescription = buildWeatherDescription(weather)

    let session = LanguageModelSession(instructions: """
    You are a food and drink advisor. Given the current weather conditions, \
    suggest exactly 5 food or drink categories that would be appealing. \
    Consider comfort, temperature, and cultural appropriateness. \
    Keep names short — 1-3 words max. \
    For each item, provide a detailed 'imagePrompt' that describes a realistic, \
    high-fidelity photo of the food or drink. Do not use words like 'cartoon' or 'drawing'.
    """)

    do {
      let response = try await session.respond(
        to: "Current weather: \(weatherDescription). Suggest 5 food items with image prompts.",
        generating: FoodsResponse.self
      )

      let items: [AIFoodItem] = response.content.items

      // Return recommendations immediately without waiting for image generation
      return items.map { item in
        Food(
          title: item.title,
          subtitle: item.subtitle,
          imageName: item.systemImageName,
          imagePrompt: item.imagePrompt
        )
      }
    } catch {
      AppLogger.placesError("foods_ai", error: error)
      return try await FallbackRecommendationService().fetchFoods(weather: weather)
    }
  }

  // MARK: - Weather Description Builder

  // Converts structured weather data into a natural language string
  // that the language model can understand and reason about.

  private func buildWeatherDescription(_ weather: CurrentWeatherData) -> String {
    var parts: [String] = []

    parts.append("Temperature: \(Int(weather.temperature.rounded()))°C")
    parts.append("Condition: \(weather.condition.description)")

    if let humidity = weather.humidity {
      parts.append("Humidity: \(humidity)%")
    }
    if let windSpeed = weather.windSpeed {
      parts.append("Wind: \(Int(windSpeed.rounded())) km/h")
    }

    parts.append(weather.isDay ? "Time: Daytime" : "Time: Nighttime")

    return parts.joined(separator: ". ")
  }
}

// MARK: - @Generable Types (Internal)

// These are only used by this service to get structured output from the AI.
// The AI generates these, then we convert them to Activity/Food for display.
//
// @Generable tells Apple's on-device model it can create instances of this struct.
// @Guide provides hints so the model generates useful values.
// .anyOf() constrains the model to only pick from valid SF Symbol names.

@Generable
struct AIActivityItem {
  @Guide(description: "A short activity name, 1-3 words")
  var title: String

  @Guide(description: "A short subtitle with duration or context, under 30 characters")
  var subtitle: String

  @Guide(.anyOf(ACTIVITY_SF_SYMBOLS))
  var systemImageName: String

  @Guide(description: "A detailed prompt for generating a realistic, high-fidelity photo of this activity. Focus on equipment and environment, avoiding people and human figures.")
  var imagePrompt: String
}

@Generable
struct AIFoodItem {
  @Guide(description: "A short food or drink category name, 1-3 words")
  var title: String

  @Guide(description: "A short subtitle with reason or context, under 30 characters")
  var subtitle: String

  @Guide(.anyOf(FOOD_SF_SYMBOLS))
  var systemImageName: String

  @Guide(description: "A detailed prompt for generating a realistic, appetizing, high-fidelity photo of this food or drink. Describe textures, lighting, and presentation.")
  var imagePrompt: String
}

// Response wrappers — the model generates all 5 items in one request.
// @Guide(.count(5)) ensures exactly 5 items.

@Generable
struct ActivitiesResponse {
  @Guide(description: "A list of 5 activity recommendations based on weather")
  @Guide(.count(5))
  var items: [AIActivityItem]
}

@Generable
struct FoodsResponse {
  @Guide(description: "A list of 5 food or drink recommendations based on weather")
  @Guide(.count(5))
  var items: [AIFoodItem]
}

// MARK: - SF Symbol Catalogs

// Predefined lists of SF Symbol names that the AI can pick from.
// These are used by @Guide(.anyOf()) to constrain the model's output
// to only valid SF Symbol names that exist on iOS.

let ACTIVITY_SF_SYMBOLS: [String] = [
  "figure.run", "figure.outdoor.cycle", "figure.soccer",
  "figure.hiking", "figure.yoga", "figure.open.water.swim",
  "figure.surfing", "figure.climbing", "figure.walk",
  "dumbbell.fill", "figure.skiing.downhill",
  "figure.strengthtraining.traditional",
  "sun.max", "cloud.sun", "wind", "cloud.rain",
  "tent", "water.waves"
]

let FOOD_SF_SYMBOLS: [String] = [
  "cup.and.saucer", "fork.knife", "takeoutbag.and.cup.and.straw",
  "carrot", "fish", "birthday.cake", "snowflake",
  "mug", "popcorn",
  "leaf", "flame",
  "cup.and.saucer.fill"
]
