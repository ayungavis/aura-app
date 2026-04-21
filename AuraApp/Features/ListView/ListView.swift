//
//  ListView.swift
//  AuraApp
//
//  The list page that shows recommended places for a given category.
//  Matches the "List Page" wireframe design.
//

import SwiftUI

struct ListView: View {

    // MARK: - Properties
    let category: String
    private let service = TripAdvisorService()

    // MARK: - State
    @State private var locations: [LocationItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showFunFactAlert = false

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            // Background color
            Color(red: 250/255, green: 250/255, blue: 250/255).edgesIgnoringSafeArea(.all)

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .center, spacing: 32) {
                        
                        // 1. Hero Activity Image
                        HeroSection(category: category)
                            .padding(.top, 40)

                        // 2. Title & Metrics
                        VStack(spacing: 8) {
                            Text(category)
                                .font(.custom("InstrumentSerif-Regular", size: 44))
                                .multilineTextAlignment(.center)
                            
                            MetricsRow()
                        }

                        // 3. Fun Fact Card
                        FunFactSection(category: category, showFunFactAlert: $showFunFactAlert)

                        // 4. Recommended Places
                        placesSection
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .overlay(FunFactAlert(showFunFactAlert: $showFunFactAlert))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
        .task {
            await loadLocations()
        }
    }

    // MARK: - Sub-Sections

    private var placesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Recommended places")
                .font(.custom("InstrumentSerif-Regular", size: 28))
            
            VStack(spacing: 8) {
                if let error = errorMessage {
                    Text(error).foregroundColor(.red).font(.caption)
                } else {
                    ForEach(locations) { location in
                        NavigationLink(destination: DetailView(locationId: location.locationId)) {
                            PlaceRow(location: location)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Load Data

    private func loadLocations() async {
        isLoading = true
        errorMessage = nil

        do {
            locations = try await service.searchLocations(
                query: category + " Bali",
                latLong: "-8.717,115.174", // Kuta, Bali
                category: "attractions"
            )
            isLoading = false
            await fetchImagesForLocations()
        } catch {
            errorMessage = "Failed to load places."
            print("Search error: \(error)")
            isLoading = false
        }
    }

    private func fetchImagesForLocations() async {
        for index in locations.indices {
            let locationId = locations[index].locationId
            do {
                if let firstPhoto = try await service.getLocationPhotos(locationId: locationId).first {
                    locations[index].imageUrl = firstPhoto.images?.medium?.url
                }
            } catch {
                print("📸 Error fetching photo for \(locationId): \(error)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ListView(category: "Running")
    }
}
