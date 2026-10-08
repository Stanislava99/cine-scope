import XCTest
@testable import CineScopeCore

final class LiveTMDBClientTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testTrendingMoviesSucceedsWithStubbedResponse() async throws {
        let fixture = try loadFixture("trending_movies")
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test-token")
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, fixture)
        }

        let client = makeClient()
        let result = try await client.trendingMovies(page: 1)

        XCTAssertEqual(result.results.count, 12)
        XCTAssertEqual(result.results.first?.title, "Nebula Drift")
    }

    func testMissingTokenFails() async {
        let configuration = AppConfiguration(
            environment: .production,
            accessToken: nil,
            prefersFixtureClient: false
        )
        let client = LiveTMDBClient(configuration: configuration)

        do {
            _ = try await client.trendingMovies(page: 1)
            XCTFail("Expected missing token error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .missingAccessToken)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testHTTPErrorSurfacesStatusCode() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let client = makeClient()

        do {
            _ = try await client.trendingMovies(page: 1)
            XCTFail("Expected http status error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .httpStatus(401))
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    private func makeClient() -> LiveTMDBClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let http = URLSessionHTTPClient(session: session)
        let appConfiguration = AppConfiguration(
            environment: .development,
            accessToken: "test-token",
            prefersFixtureClient: false
        )
        return LiveTMDBClient(httpClient: http, configuration: appConfiguration)
    }

    private func loadFixture(_ name: String) throws -> Data {
        let url = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: "json"))
        return try Data(contentsOf: url)
    }
}
