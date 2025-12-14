import Testing
import Foundation
@testable import FDJ

struct MockNetworkClientTests {
    @Test("MockNetworkClient should fetch mock data successfully")
    func testFetchMockDataSuccess() async throws {
        // Given: A mock network client
        let mockClient = MockNetworkClient()
        let testURL = URL(string: "https://api.test.com/odds")!

        // When: Fetching data
        let data = try await mockClient.fetch(from: testURL)

        // Then: Should return valid JSON data
        #expect(data.isEmpty == false)

        // And: Should be valid JSON
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        #expect(jsonObject is [String: Any])
    }

    @Test("MockNetworkClient should simulate network failure")
    func testFetchNetworkFailure() async throws {
        // Given: A mock network client configured to fail
        let mockClient = MockNetworkClient(simulateError: true)
        let testURL = URL(string: "https://api.test.com/odds")!

        // When/Then: Should throw NetworkError
        await #expect(throws: NetworkError.self) {
            try await mockClient.fetch(from: testURL)
        }
    }

    @Test("MockNetworkClient should simulate empty response")
    func testFetchEmptyResponse() async throws {
        // Given: A mock network client configured for empty response
        let mockClient = MockNetworkClient(simulateEmpty: true)
        let testURL = URL(string: "https://api.test.com/odds")!

        // When: Fetching data
        let data = try await mockClient.fetch(from: testURL)

        // Then: Should return empty data
        #expect(data.isEmpty == true)
    }

    @Test("MockNetworkClient should simulate slow response")
    func testFetchSlowResponse() async throws {
        // Given: A mock network client with delay
        let mockClient = MockNetworkClient(delay: 0.1)
        let testURL = URL(string: "https://api.test.com/odds")!

        // When: Measuring fetch time
        let startTime = Date()
        let data = try await mockClient.fetch(from: testURL)
        let elapsed = Date().timeIntervalSince(startTime)

        // Then: Should have taken at least the specified delay
        #expect(elapsed >= 0.1)
        #expect(data.isEmpty == false)
    }
}