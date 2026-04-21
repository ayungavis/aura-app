//
//  DetailView.swift
//  AuraApp
//
//  Created by Muhammad Nurul Akbar on 16/04/26.
//
//  UPDATED: Now receives a `locationId` and fetches real data
//  from TripAdvisor (details, photos, reviews) using async/await.
//

import SwiftUI

struct DetailView: View {

    // MARK: - Input
    let locationId: String

    // MARK: - Service
    private let service = TripAdvisorService()

    // MARK: - State
    @State private var detail: LocationDetail?
    @State private var photos: [LocationPhoto] = []
    @State private var reviews: [LocationReview] = []
    @State private var isLoading = true

    // MARK: - Body

    var body: some View {
        VStack {
            if isLoading {
                Spacer()
                ProgressView("Loading...")
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Top Header Image
                        HeaderImage(photos: photos)

                        // Main Content
                        VStack(alignment: .leading, spacing: 24) {
                            TitleSection(detail: detail)
                            PhotosSection(photos: photos)
                            ReviewsSection(reviews: reviews)
                            DetailsSection(detail: detail)
                        }
                        .padding(.vertical, 20)
                    }
                }
                .edgesIgnoringSafeArea(.top)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
        .task {
            await loadData()
        }
    }

    // MARK: - Load Data

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

#Preview {
    NavigationStack {
        DetailView(locationId: "3399541")
    }
}
