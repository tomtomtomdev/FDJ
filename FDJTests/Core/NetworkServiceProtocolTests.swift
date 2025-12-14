import Testing
import Foundation
@testable import FDJ

struct NetworkServiceProtocolTests {
    @Test("NetworkServiceProtocol should exist and be fetchable")
    func testNetworkServiceProtocolExists() async throws {
        // This test verifies that the NetworkServiceProtocol exists
        // and defines the expected contract for network operations

        // Given: A mock implementation of NetworkServiceProtocol
        let mockService = MockNetworkService()

        // Then: The protocol should conform to NetworkServiceProtocol
        #expect(mockService is any NetworkServiceProtocol)
    }

    @Test("NetworkServiceProtocol should fetch data successfully")
    func testFetchDataSuccess() async throws {
        // Given: A mock network service
        let mockService = MockNetworkService()
        let testURL = URL(string: "https://api.test.com/odds")!

        // When: Fetching data
        let result = try await mockService.fetch(from: testURL)

        // Then: Should return valid data
        #expect(result.isEmpty == false)
    }

    @Test("NetworkServiceProtocol should handle network errors")
    func testFetchDataFailure() async throws {
        // Given: A mock network service configured to fail
        let mockService = MockNetworkService(shouldFail: true)
        let testURL = URL(string: "https://api.test.com/odds")!

        // When/Then: Should throw an error
        await #expect(throws: NetworkError.self) {
            try await mockService.fetch(from: testURL)
        }
    }
}

// MARK: - Mock Implementation for Testing
actor MockNetworkService: NetworkServiceProtocol {
    private let shouldFail: Bool

    init(shouldFail: Bool = false) {
        self.shouldFail = shouldFail
    }

    func fetch(from url: URL) async throws -> Data {
        if shouldFail {
            throw NetworkError.requestFailed
        }

        // Return mock JSON data
        return """
        {
            "success": true,
            "data": [
                {
                    "id": "test_event_1",
                    "sport": "basketball",
                    "teams": ["Team A", "Team B"]
                }
            ]
        }
        """.data(using: .utf8) ?? Data()
    }
}