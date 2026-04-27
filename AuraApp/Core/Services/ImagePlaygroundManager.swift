//
//  ImagePlaygroundManager.swift
//  AuraApp
//
//  Manages asynchronous image generation using Apple's ImagePlayground framework.
//  Uses an internal actor to safely manage the singleton ImageCreator and prevent
//  multiple simultaneous initializations.
//
//  Created by Wahyu Kurniawan on 27/04/26.
//

import Foundation
import UIKit
import ImagePlayground
import SwiftUI

/// Internal actor to handle ImageCreator lifecycle and prevent concurrency issues.
private actor ImageGenerationActor {
  private var creator: ImageCreator?

  func getCreator() async throws -> ImageCreator {
    if let creator = creator {
      return creator
    }
    let newCreator = try await ImageCreator()
    self.creator = newCreator
    return newCreator
  }

  func generate(prompt: String) async -> UIImage? {
    do {
      let creator = try await getCreator()
      let concepts: [ImagePlaygroundConcept] = [.text(prompt)]
      
      // .illustration provides a high-quality, realistic look.
      let imageSequence = creator.images(for: concepts, style: .illustration, limit: 1)

      for try await createdImage in imageSequence {
        return UIImage(cgImage: createdImage.cgImage)
      }
    } catch {
      print("🎨 [ImagePlayground] ❌ Generation failed: \(error)")
    }
    return nil
  }
}

class ImagePlaygroundManager {
  private static let actor = ImageGenerationActor()

  /// Generate a single image from a text prompt using ImageCreator.
  /// This call is non-blocking and safe to call from any thread.
  static func generateImage(prompt: String) async -> UIImage? {
    return await actor.generate(prompt: prompt)
  }
}
