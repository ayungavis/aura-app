//
//  CurrentWeatherMockData.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

let HOURLY_FORECAST_DATA: [Forecast] = [
  Forecast(time: "Now", systemImage: "sun.max.fill", temperature: "30°", caption: nil),
  Forecast(time: "17", systemImage: "sun.max.fill", temperature: "30°", caption: nil),
  Forecast(time: "18", systemImage: "sun.max.fill", temperature: "29°", caption: nil),
  Forecast(time: "18:17", systemImage: "sunset.fill", temperature: "", caption: "Sunset"),
  Forecast(time: "19", systemImage: "moon.stars.fill", temperature: "29°", caption: nil),
  Forecast(time: "20", systemImage: "moon.stars.fill", temperature: "29°", caption: nil),
  Forecast(time: "21", systemImage: "moon.stars.fill", temperature: "28°", caption: nil),
  Forecast(time: "22", systemImage: "moon.fill", temperature: "27°", caption: nil),
  Forecast(time: "23", systemImage: "moon.haze.fill", temperature: "27°", caption: nil),
]

let RECOMMENDED_ACTIVITIES: [Activity] = [
  Activity(title: "Football", subtitle: "90 mins", imageName: "football"),
  Activity(title: "Running", subtitle: "90 mins", imageName: "running"),
  Activity(title: "Biking", subtitle: "90 mins", imageName: "biking"),
  Activity(title: "Hangout", subtitle: "7 nearby places", imageName: "hangout"),
  Activity(title: "Cafe", subtitle: "3 nearby places", imageName: "cafe-hoping"),
]

let RECOMMENDED_FOODS: [Food] = [
  Food(title: "Dessert", subtitle: "7 nearby places", imageName: "dessert"),
  Food(title: "Soup", subtitle: "5 nearby places", imageName: "soup"),
  Food(title: "Hot pot", subtitle: "2 nearby places", imageName: "hot-pot"),
  Food(title: "Fruit", subtitle: "12 nearby places", imageName: "fruit"),
  Food(title: "Ice cream", subtitle: "4 nearby places", imageName: "ice-cream"),
]
