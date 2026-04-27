//
//  FallbackRecommendationService.swift
//  AuraApp
//
//  Rule-based recommendation engine. No AI, no network — just maps
//  weather conditions to predefined activity and food suggestions.
//  Used on devices that don't support Apple Intelligence, or as a
//  fallback when the on-device model isn't available.
//

import Foundation

class FallbackRecommendationService: RecommendationServiceProtocol {

  // MARK: - Fetch Activities
  // Groups weather conditions into broad categories, then returns
  // curated recommendations for each category.

  func fetchActivities(weather: CurrentWeatherData) async throws -> [Activity] {
    let condition = weather.condition

    switch condition {
    case .clearSky, .mainlyClear:
      return sunnyActivities(temperature: weather.temperature)
    case .partlyCloudy:
      return partlyCloudyActivities()
    case .overcast:
      return overcastActivities()
    case .fog, .depositingRimeFog:
      return foggyActivities()
    case .drizzleLight, .drizzleModerate, .drizzleDense,
        .rainSlight, .rainModerate, .rainShowersSlight, .rainShowersModerate:
      return lightRainActivities()
    case .rainHeavy, .rainShowersViolent:
      return heavyRainActivities()
    case .snowFallSlight, .snowFallModerate, .snowFallHeavy,
        .snowGrains, .snowShowersSlight, .snowShowersHeavy:
      return snowActivities()
    case .thunderstorm, .thunderstormWithHailSlight, .thunderstormWithHailHeavy:
      return thunderstormActivities()
    default:
      return sunnyActivities(temperature: weather.temperature)
    }
  }

  // MARK: - Fetch Foods

  func fetchFoods(weather: CurrentWeatherData) async throws -> [Food] {
    let condition = weather.condition

    switch condition {
    case .clearSky, .mainlyClear:
      return hotWeatherFoods()
    case .partlyCloudy, .overcast:
      return mildWeatherFoods()
    case .fog, .depositingRimeFog:
      return foggyWeatherFoods()
    case .drizzleLight, .drizzleModerate, .drizzleDense,
        .rainSlight, .rainModerate, .rainShowersSlight, .rainShowersModerate,
        .rainHeavy, .rainShowersViolent:
      return rainyWeatherFoods()
    case .snowFallSlight, .snowFallModerate, .snowFallHeavy,
        .snowGrains, .snowShowersSlight, .snowShowersHeavy:
      return coldWeatherFoods()
    case .thunderstorm, .thunderstormWithHailSlight, .thunderstormWithHailHeavy:
      return rainyWeatherFoods()
    default:
      return mildWeatherFoods()
    }
  }

  // MARK: - Activity Recommendations by Weather

  private func sunnyActivities(temperature: Double) -> [Activity] {
    // temperature is in Celsius — adjust recommendations for heat
    if temperature > 30 {
      return makeActivities([
        ("Swimming", "Cool off in the water", "figure.swimming"),
        ("Indoor Gym", "Stay cool, stay fit", "figure.gym"),
        ("Surfing", "Perfect wave weather", "figure.surfing"),
        ("Cafe Hopping", "Shaded exploration", "cup.and.saucer"),
        ("Beach Walk", "Early morning stroll", "figure.walk"),
      ])
    }
    return makeActivities([
      ("Running", "Great running weather", "figure.run"),
      ("Biking", "Hit the trails", "figure.biking"),
      ("Football", "Perfect for the pitch", "figure.soccer"),
      ("Hiking", "Explore the outdoors", "figure.hiking"),
      ("Yoga", "Outdoor mindfulness", "figure.yoga"),
    ])
  }

  private func partlyCloudyActivities() -> [Activity] {
    return makeActivities([
      ("Running", "Comfortable conditions", "figure.run"),
      ("Biking", "Mild and pleasant", "figure.biking"),
      ("Hiking", "Ideal cloud cover", "figure.hiking"),
      ("Yoga", "Peaceful atmosphere", "figure.yoga"),
      ("Cafe Hopping", "Relaxed afternoon", "cup.and.saucer"),
    ])
  }

  private func overcastActivities() -> [Activity] {
    return makeActivities([
      ("Walking", "Cool and calm", "figure.walk"),
      ("Yoga", "Find your center", "figure.yoga"),
      ("Gym", "Indoor workout day", "figure.gym"),
      ("Cafe Hopping", "Cozy overcast vibes", "cup.and.saucer"),
      ("Cycling", "No sun glare", "figure.cycling"),
    ])
  }

  private func foggyActivities() -> [Activity] {
    return makeActivities([
      ("Yoga", "Misty morning zen", "figure.yoga"),
      ("Walking", "Atmospheric stroll", "figure.walk"),
      ("Gym", "Clear your mind", "figure.gym"),
      ("Cafe Hopping", "Warm up inside", "cup.and.saucer"),
      ("Indoor Climbing", "Adventure inside", "figure.climbing"),
    ])
  }

