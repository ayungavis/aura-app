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

  // MARK: - State

  @StateObject private var viewModel: ListViewModel
  @State private var showFunFactAlert = false
  @State private var isTransitioning = false
  @Namespace private var animation

  init(category: String) {
    self.category = category
    _viewModel = StateObject(wrappedValue: ListViewModel(category: category))
  }

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

      if viewModel.isLoading && viewModel.locations.isEmpty {
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else if let error = viewModel.error, viewModel.locations.isEmpty {
        listErrorView(error)
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
      viewModel.onAppear()
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

  // MARK: - Error View

  private func listErrorView(_ error: Error) -> some View {
    VStack(spacing: 16) {
      Spacer()
      Image(systemName: "exclamationmark.triangle.fill")
        .font(.system(size: 48))
        .foregroundStyle(.secondary)
      Text("Unable to load places")
        .font(.custom("InstrumentSans-Medium", size: 18))
      Text(error.localizedDescription)
        .font(.custom("InstrumentSans-Regular", size: 14))
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
      Button("Try Again") {
        viewModel.retry()
      }
      .buttonStyle(.bordered)
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  // MARK: - Sub-Sections

  private var placesSection: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text("Recommended places")
        .font(.custom("InstrumentSerif-Regular", size: 28))

      VStack(spacing: 8) {
        ForEach(viewModel.locations) { location in
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
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  NavigationStack {
    ListView(category: "Running")
  }
}
