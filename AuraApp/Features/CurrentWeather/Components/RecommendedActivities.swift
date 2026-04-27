//
//  RecommendedActivities.swift
//  AuraApp
//
//  Horizontal scrollable list of activity recommendation cards.
//  Now accepts dynamic data from the ViewModel instead of hardcoded mock data.
//

import SwiftUI

struct RecommendedActivities: View {
  @Environment(AppRouter.self) private var router
  let navigationNamespace: Namespace.ID

  /// Activity recommendations from the ViewModel.
  /// Can be AI-generated or rule-based fallback — this view doesn't care which.
  let activities: [Activity]

  var body: some View {
    Layout(direction: .vertical, spacing: 16) {
      SectionHeader(title: "Recommended Activities").padding(.horizontal, 20)

      ScrollView(.horizontal, showsIndicators: false) {
        Layout(direction: .horizontal, spacing: 12) {
          ForEach(activities) { item in
            ActivityItem(
              title: item.title,
              subtitle: item.subtitle,
              systemImageName: item.imageName,
              imageURL: item.imageURL,
              generatedImage: item.generatedImage
            )
            .matchedTransitionSource(id: item.title, in: navigationNamespace)
            .fixedSize()
            .padding(.leading, activities.first?.id == item.id ? 20 : 0)
            .padding(.trailing, activities.last?.id == item.id ? 20 : 0)
            .onTapGesture {
              router.navigate(to: .list(
                category: item.title,
                imageURL: item.imageURL,
                imageData: item.generatedImage?.pngData(),
                imageName: item.imageName
              ))
            }
          }
        }
      }
    }
  }
}

#Preview {
  @Previewable @Namespace var anim
  RecommendedActivities(navigationNamespace: anim, activities: [])
}
