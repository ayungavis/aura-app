//
//  ListViewModel.swift
//  AuraApp
//

import Combine
import Foundation
import SwiftUI

@MainActor
class ListViewModel: ObservableObject {
  @Published var locations: [LocationItem] = []
  @Published var isLoading = false
  @Published var errorMessage: String?

  private let service: TripAdvisorServiceProtocol

  init(service: TripAdvisorServiceProtocol = TripAdvisorService()) {
    self.service = service
  }

  func loadLocations(category: String) async {
    isLoading = true
    errorMessage = nil

    do {
      let fetchedLocations = try await service.searchLocations(
        query: category + " Bali",
        latLong: "-8.717,115.174",
        category: "attractions"
      )

      locations = fetchedLocations.sorted {
        let d1 = Double($0.distance ?? "") ?? Double.infinity
        let d2 = Double($1.distance ?? "") ?? Double.infinity
        return d1 < d2
      }

      isLoading = false
      await fetchImagesForLocations()
    } catch {
      errorMessage = "Failed to load places."
      AppLogger.networkError("searchLocations", error: error)
      isLoading = false
    }
  }

  private func fetchImagesForLocations() async {
    await withTaskGroup(of: (Int, String?).self) { group in
      for index in locations.indices {
        let locationId = locations[index].locationId
        group.addTask {
          do {
            let photos = try await self.service.getLocationPhotos(locationId: locationId)
            return (index, photos.first?.images?.medium?.url)
          } catch {
            AppLogger.networkError("photos_\(locationId)", error: error)
            return (index, nil)
          }
        }
      }

      for await (index, imageUrl) in group {
        locations[index].imageUrl = imageUrl
      }
    }
  }
}
