import Foundation
import Observation

/// ViewModel for managing favorite odds events
@Observable
@MainActor
final class FavoritesViewModel: ObservableObject {
    // MARK: - Published Properties
    private(set) var favoriteEvents: [OddsEvent] = []
    private(set) var isLoading = false

    // MARK: - Dependencies
    private let favoritesService: FavoritesServiceProtocol

    // MARK: - Initialization
    init(favoritesService: FavoritesServiceProtocol) {
        self.favoritesService = favoritesService
    }

    // MARK: - Computed Properties
    var favoriteCount: Int {
        favoriteEvents.count
    }

    var hasFavorites: Bool {
        !favoriteEvents.isEmpty
    }

    // MARK: - Public Methods
    /// Loads all favorites from the service
    func loadFavorites() async {
        isLoading = true
        favoriteEvents = await favoritesService.getAllFavorites().sorted { $0.commenceTime < $1.commenceTime }
        isLoading = false
    }

    /// Adds an event to favorites
    /// - Parameter event: The event to add
    func addFavorite(_ event: OddsEvent) async {
        await favoritesService.addFavorite(event)
        await loadFavorites()
    }

    /// Removes an event from favorites
    /// - Parameter event: The event to remove
    func removeFavorite(_ event: OddsEvent) async {
        await favoritesService.removeFavorite(event)
        await loadFavorites()
    }

    /// Toggles the favorite status of an event
    /// - Parameter event: The event to toggle
    func toggleFavorite(_ event: OddsEvent) async {
        if await favoritesService.isFavorite(event) {
            await removeFavorite(event)
        } else {
            await addFavorite(event)
        }
    }

    /// Checks if an event is a favorite
    /// - Parameter event: The event to check
    /// - Returns: True if the event is a favorite
    func isFavorite(_ event: OddsEvent) async -> Bool {
        return await favoritesService.isFavorite(event)
    }

    /// Clears all favorites
    func clearAllFavorites() async {
        await favoritesService.clearAll()
        await loadFavorites()
    }

    /// Gets live favorites only
    /// - Returns: Array of live favorite events
    func getLiveFavorites() async -> [OddsEvent] {
        return favoriteEvents.filter { $0.isLive }
    }

    /// Gets upcoming favorites only
    /// - Returns: Array of upcoming favorite events
    func getUpcomingFavorites() async -> [OddsEvent] {
        return favoriteEvents.filter { !$0.isLive }
    }

    /// Groups favorites by sport
    /// - Returns: Dictionary mapping sports to events
    func getFavoritesBySport() async -> [String: [OddsEvent]] {
        return Dictionary(grouping: favoriteEvents) { $0.sport }
    }

    /// Updates odds in favorites with latest data
    /// - Parameter latestOdds: The latest odds data
    func updateFavoritesWithLatest(_ latestOdds: [OddsEvent]) async {
        var updatedFavorites: [OddsEvent] = []

        for favorite in favoriteEvents {
            // Find matching event in latest odds
            if let latest = latestOdds.first(where: { $0.id == favorite.id }) {
                // Update bookmakers and odds
                let updatedEvent = OddsEvent(
                    id: favorite.id,
                    sport: latest.sport,
                    homeTeam: latest.homeTeam,
                    awayTeam: latest.awayTeam,
                    commenceTime: latest.commenceTime,
                    bookmakers: latest.bookmakers
                )
                updatedFavorites.append(updatedEvent)
            } else {
                // Keep original if no update available
                updatedFavorites.append(favorite)
            }
        }

        favoriteEvents = updatedFavorites.sorted { $0.commenceTime < $1.commenceTime }
    }
}