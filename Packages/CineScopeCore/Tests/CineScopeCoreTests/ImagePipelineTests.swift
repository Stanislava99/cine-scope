import XCTest
@testable import CineScopeCore

#if canImport(AppKit)
import AppKit
#endif

final class ImagePipelineTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testPipelineCachesDownloadedImage() async throws {
        let png = Self.makeTinyPNG()
        let counter = RequestCounter()
        MockURLProtocol.requestHandler = { request in
            counter.increment()
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "image/png"]
            )!
            return (response, png)
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let http = URLSessionHTTPClient(session: session)
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let disk = ImageDiskCache(directory: directory)
        let pipeline = ImagePipeline(httpClient: http, diskCache: disk)

        let request = ImageRequest(path: "/sample.png", size: .w185)
        let first = try await pipeline.image(for: request)
        let second = try await pipeline.image(for: request)

        XCTAssertNotNil(first)
        XCTAssertNotNil(second)
        XCTAssertEqual(counter.value, 1)
    }

    func testClientFactorySelectsFixtureWithoutToken() {
        let config = AppConfiguration(
            environment: .development,
            accessToken: nil,
            prefersFixtureClient: true
        )
        let client = TMDBClientFactory.make(configuration: config)
        XCTAssertTrue(client is FixtureTMDBClient)
    }

    func testClientFactorySelectsLiveWithToken() {
        let config = AppConfiguration(
            environment: .production,
            accessToken: "token",
            prefersFixtureClient: false
        )
        let client = TMDBClientFactory.make(configuration: config)
        XCTAssertTrue(client is LiveTMDBClient)
    }

    private static func makeTinyPNG() -> Data {
        let base64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5X2ZQAAAAASUVORK5CYII="
        return Data(base64Encoded: base64) ?? Data()
    }
}

private final class RequestCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var count = 0

    var value: Int {
        lock.lock()
        defer { lock.unlock() }
        return count
    }

    func increment() {
        lock.lock()
        count += 1
        lock.unlock()
    }
}
