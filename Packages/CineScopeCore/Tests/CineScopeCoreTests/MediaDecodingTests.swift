import XCTest
@testable import CineScopeCore

final class MediaDecodingTests: XCTestCase {
    func testDecodeTrendingMoviesFixture() throws {
        let data = try fixtureData("trending_movies")
        let dto = try JSONDecoder.tmdb.decode(TMDBPagedDTO<TMDBMediaDTO>.self, from: data)

        XCTAssertEqual(dto.page, 1)
        XCTAssertEqual(dto.results.count, 12)

        let media = dto.results[0].asMedia(defaultKind: .movie)
        XCTAssertEqual(media.id, 101)
        XCTAssertEqual(media.title, "Nebula Drift")
        XCTAssertFalse(media.shortDescription.isEmpty)
        XCTAssertEqual(media.mediaKind, .movie)
    }

    func testDecodeMovieDetailsWithCredits() throws {
        let data = try fixtureData("movie_details")
        let dto = try JSONDecoder.tmdb.decode(TMDBMovieDetailsDTO.self, from: data)
        let details = dto.asMovieDetails()

        XCTAssertEqual(details.title, "Nebula Drift")
        XCTAssertEqual(details.runtime, 128)
        XCTAssertEqual(details.genres.count, 2)
        XCTAssertEqual(details.credits.directors.first?.name, "Elena Park")
        XCTAssertEqual(details.credits.cast.count, 3)
        XCTAssertFalse(details.credits.writers.isEmpty)
    }

    func testDecodeTVDetails() throws {
        let data = try fixtureData("tv_details")
        let dto = try JSONDecoder.tmdb.decode(TMDBTVDetailsDTO.self, from: data)
        let details = dto.asTVDetails()

        XCTAssertEqual(details.name, "Station Echo")
        XCTAssertEqual(details.numberOfSeasons, 2)
        XCTAssertEqual(details.asMedia.mediaKind, .tv)
    }

    func testShortDescriptionTruncatesLongOverview() {
        let long = String(repeating: "a", count: 200)
        let media = Media(
            id: 1,
            title: "Long",
            overview: long,
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 1,
            voteCount: 1,
            popularity: 1,
            releaseDate: nil,
            mediaKind: .movie
        )
        XCTAssertEqual(media.shortDescription.count, 160)
        XCTAssertTrue(media.shortDescription.hasSuffix("..."))
    }

    private func fixtureData(_ name: String) throws -> Data {
        let url = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: "json"))
        return try Data(contentsOf: url)
    }
}
