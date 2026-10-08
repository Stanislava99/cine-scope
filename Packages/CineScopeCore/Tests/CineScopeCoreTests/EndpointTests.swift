import XCTest
@testable import CineScopeCore

final class EndpointTests: XCTestCase {
    private let baseURL = URL(string: "https://api.themoviedb.org")!

    func testTrendingEndpointBuildsPageQuery() throws {
        let endpoint = TMDBEndpoint.trendingMovies(page: 2)
        let url = try endpoint.makeURL(baseURL: baseURL)

        XCTAssertEqual(url.path, "/3/trending/movie/day")
        XCTAssertTrue(url.query?.contains("page=2") == true)
    }

    func testMovieDetailsAppendsCredits() throws {
        let endpoint = TMDBEndpoint.movieDetails(id: 42)
        let request = try endpoint.makeRequest(baseURL: baseURL, accessToken: "token-123")

        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token-123")
        XCTAssertTrue(request.url?.absoluteString.contains("append_to_response=credits") == true)
    }

    func testSearchEndpointIncludesQuery() throws {
        let endpoint = TMDBEndpoint.searchTV(query: "echo", page: 1)
        let url = try endpoint.makeURL(baseURL: baseURL)

        XCTAssertEqual(url.path, "/3/search/tv")
        XCTAssertTrue(url.query?.contains("query=echo") == true)
    }
}
