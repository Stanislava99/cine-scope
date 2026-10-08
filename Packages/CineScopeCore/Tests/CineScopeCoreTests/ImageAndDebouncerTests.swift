import XCTest
@testable import CineScopeCore

final class ImageAndDebouncerTests: XCTestCase {
    func testPosterSizeMatchesViewWidth() {
        let size = PosterImageSize.matching(pointWidth: 100, scale: 3)
        XCTAssertEqual(size, .w342)
        XCTAssertEqual(size.lowResPlaceholder, .w92)

        let capped = PosterImageSize.matching(pointWidth: 400, scale: 3, maximum: .w342)
        XCTAssertEqual(capped, .w342)
    }

    func testImageURLBuilder() {
        let builder = ImageURLBuilder()
        let url = builder.url(path: "/abc.jpg", size: .w185)
        XCTAssertEqual(url?.absoluteString, "https://image.tmdb.org/t/p/w185/abc.jpg")
        XCTAssertNil(builder.url(path: nil, size: .w185))
    }

    func testDebouncerFiresOnceAfterDelay() async {
        let debouncer = Debouncer(milliseconds: 50)
        let counter = Counter()

        await debouncer.debounce { await counter.increment() }
        await debouncer.debounce { await counter.increment() }
        await debouncer.debounce { await counter.increment() }

        try? await Task.sleep(nanoseconds: 120_000_000)
        let value = await counter.value
        XCTAssertEqual(value, 1)
    }

    func testAppConfigurationPrefersFixtureWithoutTokenInDev() {
        let config = AppConfiguration.resolve(
            environmentName: "Dev",
            accessToken: nil
        )
        XCTAssertEqual(config.environment, .development)
        XCTAssertFalse(config.usesLiveAPI)
        XCTAssertEqual(config.clientModeDescription, "Fixture")
    }

    func testAppConfigurationUsesLiveWhenTokenPresent() {
        let config = AppConfiguration(
            environment: .development,
            accessToken: "secret",
            prefersFixtureClient: false
        )
        XCTAssertTrue(config.usesLiveAPI)
    }
}

private actor Counter {
    private(set) var value = 0
    func increment() { value += 1 }
}
