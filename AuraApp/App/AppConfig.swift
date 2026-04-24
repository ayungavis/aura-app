//
//  AppConfig.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import Foundation

enum AppConfig {
  static let appName = "aura"

  private static func value(for key: String) -> String? {
    return Bundle.main.object(forInfoDictionaryKey: key) as? String
  }

  static var tripAdvisorAPIKey: String {
    value(for: "TRIPADVISOR_API_KEY") ?? ""
  }

  /// Secrets
  static func validate() {
    let keys = ["TRIPADVISOR_API_KEY"]
    for key in keys {
      if value(for: key)?.isEmpty ?? true {
        assertionFailure("Missing Environment Variable: \(key)")
      }
    }
  }
}
