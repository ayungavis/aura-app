//
//  ListView.swift
//  AuraApp
//
//  The list page that shows recommended places for a given category.
//  Matches the "List Page" wireframe design.
//

import SwiftUI

struct ListView: View {

    let category: String
    @StateObject private var viewModel: ListViewModel

    init(category: String, service: TripAdvisorServiceProtocol = TripAdvisorService()) {
        self.category = category
        self._viewModel = StateObject(wrappedValue: ListViewModel(service: service))
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 250/255, green: 250/255, blue: 250/255).edgesIgnoringSafeArea(.all)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .center, spacing: 32) {

                        HeroSection(category: category)
                            .padding(.top, 40)

                        VStack(spacing: 8) {
                            Text(category)
                                .font(.custom("InstrumentSerif-Regular", size: 44))
                                .multilineTextAlignment(.center)

                            MetricsRow()
                        }

                        FunFactSection(category: category, showFunFactAlert: $showFunFactAlert)

                        placesSection

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .overlay(FunFactAlert(showFunFactAlert: $showFunFactAlert))
        .task {
            await viewModel.loadLocations(category: category)
        }
    }

    // MARK: - Private State

    @State private var showFunFactAlert = false

    // MARK: - Sub-Sections

    private var placesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Recommended places")
                .font(.custom("InstrumentSerif-Regular", size: 28))

            VStack(spacing: 8) {
                if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Text(error).foregroundColor(.red).font(.caption)
                        Button("Retry") {
                            Task { await viewModel.loadLocations(category: category) }
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    ForEach(viewModel.locations) { location in
                        NavigationLink(destination: DetailView(locationId: location.locationId, distance: location.distance)) {
                            PlaceRow(location: location)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        ListView(category: "Running")
    }
}
