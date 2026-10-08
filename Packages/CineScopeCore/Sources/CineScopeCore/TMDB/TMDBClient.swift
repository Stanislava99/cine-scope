import Foundation

public protocol TMDBClient: Sendable {
    func trendingMovies(page: Int) async throws -> PagedResult<Media>
    func movieDetails(id: Int) async throws -> MovieDetails
    func tvDetails(id: Int) async throws -> TVDetails
    func search(query: String, kind: MediaKind, page: Int) async throws -> PagedResult<Media>
}
