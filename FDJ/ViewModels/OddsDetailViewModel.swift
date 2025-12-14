import Foundation
import Observation

/// ViewModel for displaying detailed information about a single odds event
@Observable
@MainActor
final class OddsDetailViewModel {
    // MARK: - Properties
    let event: OddsEvent

    // MARK: - Computed Properties
    var displayTitle: String {
        event.displayTitle
    }

    var sportDisplay: String {
        event.sportDisplay
    }

    var commenceTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: event.commenceTime)
    }

    var isLive: Bool {
        event.isLive
    }

    var timeUntilEvent: String {
        event.timeUntilEvent
    }

    var bookmakers: [Bookmaker] {
        event.bookmakers
    }

    var bestOdds: [Outcome]? {
        event.bestOddsAcrossBookmakers
    }

    var uniqueOutcomes: [String] {
        Array(Set(event.bookmakers.flatMap { $0.outcomes.map { $0.name } })).sorted()
    }

    // MARK: - Initialization
    init(event: OddsEvent) {
        self.event = event
    }

    // MARK: - Public Methods
    /// Formats implied probability as a percentage
    /// - Parameter probability: The probability (0.0 to 1.0)
    /// - Returns: Formatted percentage string
    func formatImpliedProbability(_ probability: Double) -> String {
        let percentage = Int(round(probability * 100))
        return "\(percentage)%"
    }

    /// Compares odds for a specific outcome across all bookmakers
    /// - Parameter outcomeName: The name of the outcome
    /// - Returns: Array of bookmaker odds for that outcome
    func compareOddsForOutcome(_ outcomeName: String) -> [BookmakerOdds] {
        var comparison: [BookmakerOdds] = []

        for bookmaker in event.bookmakers {
            if let outcome = bookmaker.outcomes.first(where: { $0.name == outcomeName }) {
                comparison.append(BookmakerOdds(
                    bookmakerName: bookmaker.name,
                    price: outcome.price,
                    isBest: isBestPrice(for: outcomeName, price: outcome.price)
                ))
            }
        }

        return comparison.sorted { $0.price > $1.price }
    }

    /// Finds the bookmaker offering the best odds for an outcome
    /// - Parameter outcomeName: The name of the outcome
    /// - Returns: The best bookmaker with odds, or nil if not found
    func bestBookmakerForOutcome(_ outcomeName: String) -> BookmakerOdds? {
        return compareOddsForOutcome(outcomeName).first
    }

    /// Calculates the arbitrage opportunity (if any)
    /// - Returns: Arbitrage information or nil if no opportunity
    func calculateArbitrage() -> ArbitrageInfo? {
        guard let uniqueOutcomes = bestOdds, uniqueOutcomes.count >= 2 else { return nil }

        var totalImpliedProbability = 0.0
        for outcome in uniqueOutcomes {
            totalImpliedProbability += (1.0 / outcome.price)
        }

        if totalImpliedProbability < 1.0 {
            let profitMargin = (1.0 - totalImpliedProbability) * 100
            return ArbitrageInfo(
                totalImpliedProbability: totalImpliedProbability,
                profitMargin: profitMargin,
                outcomes: uniqueOutcomes
            )
        }

        return nil
    }

    // MARK: - Private Methods
    private func isBestPrice(for outcomeName: String, price: Double) -> Bool {
        guard let bestOdds = bestOdds,
              let bestOutcome = bestOdds.first(where: { $0.name == outcomeName }) else {
            return false
        }
        return abs(price - bestOutcome.price) < 0.001
    }
}

// MARK: - Supporting Types

/// Represents a bookmaker's odds for a specific outcome
struct BookmakerOdds: Identifiable {
    let id = UUID()
    let bookmakerName: String
    let price: Double
    let isBest: Bool

    var displayPrice: String {
        String(format: "%.2f", price)
    }
}

/// Represents an arbitrage opportunity
struct ArbitrageInfo {
    let totalImpliedProbability: Double
    let profitMargin: Double
    let outcomes: [Outcome]

    var formattedProfitMargin: String {
        String(format: "%.2f%%", profitMargin)
    }
}