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

    // Base URL for all TripAdvisor Content API requests
    private let baseURL = "https://api.content.tripadvisor.com/api/v1"
    
    // Cache service to save costs and improve speed
    private let cache = LocalCache.shared

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

        // 1. Check Cache first
        let cacheKey = "search_\(query)_\(latLong ?? "none")_\(category ?? "none")"
        if let cachedData = cache.load(key: cacheKey, as: [LocationItem].self) {
            print("📦 CACHE HIT: Results for query '\(query)'")
            return cachedData
        }

        // 2. Not in cache, build URL
        var components = URLComponents(string: "\(baseURL)/location/search")!
        var queryItems = [
            URLQueryItem(name: "key", value: Config.tripAdvisorAPIKey),
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

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        // 3. Fetch from Network
        print("🌐 NETWORK CALL: Searching for '\(query)'")
        let (data, _) = try await URLSession.shared.data(from: url)

        // Debug: print raw response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("🔍 Search Results Raw JSON: \(jsonString)")
        }

        // JSONDecoder converts the raw JSON bytes into our Swift struct.
        let result = try JSONDecoder().decode(LocationSearchResponse.self, from: data)
        
        // 4. Save to Cache for next time
        cache.save(result.data, key: cacheKey)
        
        return result.data
    }

    // MARK: - 2. Get Location Details
    // Fetches comprehensive info about a single location.
    //
    // API docs: https://tripadvisor-content-api.readme.io/reference/getlocationdetails
    func getLocationDetails(locationId: String) async throws -> LocationDetail {
        // 1. Check Cache
        let cacheKey = "details_\(locationId)"
        if let cachedData = cache.load(key: cacheKey, as: LocationDetail.self) {
            print("📦 CACHE HIT: Details for \(locationId)")
            return cachedData
        }

        var components = URLComponents(string: "\(baseURL)/location/\(locationId)/details")!
        components.queryItems = [
            URLQueryItem(name: "key", value: Config.tripAdvisorAPIKey),
            URLQueryItem(name: "language", value: "en"),
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        print("🌐 NETWORK CALL: Getting details for \(locationId)")
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Debug: print raw response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("ℹ️ Location Details Raw JSON for \(locationId): \(jsonString)")
        }

        let result = try JSONDecoder().decode(LocationDetail.self, from: data)
        
        // 2. Save to Cache
        cache.save(result, key: cacheKey)
        
        return result
    }

    // MARK: - 3. Get Location Photos
    // Fetches up to 5 recent photos for a location.
    //
    // API docs: https://tripadvisor-content-api.readme.io/reference/getlocationphotos
    func getLocationPhotos(locationId: String) async throws -> [LocationPhoto] {
        // 1. Check Cache
        let cacheKey = "photos_\(locationId)"
        if let cachedData = cache.load(key: cacheKey, as: [LocationPhoto].self) {
            print("📦 CACHE HIT: Photos for \(locationId)")
            return cachedData
        }

        var components = URLComponents(string: "\(baseURL)/location/\(locationId)/photos")!
        components.queryItems = [
            URLQueryItem(name: "key", value: Config.tripAdvisorAPIKey),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "limit", value: "5"),
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        print("🌐 NETWORK CALL: Getting photos for \(locationId)")
        let (data, _) = try await URLSession.shared.data(from: url)

        // Debug: print raw response if decoding fails
        do {
            let result = try JSONDecoder().decode(LocationPhotosResponse.self, from: data)
            
            // 2. Save to Cache
            cache.save(result.data, key: cacheKey)
            
            return result.data
        } catch {
            let rawResponse = String(data: data, encoding: .utf8) ?? "Unable to read response"
            print("📸 Photos decode error for location \(locationId): \(error)")
            print("📸 Raw response: \(rawResponse)")
            return []  // Return empty array so the page still shows
        }
    }

    // MARK: - 4. Get Location Reviews
    // Fetches up to 5 most recent reviews for a location.
    //
    // API docs: https://tripadvisor-content-api.readme.io/reference/getlocationreviews
    func getLocationReviews(locationId: String) async throws -> [LocationReview] {
        // 1. Check Cache
        let cacheKey = "reviews_\(locationId)"
        if let cachedData = cache.load(key: cacheKey, as: [LocationReview].self) {
            print("📦 CACHE HIT: Reviews for \(locationId)")
            return cachedData
        }

        var components = URLComponents(string: "\(baseURL)/location/\(locationId)/reviews")!
        components.queryItems = [
            URLQueryItem(name: "key", value: Config.tripAdvisorAPIKey),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "limit", value: "5"),
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        print("🌐 NETWORK CALL: Getting reviews for \(locationId)")
        let (data, _) = try await URLSession.shared.data(from: url)

        // Same resilient decoding pattern as photos
        do {
            let result = try JSONDecoder().decode(LocationReviewsResponse.self, from: data)
            
            // 2. Save to Cache
            cache.save(result.data, key: cacheKey)
            
            return result.data
        } catch {
            let rawResponse = String(data: data, encoding: .utf8) ?? "Unable to read response"
            print("📝 Reviews decode error for location \(locationId): \(error)")
            print("📝 Raw response: \(rawResponse)")
            return []
        }
    }
}
