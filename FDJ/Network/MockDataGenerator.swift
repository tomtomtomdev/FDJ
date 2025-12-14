import Foundation

/// Generates realistic mock data for sports betting odds
actor MockDataGenerator {
    private let sportsData: [String: [MockSportInfo]] = [
        "basketball": [
            MockSportInfo(teams: ("Los Angeles Lakers", "Golden State Warriors"), league: "NBA"),
            MockSportInfo(teams: ("Boston Celtics", "Miami Heat"), league: "NBA"),
            MockSportInfo(teams: ("Phoenix Suns", "Denver Nuggets"), league: "NBA")
        ],
        "football": [
            MockSportInfo(teams: ("New England Patriots", "Buffalo Bills"), league: "NFL"),
            MockSportInfo(teams: ("Kansas City Chiefs", "Dallas Cowboys"), league: "NFL"),
            MockSportInfo(teams: ("Green Bay Packers", "Chicago Bears"), league: "NFL")
        ],
        "soccer": [
            MockSportInfo(teams: ("Manchester United", "Liverpool"), league: "EPL"),
            MockSportInfo(teams: ("Real Madrid", "Barcelona"), league: "La Liga"),
            MockSportInfo(teams: ("Bayern Munich", "Borussia Dortmund"), league: "Bundesliga")
        ],
        "baseball": [
            MockSportInfo(teams: ("New York Yankees", "Boston Red Sox"), league: "MLB"),
            MockSportInfo(teams: ("Los Angeles Dodgers", "San Francisco Giants"), league: "MLB")
        ],
        "hockey": [
            MockSportInfo(teams: ("Toronto Maple Leafs", "Montreal Canadiens"), league: "NHL"),
            MockSportInfo(teams: ("Chicago Blackhawks", "Detroit Red Wings"), league: "NHL")
        ]
    ]

    private let bookmakers: [String] = [
        "DraftKings", "FanDuel", "BetMGM", "William Hill", "Caesars", "PointsBet"
    ]

    /// Generates an array of mock odds events
    /// - Parameter count: Number of events to generate (default: 10)
    /// - Returns: Array of odds events
    func generateOddsEvents(count: Int = 10) -> [OddsEvent] {
        var events: [OddsEvent] = []

        for _ in 0..<count {
            events.append(generateSingleOddsEvent())
        }

        return events
    }

    /// Generates a single mock odds event
    /// - Returns: An odds event with realistic data
    private func generateSingleOddsEvent() -> OddsEvent {
        let sport = sportsData.randomElement()!
        let sportName = sport.key
        let sportInfo = sport.value.randomElement()!

        let eventId = "\(sportName)_\(sportInfo.league)_\(sportInfo.teams.0.replacingOccurrences(of: " ", with: "_"))_\(sportInfo.teams.1.replacingOccurrences(of: " ", with: "_"))_\(UUID().uuidString)"

        let commenceTime = Date().addingTimeInterval(
            TimeInterval.random(in: 3600...86400 * 7) // 1 hour to 1 week from now
        )

        let bookmakersData = generateBookmakers(for: sportName)

        return OddsEvent(
            id: eventId,
            sport: sportName,
            homeTeam: sportInfo.teams.0,
            awayTeam: sportInfo.teams.1,
            commenceTime: commenceTime,
            bookmakers: bookmakersData
        )
    }

    /// Generates mock bookmakers with odds for a given sport
    /// - Parameter sport: The sport type
    /// - Returns: Array of bookmakers with outcomes
    private func generateBookmakers(for sport: String) -> [Bookmaker] {
        let bookmakerCount = Int.random(in: 2...4)
        let selectedBookmakers = bookmakers.shuffled().prefix(bookmakerCount)

        return selectedBookmakers.map { bookmakerName in
            Bookmaker(
                name: bookmakerName,
                outcomes: generateOutcomes(for: sport)
            )
        }
    }

    /// Generates realistic odds outcomes for a sport
    /// - Parameter sport: The sport type
    /// - Returns: Array of outcomes with prices
    private func generateOutcomes(for sport: String) -> [Outcome] {
        switch sport {
        case "basketball", "baseball", "hockey":
            // Two outcomes (no draw)
            let homeWinOdds = generateRealisticOdds(impliedProbability: Double.random(in: 0.3...0.7))
            let awayWinOdds = generateRealisticOdds(impliedProbability: 1.0 - homeWinOdds.impliedProbability)

            return [
                Outcome(name: generateHomeTeamLabel(), price: homeWinOdds.price),
                Outcome(name: generateAwayTeamLabel(), price: awayWinOdds.price)
            ]

        case "football", "soccer":
            // Three outcomes (include draw)
            let homeWinProb = Double.random(in: 0.3...0.5)
            let drawProb = Double.random(in: 0.2...0.3)
            let awayWinProb = 1.0 - homeWinProb - drawProb

            let homeWinOdds = generateRealisticOdds(impliedProbability: homeWinProb)
            let drawOdds = generateRealisticOdds(impliedProbability: drawProb)
            let awayWinOdds = generateRealisticOdds(impliedProbability: awayWinProb)

            return [
                Outcome(name: generateHomeTeamLabel(), price: homeWinOdds.price),
                Outcome(name: generateAwayTeamLabel(), price: awayWinOdds.price),
                Outcome(name: "Draw", price: drawOdds.price)
            ]

        default:
            // Default to two outcomes
            return [
                Outcome(name: generateHomeTeamLabel(), price: 1.85),
                Outcome(name: generateAwayTeamLabel(), price: 1.95)
            ]
        }
    }

    /// Generates realistic odds price from implied probability
    /// - Parameter impliedProbability: The implied probability (0.0 to 1.0)
    /// - Returns: A tuple with price and implied probability
    private func generateRealisticOdds(impliedProbability: Double) -> (price: Double, impliedProbability: Double) {
        // Add bookmaker margin (typically 5-10%)
        let adjustedProbability = impliedProbability * 0.92
        let price = adjustedProbability > 0 ? (1.0 / adjustedProbability) : 10.0

        // Clamp to realistic range
        let clampedPrice = max(1.01, min(10.0, price))

        return (price: clampedPrice, impliedProbability: impliedProbability)
    }

    private func generateHomeTeamLabel() -> String {
        return ["Home", "Team 1", "Over"].randomElement()!
    }

    private func generateAwayTeamLabel() -> String {
        return ["Away", "Team 2", "Under"].randomElement()!
    }
}

// MARK: - Helper Types

private struct MockSportInfo {
    let teams: (String, String)
    let league: String
}