import Foundation

/// Mock API endpoints for simulating odds API requests
enum MockAPIEndpoints {
    private static let baseURL = "https://api.mockodds.com/v4"
    private static let defaultAPIKey = "mock_api_key_for_testing"

    /// Endpoint for fetching all upcoming odds across all sports
    static var odds: URL {
        return buildOddsURL()
    }

    /// Endpoint for fetching available sports
    static var sports: URL {
        return URL(string: "\(baseURL)/sports")!
    }

    /// Build odds URL with custom parameters
    /// - Parameters:
    ///   - apiKey: The API key (uses default if nil)
    ///   - regions: Geographic regions (default: "us")
    ///   - markets: Betting markets (default: "h2h")
    ///   - dateFormat: Date format (default: "iso")
    /// - Returns: Configured URL
    static func buildOddsURL(
        apiKey: String? = nil,
        regions: String = "us",
        markets: String = "h2h",
        dateFormat: String = "iso"
    ) -> URL {
        var components = URLComponents(string: "\(baseURL)/sports/upcoming/odds")!

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "apiKey", value: apiKey ?? defaultAPIKey),
            URLQueryItem(name: "regions", value: regions),
            URLQueryItem(name: "markets", value: markets),
            URLQueryItem(name: "dateFormat", value: dateFormat)
        ]

        components.queryItems = queryItems
        return components.url!
    }

    /// Build odds URL for a specific sport
    /// - Parameters:
    ///   - sport: The sport name (e.g., "basketball", "football")
    ///   - apiKey: The API key (uses default if nil)
    ///   - regions: Geographic regions (default: "us")
    ///   - markets: Betting markets (default: "h2h")
    /// - Returns: Configured URL
    static func oddsForSport(
        _ sport: String,
        apiKey: String? = nil,
        regions: String = "us",
        markets: String = "h2h"
    ) -> URL {
        var components = URLComponents(string: "\(baseURL)/sports/\(sport)/odds")!

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "apiKey", value: apiKey ?? defaultAPIKey),
            URLQueryItem(name: "regions", value: regions),
            URLQueryItem(name: "markets", value: markets)
        ]

        components.queryItems = queryItems
        return components.url!
    }

    /// Build URL for live odds (events that have started)
    /// - Parameters:
    ///   - apiKey: The API key (uses default if nil)
    ///   - regions: Geographic regions (default: "us")
    ///   - markets: Betting markets (default: "h2h")
    /// - Returns: Configured URL
    static func liveOdds(
        apiKey: String? = nil,
        regions: String = "us",
        markets: String = "h2h"
    ) -> URL {
        var components = URLComponents(string: "\(baseURL)/sports/live/odds")!

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "apiKey", value: apiKey ?? defaultAPIKey),
            URLQueryItem(name: "regions", value: regions),
            URLQueryItem(name: "markets", value: markets)
        ]

        components.queryItems = queryItems
        return components.url!
    }

    /// Build URL for historical odds
    /// - Parameters:
    ///   - sport: The sport name
    ///   - daysFrom: Days from now (negative for past events)
    ///   - apiKey: The API key (uses default if nil)
    ///   - regions: Geographic regions (default: "us")
    ///   - markets: Betting markets (default: "h2h")
    /// - Returns: Configured URL
    static func historicalOdds(
        sport: String,
        daysFrom: Int,
        apiKey: String? = nil,
        regions: String = "us",
        markets: String = "h2h"
    ) -> URL {
        var components = URLComponents(string: "\(baseURL)/sports/\(sport)/odds-history")!

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "apiKey", value: apiKey ?? defaultAPIKey),
            URLQueryItem(name: "daysFrom", value: String(daysFrom)),
            URLQueryItem(name: "regions", value: regions),
            URLQueryItem(name: "markets", value: markets)
        ]

        components.queryItems = queryItems
        return components.url!
    }
}