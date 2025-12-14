import Foundation

/// Manages caching of odds data with expiration support
actor OddsCacheManager {
    private let cacheTimeout: TimeInterval
    private var cachedOdds: CachedOdds?
    private let userDefaults = UserDefaults.standard
    private let cacheKey = "cached_odds"

    /// Cache timeout in seconds (default: 5 minutes)
    init(cacheTimeout: TimeInterval = 300) {
        self.cacheTimeout = cacheTimeout
    }

    /// Caches odds data with timestamp
    /// - Parameter odds: The odds events to cache
    /// - Throws: CacheError if caching fails
    func cacheOdds(_ odds: [OddsEvent]) throws {
        let cachedData = CachedOdds(
            odds: odds,
            timestamp: Date()
        )

        // Store in memory
        self.cachedOdds = cachedData

        // Persist to UserDefaults
        try persistToDisk(cachedData)
    }

    /// Retrieves cached odds if not expired
    /// - Returns: Cached odds or nil if expired/not found
    /// - Throws: CacheError if retrieval fails
    func getCachedOdds() throws -> [OddsEvent]? {
        // Try memory cache first
        if let cachedData = cachedOdds, !cachedData.isExpired(timeout: cacheTimeout) {
            return cachedData.odds
        }

        // Try loading from disk
        if let diskCachedData = loadFromDisk(), !diskCachedData.isExpired(timeout: cacheTimeout) {
            cachedOdds = diskCachedData
            return diskCachedData.odds
        }

        return nil
    }

    /// Retrieves cached odds even if expired
    /// - Returns: Stale cached odds or nil if not found
    /// - Throws: CacheError if retrieval fails
    func getStaleCachedOdds() throws -> [OddsEvent]? {
        // Try memory cache first
        if let cachedData = cachedOdds {
            return cachedData.odds
        }

        // Try loading from disk
        if let diskCachedData = loadFromDisk() {
            cachedOdds = diskCachedData
            return diskCachedData.odds
        }

        return nil
    }

    /// Clears all cached odds
    func clearCache() {
        cachedOdds = nil
        userDefaults.removeObject(forKey: cacheKey)
    }

    // MARK: - Private Methods

    private func persistToDisk(_ cachedData: CachedOdds) throws {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(cachedData)
            userDefaults.set(data, forKey: cacheKey)
        } catch {
            throw CacheError.persistError
        }
    }

    private func loadFromDisk() -> CachedOdds? {
        guard let data = userDefaults.data(forKey: cacheKey) else { return nil }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(CachedOdds.self, from: data)
        } catch {
            // If loading fails, clear corrupted cache
            userDefaults.removeObject(forKey: cacheKey)
            return nil
        }
    }
}

// MARK: - Supporting Types

private struct CachedOdds: Codable {
    let odds: [OddsEvent]
    let timestamp: Date

    func isExpired(timeout: TimeInterval) -> Bool {
        Date().timeIntervalSince(timestamp) > timeout
    }
}

// MARK: - Cache Errors

enum CacheError: Error, LocalizedError {
    case persistError
    case retrievalError
    case corruptedData

    var errorDescription: String? {
        switch self {
        case .persistError:
            return "Failed to save data to cache"
        case .retrievalError:
            return "Failed to retrieve data from cache"
        case .corruptedData:
            return "Cached data is corrupted"
        }
    }
}