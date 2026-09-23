//
//  ListViewModel.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 26/04/26.
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class ListViewModel {
  var places: [Place] = []
  var isLoading = false
  var isFunFactLoading = false
  var error: Error?
  var funFact: String?

  let category: String
  let placeKind: PlaceKind
  let searchCenter: SearchCenter?
  @ObservationIgnored private let service: PlacesServiceProtocol
  @ObservationIgnored private let recommendationService: RecommendationServiceProtocol

  init(
    category: String,
    placeKind: PlaceKind,
    searchCenter: SearchCenter?,
    service: PlacesServiceProtocol = MapKitPlacesService(),
    recommendationService: RecommendationServiceProtocol = RecommendationServiceFactory.create()
  ) {
    self.category = category
    self.placeKind = placeKind
    self.searchCenter = searchCenter
    self.service = service
    self.recommendationService = recommendationService
  }

  func onAppear() {
    Task {
      await loadPlaces()
      await loadFunFact()
    }
  }

  func retry() {
    error = nil
    Task {
      await loadPlaces()
      await loadFunFact()
    }
  }

  private func loadPlaces() async {
    isLoading = true
    error = nil
    defer { isLoading = false }

    do {
      places = try await service.searchPlaces(query: category, kind: placeKind, near: searchCenter)
      AppLogger.placesLoaded("search", count: places.count)
    } catch {
      self.error = error
      AppLogger.placesError("searchPlaces", error: error)
    }
  }

  private func loadFunFact() async {
    isFunFactLoading = true
    defer { isFunFactLoading = false }

    do {
      funFact = try await recommendationService.fetchFunFact(category: category)
    } catch {
      AppLogger.placesError("fetchFunFact", error: error)
      // Fallback or keep nil
    }
  }
}
