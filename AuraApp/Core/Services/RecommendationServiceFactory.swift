//
//  RecommendationServiceFactory.swift
//  AuraApp
//
//  Factory that picks the right recommendation service based on device capabilities.
//
//  - Apple Intelligence available → AIRecommendationService (on-device AI)
//  - Not available → FallbackRecommendationService (rule-based)
//
//  This is the "Factory Pattern" — one place decides which implementation to use,
//  so the rest of the app doesn't need to know or care.
//
//  Created by Wahyu Kurniawan on 26/04/26.
//

import FoundationModels

enum RecommendationServiceFactory {
  /// Creates the best available recommendation service for this device.
  /// Check happens at call time so it always reflects current availability.
  static func create() -> RecommendationServiceProtocol {
    let model = SystemLanguageModel.default

    switch model.availability {
    case .available:
      // On-device AI is ready — use it for personalized recommendations
      print("🤖 [RecommendationFactory] Apple Intelligence AVAILABLE — using AIRecommendationService")
      return AIRecommendationService()
    case .unavailable(let reason):
      // Device doesn't support Apple Intelligence, or it's not enabled
      // Fall back to deterministic rule-based recommendations
      print("🤖 [RecommendationFactory] Apple Intelligence UNAVAILABLE (reason: \(reason)) — using FallbackRecommendationService")
      return FallbackRecommendationService()
    @unknown default:
      // Future-proof: handle unknown cases with the safe fallback
      print("🤖 [RecommendationFactory] Apple Intelligence UNKNOWN status — using FallbackRecommendationService")
      return FallbackRecommendationService()
    }
  }
}
