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
  @State private var isTransitioning = false
  @Namespace private var animation
  
  // MARK: - Body
  
  var body: some View {
    ZStack(alignment: .top) {
      // Background color
      Color(red: 250/255, green: 250/255, blue: 250/255).edgesIgnoringSafeArea(.all)
      
      // Dither Effect Background
      ZStack(alignment: .top) {
        Image("effect-dithered")
          .resizable()
          .scaledToFill()
          .frame(height: 350)
          .clipped()
        
        LinearGradient(
          gradient: Gradient(colors: [
            Color(red: 250/255, green: 250/255, blue: 250/255).opacity(0),
            Color(red: 250/255, green: 250/255, blue: 250/255)
          ]),
          startPoint: .top,
          endPoint: .bottom
        )
        .frame(height: 350)
      }
      .ignoresSafeArea()
      .allowsHitTesting(false)
      
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
        .scrollDisabled(isTransitioning)
      }
    }
    .overlay(FunFactAlert(showFunFactAlert: $showFunFactAlert))
    .task {
      await loadLocations()
    }
    .onAppear {
      // Lock scrolling briefly ONLY when returning to the list
      isTransitioning = true
      Task {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        isTransitioning = false
      }
    }
    .onDisappear {
      // Safety net: ensure scroll is always unlocked when leaving the view
      isTransitioning = false
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
            NavigationLink(destination: DetailView(locationId: location.locationId, distance: location.distance, initialImageUrl: location.imageUrl, animation: animation)) {
              PlaceRow(location: location, animation: animation)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded {
              // Lock scrolling immediately on tap
              isTransitioning = true
              
              // Safety Timeout: If navigation fails to trigger, unlock after 1.5s
              Task {
                try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5s
                // Only reset if we haven't already navigated away
                if isTransitioning {
                  isTransitioning = false
                }
              }
            })
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
      let fetchedLocations = try await service.searchLocations(
        query: category + " Bali",
        latLong: "-8.717,115.174", // Kuta, Bali
        category: "attractions"
      )
      
      // Sort by distance (nearest first)
      // If distance is missing, place at the end
      locations = fetchedLocations.sorted {
        let d1 = Double($0.distance ?? "") ?? Double.infinity
        let d2 = Double($1.distance ?? "") ?? Double.infinity
        return d1 < d2
      }
      
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
          locations[index].imageUrl = firstPhoto.images?.large?.url
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
