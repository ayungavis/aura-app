//
//  ListView.swift
//  AuraApp
//
//  The list page that shows recommended places for a given category.
//  Matches the "List Page" wireframe design.
//
//  FLOW:
//  1. This view receives a `category` (e.g. "Running") from the home page
//  2. On appear, it calls TripAdvisor's search API to get a list of places
//  3. Each place row is tappable — navigates to DetailView with the locationId
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
                        heroSection
                            .padding(.top, 40)

                        // 2. Title & Metrics
                        VStack(spacing: 8) {
                            Text(category)
                                .font(.custom("InstrumentSerif-Regular", size: 44))
                                .multilineTextAlignment(.center)
                            
                            metricsRow
                        }

                        // 3. Fun Fact Card
                        funFactSection

                        // 4. Recommended Places
                        placesSection
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { /* Add back action */ }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
            }
        }
        .task {
            await loadLocations()
        }
    }

    // MARK: - Components

    private var heroSection: some View {
        // We use a placeholder image for the activity
        // In a real app, this would be an image representing "Running", "Hiking", etc.
        Image(systemName: iconForCategory(category))
            .font(.system(size: 80))
            .foregroundColor(.black.opacity(0.8))
            .frame(width: 240, height: 240)
            .background(
                Rectangle()
                    .fill(Color(UIColor.systemGray5))
                    .overlay(
                        // Simulate the grainy/textured background from design
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .opacity(0.1)
                    )
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    private var metricsRow: some View {
        VStack(spacing: 4) {
            Text("6 km / 60 mins")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Label("8 km/h", systemImage: "speedometer")
                Label("30°", systemImage: "sun.max")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }

    private var funFactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Fun fact")
                    .font(.custom("InstrumentSerif-Regular", size: 24))
                Image(systemName: "info.circle")
                    .font(.caption)
            }
            
            Text(funFactForCategory(category))
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }

    private var placesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Recommended places")
                .font(.custom("InstrumentSerif-Regular", size: 28))
            
            VStack(spacing: 16) {
                if let error = errorMessage {
                    Text(error).foregroundColor(.red).font(.caption)
                } else {
                    ForEach(locations) { location in
                        NavigationLink(destination: DetailView(locationId: location.locationId)) {
                            RecommendedPlaceRow(location: location)
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
            // Search based on category
            locations = try await service.searchLocations(
                query: category + " Bali",
                category: "attractions"
            )
        } catch {
            errorMessage = "Failed to load places."
            print("Search error: \(error)")
        }

        isLoading = false
    }

    // MARK: - Helpers

    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "running": return "figure.run"
        case "biking": return "figure.outdoor.cycle"
        case "swimming": return "figure.pool.swim"
        case "hiking": return "figure.hiking"
        default: return "mappin.circle.fill"
        }
    }

    private func funFactForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "running":
            return "Running can boost your mood fast. Your body releases endorphins that help you feel good."
        case "biking":
            return "Cycling for 30 minutes can burn up to 300 calories and improves heart health."
        default:
            return "Outdoor activities can boost your mood and reduce stress significantly."
        }
    }
}

// MARK: - Supporting Views

struct BackButton: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
                .padding(12)
                .background(Circle().fill(Color.white).shadow(color: .black.opacity(0.1), radius: 4))
        }
    }
}

struct RecommendedPlaceRow: View {
    let location: LocationItem
    
    var body: some View {
        HStack(spacing: 16) {
            // Square thumbnail
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.systemGray5))
                .frame(width: 80, height: 80)
                .overlay(Image(systemName: "photo").foregroundColor(.secondary))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if let address = location.addressObj?.addressString {
                    Text(address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                HStack {
                    Text("4.8 km • 10 mins")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 8))
                        Text("4.8 (1k+ reviews)")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ListView(category: "Running")
    }
}
