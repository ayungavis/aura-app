//
//  CurrentWeatherView.swift
//  AuraApp
//
//  Main weather screen. Follows the MVVM pattern:
//  - @StateObject creates and owns the ViewModel
//  - ViewModel publishes state changes → View re-renders automatically
//  - View only handles layout and user interaction, no business logic
//

import SwiftUI

struct CurrentWeatherView: View {
  // @StateObject = this View creates and owns the ViewModel.
  // SwiftUI keeps it alive across re-renders (unlike @ObservedObject).
  @StateObject private var viewModel = CurrentWeatherViewModel()
  let navigationNamespace: Namespace.ID
  @State private var isTransitioning = false
  @State private var scrollOffset: CGFloat = 0

  // MARK: - Debug State
  @State private var showDebugPanel = false
  @State private var debugOverrideEnabled = false
  @State private var debugCondition: WeatherCondition = .rainModerate
  @State private var debugIsDay = true

  /// Returns the overridden condition when debug is active,
  /// otherwise falls back to the real weather condition.
  private var effectiveCondition: WeatherCondition? {
    debugOverrideEnabled ? debugCondition : viewModel.currentWeather?.condition
  }

  var body: some View {
    Group {
      // Three-state rendering: loading → error → content
      if viewModel.isLoading {
        ProgressView()
          .progressViewStyle(.circular)
      } else if let error = viewModel.error {
        errorView(error)
      } else {
        weatherContent
      }
    }
    .onAppear {
      viewModel.onAppear()
      
      // Lock scrolling briefly ONLY when returning to the home screen
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

  // MARK: - Weather Content
  // The main scrollable layout with all weather sections.

  private var weatherContent: some View {
    ZStack {
      Layout(direction: .vertical, align: .leading, height: .fill) {
        Image("main-gradient-background")
          .resizable()
          .scaledToFit()
      }

      // Fade out weather particles as the user scrolls down.
      // Fully visible at scroll offset 0, fully faded by ~300pt.
      WeatherBackgroundEffect(condition: effectiveCondition)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(max(0, 1.0 - scrollOffset / 300))

      ScrollView {
        Layout(direction: .vertical, spacing: 50) {
          Spacer().frame(height: 127)

          // Current temperature, condition, and location name
          CurrentTemperature(
            weather: viewModel.currentWeather,
            locationName: viewModel.locationName
          )

          // Hourly forecast — real data when available, mock data as fallback
          HourlyForecast(forecasts: viewModel.hourlyForecast.isEmpty ? HOURLY_FORECAST_DATA : viewModel.hourlyForecast)

          // AI-powered activity recommendations based on weather
          RecommendedActivities(
            navigationNamespace: navigationNamespace,
            activities: viewModel.activities.isEmpty ? RECOMMENDED_ACTIVITIES : viewModel.activities,
            latLong: viewModel.latLongString
          )

          // AI-powered food recommendations based on weather
          RecommendedFoods(
            navigationNamespace: navigationNamespace,
            foods: viewModel.foods.isEmpty ? RECOMMENDED_FOODS : viewModel.foods,
            latLong: viewModel.latLongString
          )

          footer

          Spacer().frame(height: 40)
        }
      }
      .onScrollGeometryChange(for: CGFloat.self) { geometry in
        // contentOffset.y is negative when scrolled down in a top-origin ScrollView,
        // but we want a positive value representing how far the user scrolled.
        -geometry.contentOffset.y
      } action: { _, newOffset in
        scrollOffset = newOffset
      }
      .scrollDisabled(isTransitioning)
      // MARK: - Debug Overlay
      // Gear button pinned to top-right, panel slides in below it.
      VStack {
        HStack {
          Spacer()
          Button {
            withAnimation(.spring(response: 0.3)) {
              showDebugPanel.toggle()
            }
          } label: {
            Image(systemName: "gearshape.fill")
              .font(.system(size: 16, weight: .medium))
              .foregroundStyle(.black.opacity(0.4))
              .padding(10)
              .background(.ultraThinMaterial)
              .clipShape(Circle())
          }
          .padding(.trailing, 16)
          .padding(.top, 54)
        }

        if showDebugPanel {
          WeatherDebugOverlay(
            isPresented: $showDebugPanel,
            overrideEnabled: $debugOverrideEnabled,
            overrideCondition: $debugCondition,
            overrideIsDay: $debugIsDay
          )
        }

        Spacer()
      }
    }
    .ignoresSafeArea()
  }

  // MARK: - Error View
  // Shown when weather data fails to load. Includes retry button.

  private func errorView(_ error: Error) -> some View {
    VStack(spacing: 16) {
      Image(systemName: "cloud.sun.rain.fill")
        .font(.system(size: 48))
        .foregroundStyle(.secondary)
      Text("Unable to load weather")
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
    }
  }

  // MARK: - Footer
  // Branded attribution for AI features.

  private var footer: some View {
    HStack(spacing: 6) {
      Text("Powered by")
        .font(.custom("InstrumentSans-Regular", size: 14))
        .foregroundStyle(.secondary.opacity(0.8))

      Image("logo-apple-intelligence-icon")
        .resizable()
        .scaledToFit()
        .frame(height: 18)

      Image("logo-apple-intelligence-text")
        .resizable()
        .scaledToFit()
        .frame(height: 14)
    }
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  @Previewable @Namespace var anim
  CurrentWeatherView(navigationNamespace: anim)
}
