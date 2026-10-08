import Foundation

public struct ImageURLBuilder: Sendable {
    private let baseURL: URL

    public init(baseURL: URL = URL(string: "https://image.tmdb.org/t/p")!) {
        self.baseURL = baseURL
    }

    public func url(path: String?, size: PosterImageSize) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        let normalized = path.hasPrefix("/") ? path : "/\(path)"
        return baseURL
            .appending(path: size.rawValue)
            .appending(path: normalized)
    }
}
