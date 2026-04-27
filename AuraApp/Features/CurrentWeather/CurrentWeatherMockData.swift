//
//  CurrentWeatherMockData.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

let HOURLY_FORECAST_DATA: [Forecast] = [
  Forecast(time: "Now", systemImage: "cloud.rain.fill", temperature: "26°", caption: nil, precipitationPercentage: 95),
  Forecast(time: "01", systemImage: "cloud.sun.rain.fill", temperature: "26°", caption: nil, precipitationPercentage: 60),
  Forecast(time: "02", systemImage: "cloud.moon.rain.fill", temperature: "25°", caption: nil, precipitationPercentage: 55),
  Forecast(time: "03", systemImage: "cloud.rain.fill", temperature: "25°", caption: nil, precipitationPercentage: 50),
  Forecast(time: "04", systemImage: "cloud.fill", temperature: "26°", caption: nil, precipitationPercentage: 0),
  Forecast(time: "05", systemImage: "cloud.sun.rain.fill", temperature: "26°", caption: nil, precipitationPercentage: 30),
  Forecast(time: "06", systemImage: "cloud.heavyrain.fill", temperature: "25°", caption: nil, precipitationPercentage: 90),
  Forecast(time: "07", systemImage: "sun.max.fill", temperature: "27°", caption: nil, precipitationPercentage: 0),
  Forecast(time: "08", systemImage: "sun.max.fill", temperature: "28°", caption: nil, precipitationPercentage: 0),
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
