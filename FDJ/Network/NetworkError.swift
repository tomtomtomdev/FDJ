import Foundation

/// Represents network-related errors that can occur during API requests
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed
    case invalidResponse
    case decodingError(Error)
    case noData
    case unauthorized
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided is invalid"
        case .requestFailed:
            return "The network request failed"
        case .invalidResponse:
            return "The server returned an invalid response"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .noData:
            return "No data was returned from the server"
        case .unauthorized:
            return "Authentication failed - please check your credentials"
        case .serverError(let code):
            return "Server error occurred with code: \(code)"
        }
    }
}