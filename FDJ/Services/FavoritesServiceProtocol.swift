import Foundation

/// Protocol defining the contract for managing favorite odds events
protocol FavoritesServiceProtocol: Sendable {
    /// Adds an event to favorites
    /// - Parameter event: The event to add
    func addFavorite(_ event: OddsEvent) async

    /// Removes an event from favorites
    /// - Parameter event: The event to remove
    func removeFavorite(_ event: OddsEvent) async

    /// Checks if an event is in favorites
    /// - Parameter event: The event to check
    /// - Returns: True if the event is a favorite
    func isFavorite(_ event: OddsEvent) async -> Bool

    /// Gets all favorite events
    /// - Returns: Array of favorite events
    func getAllFavorites() async -> [OddsEvent]

    /// Clears all favorites
    func clearAll() async
}