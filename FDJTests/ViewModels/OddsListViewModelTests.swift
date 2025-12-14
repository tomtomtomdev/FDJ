import Testing
import Foundation
@testable import FDJ

struct OddsListViewModelTests {
    @Test("OddsListViewModel should initialize with correct state")
    func testInitialState() async {
        // Given: A mock repository
        let mockRepository = MockOddsRepository()

        // When: Creating view model
        let viewModel = OddsListViewModel(repository: mockRepository)

        // Then: Initial state should be correct
        #expect(viewModel.odds.isEmpty == true)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }

    @Test("OddsListViewModel should load odds successfully")
    func testLoadOddsSuccess() async {
        // Given: A view model with mock repository
        let mockRepository = MockOddsRepository()
        let viewModel = OddsListViewModel(repository: mockRepository)

        // When: Loading odds
        await viewModel.loadOdds()

        // Then: Should update state with odds
        #expect(viewModel.isLoading == false)
        #expect(viewModel.odds.isEmpty == false)
        #expect(viewModel.error == nil)
    }

    @Test("OddsListViewModel should handle loading errors")
    func testLoadOddsFailure() async {
        // Given: A view model with failing repository
        let mockRepository = MockOddsRepository(shouldFail: true)
        let viewModel = OddsListViewModel(repository: mockRepository)

        // When: Loading odds
        await viewModel.loadOdds()

        // Then: Should update state with error
        #expect(viewModel.isLoading == false)
        #expect(viewModel.odds.isEmpty == true)
        #expect(viewModel.error != nil)
    }

    @Test("OddsListViewModel should set loading state during fetch")
    func testLoadingState() async {
        // Given: A view model with slow repository
        let mockRepository = SlowMockOddsRepository(delay: 0.1)
        let viewModel = OddsListViewModel(repository: mockRepository)

        // When: Starting load
        Task {
            await viewModel.loadOdds()
        }

        // Then: Should be loading immediately
        #expect(viewModel.isLoading == true)

        // Wait for completion
        try? await Task.sleep(for: .milliseconds(150))
        #expect(viewModel.isLoading == false)
    }

    @Test("OddsListViewModel should refresh odds")
    func testRefreshOdds() async {
        // Given: A view model with repository
        let mockRepository = MockOddsRepository()
        let viewModel = OddsListViewModel(repository: mockRepository)

        // When: Refreshing odds
        await viewModel.refreshOdds()

        // Then: Should call refresh on repository
        #expect(mockRepository.refreshCallCount > 0)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.odds.isEmpty == false)
    }

    @Test("OddsListViewModel should filter odds by sport")
    func testFilterBySport() async {
        // Given: A view model with odds
        let mockRepository = MockOddsRepository()
        let viewModel = OddsListViewModel(repository: mockRepository)
        await viewModel.loadOdds()
        let initialCount = viewModel.odds.count

        // When: Filtering by sport
        viewModel.filterBySport("basketball")

        // Then: Should filter odds
        let filteredCount = viewModel.filteredOdds.count
        #expect(filteredCount <= initialCount)

        // All filtered odds should be basketball
        for odd in viewModel.filteredOdds {
            #expect(odd.sport == "basketball")
        }
    }

    @Test("OddsListViewModel should clear filter")
    func testClearFilter() async {
        // Given: A view model with applied filter
        let mockRepository = MockOddsRepository()
        let viewModel = OddsListViewModel(repository: mockRepository)
        await viewModel.loadOdds()
        viewModel.filterBySport("basketball")

        // When: Clearing filter
        viewModel.clearFilter()

        // Then: Should show all odds
        #expect(viewModel.filteredOdds.count == viewModel.odds.count)
        #expect(viewModel.selectedSport == nil)
    }

    @Test("OddsListViewModel should get unique sports")
    func testGetUniqueSports() async {
        // Given: A view model with odds
        let mockRepository = MockOddsRepository()
        let viewModel = OddsListViewModel(repository: mockRepository)
        await viewModel.loadOdds()

        // When: Getting unique sports
        let sports = viewModel.uniqueSports

        // Then: Should return unique sport names
        #expect(sports.isEmpty == false)
        #expect(sports.contains("basketball"))
        #expect(sports.contains("football"))
        #expect(sports.contains("soccer"))
    }

    @Test("OddsListViewModel should format time until event")
    func testTimeFormatting() {
        // Given: A view model
        let viewModel = OddsListViewModel(repository: MockOddsRepository())

        // When: Formatting different times
        let oneHour = Date().addingTimeInterval(3600)
        let oneDay = Date().addingTimeInterval(86400)
        let oneWeek = Date().addingTimeInterval(604800)

        let oneHourFormatted = viewModel.formatTimeUntil(oneHour)
        let oneDayFormatted = viewModel.formatTimeUntil(oneDay)
        let oneWeekFormatted = viewModel.formatTimeUntil(oneWeek)

        // Then: Should format times appropriately
        #expect(oneHourFormatted.isEmpty == false)
        #expect(oneDayFormatted.isEmpty == false)
        #expect(oneWeekFormatted.isEmpty == false)
    }
}

// MARK: - Mock Repositories for Testing

actor MockOddsRepository: OddsRepositoryProtocol {
    private let shouldFail: Bool
    var refreshCallCount = 0

    init(shouldFail: Bool = false) {
        self.shouldFail = shouldFail
    }

    func fetchOdds() async throws -> [OddsEvent] {
        if shouldFail {
            throw RepositoryError.fetchFailed
        }

        return [
            OddsEvent(
                id: "basketball_1",
                sport: "basketball",
                homeTeam: "Lakers",
                awayTeam: "Warriors",
                commenceTime: Date().addingTimeInterval(3600),
                bookmakers: [
                    Bookmaker(
                        name: "DraftKings",
                        outcomes: [
                            Outcome(name: "Lakers", price: 1.85),
                            Outcome(name: "Warriors", price: 1.95)
                        ]
                    )
                ]
            ),
            OddsEvent(
                id: "football_1",
                sport: "football",
                homeTeam: "Patriots",
                awayTeam: "Bills",
                commenceTime: Date().addingTimeInterval(7200),
                bookmakers: [
                    Bookmaker(
                        name: "BetMGM",
                        outcomes: [
                            Outcome(name: "Patriots", price: 2.10),
                            Outcome(name: "Bills", price: 1.80)
                        ]
                    )
                ]
            ),
            OddsEvent(
                id: "soccer_1",
                sport: "soccer",
                homeTeam: "Man United",
                awayTeam: "Liverpool",
                commenceTime: Date().addingTimeInterval(86400),
                bookmakers: [
                    Bookmaker(
                        name: "William Hill",
                        outcomes: [
                            Outcome(name: "Man United", price: 2.50),
                            Outcome(name: "Liverpool", price: 2.80)
                        ]
                    )
                ]
            )
        ]
    }

    func refreshOdds() async throws -> [OddsEvent] {
        refreshCallCount += 1
        return try await fetchOdds()
    }

    func getCachedOdds() async throws -> [OddsEvent]? {
        return nil // No cache in mock
    }
}

actor SlowMockOddsRepository: OddsRepositoryProtocol {
    private let delay: TimeInterval

    init(delay: TimeInterval) {
        self.delay = delay
    }

    func fetchOdds() async throws -> [OddsEvent] {
        try await Task.sleep(for: .seconds(delay))
        return [
            OddsEvent(
                id: "slow_event",
                sport: "basketball",
                homeTeam: "Team A",
                awayTeam: "Team B",
                commenceTime: Date().addingTimeInterval(3600),
                bookmakers: []
            )
        ]
    }

    func refreshOdds() async throws -> [OddsEvent] {
        return try await fetchOdds()
    }

    func getCachedOdds() async throws -> [OddsEvent]? {
        return nil
    }
}