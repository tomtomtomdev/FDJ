import Testing
import Foundation
@testable import FDJ

struct CachePolicyTests {
    @Test("CachePolicy should determine cache validity")
    func testCacheValidity() {
        // Given: Cache policy with 5 minute timeout
        let policy = CachePolicy(timeout: 300)

        // When: Checking recent timestamp (1 minute ago)
        let recentTimestamp = Date().addingTimeInterval(-60)
        let isValidRecent = policy.isValid(timestamp: recentTimestamp)

        // Then: Should be valid
        #expect(isValidRecent == true)

        // When: Checking old timestamp (10 minutes ago)
        let oldTimestamp = Date().addingTimeInterval(-600)
        let isValidOld = policy.isValid(timestamp: oldTimestamp)

        // Then: Should be invalid
        #expect(isValidOld == false)
    }

    @Test("CachePolicy should handle zero timeout")
    func testZeroTimeout() {
        // Given: Cache policy with zero timeout (always invalid)
        let policy = CachePolicy(timeout: 0)
        let timestamp = Date()

        // When: Checking validity
        let isValid = policy.isValid(timestamp: timestamp)

        // Then: Should always be invalid
        #expect(isValid == false)
    }

    @Test("CachePolicy should handle negative timeout")
    func testNegativeTimeout() {
        // Given: Cache policy with negative timeout (always valid)
        let policy = CachePolicy(timeout: -1)
        let timestamp = Date()

        // When: Checking validity
        let isValid = policy.isValid(timestamp: timestamp)

        // Then: Should always be valid
        #expect(isValid == true)
    }

    @Test("CachePolicy should calculate remaining time")
    func testRemainingTime() {
        // Given: Cache policy with 60 second timeout and timestamp 30 seconds ago
        let policy = CachePolicy(timeout: 60)
        let timestamp = Date().addingTimeInterval(-30)

        // When: Calculating remaining time
        let remainingTime = policy.remainingTime(for: timestamp)

        // Then: Should have ~30 seconds remaining
        #expect(remainingTime > 20)
        #expect(remainingTime <= 30)
    }

    @Test("CachePolicy should return zero for expired cache")
    func testRemainingTimeForExpired() {
        // Given: Cache policy with 60 second timeout and timestamp 2 minutes ago
        let policy = CachePolicy(timeout: 60)
        let timestamp = Date().addingTimeInterval(-120)

        // When: Calculating remaining time
        let remainingTime = policy.remainingTime(for: timestamp)

        // Then: Should return 0
        #expect(remainingTime == 0)
    }

    @Test("CachePolicy should provide default timeout")
    func testDefaultTimeout() {
        // Given: Default cache policy
        let policy = CachePolicy()

        // Then: Should have 5 minute default timeout
        #expect(policy.timeout == 300)
    }

    @Test("CachePolicy should provide expiry date")
    func testExpiryDate() {
        // Given: Cache policy with 60 second timeout
        let policy = CachePolicy(timeout: 60)
        let timestamp = Date()

        // When: Getting expiry date
        let expiryDate = policy.expiryDate(for: timestamp)

        // Then: Should be 60 seconds after timestamp
        let expectedExpiry = timestamp.addingTimeInterval(60)
        #expect(abs(expiryDate.timeIntervalSince(expectedExpiry)) < 0.1)
    }
}