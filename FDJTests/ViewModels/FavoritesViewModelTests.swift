import Testing
import Foundation
@testable import FDJ

struct FavoritesViewModelTests {
    @Test("FavoritesViewModel should initialize with empty favorites")
    func testInitialState() async {
        // Given: A favorites service
        let favoritesService = MockFavoritesService()

        // When: Creating view model
        let viewModel = FavoritesViewModel(favoritesService: favoritesService)

        // Then: Should start with empty favorites
        #expect(viewModel.favoriteEvents.isEmpty == true)
        #expect(viewModel.isLoading == false)
    }

    @Test("FavoritesViewModel should load favorites")
    func testLoadFavorites() async {
        // Given: A favorites service with saved favorites
        let favoritesService = MockFavoritesService()
        let testEvent = createTestEvent()
        await favoritesService.addFavorite(testEvent)
        let viewModel = FavoritesViewModel(favoritesService: favoritesService)

        // When: Loading favorites
        await viewModel.loadFavorites()

        // Then: Should display favorites
        #expect(viewModel.favoriteEvents.count == 1)
        #expect(viewModel.favoriteEvents.first?.id == testEvent.id)
    }

    @Test("FavoritesViewModel should add favorite")
    func testAddFavorite() async {
        // Given: A view model
        let favoritesService = MockFavoritesService()
        let viewModel = FavoritesViewModel(favoritesService: favoritesService)
        let testEvent = createTestEvent()

        // When: Adding favorite
        await viewModel.addFavorite(testEvent)

        // Then: Should be added to favorites
        #expect(viewModel.favoriteEvents.count == 1)
        #expect(viewModel.isFavorite(testEvent) == true)
    }

    @Test("FavoritesViewModel should remove favorite")
    func testRemoveFavorite() async {
        // Given: A view model with a favorite
        let favoritesService = MockFavoritesService()
        let viewModel = FavoritesViewModel(favoritesService: favoritesService)
        let testEvent = createTestEvent()
        await viewModel.addFavorite(testEvent)
        #expect(viewModel.favoriteEvents.count == 1)

        // When: Removing favorite
        await viewModel.removeFavorite(testEvent)

        // Then: Should be removed from favorites
        #expect(viewModel.favoriteEvents.isEmpty == true)
        #expect(viewModel.isFavorite(testEvent) == false)
    }

    @Test("FavoritesViewModel should toggle favorite")
    func testToggleFavorite() async {
        // Given: A view model
        let favoritesService = MockFavoritesService()
        let viewModel = FavoritesViewModel(favoritesService: favoritesService)
        let testEvent = createTestEvent()

        // When: Toggling favorite (adding)
        await viewModel.toggleFavorite(testEvent)
        #expect(viewModel.isFavorite(testEvent) == true)

        // When: Toggling favorite (removing)
        await viewModel.toggleFavorite(testEvent)
        #expect(viewModel.isFavorite(testEvent) == false)
    }

    @Test("FavoritesViewModel should sort favorites by commence time")
    func testSortFavorites() async {
        // Given: A view model with multiple favorites
        let favoritesService = MockFavoritesService()
        let viewModel = FavoritesViewModel(favoritesService: favoritesService)

        let event1 = createTestEvent(id: "1", commenceTime: Date().addingTimeInterval(7200))
        let event2 = createTestEvent(id: "2", commenceTime: Date().addingTimeInterval(3600))
        let event3 = createTestEvent(id: "3", commenceTime: Date().addingTimeInterval(10800))

        await viewModel.addFavorite(event1)
        await viewModel.addFavorite(event2)
        await viewModel.addFavorite(event3)

        // Then: Should be sorted by commence time
        let sortedEvents = viewModel.favoriteEvents
        #expect(sortedEvents[0].id == "2") // 1 hour
        #expect(sortedEvents[1].id == "1") // 2 hours
        #expect(sortedEvents[2].id == "3") // 3 hours
    }

    @Test("FavoritesViewModel should handle duplicate favorites")
    func testDuplicateFavorites() async {
        // Given: A view model
        let favoritesService = MockFavoritesService()
        let viewModel = FavoritesViewModel(favoritesService: favoritesService)
        let testEvent = createTestEvent()

        // When: Adding the same favorite twice
        await viewModel.addFavorite(testEvent)
        await viewModel.addFavorite(testEvent)

        // Then: Should only have one copy
        #expect(viewModel.favoriteEvents.count == 1)
    }

    @Test("FavoritesViewModel should clear all favorites")
    func testClearAllFavorites() async {
        // Given: A view model with multiple favorites
        let favoritesService = MockFavoritesService()
        let viewModel = FavoritesViewModel(favoritesService: favoritesService)

        await viewModel.addFavorite(createTestEvent(id: "1"))
        await viewModel.addFavorite(createTestEvent(id: "2"))
        #expect(viewModel.favoriteEvents.count == 2)

        // When: Clearing all favorites
        await viewModel.clearAllFavorites()

        // Then: Should be empty
        #expect(viewModel.favoriteEvents.isEmpty == true)
    }

    @Test("FavoritesViewModel should get favorite count")
    func testFavoriteCount() async {
        // Given: A view model
        let favoritesService = MockFavoritesService()
        let viewModel = FavoritesViewModel(favoritesService: favoritesService)

        // Then: Initial count should be 0
        #expect(viewModel.favoriteCount == 0)

        // When: Adding favorites
        await viewModel.addFavorite(createTestEvent(id: "1"))
        #expect(viewModel.favoriteCount == 1)

        await viewModel.addFavorite(createTestEvent(id: "2"))
        #expect(viewModel.favoriteCount == 2)

        // When: Removing a favorite
        await viewModel.removeFavorite(createTestEvent(id: "1"))
        #expect(viewModel.favoriteCount == 1)
    }

    // MARK: - Helper Methods

    private func createTestEvent(
        id: String = "test_event",
        commenceTime: Date = Date().addingTimeInterval(3600)
    ) -> OddsEvent {
        return OddsEvent(
            id: id,
            sport: "basketball",
            homeTeam: "Lakers",
            awayTeam: "Warriors",
            commenceTime: commenceTime,
            bookmakers: [
                Bookmaker(
                    name: "DraftKings",
                    outcomes: [
                        Outcome(name: "Lakers", price: 1.85),
                        Outcome(name: "Warriors", price: 1.95)
                    ]
                )
            ]
        )
    }
}

// MARK: - Mock Favorites Service for Testing

actor MockFavoritesService: FavoritesServiceProtocol {
    private var favorites: Set<String> = []
    private var events: [String: OddsEvent] = [:]

    func addFavorite(_ event: OddsEvent) async {
        favorites.insert(event.id)
        events[event.id] = event
    }

    func removeFavorite(_ event: OddsEvent) async {
        favorites.remove(event.id)
        events.removeValue(forKey: event.id)
    }

    func isFavorite(_ event: OddsEvent) async -> Bool {
        favorites.contains(event.id)
    }

    func getAllFavorites() async -> [OddsEvent] {
        return favorites.compactMap { events[$0] }
    }

    func clearAll() async {
        favorites.removeAll()
        events.removeAll()
    }
}