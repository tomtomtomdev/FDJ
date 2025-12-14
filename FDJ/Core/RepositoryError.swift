import Foundation

/// Represents repository-related errors that can occur during data operations
enum RepositoryError: Error, LocalizedError {
    case fetchFailed
    case cacheError
    case invalidData
    case networkError(NetworkError)

    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            return "Failed to fetch data from the repository"
        case .cacheError:
            return "An error occurred with the cache"
        case .invalidData:
            return "The data is invalid or corrupted"
        case .networkError(let networkError):
            return networkError.localizedDescription
        }
    }
}