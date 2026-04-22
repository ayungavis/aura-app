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
    var distance: String? = nil

    // MARK: - Service
    private let service = TripAdvisorService()

    // MARK: - State
    @State private var detail: LocationDetail?
    @State private var photos: [LocationPhoto] = []
    @State private var reviews: [LocationReview] = []
    @State private var isLoading = true

    // MARK: - Body

    var body: some View {
        ZStack {
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
                            VStack(alignment: .leading, spacing: 32) {
                                TitleSection(detail: detail, distance: distance)
                                PhotosSection(photos: photos)
                                ReviewsSection(reviews: reviews, webUrl: detail?.webUrl)
                                DetailsSection(detail: detail)
                            }
                            .padding(.vertical, 20)
                            .padding(.bottom, 80) // Space for sticky button
                        }
                    }
                    .edgesIgnoringSafeArea(.top)
                }
            }
            
            if !isLoading {
                // Sticky Bottom Button
                VStack {
                    Spacer()
                    Button(action: openMaps) {
                        HStack {
                            Image(systemName: "location.fill") // Using location arrow for directions
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
                if !isLoading {
                    TopRightActions(detail: detail, openMapsAction: openMaps)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
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
    
    private func openMaps() {
        let name = detail?.name ?? ""
        let address = detail?.addressObj?.addressString ?? ""
        let query = [name, address].filter { !$0.isEmpty }.joined(separator: ", ")
        
        if let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "http://maps.apple.com/?q=\(encoded)") {
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
                    .contentShape(Rectangle()) // Ensures tap area is correct
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
