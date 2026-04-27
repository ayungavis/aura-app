//
//  RecommendedFoods.swift
//  AuraApp
//
//  Horizontal scrollable list of food/drink recommendation cards.
//  Now accepts dynamic data from the ViewModel instead of hardcoded mock data.
//

import SwiftUI

struct RecommendedFoods: View {
  @Environment(AppRouter.self) private var router

  /// Food recommendations from the ViewModel.
  let foods: [Food]

  var body: some View {
    Layout(direction: .vertical, spacing: 16) {
      SectionHeader(title: "Recommended Foods").padding(.horizontal, 20)

      ScrollView(.horizontal, showsIndicators: false) {
        Layout(direction: .horizontal, spacing: 12) {
          ForEach(foods) { item in
            ActivityItem(
              title: item.title,
              subtitle: item.subtitle,
              systemImageName: item.imageName
            )
            .fixedSize()
            .padding(.leading, foods.first?.id == item.id ? 20 : 0)
            .padding(.trailing, foods.last?.id == item.id ? 20 : 0)
            .onTapGesture {
              router.navigate(to: .list(category: item.title))
            }
          }
        }
      }
    }
  }
}

#Preview {
  RecommendedFoods(foods: [])
}
