//
//  AppRootView.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI

struct AppRootView: View {
  @Environment(AppRouter.self) private var router

  // MARK: - Configuration

  private let splashDuration: TimeInterval = 3.0
  private let fadeOutDuration: TimeInterval = 0.6

  private func scheduleSplashDismissal() {
    DispatchQueue.main.asyncAfter(deadline: .now() + splashDuration) {
      withAnimation(.easeInOut(duration: fadeOutDuration)) {
        router.completeSplash()
      }
    }
  }

  var body: some View {
    ZStack {
      NavigationStack(path: Bindable(router).navigationPath) {
        CurrentWeatherView()
          .navigationDestination(for: AppDestination.self) { destination in
            switch destination {
            case .list(let category):
              ListView(category: category)
            }
          }
      }

      if !router.isSplashFinished {
        SplashScreenView()
          .transition(.opacity)
          .zIndex(1)
          .onAppear {
            scheduleSplashDismissal()
          }
      }
    }
  }
}

#Preview {
  AppRootView()
}
