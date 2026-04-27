//
//  ForecastItem.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI

struct ForecastItem: View {
  let forecast: Forecast

  private var isRainy: Bool {
    let image = forecast.systemImage.lowercased()
    return image.contains("rain") || image.contains("drizzle") || image.contains("sleet")
  }

  var body: some View {
    Layout(direction: .vertical, align: .center, spacing: 12, width: .fit, height: .fixed(130)) {
      CustomText(forecast.time)

      VStack(spacing: 4) {
        Image(systemName: forecast.systemImage)
          .resizable()
          .scaledToFit()
          .frame(width: 32, height: 32)
          .symbolRenderingMode(isRainy ? .palette : .hierarchical)
          .foregroundStyle(
            isRainy ? Color.black : Color.black,
            isRainy ? Color.auraPrimary : Color.black,
            isRainy ? Color.auraPrimary : Color.black
          )
        
        if isRainy, let precipitation = forecast.precipitationPercentage, precipitation > 0 {
          CustomText("\(precipitation)%", variant: .caption, color: .auraPrimary)
        } else {
          // Empty text with same variant to maintain vertical spacing consistency
          CustomText(" ", variant: .caption)
            .opacity(0)
        }
      }
      .frame(height: 52)

      if let caption = forecast.caption {
        CustomText(caption)
      } else {
        CustomText(forecast.temperature)
      }
    }
  }
}

#Preview {
  ForecastItem(forecast: Forecast(time: "Now", systemImage: "sun.max.fill", temperature: "30°", caption: nil, precipitationPercentage: nil))
}
