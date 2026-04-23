//
//  RecommendedFoods.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 22/04/26.
//

import SwiftUI

struct RecommendedFoods: View {
  var body: some View {
    Layout(direction: .vertical, spacing: 16) {
      SectionHeader(title: "Recommended Foods").padding(.horizontal, 20)

      ScrollView(.horizontal, showsIndicators: false) {
        Layout(direction: .horizontal, spacing: 12) {
          ForEach(
            Array(RECOMMENDED_FOODS.enumerated()),
            id: \.element.id
          ) { index, item in
            ActivityItem(activity: item)
              .fixedSize()
              .padding(.leading, index == 0 ? 20 : 0)
              .padding(.trailing, index == RECOMMENDED_FOODS.count - 1 ? 20 : 0)
          }
        }
      }
    }
  }
}

#Preview {
  RecommendedFoods()
}
