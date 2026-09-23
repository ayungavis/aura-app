//
//  WeatherAttributionView.swift
//  AuraApp
//
//  Apple requires the Apple Weather mark and a link to their legal attribution
//  page on any surface displaying WeatherKit data. Shipping without it is
//  grounds for App Store rejection.
//
//  The mark and legal URL are fetched from WeatherKit (they are localised and
//  Apple can change them), so this loads once and caches for the session.
//

import SwiftUI

/// Session-scoped cache. The attribution endpoint is a network call, and every
/// screen showing weather would otherwise refetch it.
@MainActor
@Observable
final class WeatherAttributionModel {
  static let shared = WeatherAttributionModel()

  private(set) var lightLogoURL: URL?
  private(set) var darkLogoURL: URL?
  private(set) var legalPageURL: URL?

  @ObservationIgnored private var hasLoaded = false

  func loadIfNeeded() async {
    guard !hasLoaded else { return }
    hasLoaded = true

    guard let attribution = await WeatherKitAttribution.load() else { return }
    lightLogoURL = attribution.lightLogo
    darkLogoURL = attribution.darkLogo
    legalPageURL = attribution.legalPage
  }
}

struct WeatherAttributionView: View {
  /// Pass `.openMeteo` to hide the Apple mark when Apple did not supply the data.
  var source: WeatherSource? = .weatherKit

  @State private var model = WeatherAttributionModel.shared
  @Environment(\.colorScheme) private var colorScheme

  private var logoURL: URL? {
    colorScheme == .dark ? model.darkLogoURL : model.lightLogoURL
  }

  var body: some View {
    Group {
      if source == .weatherKit {
        appleWeatherMark
      } else {
        Text("Weather data by Open-Meteo")
          .font(.aura(.sans, weight: .regular, size: 11))
          .foregroundStyle(.secondary.opacity(0.7))
      }
    }
    .task { await model.loadIfNeeded() }
  }

  /// The mark itself links to Apple's legal page, which satisfies the
  /// attribution requirement without a separate "Other data sources" label.
  @ViewBuilder
  private var appleWeatherMark: some View {
    if let legalPageURL = model.legalPageURL {
      Link(destination: legalPageURL) { logo }
        .accessibilityLabel("Apple Weather data sources")
    } else {
      logo
    }
  }

  @ViewBuilder
  private var logo: some View {
    if let logoURL {
      AsyncImage(url: logoURL) { image in
        image.resizable().scaledToFit()
      } placeholder: {
        Color.clear
      }
      .frame(height: 14)
    }
  }
}
