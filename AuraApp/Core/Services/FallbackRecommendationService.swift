//
//  FallbackRecommendationService.swift
//  AuraApp
//
//  Rule-based recommendation engine. No AI, no network — just maps
//  weather conditions to predefined activity and food suggestions.
//  Used on devices that don't support Apple Intelligence, or as a
//  fallback when the on-device model isn't available.
//
//  Created by Wahyu Kurniawan on 26/04/26.
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
        ("Swimming", "Cool off in the water", "figure.open.water.swim", "Crystal clear outdoor pool on a bright sunny day, blue water reflecting sunlight, sparkling surface"),
        ("Indoor Gym", "Stay cool, stay fit", "dumbbell.fill", "Modern gym interior with weight equipment, bright lighting, dumbbells and gym machines"),
        ("Surfing", "Perfect wave weather", "figure.surfing", "A surfboard on a tropical beach wave, golden sunlight, turquoise ocean water, white foam"),
        ("Cafe Hopping", "Shaded exploration", "cup.and.saucer", "Cozy outdoor cafe terrace with iced coffee drinks, umbrellas providing shade on a sunny day"),
        ("Beach Walk", "Early morning stroll", "figure.walk", "Sandy beach at sunrise, gentle waves, warm golden light, footprints in the sand"),
      ])
    }
    return makeActivities([
      ("Running", "Great running weather", "figure.run", "Scenic park trail surrounded by green trees on a beautiful sunny morning, running shoes on gravel"),
      ("Biking", "Hit the trails", "figure.outdoor.cycle", "Mountain bike on a dirt trail through a lush green forest, dappled sunlight, bicycle detail"),
      ("Football", "Perfect for the pitch", "figure.soccer", "Football match on a green grass field under a clear blue sky, goal post and soccer ball"),
      ("Hiking", "Explore the outdoors", "figure.hiking", "Mountain trail with panoramic views, clear sky, lush green vegetation, hiking boots on rock"),
      ("Yoga", "Outdoor mindfulness", "figure.yoga", "Yoga mat outdoors in a peaceful garden, morning sunlight, zen garden setting"),
    ])
  }

  private func partlyCloudyActivities() -> [Activity] {
    return makeActivities([
      ("Running", "Comfortable conditions", "figure.run", "City sidewalk under partly cloudy sky, comfortable weather, urban park setting, cityscape"),
      ("Biking", "Mild and pleasant", "figure.outdoor.cycle", "Paved bike path with scattered clouds in the sky, pleasant temperature, bicycle wheel"),
      ("Hiking", "Ideal cloud cover", "figure.hiking", "Nature trail with fluffy clouds overhead providing comfortable shade, forest path"),
      ("Yoga", "Peaceful atmosphere", "figure.yoga", "Open-air pavilion, soft cloudy sky, tranquil setting, yoga bolster and mat"),
      ("Cafe Hopping", "Relaxed afternoon", "cup.and.saucer", "Charming street cafe with outdoor seating, warm drinks, pleasant partly cloudy sky"),
    ])
  }

  private func overcastActivities() -> [Activity] {
    return makeActivities([
      ("Walking", "Cool and calm", "figure.walk", "Quiet neighborhood street on an overcast day, cool and peaceful atmosphere, autumn leaves"),
      ("Yoga", "Find your center", "figure.yoga", "Indoor yoga studio with natural light from large windows, calm and serene atmosphere"),
      ("Gym", "Indoor workout day", "dumbbell.fill", "Well-equipped modern gym with weight equipment, warm indoor lighting on a grey day"),
      ("Cafe Hopping", "Cozy overcast vibes", "cup.and.saucer", "Warm cozy cafe interior with steaming coffee, bookshelves, soft lighting on a grey day"),
      ("Cycling", "No sun glare", "figure.outdoor.cycle", "Quiet road on an overcast day, comfortable and cool conditions, bicycle handlebars"),
    ])
  }

  private func foggyActivities() -> [Activity] {
    return makeActivities([
      ("Yoga", "Misty morning zen", "figure.yoga", "Misty garden at dawn, ethereal foggy atmosphere, peaceful setting, stone lantern"),
      ("Walking", "Atmospheric stroll", "figure.walk", "Foggy tree-lined path, mysterious and atmospheric, soft diffused light, wooden bench"),
      ("Gym", "Clear your mind", "dumbbell.fill", "Modern gym interior with warm lighting, treadmills, foggy view through windows"),
      ("Cafe Hopping", "Warm up inside", "cup.and.saucer", "Steaming cup of coffee in a warm cafe, condensation on windows from fog outside"),
      ("Indoor Climbing", "Adventure inside", "figure.climbing", "Indoor rock climbing wall with colorful holds, climbing ropes, well-lit facility"),
    ])
  }

  private func lightRainActivities() -> [Activity] {
    return makeActivities([
      ("Gym", "Stay dry, stay strong", "dumbbell.fill", "Weights in a modern gym, rain visible through large windows, motivating atmosphere"),
      ("Yoga", "Rainy day calm", "figure.yoga", "Peaceful indoor yoga session, sound of rain on windows, candles and warm lighting"),
      ("Indoor Swimming", "Water on both sides", "figure.open.water.swim", "Indoor swimming pool with lane markers, warm lighting, steam rising from heated water"),
      ("Cafe Hopping", "Watch the rain", "cup.and.saucer", "Hot latte by a rain-streaked cafe window, cozy warm interior, rainy street view"),
      ("Museum Visit", "Culture indoors", "building.columns", "Grand museum interior with high ceilings, art on walls, quiet corridors on a rainy day"),
    ])
  }

  private func heavyRainActivities() -> [Activity] {
    return makeActivities([
      ("Gym", "Perfect indoor day", "dumbbell.fill", "Busy gym with weight racks, heavy rain pouring outside windows, energetic atmosphere"),
      ("Yoga", "Stay in, stretch out", "figure.yoga", "Home yoga setup with mat and cushions, rain pouring outside, warm ambient lighting"),
      ("Indoor Swimming", "Already wet anyway", "figure.open.water.swim", "Large indoor pool facility, blue water, bright overhead lighting"),
      ("Cafe Hopping", "Hot drink weather", "cup.and.saucer", "Cozy cafe with hot chocolate and pastries, heavy rain outside, warm golden interior"),
      ("Home Cooking", "Try a new recipe", "fork.knife", "Kitchen scene with fresh ingredients, pot on stove, warm homey atmosphere"),
    ])
  }

  private func snowActivities() -> [Activity] {
    return makeActivities([
      ("Skiing", "Fresh powder day", "figure.skiing.downhill", "Skis on fresh powder snow on a mountain slope, bright winter sunshine, ski resort"),
      ("Snow Walk", "Winter wonderland", "figure.walk", "Snow-covered park path, snowflakes falling, beautiful winter landscape, pine trees"),
      ("Gym", "Warm indoor session", "dumbbell.fill", "Warm gym interior with exercise equipment, snowy scene visible through frosted windows"),
      ("Cafe Hopping", "Hot chocolate weather", "cup.and.saucer", "Mug of hot chocolate with marshmallows in a ski lodge cafe, snow-capped mountains outside"),
      ("Indoor Yoga", "Stretch and warm up", "figure.yoga", "Cozy indoor yoga studio with heated floor, snow falling outside large windows"),
    ])
  }

  private func thunderstormActivities() -> [Activity] {
    return makeActivities([
      ("Gym", "Safe indoor workout", "dumbbell.fill", "Workout equipment in a gym, dramatic lightning visible through windows"),
      ("Yoga", "Stormy zen mode", "figure.yoga", "Calm meditation and yoga setup at home, thunderstorm outside, candles flickering"),
      ("Home Cooking", "Comfort food time", "fork.knife", "Comfort food cooking scene with stew in a pot, warm kitchen, stormy weather outside"),
      ("Reading", "Cozy up with a book", "book", "Book on a comfortable sofa with a blanket, rain on windows, warm lamp"),
      ("Movie Night", "Perfect storm excuse", "popcorn", "Home cinema setup with popcorn and blankets, television screen, thunderstorm outside"),
    ])
  }

  // MARK: - Food Recommendations by Weather

  private func hotWeatherFoods() -> [Food] {
    return makeFoods([
      ("Ice Cream", "Cool down treat", "snowflake", "Colorful scoops of artisan ice cream in a waffle cone, melting slightly in summer heat"),
      ("Fresh Fruit", "Hydrating and sweet", "leaf", "Fresh tropical fruit platter with watermelon, mango, and berries, glistening with water droplets"),
      ("Smoothie", "Blend the heat away", "cup.and.saucer", "Vibrant colorful fruit smoothie in a tall glass with a straw, fresh fruit garnish"),
      ("Salad", "Light and refreshing", "leaf", "Fresh garden salad with colorful vegetables, light dressing, crisp lettuce, cherry tomatoes"),
      ("Cold Brew", "Iced coffee energy", "mug", "Tall glass of cold brew coffee with ice cubes, condensation on glass, refreshing summer drink"),
    ])
  }

  private func mildWeatherFoods() -> [Food] {
    return makeFoods([
      ("Cafe", "Perfect cafe weather", "cup.and.saucer", "Artisan cappuccino with latte art in a ceramic cup, cafe setting with pastries"),
      ("Pizza", "Casual outdoor dining", "flame", "Wood-fired Neapolitan pizza fresh from oven, melted cheese, fresh basil, rustic setting"),
      ("Rice Bowl", "Warm and satisfying", "fork.knife.circle", "Colorful poke bowl with rice, fresh fish, avocado, edamame, and sesame seeds"),
      ("Soup", "Light and comforting", "flame", "Bowl of homemade vegetable soup with crusty bread, steam rising, warm kitchen setting"),
      ("Fruit Bowl", "Fresh and healthy", "leaf", "Açaí bowl topped with fresh berries, granola, banana slices, and honey drizzle"),
    ])
  }

  private func foggyWeatherFoods() -> [Food] {
    return makeFoods([
      ("Hot Coffee", "Cut through the fog", "mug", "Steaming cup of black coffee in a ceramic mug, morning fog visible through window"),
      ("Soup", "Warming comfort", "flame", "Creamy pumpkin soup in a rustic bowl with crusty bread, warm autumn atmosphere"),
      ("Rice Bowl", "Hearty and warm", "fork.knife.circle", "Steaming bowl of rice with grilled chicken, vegetables, and savory sauce"),
      ("Bakery", "Fresh from the oven", "birthday.cake", "Fresh croissants and pastries on a wooden tray, golden brown, bakery setting"),
      ("Tea", "Soothing and warm", "cup.and.saucer.fill", "Elegant cup of green tea with steam rising, Japanese tea set, tranquil setting"),
    ])
  }

  private func rainyWeatherFoods() -> [Food] {
    return makeFoods([
      ("Hot Pot", "Rainy day favorite", "flame", "Bubbling hot pot with fresh vegetables and meat, steam rising, communal dining table setting"),
      ("Soup", "Warms the soul", "flame", "Rich ramen with soft-boiled egg, noodles, and broth in a deep bowl, chopsticks resting on the side"),
      ("Ramen", "Slurp the stress away", "fork.knife.circle", "Authentic Japanese ramen with chashu pork, nori, and a perfectly runny egg, close-up photo"),
      ("Hot Coffee", "Cozy caffeine fix", "mug", "Latte in a large ceramic mug on a wooden table, rain-streaked window in background, cozy atmosphere"),
      ("Comfort Food", "Hug on a plate", "fork.knife", "Mac and cheese in a cast iron skillet, golden bubbly top, rustic wooden table setting"),
    ])
  }

  private func coldWeatherFoods() -> [Food] {
    return makeFoods([
      ("Hot Pot", "Winter essential", "flame", "Steaming shabu-shabu hot pot with thinly sliced beef, winter vegetables, snowy window"),
      ("Soup", "Bone-warming broth", "flame", "Hearty beef stew with root vegetables in a ceramic bowl, crusty bread, winter setting"),
      ("Hot Chocolate", "Sweet warmth", "mug", "Rich hot chocolate topped with whipped cream and cocoa powder in a winter mug"),
      ("Rice Bowl", "Stick to your ribs", "fork.knife.circle", "Warm donburi rice bowl with teriyaki chicken, steamed vegetables, sesame seeds"),
      ("Roasted Veg", "Winter harvest", "carrot", "Roasted root vegetables with herbs on a baking tray, golden and caramelized"),
    ])
  }

  // MARK: - Helpers

  // Convert tuple arrays into Activity/Food structs.
  // imageName stores the SF Symbol name — the card component renders it.
  // imagePrompt is used to generate a realistic photo via Image Playground.

  private func makeActivities(_ items: [(String, String, String, String)]) -> [Activity] {
    items.map { Activity(title: $0.0, subtitle: $0.1, imageName: $0.2, imagePrompt: $0.3) }
  }

  private func makeFoods(_ items: [(String, String, String, String)]) -> [Food] {
    items.map { Food(title: $0.0, subtitle: $0.1, imageName: $0.2, imagePrompt: $0.3) }
  }
}
