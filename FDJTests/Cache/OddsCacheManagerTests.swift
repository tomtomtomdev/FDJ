import Testing
import Foundation
@testable import FDJ

struct OddsCacheManagerTests {
    @Test("OddsCacheManager should cache and retrieve odds")
    func testCacheAndRetrieveOdds() async throws {
        // Given: Cache manager and test odds
        let cacheManager = OddsCacheManager(cacheTimeout: 10)
        let testOdds = generateTestOdds()

        // When: Caching odds
        try cacheManager.cacheOdds(testOdds)

        // Then: Should retrieve cached odds
        let cachedOdds = try cacheManager.getCachedOdds()
        #expect(cachedOdds?.count == testOdds.count)
        #expect(cachedOdds?.first?.id == testOdds.first?.id)
    }

    @Test("OddsCacheManager should return nil for expired cache")
    func testExpiredCacheReturnsNil() async throws {
        // Given: Cache manager with very short timeout
        let cacheManager = OddsCacheManager(cacheTimeout: 0.1)
        let testOdds = generateTestOdds()

        // When: Caching odds and waiting for expiration
        try cacheManager.cacheOdds(testOdds)
        try await Task.sleep(for: .seconds(0.2))

        // Then: Should return nil for expired cache
        let cachedOdds = try cacheManager.getCachedOdds()
        #expect(cachedOdds == nil)
    }

    @Test("OddsCacheManager should return stale cache when requested")
    func testGetStaleCache() async throws {
        // Given: Cache manager with short timeout
        let cacheManager = OddsCacheManager(cacheTimeout: 0.1)
        let testOdds = generateTestOdds()

        // When: Caching odds and waiting for expiration
        try cacheManager.cacheOdds(testOdds)
        try await Task.sleep(for: .seconds(0.2))

        // Then: Should return stale cache when explicitly requested
        let staleOdds = try cacheManager.getStaleCachedOdds()
        #expect(staleOdds?.count == testOdds.count)
    }

    @Test("OddsCacheManager should clear cache")
    func testClearCache() async throws {
        // Given: Cache manager with cached odds
        let cacheManager = OddsCacheManager(cacheTimeout: 10)
        let testOdds = generateTestOdds()
        try cacheManager.cacheOdds(testOdds)

        // Verify cache exists
        let cachedOdds = try cacheManager.getCachedOdds()
        #expect(cachedOdds != nil)

        // When: Clearing cache
        cacheManager.clearCache()

        // Then: Cache should be empty
        let clearedOdds = try cacheManager.getCachedOdds()
        #expect(clearedOdds == nil)
    }

    @Test("OddsCacheManager should update cache")
    func testUpdateCache() async throws {
        // Given: Cache manager with initial odds
        let cacheManager = OddsCacheManager(cacheTimeout: 10)
        let initialOdds = generateTestOdds(count: 3)
        try cacheManager.cacheOdds(initialOdds)

        // When: Updating with new odds
        let updatedOdds = generateTestOdds(count: 5)
        try cacheManager.cacheOdds(updatedOdds)

        // Then: Should return updated odds
        let cachedOdds = try cacheManager.getCachedOdds()
        #expect(cachedOdds?.count == 5)
        #expect(cachedOdds?.first?.id != initialOdds.first?.id)
    }

    @Test("OddsCacheManager should handle empty cache")
    func testEmptyCache() async throws {
        // Given: Empty cache manager
        let cacheManager = OddsCacheManager()

        // When/Then: Should return nil
        let cachedOdds = try cacheManager.getCachedOdds()
        #expect(cachedOdds == nil)

        let staleOdds = try cacheManager.getStaleCachedOdds()
        #expect(staleOdds == nil)
    }

    // MARK: - Helper Methods

    private func generateTestOdds(count: Int = 3) -> [OddsEvent] {
        return (0..<count).map { index in
            OddsEvent(
                id: "test_event_\(index)",
                sport: "basketball",
                homeTeam: "Home Team \(index)",
                awayTeam: "Away Team \(index)",
                commenceTime: Date().addingTimeInterval(Double(index * 3600)),
                bookmakers: [
                    Bookmaker(
                        name: "TestBookmaker",
                        outcomes: [
                            Outcome(name: "Home Team \(index)", price: 1.85),
                            Outcome(name: "Away Team \(index)", price: 1.95)
                        ]
                    )
                ]
            )
        }
    }
}