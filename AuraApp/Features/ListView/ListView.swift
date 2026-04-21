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
        .overlay(funFactAlertOverlay)
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
                
                Button(action: {
                    showFunFactAlert = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            Text(funFactForCategory(category))
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }

    private var funFactAlertOverlay: some View {
        ZStack {
            if showFunFactAlert {
                // Dimmed background
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .onTapGesture {
                        showFunFactAlert = false
                    }
                
                // Alert Box
                VStack(alignment: .leading, spacing: 16) {
                    Text("Fun Fact Notice")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("This fun fact is randomly generated from publicly available internet sources and may vary in accuracy.")
                            .font(.body)
                        
                        Text("Enjoy it as light, motivational content.")
                            .font(.body)
                    }
                    .foregroundColor(.secondary)
                    
                    Button(action: {
                        showFunFactAlert = false
                    }) {
                        Text("Got it 👌")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(25)
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 8)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.white)
                )
                .padding(.horizontal, 30)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showFunFactAlert)
    }

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
            // We pass a central Bali latLong to get actual distances
            locations = try await service.searchLocations(
                query: category + " Bali",
                latLong: "-8.717,115.174", // Kuta, Bali
                category: "attractions"
            )
            
            // Once we have text data, we can stop loading
            isLoading = false
            
            // Now fetch images for each location in the background
            await fetchImagesForLocations()
        } catch {
            errorMessage = "Failed to load places."
            print("Search error: \(error)")
            isLoading = false
        }
    }

    /// Fetches a photo for each location sequentially to avoid overloading the API
    private func fetchImagesForLocations() async {
        // Use a loop to fetch photos for each location
        for index in locations.indices {
            let locationId = locations[index].locationId
            do {
                if let firstPhoto = try await service.getLocationPhotos(locationId: locationId).first {
                    // Update the image URL in the state array
                    // This triggers a UI refresh for that specific row
                    locations[index].imageUrl = firstPhoto.images?.medium?.url
                }
            } catch {
                print("📸 Error fetching photo for \(locationId): \(error)")
            }
        }
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
            Group {
                if let imageUrl = location.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        placeholderImage
                    }
                } else {
                    placeholderImage
                }
            }
            .frame(width: 80, height: 80)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                let country = location.addressObj?.country ?? ""
                let cityName = location.addressObj?.city ?? ""
                
                // 1. Dynamic Name Trimming
                // If the name ends with the country name, trim it for a cleaner look.
                let cleanedName: String = {
                    let original = location.name
                    guard !country.isEmpty else { return original }
                    
                    // Global case-insensitive replacement of the country name
                    var result = original.replacingOccurrences(of: country, with: "", options: [.caseInsensitive])
                    
                    // Cleanup: remove double spaces, leading/trailing spaces, and stray punctuation like " - " or ", "
                    // Matches characters like hyphen, comma, or space if they are now leading/trailing or doubled
                    let cleanupPattern = "^[-,\\s]+|[-,\\s]+$|([-,\\s]){2,}"
                    if let regex = try? NSRegularExpression(pattern: cleanupPattern) {
                        let range = NSRange(location: 0, length: result.utf16.count)
                        result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$1")
                    }
                    
                    result = result.trimmingCharacters(in: .whitespacesAndNewlines)
                    return result.isEmpty ? original : result
                }()
                
                Text(cleanedName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // 2. Dynamic Address Row
                // Format: "City, Country"
                let addressParts = [cityName, country].filter { !$0.isEmpty }
                if !addressParts.isEmpty {
                    Text(addressParts.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                HStack {
                    if let distString = location.distance, let distDouble = Double(distString) {
                         // Motorcycle speed estimate: 12 km/h (traffic-adjusted average)
                         // min = (dist / 12) * 60 = dist * 5
                         let mins = Int(ceil(distDouble * 5))
                         let timeDisplay = mins > 0 ? "\(mins) mins" : "1 min"
                         
                         Text("\(String(format: "%.1f", distDouble)) km • \(timeDisplay)")
                             .font(.caption2)
                             .foregroundColor(.secondary)
                    } else {
                         Text("• 10 mins")
                             .font(.caption2)
                             .foregroundColor(.secondary)
                    }
                    
                    // Rating and reviews removed to reduce API costs (not present in search response)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .fill(Color(UIColor.systemGray5))
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(.secondary)
            )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ListView(category: "Running")
    }
}
