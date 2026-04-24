//
//  DetailView.swift
//  AuraApp
//
//  Created by Muhammad Nurul Akbar on 16/04/26.
//

import SwiftUI

struct DetailView: View {

    let locationId: String
    var distance: String? = nil

    @State private var detail: LocationDetail?
    @State private var photos: [LocationPhoto] = []
    @State private var reviews: [LocationReview] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    private let service: TripAdvisorServiceProtocol

    init(locationId: String, distance: String? = nil, service: TripAdvisorServiceProtocol = TripAdvisorService()) {
        self.locationId = locationId
        self.distance = distance
        self.service = service
    }

    var body: some View {
        ZStack {
            VStack {
                if isLoading {
                    Spacer()
                    ProgressView("Loading...")
                    Spacer()
                } else if let error = errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text(error)
                            .font(.custom("InstrumentSans-Regular", size: 14))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Button("Retry") {
                            Task { await loadData() }
                        }
                        .buttonStyle(.bordered)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            HeaderImage(photos: photos)

                            VStack(alignment: .leading, spacing: 32) {
                                TitleSection(detail: detail, distance: distance)
                                PhotosSection(photos: photos, photoCount: detail?.photoCount, webUrl: detail?.webUrl)
                                ReviewsSection(reviews: reviews, numReviews: detail?.numReviews, webUrl: detail?.webUrl)
                                DetailsSection(detail: detail)
                            }
                            .padding(.vertical, 20)
                            .padding(.bottom, 80)
                        }
                    }
                    .edgesIgnoringSafeArea(.top)
                }
            }

            if !isLoading && errorMessage == nil {
                VStack {
                    Spacer()
                    Button(action: openMaps) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Get directions")
                                .font(.custom("InstrumentSans-SemiBold", size: 16))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
        }
        .task {
            await loadData()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !isLoading && errorMessage == nil {
                    TopRightActions(detail: detail, openMapsAction: openMaps)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            detail = try await service.getLocationDetails(locationId: locationId)
        } catch {
            AppLogger.networkError("details_\(locationId)", error: error)
        }

        do {
            photos = try await service.getLocationPhotos(locationId: locationId)
        } catch {
            AppLogger.networkError("photos_\(locationId)", error: error)
        }

        do {
            reviews = try await service.getLocationReviews(locationId: locationId)
        } catch {
            AppLogger.networkError("reviews_\(locationId)", error: error)
        }

        if detail == nil && photos.isEmpty && reviews.isEmpty {
            errorMessage = "Failed to load place details."
        }

        isLoading = false
    }

    private func openMaps() {
        let name = detail?.name ?? ""
        let address = detail?.addressObj?.addressString ?? ""
        let query = [name, address].filter { !$0.isEmpty }.joined(separator: ", ")

        if let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "https://maps.apple.com/?q=\(encoded)") {
            UIApplication.shared.open(url)
        }
    }
}

struct TopRightActions: View {
    let detail: LocationDetail?
    let openMapsAction: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            Button(action: openMapsAction) {
                Image(systemName: "location")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }

            Menu {
                if let phone = detail?.phone, !phone.isEmpty {
                    let cleanPhone = phone.filter { "0123456789+".contains($0) }
                    if let url = URL(string: "tel://\(cleanPhone)") {
                        Link(destination: url) {
                            Label("Call", systemImage: "phone")
                        }
                    }
                }

                if let website = detail?.website, !website.isEmpty, let url = URL(string: website) {
                    Link(destination: url) {
                        Label("Open website", systemImage: "globe")
                    }
                }

                if let webUrl = detail?.webUrl, !webUrl.isEmpty, let url = URL(string: webUrl) {
                    ShareLink(item: url) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                    .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview {
    NavigationStack {
        DetailView(locationId: "3399541")
    }
}
