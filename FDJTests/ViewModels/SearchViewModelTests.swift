import Testing
import Foundation
@testable import FDJ

struct SearchViewModelTests {
    @Test("SearchViewModel should initialize with empty state")
    func testInitialState() {
        // Given: A view model
        let viewModel = SearchViewModel()

        // Then: Initial state should be empty
        #expect(viewModel.searchText.isEmpty == true)
        #expect(viewModel.filteredOdds.isEmpty == true)
        #expect(viewModel.isSearching == false)
    }

    @Test("SearchViewModel should filter odds by team name")
    func testSearchByTeamName() {
        // Given: A view model with test odds
        let viewModel = SearchViewModel()
        viewModel.updateOdds(createTestOdds())

        // When: Searching for "Lakers"
        viewModel.searchText = "Lakers"

        // Then: Should filter to Lakers events
        #expect(viewModel.filteredOdds.count == 1)
        #expect(viewModel.filteredOdds.first?.homeTeam == "Los Angeles Lakers")
    }

    @Test("SearchViewModel should filter odds by sport")
    func testSearchBySport() {
        // Given: A view model with test odds
        let viewModel = SearchViewModel()
        viewModel.updateOdds(createTestOdds())

        // When: Searching for "basketball"
        viewModel.searchText = "basketball"

        // Then: Should filter to basketball events
        #expect(viewModel.filteredOdds.count == 2)
        viewModel.filteredOdds.forEach { odd in
            #expect(odd.sport == "basketball")
        }
    }

    @Test("SearchViewModel should handle case insensitive search")
    func testCaseInsensitiveSearch() {
        // Given: A view model with test odds
        let viewModel = SearchViewModel()
        viewModel.updateOdds(createTestOdds())

        // When: Searching with different cases
        viewModel.searchText = "lakers"
        #expect(viewModel.filteredOdds.count == 1)

        viewModel.searchText = "BASKETBALL"
        #expect(viewModel.filteredOdds.count == 2)
    }

    @Test("SearchViewModel should handle empty search")
    func testEmptySearch() {
        // Given: A view model with test odds and search term
        let viewModel = SearchViewModel()
        viewModel.updateOdds(createTestOdds())
        viewModel.searchText = "Lakers"
        #expect(viewModel.filteredOdds.count == 1)

        // When: Clearing search
        viewModel.searchText = ""

        // Then: Should clear filtered results
        #expect(viewModel.filteredOdds.isEmpty == true)
    }

    @Test("SearchViewModel should update odds")
    func testUpdateOdds() {
        // Given: A view model
        let viewModel = SearchViewModel()

        // When: Updating odds
        viewModel.updateOdds(createTestOdds())

        // Then: Should have odds available for searching
        #expect(viewModel.allOdds.count == 4)
    }

    @Test("SearchViewModel should debounce search")
    func testSearchDebouncing() async throws {
        // Given: A view model with test odds
        let viewModel = SearchViewModel()
        viewModel.updateOdds(createTestOdds())

        // When: Quickly changing search terms
        viewModel.searchText = "L"
        try await Task.sleep(for: .milliseconds(100))
        viewModel.searchText = "La"
        try await Task.sleep(for: .milliseconds(100))
        viewModel.searchText = "Lak"
        try await Task.sleep(for: .milliseconds(400)) // Wait for debounce

        // Then: Should only search with last term
        #expect(viewModel.filteredOdds.count == 1)
        #expect(viewModel.filteredOdds.first?.homeTeam == "Los Angeles Lakers")
    }

    @Test("SearchViewModel should provide search suggestions")
    func testSearchSuggestions() {
        // Given: A view model with test odds
        let viewModel = SearchViewModel()
        viewModel.updateOdds(createTestOdds())

        // When: Getting suggestions for partial text
        let suggestions = viewModel.searchSuggestions(for: "La")

        // Then: Should return matching team names
        #expect(suggestions.contains("Los Angeles Lakers"))
        #expect(suggestions.isEmpty == false)
    }

    @Test("SearchViewModel should clear search")
    func testClearSearch() {
        // Given: A view model with active search
        let viewModel = SearchViewModel()
        viewModel.updateOdds(createTestOdds())
        viewModel.searchText = "Lakers"

        // When: Clearing search
        viewModel.clearSearch()

        // Then: Should reset state
        #expect(viewModel.searchText.isEmpty == true)
        #expect(viewModel.filteredOdds.isEmpty == true)
    }

    @Test("SearchViewModel should highlight search text")
    func testSearchHighlighting() {
        // Given: A view model
        let viewModel = SearchViewModel()
        let text = "Los Angeles Lakers"
        let searchText = "Lakers"

        // When: Highlighting search text
        let highlighted = viewModel.highlightedText(text: text, searchText: searchText)

        // Then: Should include highlighting (simplified check)
        #expect(highlighted.contains("Lakers"))
    }

    // MARK: - Helper Methods

    private func createTestOdds() -> [OddsEvent] {
        return [
            OddsEvent(
                id: "1",
                sport: "basketball",
                homeTeam: "Los Angeles Lakers",
                awayTeam: "Golden State Warriors",
                commenceTime: Date().addingTimeInterval(3600),
                bookmakers: []
            ),
            OddsEvent(
                id: "2",
                sport: "basketball",
                homeTeam: "Boston Celtics",
                awayTeam: "Miami Heat",
                commenceTime: Date().addingTimeInterval(7200),
                bookmakers: []
            ),
            OddsEvent(
                id: "3",
                sport: "football",
                homeTeam: "New England Patriots",
                awayTeam: "Buffalo Bills",
                commenceTime: Date().addingTimeInterval(86400),
                bookmakers: []
            ),
            OddsEvent(
                id: "4",
                sport: "soccer",
                homeTeam: "Manchester United",
                awayTeam: "Liverpool",
                commenceTime: Date().addingTimeInterval(86400),
                bookmakers: []
            )
        ]
    }
}