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

    // The category passed from the home page (e.g. "Running", "Biking")
    // For now we hardcode a default value for testing.
    let category: String

    // The service object that handles API calls
    private let service = TripAdvisorService()

    // MARK: - State
    // @State means SwiftUI will re-render the view whenever these values change.
    // When `locations` goes from empty → populated, the list automatically updates.
    @State private var locations: [LocationItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // ── Header Section ──
                // Shows the category name and weather info (hardcoded for now)
                headerSection

                // ── Fun Fact Card ──
                funFactCard

                // ── Recommended Places ──
                placesSection
            }
            .padding(.horizontal)
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.inline)
        // MARK: - .task modifier
        // `.task` runs an async function when the view first appears.
        // This is the SwiftUI way to load data — it's automatically cancelled
        // if the view disappears before the data loads.
        .task {
            await loadLocations()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                // Category icon
                Image(systemName: iconForCategory(category))
                    .font(.system(size: 40))
                    .foregroundColor(.primary)

                Text(category)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }

            // Weather info (hardcoded for now — your friend's home page will provide this)
            HStack(spacing: 8) {
                Image(systemName: "cloud.sun.fill")
                    .foregroundColor(.secondary)
                Text("30°")
                    .foregroundColor(.secondary)
                Text("Mostly cloudy")
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
        }
        .padding(.top)
    }

    // MARK: - Fun Fact Card

    private var funFactCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FUN FACT")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)

            Text(funFactForCategory(category))
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Places Section

    private var placesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recommended Places")
                .font(.headline)

            if isLoading {
                // Show a spinner while loading
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
            } else if let error = errorMessage {
                // Show error message if something went wrong
                Text(error)
                    .foregroundColor(.red)
                    .font(.subheadline)
            } else {
                // MARK: - Place Rows
                // ForEach loops over the locations array.
                // Because LocationItem conforms to Identifiable (using locationId),
                // SwiftUI can efficiently track each row.
                ForEach(locations) { location in
                    // NavigationLink makes the row tappable.
                    // When tapped, it pushes DetailView onto the navigation stack,
                    // passing the locationId so DetailView can fetch its own data.
                    NavigationLink(destination: DetailView(locationId: location.locationId)) {
                        PlaceRowView(location: location)
                    }
                    .buttonStyle(.plain) // Removes the default blue tint

                    // Add a divider between rows (but not after the last one)
                    if location.id != locations.last?.id {
                        Divider()
                    }
                }
            }
        }
    }

    // MARK: - Load Data

    private func loadLocations() async {
        isLoading = true
        errorMessage = nil

        do {
            // For now, we hardcode the search query.
            // Later, this will use the category + user location.
            locations = try await service.searchLocations(
                query: "beach Bali",
                category: "attractions"
            )
        } catch {
            errorMessage = "Failed to load places. Please try again."
            print("Search error: \(error)")  // Print to Xcode console for debugging
        }

        isLoading = false
    }

    // MARK: - Helpers

    /// Maps a category name to an SF Symbol icon
    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "running": return "figure.run"
        case "biking": return "figure.outdoor.cycle"
        case "swimming": return "figure.pool.swim"
        case "hiking": return "figure.hiking"
        default: return "mappin.circle.fill"
        }
    }

    /// Returns a fun fact string based on the category
    private func funFactForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "running":
            return "Running 5km a day will make your life longer 10%"
        case "biking":
            return "Cycling for 30 minutes can burn up to 300 calories"
        default:
            return "Outdoor activities can boost your mood and reduce stress"
        }
    }
}

// MARK: - Place Row View
// A reusable row component showing a single place in the list.
// Separated into its own struct to keep the code organized.

struct PlaceRowView: View {
    let location: LocationItem

    var body: some View {
        HStack(spacing: 12) {
            // Placeholder image
            // TripAdvisor's search endpoint doesn't return photos,
            // so we show a placeholder. The detail page will have real photos.
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.systemGray5))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.secondary)
                )

            // Place info
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                // Show address if available
                if let address = location.addressObj?.addressString {
                    Text(address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Chevron to indicate it's tappable
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
// Previews let you see the UI in Xcode's canvas without running the app.
// We wrap in NavigationStack because the view expects to be inside one.

#Preview {
    NavigationStack {
        ListView(category: "Running")
    }
}

