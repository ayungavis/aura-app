//
//  DetailView.swift
//  AuraApp
//
//  Created by Muhammad Nurul Akbar on 16/04/26.
//
//  UPDATED: Now receives a `locationId` and fetches real data
//  from TripAdvisor (details, photos, reviews) using async/await.
//
//  WHAT CHANGED from the original:
//  - Added `locationId` parameter (passed from ListView)
//  - Added @State properties to hold fetched data
//  - Added `.task` to load data on appear
//  - Replaced hardcoded Image() with AsyncImage() for remote photos
//  - Replaced hardcoded text with data from API
//  - Used ForEach instead of copy-pasting review cards
//  - FIXED: Layout width constraints to prevent content pushing out
//

import SwiftUI

struct DetailView: View {

    // MARK: - Input
    // This is passed from ListView when the user taps a place.
    let locationId: String

    // MARK: - Service
    private let service = TripAdvisorService()

    // MARK: - State
    // These start as nil/empty and get populated when the API responds.
    // SwiftUI automatically re-renders the view when they change.
    @State private var detail: LocationDetail?
    @State private var photos: [LocationPhoto] = []
    @State private var reviews: [LocationReview] = []
    @State private var isLoading = true

    // MARK: - Body

    var body: some View {
        VStack {
            if isLoading {
                // Show a loading spinner while data is being fetched
                Spacer()
                ProgressView("Loading...")
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Top Header Image
                        headerImage

                        // Main Content
                        // We wrap the rest in a VStack with spacing so it looks consistent
                        VStack(alignment: .leading, spacing: 24) {
                            titleSection
                            photosSection
                            reviewsSection
                            detailsSection
                        }
                        .padding(.vertical, 20)
                    }
                }
                .edgesIgnoringSafeArea(.top)
            }
        }
        // MARK: - .task with async let
        // We fetch details, photos, and reviews IN PARALLEL using `async let`.
        // This is faster than fetching them one after another (sequential).
        //
        // Think of it like ordering 3 dishes at a restaurant at once,
        // instead of waiting for each dish to arrive before ordering the next.
        .task {
            await loadData()
        }
    }

    // MARK: - Header Image

    private var headerImage: some View {
        Group {
            if let firstPhoto = photos.first,
               let urlString = firstPhoto.images?.large?.url,
               let url = URL(string: urlString) {
                // AsyncImage loads an image from a URL.
                // It handles downloading, caching, and displaying automatically.
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color(UIColor.systemGray5))
                        .overlay(ProgressView())
                }
                .frame(width: UIScreen.main.bounds.width, height: 300)
                .clipped()
            } else {
                // Fallback placeholder if no photos available
                Rectangle()
                    .fill(Color(UIColor.systemGray5))
                    .frame(width: UIScreen.main.bounds.width, height: 300)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                    )
            }
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(detail?.name ?? "Unknown Place")
                .font(.title2)
                .fontWeight(.bold)

            // Show address if available
            if let address = detail?.addressObj?.addressString {
                Text(address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Show category/subcategory (e.g. "Beach", "Sport Center")
            if let subcategories = detail?.subcategory, !subcategories.isEmpty {
                Text(subcategories.compactMap { $0.localizedName }.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else if let categoryName = detail?.category?.localizedName {
                Text(categoryName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Show rating and review count
            if let rating = detail?.rating, let numReviews = detail?.numReviews {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(rating)
                        .font(.subheadline)
                    Text("(\(numReviews) reviews)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Photos Section

    private var photosSection: some View {
        VStack(alignment: .leading) {
            Text("Photos")
                .font(.headline)

            if photos.isEmpty {
                Text("No photos available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        // ForEach loops over the photos array.
                        // Each LocationPhoto has a unique `id` (Identifiable).
                        ForEach(photos) { photo in
                            if let urlString = photo.images?.large?.url,
                               let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color(UIColor.systemGray5))
                                        .overlay(ProgressView())
                                }
                                .frame(width: 160, height: 120)
                                .clipped()
                                .cornerRadius(10)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Reviews Section

    private var reviewsSection: some View {
        VStack(alignment: .leading) {
            Text("Ratings and Reviews")
                .font(.headline)

            if reviews.isEmpty {
                Text("No reviews available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        // Instead of copy-pasting the review card (like the original),
                        // we loop over the reviews array. Much cleaner!
                        ForEach(reviews) { review in
                            ReviewCardView(review: review)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.headline)

            VStack(spacing: 12) {
                if let phone = detail?.phone, !phone.isEmpty {
                    ContactRowView(title: "Phone", value: phone)
                }
                if let website = detail?.website, !website.isEmpty {
                    ContactRowView(title: "Website", value: website)
                }

                // Build the address string from address components
                if let addr = detail?.addressObj {
                    let addressParts = [
                        addr.street1,
                        addr.city,
                        addr.state,
                        addr.country
                    ].compactMap { $0 }  // compactMap removes nil values

                    if !addressParts.isEmpty {
                        ContactRowView(
                            title: "Address",
                            value: addressParts.joined(separator: "\n")
                        )
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Load Data
    // Fetches detail, photos, and reviews one after another (sequentially).
    // We keep it simple here — sequential fetching avoids Swift concurrency
    // issues with @MainActor and Sendable that `async let` can cause.

    private func loadData() async {
        isLoading = true

        do {
            detail = try await service.getLocationDetails(locationId: locationId)
        } catch {
            print("Error loading detail: \(error)")
        }

        do {
            photos = try await service.getLocationPhotos(locationId: locationId)
        } catch {
            print("Error loading photos: \(error)")
        }

        do {
            reviews = try await service.getLocationReviews(locationId: locationId)
        } catch {
            print("Error loading reviews: \(error)")
        }

        isLoading = false
    }
}

// MARK: - Review Card View
// Extracted from the original DetailView's duplicated review cards.
// Now it's reusable and driven by data instead of hardcoded text.

struct ReviewCardView: View {
    let review: LocationReview

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Review text
            Text(review.text ?? "No review text")
                .font(.footnote)
                .foregroundColor(.primary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                // User avatar (generic — TripAdvisor doesn't give us profile pics)
                Circle()
                    .fill(Color.black)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    // Star rating
                    HStack(spacing: 2) {
                        // Using Array() because ForEach requires a constant range.
                        // 0..<(variable) is computed at runtime and will crash.
                        // max(0, ...) prevents negative ranges.
                        ForEach(Array(0..<max(0, review.rating ?? 0)), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .resizable()
                                .frame(width: 8, height: 8)
                                .foregroundColor(.yellow)
                        }
                    }

                    // Username and date
                    Text("\(review.user?.username ?? "Anonymous") • \(formattedDate(review.publishedDate))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .frame(width: 220, alignment: .topLeading)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }

    /// Formats the ISO date string into a more readable format
    private func formattedDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "" }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // Try parsing with fractional seconds first, then without
        if let date = isoFormatter.date(from: dateString) {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return formatter.localizedString(for: date, relativeTo: Date())
        }

        // Fallback: try without fractional seconds
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return formatter.localizedString(for: date, relativeTo: Date())
        }

        return dateString  // Return raw string if parsing fails
    }
}

// The ContactRowView stays exactly the same as your original
struct ContactRowView: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    NavigationStack {
        // Preview with a sample TripAdvisor location ID for Kuta Beach
        DetailView(locationId: "3399541")
    }
}
