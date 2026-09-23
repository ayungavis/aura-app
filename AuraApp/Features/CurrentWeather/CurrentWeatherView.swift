//
//  CurrentWeatherView.swift
//  AuraApp
//
//  Main weather screen.
//
//  Two deliberate structural choices here, both for scroll performance:
//
//  1. Scroll offset lives in a separate `@Observable` box rather than `@State`.
//     Writing it every frame would otherwise invalidate this whole view — all
//     sections, every frame of every scroll.
//  2. Loading does not swap the content tree for a spinner. Swapping tears down
//     and rebuilds the entire hierarchy on each refresh; instead the sections
//     render their own placeholders.
//

import SwiftUI

/// Holds the live scroll offset outside `CurrentWeatherView`'s own state, so only
/// the views that actually read it re-render as the user scrolls.
@Observable
final class ScrollOffsetModel {
  var offset: CGFloat = 0
}

struct CurrentWeatherView: View {
  @State private var viewModel = CurrentWeatherViewModel()
  let navigationNamespace: Namespace.ID

  @State private var isTransitioning = false
  @State private var scroll = ScrollOffsetModel()
  @Environment(\.openURL) private var openURL

  #if DEBUG
    @State private var showDebugPanel = false
    @State private var debugOverrideEnabled = false
    @State private var debugCondition: WeatherCondition = .rainModerate
    @State private var debugIsDay = true
  #endif

  /// Real condition, unless the debug panel is overriding it.
  private var effectiveCondition: WeatherCondition? {
    #if DEBUG
      return debugOverrideEnabled ? debugCondition : viewModel.currentWeather?.condition
    #else
      return viewModel.currentWeather?.condition
    #endif
  }

  var body: some View {
    Group {
      if viewModel.isLocationDenied, viewModel.currentWeather == nil {
        locationDeniedView
      } else if let error = viewModel.error, viewModel.currentWeather == nil {
        errorView(error)
      } else {
        weatherContent
      }
    }
    .onAppear {
      viewModel.onAppear()

      // Briefly lock scrolling while the zoom transition settles.
      isTransitioning = true
      Task {
        try? await Task.sleep(for: .milliseconds(500))
        isTransitioning = false
      }
    }
    .onDisappear { isTransitioning = false }
  }

  // MARK: - Weather Content

  private var weatherContent: some View {
    ZStack {
      Layout(direction: .vertical, align: .leading, height: .fill) {
        Image("main-gradient-background")
          .resizable()
          .scaledToFit()
      }

      // Reads `scroll.offset` itself so scrolling never invalidates the parent.
      ScrollFadingWeatherEffect(condition: effectiveCondition, scroll: scroll)

      ScrollView {
        Layout(direction: .vertical, spacing: 50) {
          Spacer().frame(height: 127)

          CurrentTemperature(
            weather: viewModel.currentWeather,
            locationName: viewModel.locationName
          )

          HourlyForecast(
            forecasts: viewModel.hourlyForecast.isEmpty
              ? HOURLY_FORECAST_DATA
              : viewModel.hourlyForecast
          )

          RecommendedActivities(
            navigationNamespace: navigationNamespace,
            activities: viewModel.activities.isEmpty ? RECOMMENDED_ACTIVITIES : viewModel.activities,
            searchCenter: viewModel.searchCenter,
            onImageGenerated: viewModel.setGeneratedImage
          )

          RecommendedFoods(
            navigationNamespace: navigationNamespace,
            foods: viewModel.foods.isEmpty ? RECOMMENDED_FOODS : viewModel.foods,
            searchCenter: viewModel.searchCenter,
            onImageGenerated: viewModel.setGeneratedImage
          )

          footer

          Spacer().frame(height: 40)
        }
      }
      .onScrollGeometryChange(for: CGFloat.self) { geometry in
        // contentOffset.y goes negative as the user pulls content up; flip it so
        // the value reads as "distance scrolled".
        -geometry.contentOffset.y
      } action: { _, newOffset in
        scroll.offset = newOffset
      }
      .scrollDisabled(isTransitioning)

      #if DEBUG
        debugOverlay
      #endif
    }
    .ignoresSafeArea()
  }

  // MARK: - Debug Overlay

  #if DEBUG
    private var debugOverlay: some View {
      VStack {
        HStack {
          Spacer()
          Button {
            withAnimation(.spring(response: 0.3)) { showDebugPanel.toggle() }
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
  #endif

  // MARK: - Error View

  private func errorView(_ error: Error) -> some View {
    VStack(spacing: 16) {
      Image(systemName: "cloud.sun.rain.fill")
        .font(.system(size: 48))
        .foregroundStyle(.secondary)
      Text("Unable to load weather")
        .font(.aura(.sans, weight: .medium, size: 18))
      Text(error.localizedDescription)
        .font(.aura(.sans, weight: .regular, size: 14))
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
      Button("Try Again") { viewModel.retry() }
        .buttonStyle(.bordered)
    }
  }

  // MARK: - Location Denied

  private var locationDeniedView: some View {
    VStack(spacing: 16) {
      Image(systemName: "location.slash.fill")
        .font(.system(size: 48))
        .foregroundStyle(.secondary)
      Text("Location is turned off")
        .font(.aura(.sans, weight: .medium, size: 18))
      Text("Aura uses your location to show local weather and recommend things to do nearby.")
        .font(.aura(.sans, weight: .regular, size: 14))
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
      Button("Open Settings") {
        if let url = URL(string: UIApplication.openSettingsURLString) {
          openURL(url)
        }
      }
      .buttonStyle(.bordered)
    }
  }

  // MARK: - Footer

  private var footer: some View {
    VStack(spacing: 12) {
      // Plain text on purpose: Apple's logo artwork isn't licensed for
      // third-party apps (App Review Guideline 5.2.5).
      Text("Suggestions by Apple Intelligence")
        .font(.aura(.sans, weight: .regular, size: 14))
        .foregroundStyle(.secondary.opacity(0.8))

      // Required whenever WeatherKit data is on screen.
      WeatherAttributionView(source: viewModel.weatherSource)
    }
    .frame(maxWidth: .infinity)
  }
}

// MARK: - Scroll-Faded Effect

/// Wraps the particle/ray effect and fades it out as the user scrolls past it.
///
/// Owning the offset read here (rather than in `CurrentWeatherView`) keeps
/// per-frame scroll updates from invalidating the rest of the screen. Once the
/// effect is fully transparent it is removed from the hierarchy entirely, which
/// stops its `TimelineView` from driving the display link at full refresh rate
/// for something nobody can see.
private struct ScrollFadingWeatherEffect: View {
  let condition: WeatherCondition?
  let scroll: ScrollOffsetModel

  private var opacity: Double {
    max(0, 1.0 - scroll.offset / 300)
  }

  var body: some View {
    let opacity = opacity

    Group {
      if opacity > 0.01 {
        WeatherBackgroundEffect(condition: condition)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .opacity(opacity)
      }
    }
  }
}

#Preview {
  @Previewable @Namespace var anim
  CurrentWeatherView(navigationNamespace: anim)
}
