//
//  TripAdvisorService.swift
//  AuraApp
//
//  Handles all communication with the TripAdvisor Content API.
//  Each function follows the same pattern:
//    1. Build URL with query parameters
//    2. Fetch data using URLSession
//    3. Decode JSON into our models
//    4. Return the result
//

import Foundation

// MARK: - Why a class?

// We use a class (not struct) because this is a "service" — a shared utility
// that performs network operations. We don't need value-type semantics here.
//
// MARK: - What is `async`?

// `async` means the function can pause while waiting for the network response
// without blocking the UI. You call it with `await` from a `.task {}` modifier
// or another async context.

class TripAdvisorService {
    /// Base URL for all TripAdvisor Content API requests
    private let baseURL = "https://api.content.tripadvisor.com/api/v1"

    // MARK: - 1. Search Locations

    // Searches for places matching a text query.
    // Example: searchLocations(query: "beach Bali", category: "attractions")
    //
    // API docs: https://tripadvisor-content-api.readme.io/reference/searchforlocations
    func searchLocations(
        query: String,
        latLong: String? = nil,
        category: String? = nil
    ) async throws -> [LocationItem] {
        // URLComponents helps us safely build a URL with query parameters.
        // It handles special characters (spaces, etc.) automatically.
        var components = URLComponents(string: "\(baseURL)/location/search")!
        var queryItems = [
            URLQueryItem(name: "key", value: "TRIPADVIOR_API_KEY"),
            URLQueryItem(name: "searchQuery", value: query),
            URLQueryItem(name: "language", value: "en"),
        ]

        // Only add optional parameters if they have values
        if let latLong = latLong {
            queryItems.append(URLQueryItem(name: "latLong", value: latLong))
        }
        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }

        components.queryItems = queryItems

        // `guard` is like an `if` but forces you to exit if the condition fails.
        // This avoids deeply-nested code.
        guard let url = components.url else {
            throw URLError(.badURL)
        }

        // `URLSession.shared.data(from:)` is the async networking call.
        // It returns a tuple: (data, response). We only need `data`.
        let (data, _) = try await URLSession.shared.data(from: url)

        // JSONDecoder converts the raw JSON bytes into our Swift struct.
        let result = try JSONDecoder().decode(LocationSearchResponse.self, from: data)
        return result.data
    }

    // MARK: - 2. Get Location Details

    /// Fetches comprehensive info about a single location.
    ///
    /// API docs: https://tripadvisor-content-api.readme.io/reference/getlocationdetails
    func getLocationDetails(locationId: String) async throws -> LocationDetail {
        var components = URLComponents(string: "\(baseURL)/location/\(locationId)/details")!
        components.queryItems = [
            URLQueryItem(name: "key", value: "TRIPADVIOR_API_KEY"),
            URLQueryItem(name: "language", value: "en"),
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(LocationDetail.self, from: data)
    }

    // MARK: - 3. Get Location Photos

    /// Fetches up to 5 recent photos for a location.
    ///
    /// API docs: https://tripadvisor-content-api.readme.io/reference/getlocationphotos
    func getLocationPhotos(locationId: String) async throws -> [LocationPhoto] {
        var components = URLComponents(string: "\(baseURL)/location/\(locationId)/photos")!
        components.queryItems = [
            URLQueryItem(name: "key", value: "TRIPADVIOR_API_KEY"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "limit", value: "5"),
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        // Debug: print raw response if decoding fails
        // The API may return an error object instead of { "data": [...] }
        do {
            let result = try JSONDecoder().decode(LocationPhotosResponse.self, from: data)
            return result.data
        } catch {
            let rawResponse = String(data: data, encoding: .utf8) ?? "Unable to read response"
            print("📸 Photos decode error for location \(locationId): \(error)")
            print("📸 Raw response: \(rawResponse)")
            return [] // Return empty array so the page still shows
        }
    }

    // MARK: - 4. Get Location Reviews

    /// Fetches up to 5 most recent reviews for a location.
    ///
    /// API docs: https://tripadvisor-content-api.readme.io/reference/getlocationreviews
    func getLocationReviews(locationId: String) async throws -> [LocationReview] {
        var components = URLComponents(string: "\(baseURL)/location/\(locationId)/reviews")!
        components.queryItems = [
            URLQueryItem(name: "key", value: "TRIPADVIOR_API_KEY"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "limit", value: "5"),
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        // Same resilient decoding pattern as photos
        do {
            let result = try JSONDecoder().decode(LocationReviewsResponse.self, from: data)
            return result.data
        } catch {
            let rawResponse = String(data: data, encoding: .utf8) ?? "Unable to read response"
            print("📝 Reviews decode error for location \(locationId): \(error)")
            print("📝 Raw response: \(rawResponse)")
            return []
        }
    }
}
