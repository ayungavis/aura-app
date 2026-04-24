//
//  TripAdvisorServiceProtocol.swift
//  AuraApp
//

import Foundation

protocol TripAdvisorServiceProtocol {
    func searchLocations(
        query: String,
        latLong: String?,
        category: String?
    ) async throws -> [LocationItem]

    func getLocationDetails(locationId: String) async throws -> LocationDetail
    func getLocationPhotos(locationId: String) async throws -> [LocationPhoto]
    func getLocationReviews(locationId: String) async throws -> [LocationReview]
}
