//
//  ListViewModel.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 26/04/26.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class ListViewModel: ObservableObject {
  @Published var locations: [LocationItem] = []
  @Published var isLoading = false
  @Published var error: Error?

  let category: String
  private let service: TripAdvisorServiceProtocol

  init(
    category: String,
    service: TripAdvisorServiceProtocol = TripAdvisorService()
  ) {
    self.category = category
    self.service = service
  }

  func onAppear() {
    Task {
      await loadLocations()
    }
  }

  func retry() {
    error = nil
    Task {
      await loadLocations()
    }
  }

  private func loadLocations() async {
    isLoading = true
    error = nil
    defer { isLoading = false }

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

      AppLogger.placesLoaded("search", count: locations.count)
      await fetchImagesForLocations()
    } catch {
      self.error = error
      AppLogger.placesError("searchLocations", error: error)
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
