//
//  CurrentWeatherView.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI
import WeatherKit

struct CurrentWeatherView: View {
  @StateObject private var locationManager = LocationManager()
  @StateObject private var weatherService = WeatherService.shared

  var body: some View {
    Group {
      if weatherService.isLoading {
        ProgressView()
          .progressViewStyle(.circular)
      } else {
        ZStack {
          Layout(direction: .vertical, align: .leading, height: .fill) {
            Image("main-gradient-background")
              .resizable()
              .scaledToFit()
          }

          ScrollView {
            Layout(direction: .vertical, spacing: 50) {
              Spacer().frame(height: 127)
              CurrentTemperature()
              HourlyForecast()
              RecommendedActivities()
              RecommendedFoods()
              Spacer().frame(height: 20)
            }
          }
        }
        .ignoresSafeArea()
      }
    }
  }
}

#Preview {
  CurrentWeatherView()
}
