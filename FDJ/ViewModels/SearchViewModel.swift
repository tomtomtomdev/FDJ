import Foundation
import Observation

/// ViewModel for managing search functionality for odds events
@Observable
@MainActor
final class SearchViewModel {
    // MARK: - Published Properties
    var searchText = "" {
        didSet {
            Task {
                await debouncedSearch()
            }
        }
    }

    private(set) var filteredOdds: [OddsEvent] = []
    private(set) var isSearching = false
    private var allOdds: [OddsEvent] = []

    // MARK: - Private Properties
    private var searchTask: Task<Void, Never>?

    // MARK: - Computed Properties
    var hasResults: Bool {
        !filteredOdds.isEmpty
    }

    var hasSearchTerm: Bool {
        !searchText.isEmpty
    }

    // MARK: - Public Methods
    /// Updates the odds data available for searching
    /// - Parameter odds: The odds events to search through
    func updateOdds(_ odds: [OddsEvent]) {
        self.allOdds = odds
        if !searchText.isEmpty {
            Task {
                await performSearch()
            }
        }
    }

    /// Clears the search and resets state
    func clearSearch() {
        searchTask?.cancel()
        searchTask = nil
        searchText = ""
        filteredOdds = []
        isSearching = false
    }

    /// Gets search suggestions based on current input
    /// - Parameter text: The text to get suggestions for
    /// - Returns: Array of suggested search terms
    func searchSuggestions(for text: String) -> [String] {
        guard text.count >= 2 else { return [] }

        let lowercasedText = text.lowercased()
        var suggestions = Set<String>()

        for odd in allOdds {
            // Check team names
            if odd.homeTeam.lowercased().contains(lowercasedText) {
                suggestions.insert(odd.homeTeam)
            }
            if odd.awayTeam.lowercased().contains(lowercasedText) {
                suggestions.insert(odd.awayTeam)
            }

            // Check sport names
            if odd.sport.lowercased().contains(lowercasedText) {
                suggestions.insert(odd.sport)
            }
        }

        return Array(suggestions).sorted().prefix(5).map { $0 }
    }

    /// Highlights search text in a display string
    /// - Parameters:
    ///   - text: The text to display
    ///   - searchText: The text to highlight
    /// - Returns: Attributed string with highlighted text
    func highlightedText(text: String, searchText: String) -> AttributedString {
        var attributedString = AttributedString(text)

        guard !searchText.isEmpty else {
            return attributedString
        }

        let range = text.lowercased().range(of: searchText.lowercased())
        if let range = range {
            let nsRange = NSRange(range, in: text)
            if let attributedRange = Range(nsRange, in: attributedString) {
                attributedString[attributedRange].backgroundColor = .yellow
            }
        }

        return attributedString
    }

    // MARK: - Private Methods
    private func debouncedSearch() async {
        // Cancel previous search
        searchTask?.cancel()

        // Create new search task with debounce
        searchTask = Task {
            isSearching = true
            try? await Task.sleep(for: .milliseconds(300))

            if !Task.isCancelled {
                await performSearch()
            }

            isSearching = false
        }
    }

    private func performSearch() async {
        guard !searchText.isEmpty else {
            filteredOdds = []
            return
        }

        let lowercasedSearchText = searchText.lowercased()

        filteredOdds = allOdds.filter { odd in
            odd.homeTeam.lowercased().contains(lowercasedSearchText) ||
            odd.awayTeam.lowercased().contains(lowercasedSearchText) ||
            odd.sport.lowercased().contains(lowercasedSearchText) ||
            odd.displayTitle.lowercased().contains(lowercasedSearchText)
        }
    }
}