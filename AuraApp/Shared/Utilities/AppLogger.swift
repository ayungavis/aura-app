//
//  AppLogger.swift
//  AuraApp
//

import os
import Foundation

enum AppLogger {
    private static let network = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.aura.app", category: "Network")
    private static let location = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.aura.app", category: "Location")
    private static let cache = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.aura.app", category: "Cache")
    private static let weather = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.aura.app", category: "Weather")
    private static let places = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.aura.app", category: "Places")

    static func networkRequest(_ endpoint: String) {
        network.info("Request: \(endpoint, privacy: .public)")
    }

    static func networkResponse(_ endpoint: String, statusCode: Int? = nil) {
        if let code = statusCode {
            network.info("Response: \(endpoint, privacy: .public) — status \(code)")
        } else {
            network.info("Response: \(endpoint, privacy: .public)")
        }
    }

    static func networkError(_ endpoint: String, error: Error) {
        network.error("Error: \(endpoint, privacy: .public) — \(error.localizedDescription, privacy: .public)")
    }

    static func cacheHit(_ key: String) {
        cache.debug("Hit: \(key, privacy: .public)")
    }

    static func cacheMiss(_ key: String) {
        cache.debug("Miss: \(key, privacy: .public)")
    }

    static func cacheSave(_ key: String) {
        cache.debug("Saved: \(key, privacy: .public)")
    }

    static func cacheError(_ key: String, error: Error) {
        cache.error("Error: \(key, privacy: .public) — \(error.localizedDescription, privacy: .public)")
    }

    static func locationUpdate(_ coordinate: String) {
        location.info("Updated: \(coordinate, privacy: .private)")
    }

    static func locationError(_ error: Error) {
        location.error("Error: \(error.localizedDescription, privacy: .public)")
    }

    static func locationAuthChange(_ status: String) {
        location.info("Auth: \(status, privacy: .public)")
    }

    static func weatherUpdate(_ summary: String) {
        weather.info("Update: \(summary, privacy: .public)")
    }

    static func weatherError(_ error: Error) {
        weather.error("Error: \(error.localizedDescription, privacy: .public)")
    }

    static func placesLoaded(_ context: String, count: Int) {
        places.info("Loaded: \(context, privacy: .public) — \(count) items")
    }

    static func placesError(_ context: String, error: Error) {
        places.error("Error: \(context, privacy: .public) — \(error.localizedDescription, privacy: .public)")
    }
}
