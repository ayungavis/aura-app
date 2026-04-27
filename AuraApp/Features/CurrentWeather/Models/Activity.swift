//
//  Activity.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 22/04/26.
//

import SwiftUI

struct Activity: CardItem {
  let id = UUID()
  let title: String
  let subtitle: String
  let imageName: String
  var imageURL: URL? = nil

  /// The AI-generated prompt describing a realistic photo of this activity.
  /// Used by ImagePlaygroundManager to generate the actual image.
  var imagePrompt: String? = nil

  /// The generated image loaded from Image Playground, stored in memory.
  var generatedImage: UIImage? = nil

  /// Whether image generation failed after retries.
  var isGenerationFailed: Bool = false
}
