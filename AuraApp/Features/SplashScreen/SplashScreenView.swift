//
//  SplashScreenView.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            AnimatedMeshBackground()
            Logo()
        }
    }
}

#Preview {
    SplashScreenView()
}
