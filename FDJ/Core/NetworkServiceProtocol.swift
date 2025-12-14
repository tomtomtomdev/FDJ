import Foundation

/// Protocol defining the contract for network operations
protocol NetworkServiceProtocol: Sendable {
    /// Fetches data from the specified URL
    /// - Parameter url: The URL to fetch data from
    /// - Returns: The data fetched from the URL
    /// - Throws: A NetworkError if the request fails
    func fetch(from url: URL) async throws -> Data
}