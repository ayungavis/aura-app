//
//  LocalCache.swift
//  AuraApp
//
//  Disk-based caching utility for Codable objects.
//
//  Storage lives in the shared App Group container when it is available, so the
//  widget extension reads exactly the same payload the app just wrote. When the
//  container is missing (e.g. entitlement not yet provisioned) it degrades to the
//  per-process Caches directory rather than failing.
//

import Foundation

/// Identifiers shared between the app and its extensions.
nonisolated enum AppGroup {
  static let identifier = "group.com.babono.AuraApp"

  /// Shared container URL, or `nil` when the App Group entitlement is unavailable.
  static var containerURL: URL? {
    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
  }
}

nonisolated final class LocalCache: @unchecked Sendable {

  static let shared = LocalCache()

  private let fileManager = FileManager.default
  private let cacheDirectory: URL
  private let defaultExpiration: TimeInterval = 24 * 60 * 60

  /// Serialises disk access so the app and widget never interleave a read with a
  /// half-written file.
  private let queue = DispatchQueue(label: "com.babono.AuraApp.LocalCache", attributes: .concurrent)

  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  private init() {
    let root = AppGroup.containerURL
      ?? fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    cacheDirectory = root.appendingPathComponent("APICache", isDirectory: true)
    try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
  }

  private struct CacheEntry<T: Codable>: Codable {
    let value: T
    let timestamp: Date
  }

  func save<T: Codable>(_ object: T, key: String) {
    let entry = CacheEntry(value: object, timestamp: Date())
    let fileURL = cacheDirectory.appendingPathComponent(sanitizeKey(key))

    queue.async(flags: .barrier) { [encoder] in
      do {
        let data = try encoder.encode(entry)
        // Atomic so a reader in the widget process never sees a partial file.
        try data.write(to: fileURL, options: .atomic)
        AppLogger.cacheSave(key)
      } catch {
        AppLogger.cacheError(key, error: error)
      }
    }
  }

  func load<T: Codable>(key: String, as type: T.Type, expiration: TimeInterval? = nil) -> T? {
    let fileURL = cacheDirectory.appendingPathComponent(sanitizeKey(key))
    let maxAge = expiration ?? defaultExpiration

    return queue.sync { [decoder] in
      guard let data = try? Data(contentsOf: fileURL) else {
        AppLogger.cacheMiss(key)
        return nil
      }

      do {
        let entry = try decoder.decode(CacheEntry<T>.self, from: data)

        if Date().timeIntervalSince(entry.timestamp) > maxAge {
          try? fileManager.removeItem(at: fileURL)
          AppLogger.cacheMiss(key)
          return nil
        }

        AppLogger.cacheHit(key)
        return entry.value
      } catch {
        AppLogger.cacheError(key, error: error)
        return nil
      }
    }
  }

  func remove(key: String) {
    let fileURL = cacheDirectory.appendingPathComponent(sanitizeKey(key))
    queue.async(flags: .barrier) { [fileManager] in
      try? fileManager.removeItem(at: fileURL)
    }
  }

  func clearAll() {
    queue.async(flags: .barrier) { [fileManager, cacheDirectory] in
      try? fileManager.removeItem(at: cacheDirectory)
      try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
  }

  private func sanitizeKey(_ key: String) -> String {
    key.replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: ":", with: "_")
      .replacingOccurrences(of: " ", with: "_")
  }
}
