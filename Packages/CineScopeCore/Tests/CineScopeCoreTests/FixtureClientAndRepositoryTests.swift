import XCTest
@testable import CineScopeCore

final class FixtureClientAndRepositoryTests: XCTestCase {
    func testFixtureClientPaginatesTrending() async throws {
        let client = FixtureTMDBClient(artificialDelayNanoseconds: 0)
        let page1 = try await client.trendingMovies(page: 1)
        let page2 = try await client.trendingMovies(page: 2)

        XCTAssertEqual(page1.results.count, 10)
        XCTAssertEqual(page2.results.count, 2)
        XCTAssertTrue(page1.hasMorePages)
        XCTAssertFalse(page2.hasMorePages)
    }

    func testFixtureSearchFiltersByTitle() async throws {
        let client = FixtureTMDBClient(artificialDelayNanoseconds: 0)
        let result = try await client.search(query: "Nebula", kind: .movie, page: 1)
        XCTAssertEqual(result.results.count, 1)
        XCTAssertEqual(result.results.first?.title, "Nebula Drift")
    }

    func testEmptySearchThrows() async {
        let client = FixtureTMDBClient(artificialDelayNanoseconds: 0)
        do {
            _ = try await client.search(query: "   ", kind: .movie, page: 1)
            XCTFail("Expected empty query error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .emptyQuery)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testRepositoryFallsBackToStoreOnFailure() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = MediaStore(directory: directory)
        let goodClient = FixtureTMDBClient(artificialDelayNanoseconds: 0)
        let repository = LiveMediaRepository(client: goodClient, store: store)

        let live = try await repository.trendingMovies(page: 1)
        XCTAssertFalse(live.results.isEmpty)

        let failing = LiveMediaRepository(client: FailingTMDBClient(), store: store)
        let cached = try await failing.trendingMovies(page: 1)
        XCTAssertEqual(cached.results.count, live.results.count)
    }

    func testFavoritesStoreTogglePersists() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = FavoritesStore(directory: directory)
        let media = Media(
            id: 9,
            title: "Fav",
            overview: "Overview",
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 1,
            voteCount: 1,
            popularity: 1,
            releaseDate: nil,
            mediaKind: .movie
        )

        let added = await store.toggle(media)
        XCTAssertTrue(added)
        let containsAfterAdd = await store.contains(media)
        XCTAssertTrue(containsAfterAdd)

        let reloaded = FavoritesStore(directory: directory)
        let containsReloaded = await reloaded.contains(id: 9, kind: .movie)
        XCTAssertTrue(containsReloaded)

        let removed = await reloaded.toggle(media)
        XCTAssertFalse(removed)
    }
}

private struct FailingTMDBClient: TMDBClient {
    func trendingMovies(page: Int) async throws -> PagedResult<Media> {
        throw NetworkError.transport("offline")
    }

    func movieDetails(id: Int) async throws -> MovieDetails {
        throw NetworkError.transport("offline")
    }

    func tvDetails(id: Int) async throws -> TVDetails {
        throw NetworkError.transport("offline")
    }

    func search(query: String, kind: MediaKind, page: Int) async throws -> PagedResult<Media> {
        throw NetworkError.transport("offline")
    }
}
