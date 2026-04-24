//
//  TripAdvisorService.swift
//  AuraApp
//
//  Handles all communication with the TripAdvisor Content API.
//

import Foundation

class TripAdvisorService: TripAdvisorServiceProtocol {
  private let baseURL = "https://api.content.tripadvisor.com/api/v1"
  private let cache = LocalCache.shared

  func searchLocations(
    query: String,
    latLong: String? = nil,
    category: String? = nil
  ) async throws -> [LocationItem] {
    let cacheKey = "search_\(query)_\(latLong ?? "none")_\(category ?? "none")"
    if let cachedData = cache.load(key: cacheKey, as: [LocationItem].self) {
      AppLogger.cacheHit(cacheKey)
      return cachedData
    }

    var components = URLComponents(string: "\(baseURL)/location/search")!
    var queryItems = [
      URLQueryItem(name: "key", value: AppConfig.tripAdvisorAPIKey),
      URLQueryItem(name: "searchQuery", value: query),
      URLQueryItem(name: "language", value: "en"),
    ]

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

    AppLogger.networkRequest("searchLocations: \(query)")
    let (data, response) = try await URLSession.shared.data(from: url)
    let statusCode = (response as? HTTPURLResponse)?.statusCode
    AppLogger.networkResponse("searchLocations", statusCode: statusCode)

    let result = try JSONDecoder().decode(LocationSearchResponse.self, from: data)
    cache.save(result.data, key: cacheKey)
    AppLogger.cacheSave(cacheKey)

    return result.data
  }

  func getLocationDetails(locationId: String) async throws -> LocationDetail {
    let cacheKey = "details_\(locationId)"
    if let cachedData = cache.load(key: cacheKey, as: LocationDetail.self) {
      AppLogger.cacheHit(cacheKey)
      return cachedData
    }

    var components = URLComponents(string: "\(baseURL)/location/\(locationId)/details")!
    components.queryItems = [
      URLQueryItem(name: "key", value: AppConfig.tripAdvisorAPIKey),
      URLQueryItem(name: "language", value: "en"),
    ]

    guard let url = components.url else {
      throw URLError(.badURL)
    }

    AppLogger.networkRequest("locationDetails: \(locationId)")
    let (data, response) = try await URLSession.shared.data(from: url)
    AppLogger.networkResponse("locationDetails", statusCode: (response as? HTTPURLResponse)?.statusCode)

    let result = try JSONDecoder().decode(LocationDetail.self, from: data)
    cache.save(result, key: cacheKey)
    AppLogger.cacheSave(cacheKey)

    return result
  }

  func getLocationPhotos(locationId: String) async throws -> [LocationPhoto] {
    let cacheKey = "photos_\(locationId)"
    if let cachedData = cache.load(key: cacheKey, as: [LocationPhoto].self) {
      AppLogger.cacheHit(cacheKey)
      return cachedData
    }

    var components = URLComponents(string: "\(baseURL)/location/\(locationId)/photos")!
    components.queryItems = [
      URLQueryItem(name: "key", value: AppConfig.tripAdvisorAPIKey),
      URLQueryItem(name: "language", value: "en"),
      URLQueryItem(name: "limit", value: "5"),
    ]

    guard let url = components.url else {
      throw URLError(.badURL)
    }

    AppLogger.networkRequest("locationPhotos: \(locationId)")
    let (data, response) = try await URLSession.shared.data(from: url)
    AppLogger.networkResponse("locationPhotos", statusCode: (response as? HTTPURLResponse)?.statusCode)

    do {
      let result = try JSONDecoder().decode(LocationPhotosResponse.self, from: data)
      cache.save(result.data, key: cacheKey)
      AppLogger.cacheSave(cacheKey)
      return result.data
    } catch {
      AppLogger.networkError("photos_decode_\(locationId)", error: error)
      throw error
    }
  }

  func getLocationReviews(locationId: String) async throws -> [LocationReview] {
    let cacheKey = "reviews_\(locationId)"
    if let cachedData = cache.load(key: cacheKey, as: [LocationReview].self) {
      AppLogger.cacheHit(cacheKey)
      return cachedData
    }

    var components = URLComponents(string: "\(baseURL)/location/\(locationId)/reviews")!
    components.queryItems = [
      URLQueryItem(name: "key", value: AppConfig.tripAdvisorAPIKey),
      URLQueryItem(name: "language", value: "en"),
      URLQueryItem(name: "limit", value: "5"),
    ]

    guard let url = components.url else {
      throw URLError(.badURL)
    }

    AppLogger.networkRequest("locationReviews: \(locationId)")
    let (data, response) = try await URLSession.shared.data(from: url)
    AppLogger.networkResponse("locationReviews", statusCode: (response as? HTTPURLResponse)?.statusCode)

    do {
      let result = try JSONDecoder().decode(LocationReviewsResponse.self, from: data)
      cache.save(result.data, key: cacheKey)
      AppLogger.cacheSave(cacheKey)
      return result.data
    } catch {
      AppLogger.networkError("reviews_decode_\(locationId)", error: error)
      throw error
    }
  }
}
