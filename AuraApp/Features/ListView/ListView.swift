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
  let initialImage: UIImage?
  let imageURL: URL?
  let imageName: String?
  let navigationNamespace: Namespace.ID

  // MARK: - State

  @StateObject private var viewModel: ListViewModel
  @State private var showFunFactAlert = false
  @State private var isTransitioning = false
  @Namespace private var animation

  init(category: String, initialImage: UIImage? = nil, imageURL: URL? = nil, imageName: String? = nil, navigationNamespace: Namespace.ID) {
    self.category = category
    self.initialImage = initialImage
    self.imageURL = imageURL
    self.imageName = imageName
    self.navigationNamespace = navigationNamespace
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

      ScrollView {
        VStack(alignment: .center, spacing: 32) {
          // 1. Hero Activity Image
          HeroSection(category: category, initialImage: initialImage, imageURL: imageURL, imageName: imageName)
            .padding(.top, 40)

          // 2. Title
          Text(category)
            .font(.custom("InstrumentSerif-Regular", size: 44))
            .multilineTextAlignment(.center)

          // Content Section
          ZStack {
            if viewModel.isLoading && viewModel.locations.isEmpty {
              VStack(alignment: .center, spacing: 32) {
                // Metrics Skeleton
                HStack(spacing: 24) {
                    ForEach(0..<3) { _ in
                        SkeletonView()
                            .frame(width: 60, height: 20)
                    }
                }
                
                // Fun Fact Skeleton
                SkeletonView()
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                
                // Places Skeleton
                VStack(spacing: 20) {
                    ForEach(0..<3) { _ in
                        SkeletonRow()
                    }
                }
              }
              .transition(.opacity)
            } else if let error = viewModel.error, viewModel.locations.isEmpty {
              listErrorView(error)
                .transition(.opacity)
            } else {
              VStack(alignment: .center, spacing: 32) {
                MetricsRow()
                FunFactSection(category: category, showFunFactAlert: $showFunFactAlert)
                placesSection
              }
              .transition(.opacity)
            }
          }
          .animation(.easeInOut(duration: 0.4), value: viewModel.isLoading)

          Spacer(minLength: 40)
        }
        .padding(.horizontal)
      }
      .scrollDisabled(isTransitioning)
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
    .navigationTransition(.zoom(sourceID: category, in: navigationNamespace))
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
  @Previewable @Namespace var anim
  NavigationStack {
    ListView(category: "Running", navigationNamespace: anim)
  }
}
