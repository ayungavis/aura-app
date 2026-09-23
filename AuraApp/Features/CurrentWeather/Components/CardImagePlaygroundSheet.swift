//
//  CardImagePlaygroundSheet.swift
//  AuraApp
//
//  iOS 27 deprecated programmatic generation (`ImageCreator`), so recommendation
//  cards there offer a Generate button that opens the system Image Playground
//  sheet pre-filled with the card's prompt.
//

import ImagePlayground
import UIKit
import SwiftUI

/// The card the user asked to generate an image for.
struct CardImageRequest: Equatable {
  let id: UUID
  let prompt: String
}

private struct CardImagePlaygroundSheet: ViewModifier {
  @Binding var request: CardImageRequest?
  let onImageGenerated: (UUID, UIImage) -> Void

  func body(content: Content) -> some View {
    // Captured now: the sheet may clear `request` on dismiss before completion fires.
    let current = request

    content
      .imagePlaygroundSheet(
        isPresented: Binding(
          get: { request != nil },
          set: { if !$0 { request = nil } }
        ),
        concept: current?.prompt ?? "",
        onCompletion: { url in
          // The sheet hands back a temporary file; read it before it is cleaned up.
          guard let current,
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data)
          else { return }
          onImageGenerated(current.id, image)
          request = nil
        },
        onCancellation: { request = nil }
      )
      .imagePlaygroundGenerationStyle(.illustration)
  }
}

extension View {
  func cardImagePlaygroundSheet(
    request: Binding<CardImageRequest?>,
    onImageGenerated: @escaping (UUID, UIImage) -> Void
  ) -> some View {
    modifier(CardImagePlaygroundSheet(request: request, onImageGenerated: onImageGenerated))
  }
}

extension CardItem {
  /// Whether this card should offer the manual Image Playground button.
  @MainActor
  func needsManualImageGeneration(supportsImagePlayground: Bool) -> Bool {
    !CurrentWeatherViewModel.supportsBackgroundImageGeneration
      && supportsImagePlayground
      && generatedImage == nil
      && imagePrompt != nil
  }
}
