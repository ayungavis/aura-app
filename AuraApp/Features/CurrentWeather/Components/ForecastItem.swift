//
//  ForecastItem.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI

struct ForecastItem: View {
  let forecast: Forecast

  var body: some View {
    Layout(direction: .vertical, align: .center, spacing: 24, width: .fit, height: .fit) {
      CustomText(forecast.time)

      Image(systemName: forecast.systemImage)
        .resizable()
        .frame(width: 24, height: 24)
        .foregroundStyle(forecast.systemImage.contains("sun") ? .yellow : .blue)
        .symbolRenderingMode(.multicolor)

      if let caption = forecast.caption {
        CustomText(caption)
      } else {
        CustomText(forecast.temperature)
      }
    }
  }
}

#Preview {
  ForecastItem(forecast: Forecast(time: "Now", systemImage: "sun.max.fill", temperature: "30°", caption: nil))
}
