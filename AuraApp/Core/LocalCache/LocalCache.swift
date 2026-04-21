//
//  LocalCache.swift
//  AuraApp
//
//  A simple disk-based caching utility for storing Codable objects.
//  Uses the device's Caches directory to allow individual API responses
//  to be saved and retrieved, reducing network usage and improving speed.
//

import Foundation

class LocalCache {
    
    static let shared = LocalCache()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    // Default expiration: 24 hours
    private let defaultExpiration: TimeInterval = 24 * 60 * 60
    
    private init() {
        // Get the system Caches directory for this app
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("APICache")
        
        // Create the directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Wrapper Struct
    
    /// A private wrapper to store the object along with its save date.
    private struct CacheEntry<T: Codable>: Codable {
        let value: T
        let timestamp: Date
    }
    
    // MARK: - Public Methods
    
    /// Saves a Codable object to disk with a specific key.
    func save<T: Codable>(_ object: T, key: String) {
        let entry = CacheEntry(value: object, timestamp: Date())
        let fileURL = cacheDirectory.appendingPathComponent(sanitizeKey(key))
        
        do {
            let data = try JSONEncoder().encode(entry)
            try data.write(to: fileURL)
            // print("💾 Saved to cache: \(key)")
        } catch {
            print("❌ Cache Save Error for \(key): \(error)")
        }
    }
    
    /// Loads a Codable object from disk if it exists and hasn't expired.
    func load<T: Codable>(key: String, as type: T.Type, expiration: TimeInterval? = nil) -> T? {
        let fileURL = cacheDirectory.appendingPathComponent(sanitizeKey(key))
        let maxAge = expiration ?? defaultExpiration
        
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let entry = try JSONDecoder().decode(CacheEntry<T>.self, from: data)
            
            // Check if the entry is too old
            let age = Date().timeIntervalSince(entry.timestamp)
            if age > maxAge {
                // print("⏳ Cache expired for: \(key) (Age: \(Int(age/3600))h)")
                try? fileManager.removeItem(at: fileURL)
                return nil
            }
            
            // print("✅ Cache hit: \(key)")
            return entry.value
        } catch {
            print("❌ Cache Load Error for \(key): \(error)")
            return nil
        }
    }
    
    /// Manually removes a specific cache entry.
    func remove(key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(sanitizeKey(key))
        try? fileManager.removeItem(at: fileURL)
    }
    
    /// Clears all cached API responses.
    func clearAll() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Private Helpers
    
    /// Helps ensure keys are safe to use as filenames.
    private func sanitizeKey(_ key: String) -> String {
        // Replace common characters that might cause issues in filenames
        return key.replacingOccurrences(of: "/", with: "_")
                  .replacingOccurrences(of: ":", with: "_")
                  .replacingOccurrences(of: " ", with: "_")
    }
}
