import Testing
import Foundation
@testable import FDJ

struct OddsRepositoryTests {
    @Test("OddsRepository should fetch odds from network")
    func testFetchOddsFromNetwork() async throws {
        // Given: Repository with mock network client
        let mockNetwork = MockNetworkClient()
        let mockDataGenerator = MockDataGenerator()
        let repository = DefaultOddsRepository(
            networkService: mockNetwork,
            dataGenerator: mockDataGenerator
        )

        // When: Fetching odds
        let odds = try await repository.fetchOdds()

        // Then: Should return odds events
        #expect(odds.isEmpty == false)
    }

    @Test("OddsRepository should handle network errors")
    func testFetchOddsNetworkError() async throws {
        // Given: Repository with failing network client
        let mockNetwork = MockNetworkClient(simulateError: true)
        let mockDataGenerator = MockDataGenerator()
        let repository = DefaultOddsRepository(
            networkService: mockNetwork,
            dataGenerator: mockDataGenerator
        )

        // When/Then: Should throw repository error
        await #expect(throws: RepositoryError.self) {
            try await repository.fetchOdds()
        }
    }

    @Test("OddsRepository should cache odds after fetching")
    func testCacheOddsAfterFetch() async throws {
        // Given: Repository
        let mockNetwork = MockNetworkClient()
        let mockDataGenerator = MockDataGenerator()
        let repository = DefaultOddsRepository(
            networkService: mockNetwork,
            dataGenerator: mockDataGenerator
        )

        // When: Fetching odds
        let odds = try await repository.fetchOdds()

        // Then: Should be able to retrieve from cache
        let cachedOdds = try await repository.getCachedOdds()
        #expect(cachedOdds?.count == odds.count)
    }

    @Test("OddsRepository should refresh odds from network")
    func testRefreshOdds() async throws {
        // Given: Repository
        let mockNetwork = MockNetworkClient()
        let mockDataGenerator = MockDataGenerator()
        let repository = DefaultOddsRepository(
            networkService: mockNetwork,
            dataGenerator: mockDataGenerator
        )

        // When: Refreshing odds
        let odds = try await repository.refreshOdds()

        // Then: Should return fresh odds
        #expect(odds.isEmpty == false)
    }

    @Test("OddsRepository should return nil for empty cache")
    func testEmptyCacheReturnsNil() async throws {
        // Given: New repository (no cache)
        let mockNetwork = MockNetworkClient()
        let mockDataGenerator = MockDataGenerator()
        let repository = DefaultOddsRepository(
            networkService: mockNetwork,
            dataGenerator: mockDataGenerator
        )

        // When: Getting cached odds before any fetch
        let cachedOdds = try await repository.getCachedOdds()

        // Then: Should return nil
        #expect(cachedOdds == nil)
    }

    @Test("OddsRepository should use cache when network is slow")
    func testUseCacheWhenNetworkSlow() async throws {
        // Given: Repository with slow network
        let mockNetwork = MockNetworkClient(delay: 0.1)
        let mockDataGenerator = MockDataGenerator()
        let repository = DefaultOddsRepository(
            networkService: mockNetwork,
            dataGenerator: mockDataGenerator,
            cacheTimeout: 5.0 // 5 seconds cache timeout
        )

        // When: First fetch (from network)
        let startTime = Date()
        let firstOdds = try await repository.fetchOdds()
        let firstFetchTime = Date().timeIntervalSince(startTime)

        // And: Second fetch (should use cache)
        let secondStartTime = Date()
        let secondOdds = try await repository.fetchOdds()
        let secondFetchTime = Date().timeIntervalSince(secondStartTime)

        // Then: First fetch should take time (network delay)
        #expect(firstFetchTime >= 0.1)

        // And: Second fetch should be faster (from cache)
        #expect(secondFetchTime < 0.05)

        // And: Results should be the same
        #expect(firstOdds.count == secondOdds.count)
    }
}