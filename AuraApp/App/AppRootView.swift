//
//  AppRootView.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI

struct AppRootView: View {
    @State private var router = AppRouter()

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
            NavigationStack {
                ListView(category: "Running")
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
