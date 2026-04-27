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
import FoundationModels

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

  func generate(prompt: String, retryCount: Int = 2) async -> UIImage? {
    var currentPrompt = prompt
    var attempts = 0
    var usePersonIdentity = false
    
    while attempts < retryCount {
      do {
        let creator = try await getCreator()
        var concepts: [ImagePlaygroundConcept] = [.text(currentPrompt)]
        
        // If we detected that a person identity is needed, attach the local asset
        if usePersonIdentity, let personImage = UIImage(named: "potrait-aura-boy"), let cgImage = personImage.cgImage {
          concepts.append(.image(cgImage))
          print("🎨 [ImagePlayground] 👤 Attaching person identity (CGImage): potrait-aura-boy")
        }
        
        let imageSequence = creator.images(for: concepts, style: .illustration, limit: 1)

        for try await createdImage in imageSequence {
          return UIImage(cgImage: createdImage.cgImage)
        }
      } catch {
        let errorDescription = "\(error)"
        print("🎨 [ImagePlayground] ⚠️ Attempt \(attempts + 1) failed: \(errorDescription)")
        
        if attempts < retryCount - 1 {
          // If the error specifically asks for a person identity, enable it for the next retry
          if errorDescription.contains("conceptsRequirePersonIdentity") {
            usePersonIdentity = true
            print("🎨 [ImagePlayground] 🔄 Person identity required. Will retry with local portrait.")
          } else if let rewritten = await rewritePrompt(currentPrompt, error: errorDescription) {
            currentPrompt = rewritten
            print("🎨 [ImagePlayground] 🤖 LLM Rewrote prompt for retry: \(currentPrompt)")
          } else {
            currentPrompt = cleanPrompt(currentPrompt)
          }
        }
        
        attempts += 1
      }
    }
    
    print("🎨 [ImagePlayground] ❌ Generation failed after \(retryCount) attempts.")
    return nil
  }

  private func rewritePrompt(_ prompt: String, error: String) async -> String? {
    let session = LanguageModelSession(instructions: """
    You are an expert at writing prompts for Apple's Image Playground. \
    The user's prompt failed with this error: \(error). \
    Rewrite the prompt to avoid the error. \
    Rules: \
    1. Use ONLY English words. \
    2. Focus strictly on STILL OBJECTS, EQUIPMENT, and EMPTY SCENERY. \
    3. Remove all people, faces, or words implying human presence. \
    4. If the error is 'unsupportedLanguage', translate foreign words. \
    5. Keep it under 20 words.
    """)
    
    do {
      let response = try await session.respond(to: "Rewrite this prompt: \(prompt)")
      return response.content
    } catch {
      print("🎨 [ImagePlayground] ❌ LLM Rewrite failed: \(error)")
      return nil
    }
  }

  private func cleanPrompt(_ prompt: String) -> String {
    let forbiddenWords = [
      "person", "human", "people", "man", "woman", "men", "women", 
      "child", "children", "boy", "girl", "face", "portrait", "figure",
      "someone", "anybody", "everybody"
    ]
    
    var words = prompt.components(separatedBy: .whitespacesAndNewlines)
    words = words.filter { word in
      let cleanWord = word.lowercased().trimmingCharacters(in: .punctuationCharacters)
      return !forbiddenWords.contains(cleanWord)
    }
    
    return words.joined(separator: " ")
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
