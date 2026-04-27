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
            activities: viewModel.activities.isEmpty ? RECOMMENDED_ACTIVITIES : viewModel.activities
          )

          // AI-powered food recommendations based on weather
          RecommendedFoods(
            navigationNamespace: navigationNamespace,
            foods: viewModel.foods.isEmpty ? RECOMMENDED_FOODS : viewModel.foods
          )

          Spacer().frame(height: 20)
        }
      }
      .scrollDisabled(isTransitioning)
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
}

#Preview {
  @Previewable @Namespace var anim
  CurrentWeatherView(navigationNamespace: anim)
}
