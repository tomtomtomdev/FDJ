import Foundation

/// Default implementation of OddsRepositoryProtocol
actor DefaultOddsRepository: OddsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let dataGenerator: MockDataGenerator
    private let cacheManager: OddsCacheManager

    init(
        networkService: NetworkServiceProtocol,
        dataGenerator: MockDataGenerator,
        cacheTimeout: TimeInterval = 300 // 5 minutes default
    ) {
        self.networkService = networkService
        self.dataGenerator = dataGenerator
        self.cacheManager = OddsCacheManager(cacheTimeout: cacheTimeout)
    }

    func fetchOdds() async throws -> [OddsEvent] {
        // First, check if we have valid cache
        if let cachedOdds = try await cacheManager.getCachedOdds() {
            return cachedOdds
        }

        // If no valid cache, fetch from network
        do {
            let odds = try await fetchFromNetwork()
            try await cacheManager.cacheOdds(odds)
            return odds
        } catch {
            // If network fails, try to return stale cache if available
            if let staleCache = try await cacheManager.getStaleCachedOdds() {
                return staleCache
            }
            throw error
        }
    }

    func refreshOdds() async throws -> [OddsEvent] {
        // Force fetch from network
        let odds = try await fetchFromNetwork()
        try await cacheManager.cacheOdds(odds)
        return odds
    }

    func getCachedOdds() async throws -> [OddsEvent]? {
        return try await cacheManager.getCachedOdds()
    }

    // MARK: - Private Methods

    private func fetchFromNetwork() async throws -> [OddsEvent] {
        // Use the mock data generator instead of actual network
        // In a real implementation, this would parse network response
        let mockData = try await networkService.fetch(from: MockAPIEndpoints.odds)

        // For mock implementation, generate data directly
        return await dataGenerator.generateOddsEvents(count: 15)
    }
}