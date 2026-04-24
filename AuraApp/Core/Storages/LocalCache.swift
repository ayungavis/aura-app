//
//  LocalCache.swift
//  AuraApp
//
//  Disk-based caching utility for Codable objects.
//  Uses Caches directory with configurable expiration.
//

import Foundation

class LocalCache {

    static let shared = LocalCache()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let defaultExpiration: TimeInterval = 24 * 60 * 60

    private init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("APICache")
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    private struct CacheEntry<T: Codable>: Codable {
        let value: T
        let timestamp: Date
    }

    func save<T: Codable>(_ object: T, key: String) {
        let entry = CacheEntry(value: object, timestamp: Date())
        let fileURL = cacheDirectory.appendingPathComponent(sanitizeKey(key))

        do {
            let data = try JSONEncoder().encode(entry)
            try data.write(to: fileURL)
            AppLogger.cacheSave(key)
        } catch {
            AppLogger.cacheError(key, error: error)
        }
    }

    func load<T: Codable>(key: String, as type: T.Type, expiration: TimeInterval? = nil) -> T? {
        let fileURL = cacheDirectory.appendingPathComponent(sanitizeKey(key))
        let maxAge = expiration ?? defaultExpiration

        guard fileManager.fileExists(atPath: fileURL.path) else {
            AppLogger.cacheMiss(key)
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let entry = try JSONDecoder().decode(CacheEntry<T>.self, from: data)

            let age = Date().timeIntervalSince(entry.timestamp)
            if age > maxAge {
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

    func remove(key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(sanitizeKey(key))
        try? fileManager.removeItem(at: fileURL)
    }

    func clearAll() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    private func sanitizeKey(_ key: String) -> String {
        return key.replacingOccurrences(of: "/", with: "_")
                  .replacingOccurrences(of: ":", with: "_")
                  .replacingOccurrences(of: " ", with: "_")
    }
}
