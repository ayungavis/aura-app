//
//  RecommendedFoods.swift
//  AuraApp
//
//  Horizontal scrollable list of food/drink recommendation cards.
//  Now accepts dynamic data from the ViewModel instead of hardcoded mock data.
//

import ImagePlayground
import SwiftUI

struct RecommendedFoods: View {
  @Environment(AppRouter.self) private var router
  let navigationNamespace: Namespace.ID

  /// Food recommendations from the ViewModel.
  let foods: [Food]
  let searchCenter: SearchCenter?
  var onImageGenerated: (UUID, UIImage) -> Void = { _, _ in }

  @Environment(\.supportsImagePlayground) private var supportsImagePlayground
  @State private var imageRequest: CardImageRequest?

  var body: some View {
    Layout(direction: .vertical, spacing: 16) {
      SectionHeader(title: "Recommended Foods").padding(.horizontal, 20)

      ScrollView(.horizontal, showsIndicators: false) {
        Layout(direction: .horizontal, spacing: 12) {
          ForEach(foods) { item in
            ActivityItem(
              title: item.title,
              subtitle: item.subtitle,
              systemImageName: item.imageName,
              imageURL: item.imageURL,
              generatedImage: item.generatedImage,
              isGenerationFailed: item.isGenerationFailed,
              onGenerate: generateAction(for: item)
            )
            .matchedTransitionSource(id: item.title, in: navigationNamespace)
            .fixedSize()
            .padding(.leading, foods.first?.id == item.id ? 20 : 0)
            .padding(.trailing, foods.last?.id == item.id ? 20 : 0)
            .onTapGesture {
              router.navigate(to: .list(
                category: item.title,
                imageURL: item.imageURL,
                imageData: item.generatedImage?.pngData(),
                imageName: item.imageName,
                placeKind: .food,
                searchCenter: searchCenter
              ))
            }
          }
        }
      }
    }
    .cardImagePlaygroundSheet(request: $imageRequest, onImageGenerated: onImageGenerated)
  }

  private func generateAction(for item: Food) -> (() -> Void)? {
    guard item.needsManualImageGeneration(supportsImagePlayground: supportsImagePlayground),
          let prompt = item.imagePrompt
    else { return nil }
    return { imageRequest = CardImageRequest(id: item.id, prompt: prompt) }
  }
}
