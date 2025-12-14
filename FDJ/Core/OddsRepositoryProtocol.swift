import Foundation

/// Protocol defining the contract for odds data operations
protocol OddsRepositoryProtocol: Sendable {
    /// Fetches odds events from the data source
    /// - Returns: An array of odds events
    /// - Throws: A RepositoryError if the operation fails
    func fetchOdds() async throws -> [OddsEvent]

    /// Refreshes odds data from the network
    /// - Returns: An array of fresh odds events
    /// - Throws: A RepositoryError if the operation fails
    func refreshOdds() async throws -> [OddsEvent]

    /// Fetches cached odds if available
    /// - Returns: An array of cached odds events or nil if no cache exists
    /// - Throws: A RepositoryError if the cache operation fails
    func getCachedOdds() async throws -> [OddsEvent]?
}