import Foundation
import Observation

/// ViewModel for managing the list of sports odds events
@Observable
@MainActor
final class OddsListViewModel {
    // MARK: - Published Properties
    private(set) var odds: [OddsEvent] = []
    private(set) var isLoading = false
    private(set) var error: Error?

    // MARK: - Filter State
    private(set) var selectedSport: String?
    var filteredOdds: [OddsEvent] {
        guard let selectedSport = selectedSport else { return odds }
        return odds.filter { $0.sport == selectedSport }
    }

    // MARK: - Dependencies
    private let repository: OddsRepositoryProtocol

    // MARK: - Initialization
    init(repository: OddsRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Public Methods
    /// Loads odds from the repository
    func loadOdds() async {
        error = nil
        isLoading = true

        do {
            odds = try await repository.fetchOdds()
        } catch {
            self.error = error
            odds = []
        }

        isLoading = false
    }

    /// Refreshes odds from the network (ignoring cache)
    func refreshOdds() async {
        error = nil
        isLoading = true

        do {
            odds = try await repository.refreshOdds()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    /// Filters odds by sport type
    /// - Parameter sport: The sport to filter by
    func filterBySport(_ sport: String) {
        selectedSport = sport
    }

    /// Clears any active filters
    func clearFilter() {
        selectedSport = nil
    }

    /// Returns unique sports available in the odds
    var uniqueSports: [String] {
        Array(Set(odds.map { $0.sport })).sorted()
    }

    /// Formats the time until an event starts
    /// - Parameter date: The event start date
    /// - Returns: Formatted time string
    func formatTimeUntil(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    /// Returns the best odds across all bookmakers for an event
    /// - Parameter event: The odds event
    /// - Returns: Array of best odds
    func bestOddsForEvent(_ event: OddsEvent) -> [Outcome]? {
        return event.bestOddsAcrossBookmakers
    }

    /// Determines if an event is live
    /// - Parameter event: The odds event
    /// - Returns: True if event is live
    func isLive(_ event: OddsEvent) -> Bool {
        event.isLive
    }

    /// Returns the count of visible odds (after filtering)
    var visibleOddsCount: Int {
        filteredOdds.count
    }

    /// Returns a boolean indicating if there are filtered results
    var hasFilteredResults: Bool {
        selectedSport != nil
    }
}