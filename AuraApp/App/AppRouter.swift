//
//  AppRouter.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import Foundation
import SwiftUI

@Observable
final class AppRouter {
  var isSplashFinished: Bool = false
  var navigationPath = NavigationPath()

  func completeSplash() {
    isSplashFinished = true
  }

  func navigate(to destination: AppDestination) {
    navigationPath.append(destination)
  }
}
