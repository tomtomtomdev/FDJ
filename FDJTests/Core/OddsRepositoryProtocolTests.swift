import Testing
import Foundation
@testable import FDJ

struct OddsRepositoryProtocolTests {
    @Test("OddsRepositoryProtocol should exist and be fetchable")
    func testOddsRepositoryProtocolExists() async throws {
        // Given: A mock implementation of OddsRepositoryProtocol
        let mockRepository = MockOddsRepository()

        // Then: The protocol should conform to OddsRepositoryProtocol
        #expect(mockRepository is any OddsRepositoryProtocol)
    }

    @Test("OddsRepositoryProtocol should fetch odds successfully")
    func testFetchOddsSuccess() async throws {
        // Given: A mock repository
        let mockRepository = MockOddsRepository()

        // When: Fetching odds
        let odds = try await mockRepository.fetchOdds()

        // Then: Should return odds
        #expect(odds.isEmpty == false)
    }

    @Test("OddsRepositoryProtocol should handle fetch errors")
    func testFetchOddsFailure() async throws {
        // Given: A mock repository configured to fail
        let mockRepository = MockOddsRepository(shouldFail: true)

        // When/Then: Should throw an error
        await #expect(throws: RepositoryError.self) {
            try await mockRepository.fetchOdds()
        }
    }

    @Test("OddsRepositoryProtocol should refresh odds")
    func testRefreshOdds() async throws {
        // Given: A mock repository
        let mockRepository = MockOddsRepository()

        // When: Refreshing odds
        let odds = try await mockRepository.refreshOdds()

        // Then: Should return fresh odds
        #expect(odds.isEmpty == false)
    }
}

// MARK: - Mock Implementation for Testing
actor MockOddsRepository: OddsRepositoryProtocol {
    private let shouldFail: Bool

    init(shouldFail: Bool = false) {
        self.shouldFail = shouldFail
    }

    func fetchOdds() async throws -> [OddsEvent] {
        if shouldFail {
            throw RepositoryError.fetchFailed
        }

        return [
            OddsEvent(
                id: "test_1",
                sport: "basketball",
                homeTeam: "Lakers",
                awayTeam: "Warriors",
                commenceTime: Date().addingTimeInterval(3600),
                bookmakers: [
                    Bookmaker(
                        name: "MockBookmaker",
                        outcomes: [
                            Outcome(name: "Lakers", price: 1.85),
                            Outcome(name: "Warriors", price: 1.95)
                        ]
                    )
                ]
            )
        ]
    }

    func refreshOdds() async throws -> [OddsEvent] {
        return try await fetchOdds()
    }

    func getCachedOdds() async throws -> [OddsEvent]? {
        if shouldFail {
            throw RepositoryError.cacheError
        }
        return nil // No cache in mock
    }
}