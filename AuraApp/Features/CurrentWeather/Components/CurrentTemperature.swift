//
//  CurrentTemperature.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI

struct CurrentTemperature: View {
  var body: some View {
    Layout(direction: .vertical, horizontalPadding: 20) {
      CustomText("Mostly cloudy", variant: .caption, color: .black)
        .opacity(0.56)

      CustomText(
        "29°",
        variant:
        .custom(
          family: .serif,
          weight: .regular,
          size: 96,
          style: .largeTitle
        )
      )

      Layout(direction: .horizontal, spacing: 4) {
        Image(systemName: "location")
        CustomText("Kabupaten Badung")
      }
    }
  }
}

#Preview {
  CurrentTemperature()
}
