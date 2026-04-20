//
//  Models.swift
//  AuraApp
//
//  Data models that match the TripAdvisor Content API JSON responses.
//  All models use `Codable` so Swift can automatically decode JSON into these structs.
//

import Foundation

// MARK: - Location Search Response
// API: GET /location/search
// Returns a list of locations matching a search query.

/// The top-level wrapper — the API returns `{ "data": [...] }`
struct LocationSearchResponse: Codable {
    let data: [LocationItem]
}

/// Each location in the search results.
/// We only decode the fields we actually need — extra JSON fields are safely ignored.
struct LocationItem: Codable, Identifiable {
    let locationId: String       // Unique ID on TripAdvisor (e.g. "258730")
    let name: String             // Place name (e.g. "Kuta Beach")
    let addressObj: AddressObj?  // Address info (optional — not always present)

    // MARK: - CodingKeys
    // The API uses snake_case (e.g. "location_id") but Swift convention is camelCase.
    // CodingKeys tells Swift how to map between the two.
    enum CodingKeys: String, CodingKey {
        case locationId = "location_id"
        case name
        case addressObj = "address_obj"
    }

    // MARK: - Identifiable
    // SwiftUI's `ForEach` and `List` need each item to have a unique `id`.
    // We use the TripAdvisor `locationId` as our identifier.
    var id: String { locationId }
}

/// Address information for a location.
struct AddressObj: Codable {
    let street1: String?
    let street2: String?
    let city: String?
    let state: String?
    let country: String?
    let postalcode: String?
    let addressString: String?  // A pre-formatted full address

    enum CodingKeys: String, CodingKey {
        case street1, street2, city, state, country, postalcode
        case addressString = "address_string"
    }
}

// MARK: - Location Details Response
// API: GET /location/{id}/details
// Returns comprehensive info about a single location.

struct LocationDetail: Codable {
    let locationId: String?
    let name: String?
    let description: String?
    let webUrl: String?          // Link to TripAdvisor page
    let addressObj: AddressObj?
    let rating: String?          // e.g. "4.5" (it's a String in the API!)
    let numReviews: String?      // e.g. "1250" (also a String)
    let phone: String?
    let website: String?         // The place's own website
    let category: Category?
    let subcategory: [Subcategory]?
    let photoCount: String?

    enum CodingKeys: String, CodingKey {
        case locationId = "location_id"
        case name, description
        case webUrl = "web_url"
        case addressObj = "address_obj"
        case rating
        case numReviews = "num_reviews"
        case phone, website, category, subcategory
        case photoCount = "photo_count"
    }
}

struct Category: Codable {
    let name: String?
    let localizedName: String?

    enum CodingKeys: String, CodingKey {
        case name
        case localizedName = "localized_name"
    }
}

struct Subcategory: Codable {
    let name: String?
    let localizedName: String?

    enum CodingKeys: String, CodingKey {
        case name
        case localizedName = "localized_name"
    }
}

// MARK: - Location Photos Response
// API: GET /location/{id}/photos
// Returns up to 5 recent photos.

struct LocationPhotosResponse: Codable {
    let data: [LocationPhoto]
}

/// Each photo has multiple sizes (thumbnail, small, medium, large, original).
struct LocationPhoto: Codable, Identifiable {
    let id: Int
    let images: PhotoImages?
    let caption: String?
}

/// Container for the different image sizes TripAdvisor provides.
struct PhotoImages: Codable {
    let thumbnail: PhotoSize?
    let small: PhotoSize?
    let medium: PhotoSize?
    let large: PhotoSize?
    let original: PhotoSize?
}

/// A single image size with its URL and dimensions.
/// Note: The API returns width/height as integers, not strings!
struct PhotoSize: Codable {
    let url: String?
    let width: Int?
    let height: Int?
}

// MARK: - Location Reviews Response
// API: GET /location/{id}/reviews
// Returns up to 5 most recent reviews.

struct LocationReviewsResponse: Codable {
    let data: [LocationReview]
}

struct LocationReview: Codable, Identifiable {
    let id: Int
    let title: String?
    let text: String?
    let rating: Int?
    let publishedDate: String?
    let user: ReviewUser?

    enum CodingKeys: String, CodingKey {
        case id, title, text, rating
        case publishedDate = "published_date"
        case user
    }
}

struct ReviewUser: Codable {
    let username: String?
    let userLocation: UserLocation?

    enum CodingKeys: String, CodingKey {
        case username
        case userLocation = "user_location"
    }
}

struct UserLocation: Codable {
    let name: String?
}
