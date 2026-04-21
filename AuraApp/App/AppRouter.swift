//
//  AppRouter.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI

@Observable
final class AppRouter {
    var isSplashFinished: Bool = false

    func completeSplash() {
        isSplashFinished = true
    }
}
