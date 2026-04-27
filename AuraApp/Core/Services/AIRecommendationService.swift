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

import FoundationModels

class AIRecommendationService: RecommendationServiceProtocol {
  // MARK: - Fetch Activities

  // Asks the on-device model to suggest activities that match the weather.

  func fetchActivities(weather: CurrentWeatherData) async throws -> [Activity] {
    let weatherDescription = buildWeatherDescription(weather)

    // Create a session with instructions that set the model's "personality"
    let session = LanguageModelSession(instructions: """
    You are an outdoor activity advisor. Given the current weather conditions, \
    suggest exactly 5 activities that would be enjoyable and safe. \
    Consider temperature, precipitation, and overall conditions. \
    Be creative but practical — suggest things people would actually want to do.
    """)

    do {
      // Ask the model to generate 5 structured recommendations
      let response = try await session.respond(
        to: "Current weather: \(weatherDescription). Suggest 5 activities.",
        generating: ActivitiesResponse.self
      )

      // Convert @Generable output into Activity display models
      return response.content.items.map { item in
        Activity(title: item.title, subtitle: item.subtitle, imageName: item.systemImageName)
      }
    } catch {
      // If AI fails for any reason, fall back to rule-based recommendations
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
    Keep names short — 1-3 words max.
    """)

    do {
      let response = try await session.respond(
        to: "Current weather: \(weatherDescription). Suggest 5 food or drink categories.",
        generating: FoodsResponse.self
      )

      return response.content.items.map { item in
        Food(title: item.title, subtitle: item.subtitle, imageName: item.systemImageName)
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
}

@Generable
struct AIFoodItem {
  @Guide(description: "A short food or drink category name, 1-3 words")
  var title: String

  @Guide(description: "A short subtitle with reason or context, under 30 characters")
  var subtitle: String

  @Guide(.anyOf(FOOD_SF_SYMBOLS))
  var systemImageName: String
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
  "figure.run", "figure.biking", "figure.soccer",
  "figure.hiking", "figure.yoga", "figure.swimming",
  "figure.surfing", "figure.climbing", "figure.walk",
  "figure.gym", "figure.pool", "figure.skiing",
  "figure.cycling", "figure.strengthtraining",
  "sun.max", "cloud.sun", "wind", "cloud.rain",
  "tent", "water.waves"
]

let FOOD_SF_SYMBOLS: [String] = [
  "cup.and.saucer", "fork.knife", "takeoutbag.and.cup.and.straw",
  "carrot", "fish", "cake", "icecream",
  "mug", "popcorn", "pizza",
  "apple", "leaf", "flame",
  "bowl.rice", "cup.saucer", "birthday.cake"
]
