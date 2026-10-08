import Foundation

public protocol Endpoint: Sendable {
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var method: String { get }
}

public extension Endpoint {
    var method: String { "GET" }

    func makeURL(baseURL: URL) throws -> URL {
        guard var components = URLComponents(
            url: baseURL.appending(path: path),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }

        let items = queryItems.filter { item in
            guard let value = item.value else { return false }
            return !value.isEmpty
        }
        components.queryItems = items.isEmpty ? nil : items

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        return url
    }

    func makeRequest(baseURL: URL, accessToken: String?) throws -> URLRequest {
        let url = try makeURL(baseURL: baseURL)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let accessToken, !accessToken.isEmpty {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
