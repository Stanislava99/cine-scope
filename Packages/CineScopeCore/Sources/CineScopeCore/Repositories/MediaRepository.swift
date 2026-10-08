import Foundation

public protocol MediaRepository: Sendable {
    func trendingMovies(page: Int) async throws -> PagedResult<Media>
    func details(for media: Media) async throws -> MediaDetails
    func search(query: String, kind: MediaKind, page: Int) async throws -> PagedResult<Media>
}

public struct LiveMediaRepository: MediaRepository {
    private let client: any TMDBClient
    private let store: MediaStore

    public init(client: any TMDBClient, store: MediaStore) {
        self.client = client
        self.store = store
    }

    public func trendingMovies(page: Int) async throws -> PagedResult<Media> {
        do {
            let result = try await client.trendingMovies(page: page)
            await store.saveTrendingPage(result)
            return result
        } catch {
            if let cached = await store.trendingPage(page: page) {
                return cached
            }
            throw error
        }
    }

    public func details(for media: Media) async throws -> MediaDetails {
        do {
            let details: MediaDetails
            switch media.mediaKind {
            case .movie:
                details = .movie(try await client.movieDetails(id: media.id))
            case .tv:
                details = .tv(try await client.tvDetails(id: media.id))
            }
            await store.saveDetails(details)
            return details
        } catch {
            if let cached = await store.details(id: media.id, kind: media.mediaKind) {
                return cached
            }
            throw error
        }
    }

    public func search(query: String, kind: MediaKind, page: Int) async throws -> PagedResult<Media> {
        try await client.search(query: query, kind: kind, page: page)
    }
}
