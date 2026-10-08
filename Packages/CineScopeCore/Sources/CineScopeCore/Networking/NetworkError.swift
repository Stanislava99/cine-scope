import Foundation

public enum NetworkError: Error, LocalizedError, Sendable, Equatable {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed(String)
    case transport(String)
    case missingAccessToken
    case emptyQuery
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The request URL is invalid."
        case .invalidResponse:
            "The server returned an invalid response."
        case .httpStatus(let code):
            "The server responded with status code \(code)."
        case .decodingFailed(let message):
            "Failed to decode the response: \(message)"
        case .transport(let message):
            "A network transport error occurred: \(message)"
        case .missingAccessToken:
            "A TMDB access token is required for live API requests."
        case .emptyQuery:
            "The search query is empty."
        case .cancelled:
            "The request was cancelled."
        }
    }
}
