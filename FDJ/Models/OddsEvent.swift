import Foundation

/// Represents a sports event with betting odds
struct OddsEvent: Codable, Sendable, Identifiable, Equatable {
    let id: String
    let sport: String
    let homeTeam: String
    let awayTeam: String
    let commenceTime: Date
    let bookmakers: [Bookmaker]

    var displayTitle: String {
        "\(homeTeam) vs \(awayTeam)"
    }

    var sportDisplay: String {
        sport.capitalized
    }

    var isLive: Bool {
        commenceTime <= Date()
    }

    var timeUntilEvent: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: commenceTime, relativeTo: Date())
    }

    var bestOddsAcrossBookmakers: [Outcome]? {
        guard !bookmakers.isEmpty else { return nil }

        var bestOdds: [String: Outcome] = [:]

        for bookmaker in bookmakers {
            for outcome in bookmaker.outcomes {
                let key = outcome.name.lowercased()
                if let currentBest = bestOdds[key] {
                    if outcome.price > currentBest.price {
                        bestOdds[key] = outcome
                    }
                } else {
                    bestOdds[key] = outcome
                }
            }
        }

        return Array(bestOdds.values).sorted { $0.name < $1.name }
    }
}