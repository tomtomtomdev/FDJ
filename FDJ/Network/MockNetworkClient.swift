import Foundation

/// Mock network client that simulates API responses for testing
actor MockNetworkClient: NetworkServiceProtocol {
    private let simulateError: Bool
    private let simulateEmpty: Bool
    private let delay: TimeInterval

    init(simulateError: Bool = false, simulateEmpty: Bool = false, delay: TimeInterval = 0) {
        self.simulateError = simulateError
        self.simulateEmpty = simulateEmpty
        self.delay = delay
    }

    func fetch(from url: URL) async throws -> Data {
        // Simulate network delay if configured
        if delay > 0 {
            try await Task.sleep(for: .seconds(delay))
        }

        // Simulate network error
        if simulateError {
            throw NetworkError.requestFailed
        }

        // Simulate empty response
        if simulateEmpty {
            return Data()
        }

        // Return mock data based on URL
        return try await generateMockData(for: url)
    }

    private func generateMockData(for url: URL) async throws -> Data {
        let mockData: [String: Any]

        if url.absoluteString.contains("odds") {
            mockData = generateOddsData()
        } else {
            mockData = ["success": true, "message": "Mock response"]
        }

        return try JSONSerialization.data(withJSONObject: mockData)
    }

    private func generateOddsData() -> [String: Any] {
        return [
            "success": true,
            "data": [
                [
                    "id": "basketball_nba_lakers_warriors_\(Date().timeIntervalSince1970)",
                    "sport": "basketball",
                    "homeTeam": "Los Angeles Lakers",
                    "awayTeam": "Golden State Warriors",
                    "commenceTime": ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600)),
                    "bookmakers": [
                        [
                            "name": "DraftKings",
                            "outcomes": [
                                ["name": "Los Angeles Lakers", "price": 1.85],
                                ["name": "Golden State Warriors", "price": 1.95]
                            ]
                        ],
                        [
                            "name": "FanDuel",
                            "outcomes": [
                                ["name": "Los Angeles Lakers", "price": 1.90],
                                ["name": "Golden State Warriors", "price": 1.90]
                            ]
                        ]
                    ]
                ],
                [
                    "id": "football_nfl_patriots_bills_\(Date().timeIntervalSince1970)",
                    "sport": "football",
                    "homeTeam": "New England Patriots",
                    "awayTeam": "Buffalo Bills",
                    "commenceTime": ISO8601DateFormatter().string(from: Date().addingTimeInterval(7200)),
                    "bookmakers": [
                        [
                            "name": "BetMGM",
                            "outcomes": [
                                ["name": "New England Patriots", "price": 2.10],
                                ["name": "Buffalo Bills", "price": 1.80],
                                ["name": "Draw", "price": 3.40]
                            ]
                        ]
                    ]
                ],
                [
                    "id": "soccer_epl_manchester_liverpool_\(Date().timeIntervalSince1970)",
                    "sport": "soccer",
                    "homeTeam": "Manchester United",
                    "awayTeam": "Liverpool",
                    "commenceTime": ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400)),
                    "bookmakers": [
                        [
                            "name": "William Hill",
                            "outcomes": [
                                ["name": "Manchester United", "price": 2.50],
                                ["name": "Liverpool", "price": 2.80],
                                ["name": "Draw", "price": 3.20]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    }
}