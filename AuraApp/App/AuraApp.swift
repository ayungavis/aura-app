//
//  AuraAppApp.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 16/04/26.
//

import SwiftUI

@main
struct AuraApp: App {
  @State private var router = AppRouter()

  init() {
    AppConfig.validate()
  }

  var body: some Scene {
    WindowGroup {
      AppRootView()
        .environment(router)
    }
  }
}
