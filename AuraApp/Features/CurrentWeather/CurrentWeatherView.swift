//
//  CurrentWeatherView.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI

struct CurrentWeatherView: View {
  var body: some View {
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

#Preview {
  CurrentWeatherView()
}
