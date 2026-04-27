//
//  DetailViewModel.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 26/04/26.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class DetailViewModel: ObservableObject {
  @Published var detail: LocationDetail?
  @Published var photos: [LocationPhoto] = []
  @Published var reviews: [LocationReview] = []
  @Published var isLoading = false
  @Published var error: Error?

  let locationId: String
  let distance: String?
  let initialImageUrl: String?

  private let service: TripAdvisorServiceProtocol

  init(
    locationId: String,
    distance: String? = nil,
    initialImageUrl: String? = nil,
    service: TripAdvisorServiceProtocol = TripAdvisorService()
  ) {
    self.locationId = locationId
    self.distance = distance
    self.initialImageUrl = initialImageUrl
    self.service = service
  }

  func onAppear() {
    Task {
      await loadData()
    }
  }

  func retry() {
    error = nil
    Task {
      await loadData()
    }
  }

  func openMaps() {
    let name = detail?.name ?? ""
    let address = detail?.addressObj?.addressString ?? ""
    let query = [name, address].filter { !$0.isEmpty }.joined(separator: ", ")

    guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: "http://maps.apple.com/?q=\(encoded)")
    else { return }

    UIApplication.shared.open(url)
  }

  private func loadData() async {
    isLoading = true
    error = nil
    defer { isLoading = false }

    do {
      async let detailTask = service.getLocationDetails(locationId: locationId)
      async let photosTask = service.getLocationPhotos(locationId: locationId)
      async let reviewsTask = service.getLocationReviews(locationId: locationId)

      let (fetchedDetail, fetchedPhotos, fetchedReviews) = try await (
        detailTask, photosTask, reviewsTask
      )

      detail = fetchedDetail
      photos = fetchedPhotos
      reviews = fetchedReviews

      AppLogger.placesLoaded("detail_\(locationId)", count: fetchedPhotos.count)
    } catch {
      self.error = error
      AppLogger.placesError("detailView_\(locationId)", error: error)
    }
  }
}
