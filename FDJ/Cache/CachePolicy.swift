import Foundation

/// Defines caching behavior and policies for odds data
struct CachePolicy: Sendable {
    /// Cache timeout in seconds
    let timeout: TimeInterval

    /// Default cache timeout (5 minutes)
    static let defaultTimeout: TimeInterval = 300

    /// Initialize with custom timeout
    /// - Parameter timeout: Cache timeout in seconds
    init(timeout: TimeInterval = defaultTimeout) {
        self.timeout = timeout
    }

    /// Determines if cached data is still valid
    /// - Parameter timestamp: The timestamp when data was cached
    /// - Returns: True if data is still valid, false otherwise
    func isValid(timestamp: Date) -> Bool {
        // Negative timeout means cache never expires
        if timeout < 0 {
            return true
        }

        // Zero timeout means cache is always expired
        if timeout == 0 {
            return false
        }

        let timeSinceCache = Date().timeIntervalSince(timestamp)
        return timeSinceCache <= timeout
    }

    /// Calculates remaining time before cache expires
    /// - Parameter timestamp: The timestamp when data was cached
    /// - Returns: Remaining time in seconds (0 if expired)
    func remainingTime(for timestamp: Date) -> TimeInterval {
        let timeSinceCache = Date().timeIntervalSince(timestamp)
        let remaining = timeout - timeSinceCache
        return max(0, remaining)
    }

    /// Calculates expiry date for cached data
    /// - Parameter timestamp: The timestamp when data was cached
    /// - Returns: Date when cache expires
    func expiryDate(for timestamp: Date) -> Date {
        // Negative timeout means cache never expires (use distant future)
        if timeout < 0 {
            return Date.distantFuture
        }

        return timestamp.addingTimeInterval(timeout)
    }
}