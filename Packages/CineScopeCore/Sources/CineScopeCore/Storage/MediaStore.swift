import Foundation

public actor MediaStore {
    private let fileManager: FileManager
    private let rootDirectory: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        fileManager: FileManager = .default,
        directory: URL? = nil
    ) {
        self.fileManager = fileManager
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()

        if let directory {
            self.rootDirectory = directory
        } else {
            let base = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
                ?? fileManager.temporaryDirectory
            self.rootDirectory = base.appendingPathComponent("CineScopeMediaStore", isDirectory: true)
        }

        try? fileManager.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
    }

    public func saveTrendingPage(_ page: PagedResult<Media>) {
        let payload = StoredPagedMedia(
            page: page.page,
            totalPages: page.totalPages,
            totalResults: page.totalResults,
            results: page.results
        )
        try? write(payload, to: trendingURL(page: page.page))
    }

    public func trendingPage(page: Int) -> PagedResult<Media>? {
        guard let payload: StoredPagedMedia = try? read(from: trendingURL(page: page)) else {
            return nil
        }
        return PagedResult(
            page: payload.page,
            totalPages: payload.totalPages,
            totalResults: payload.totalResults,
            results: payload.results
        )
    }

    public func saveDetails(_ details: MediaDetails) {
        let stored = StoredMediaDetails(details: details)
        try? write(stored, to: detailsURL(id: details.id, kind: details.asMedia.mediaKind))
    }

    public func details(id: Int, kind: MediaKind) -> MediaDetails? {
        guard let stored: StoredMediaDetails = try? read(from: detailsURL(id: id, kind: kind)) else {
            return nil
        }
        return stored.details
    }

    private func trendingURL(page: Int) -> URL {
        rootDirectory.appendingPathComponent("trending-\(page).json")
    }

    private func detailsURL(id: Int, kind: MediaKind) -> URL {
        rootDirectory.appendingPathComponent("\(kind.rawValue)-\(id).json")
    }

    private func write<T: Encodable>(_ value: T, to url: URL) throws {
        let data = try encoder.encode(value)
        try data.write(to: url, options: .atomic)
    }

    private func read<T: Decodable>(from url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        return try decoder.decode(T.self, from: data)
    }
}

private struct StoredPagedMedia: Codable, Sendable {
    let page: Int
    let totalPages: Int
    let totalResults: Int
    let results: [Media]
}

private struct StoredMediaDetails: Codable, Sendable {
    enum Kind: String, Codable, Sendable {
        case movie
        case tv
    }

    let kind: Kind
    let movie: MovieDetails?
    let tv: TVDetails?

    init(details: MediaDetails) {
        switch details {
        case .movie(let value):
            kind = .movie
            movie = value
            tv = nil
        case .tv(let value):
            kind = .tv
            movie = nil
            tv = value
        }
    }

    var details: MediaDetails? {
        switch kind {
        case .movie:
            guard let movie else { return nil }
            return .movie(movie)
        case .tv:
            guard let tv else { return nil }
            return .tv(tv)
        }
    }
}