  private func lightRainActivities() -> [Activity] {
    return makeActivities([
      ("Gym", "Stay dry, stay strong", "figure.gym"),
      ("Yoga", "Rainy day calm", "figure.yoga"),
      ("Indoor Swimming", "Water on both sides", "figure.pool"),
      ("Cafe Hopping", "Watch the rain", "cup.and.saucer"),
      ("Museum Visit", "Culture indoors", "building.columns"),
    ])
  }

  private func heavyRainActivities() -> [Activity] {
    return makeActivities([
      ("Gym", "Perfect indoor day", "figure.gym"),
      ("Yoga", "Stay in, stretch out", "figure.yoga"),
      ("Indoor Swimming", "Already wet anyway", "figure.pool"),
      ("Cafe Hopping", "Hot drink weather", "cup.and.saucer"),
      ("Home Cooking", "Try a new recipe", "fork.knife"),
    ])
  }

  private func snowActivities() -> [Activity] {
    return makeActivities([
      ("Skiing", "Fresh powder day", "figure.skiing"),
      ("Snow Walk", "Winter wonderland", "figure.walk"),
      ("Gym", "Warm indoor session", "figure.gym"),
      ("Cafe Hopping", "Hot chocolate weather", "cup.and.saucer"),
      ("Indoor Yoga", "Stretch and warm up", "figure.yoga"),
    ])
  }

  private func thunderstormActivities() -> [Activity] {
    return makeActivities([
      ("Gym", "Safe indoor workout", "figure.gym"),
      ("Yoga", "Stormy zen mode", "figure.yoga"),
      ("Home Cooking", "Comfort food time", "fork.knife"),
      ("Reading", "Cozy up with a book", "book"),
      ("Movie Night", "Perfect storm excuse", "popcorn"),
    ])
  }

  // MARK: - Food Recommendations by Weather

  private func hotWeatherFoods() -> [Food] {
    return makeFoods([
      ("Ice Cream", "Cool down treat", "icecream"),
      ("Fresh Fruit", "Hydrating and sweet", "apple"),
      ("Smoothie", "Blend the heat away", "cup.and.saucer"),
      ("Salad", "Light and refreshing", "leaf"),
      ("Cold Brew", "Iced coffee energy", "mug"),
    ])
  }

  private func mildWeatherFoods() -> [Food] {
    return makeFoods([
      ("Cafe", "Perfect cafe weather", "cup.and.saucer"),
      ("Pizza", "Casual outdoor dining", "pizza"),
      ("Rice Bowl", "Warm and satisfying", "bowl.rice"),
      ("Soup", "Light and comforting", "flame"),
      ("Fruit Bowl", "Fresh and healthy", "apple"),
    ])
  }

  private func foggyWeatherFoods() -> [Food] {
    return makeFoods([
      ("Hot Coffee", "Cut through the fog", "mug"),
      ("Soup", "Warming comfort", "flame"),
      ("Rice Bowl", "Hearty and warm", "bowl.rice"),
      ("Bakery", "Fresh from the oven", "birthday.cake"),
      ("Tea", "Soothing and warm", "cup.saucer"),
    ])
  }

  private func rainyWeatherFoods() -> [Food] {
    return makeFoods([
      ("Hot Pot", "Rainy day favorite", "flame"),
      ("Soup", "Warms the soul", "flame"),
      ("Ramen", "Slurp the stress away", "bowl.rice"),
      ("Hot Coffee", "Cozy caffeine fix", "mug"),
      ("Comfort Food", "Hug on a plate", "fork.knife"),
    ])
  }

  private func coldWeatherFoods() -> [Food] {
    return makeFoods([
      ("Hot Pot", "Winter essential", "flame"),
      ("Soup", "Bone-warming broth", "flame"),
      ("Hot Chocolate", "Sweet warmth", "mug"),
      ("Rice Bowl", "Stick to your ribs", "bowl.rice"),
      ("Roasted Veg", "Winter harvest", "carrot"),
    ])
  }

  // MARK: - Helpers
  // Convert tuple arrays into Activity/Food structs.
  // imageName stores the SF Symbol name — the card component renders it.

  private func makeActivities(_ items: [(String, String, String)]) -> [Activity] {
    items.map { Activity(title: $0.0, subtitle: $0.1, imageName: $0.2) }
  }

  private func makeFoods(_ items: [(String, String, String)]) -> [Food] {
    items.map { Food(title: $0.0, subtitle: $0.1, imageName: $0.2) }
  }
}
