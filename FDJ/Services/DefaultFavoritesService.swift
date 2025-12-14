import Foundation

/// Default implementation of FavoritesServiceProtocol using UserDefaults
actor DefaultFavoritesService: FavoritesServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favorite_events"
    private let eventsKey = "favorite_events_data"

    func addFavorite(_ event: OddsEvent) async {
        var favorites = getFavoriteIds()
        favorites.insert(event.id)
        saveFavoriteIds(favorites)
        saveFavoriteEvent(event)
    }

    func removeFavorite(_ event: OddsEvent) async {
        var favorites = getFavoriteIds()
        favorites.remove(event.id)
        saveFavoriteIds(favorites)
        removeFavoriteEvent(event.id)
    }

    func isFavorite(_ event: OddsEvent) async -> Bool {
        return getFavoriteIds().contains(event.id)
    }

    func getAllFavorites() async -> [OddsEvent] {
        let favoriteIds = getFavoriteIds()
        var events: [OddsEvent] = []

        for id in favoriteIds {
            if let event = getFavoriteEvent(id: id) {
                events.append(event)
            }
        }

        return events.sorted { $0.commenceTime < $1.commenceTime }
    }

    func clearAll() async {
        saveFavoriteIds(Set<String>())
        clearAllFavoriteEvents()
    }

    // MARK: - Private Methods
    private func getFavoriteIds() -> Set<String> {
        guard let data = userDefaults.data(forKey: favoritesKey),
              let ids = try? JSONDecoder().decode(Set<String>.self, from: data) else {
            return Set<String>()
        }
        return ids
    }

    private func saveFavoriteIds(_ ids: Set<String>) {
        if let data = try? JSONEncoder().encode(ids) {
            userDefaults.set(data, forKey: favoritesKey)
        }
    }

    private func saveFavoriteEvent(_ event: OddsEvent) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let key = "\(eventsKey)_\(event.id)"
        if let data = try? encoder.encode(event) {
            userDefaults.set(data, forKey: key)
        }
    }

    private func getFavoriteEvent(id: String) -> OddsEvent? {
        let key = "\(eventsKey)_\(id)"
        guard let data = userDefaults.data(forKey: key) else { return nil }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try? decoder.decode(OddsEvent.self, from: data)
    }

    private func removeFavoriteEvent(_ id: String) {
        let key = "\(eventsKey)_\(id)"
        userDefaults.removeObject(forKey: key)
    }

    private func clearAllFavoriteEvents() {
        // Remove all event data
        let allKeys = userDefaults.dictionaryRepresentation().keys
        for key in allKeys {
            if key.hasPrefix(eventsKey) {
                userDefaults.removeObject(forKey: key)
            }
        }
    }

    /// Update favorite events with latest data
    /// - Parameter latestOdds: Array of latest odds from API
    func updateFavoritesWithLatest(_ latestOdds: [OddsEvent]) async -> [OddsEvent] {
        let favoriteIds = getFavoriteIds()
        var updatedFavorites: [OddsEvent] = []

        for id in favoriteIds {
            if let latest = latestOdds.first(where: { $0.id == id }) {
                // Update with latest data
                let updatedEvent = OddsEvent(
                    id: latest.id,
                    sport: latest.sport,
                    homeTeam: latest.homeTeam,
                    awayTeam: latest.awayTeam,
                    commenceTime: latest.commenceTime,
                    bookmakers: latest.bookmakers
                )
                saveFavoriteEvent(updatedEvent)
                updatedFavorites.append(updatedEvent)
            } else if let cached = getFavoriteEvent(id: id) {
                // Keep cached event if no update available
                updatedFavorites.append(cached)
            }
        }

        return updatedFavorites.sorted { $0.commenceTime < $1.commenceTime }
    }
}