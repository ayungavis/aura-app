//
//  HourlyForecast.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI

struct HourlyForecast: View {
  var body: some View {
    Layout(direction: .vertical, spacing: 28) {
      Layout(direction: .horizontal, horizontalPadding: 16) {
        CustomText(
          "Clouds gather softly above. The daylight moves in silence. The sky feels calm today."
        )
      }

      ScrollView(.horizontal, showsIndicators: false) {
        Layout(direction: .horizontal, spacing: 28) {
          ForEach(Array(HOURLY_FORECAST_DATA.enumerated()), id: \.element.id) { index, item in
            ForecastItem(forecast: item)
              .fixedSize()
              .padding(.leading, index == 0 ? 20 : 0)
              .padding(.trailing, index == HOURLY_FORECAST_DATA.count - 1 ? 20 : 0)
          }
        }
      }
    }
  }
}

#Preview {
  HourlyForecast()
}
