import XCTest

final class CineScopeUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-ui-testing")
        app.launch()
    }

    func testEnvironmentBadgeIsVisible() {
        let badge = app.staticTexts.matching(identifier: "environment.badge").firstMatch
        XCTAssertTrue(badge.waitForExistence(timeout: 5))
    }

    func testTrendingCollectionLoads() {
        let collection = app.scrollViews["media.collection"]
        XCTAssertTrue(collection.waitForExistence(timeout: 8))
        let firstCard = app.buttons["media.card.101"]
        XCTAssertTrue(firstCard.waitForExistence(timeout: 8))
    }

    func testOpenDetailsFromTrending() {
        let firstCard = app.buttons["media.card.101"]
        XCTAssertTrue(firstCard.waitForExistence(timeout: 8))
        firstCard.tap()
        let favorite = app.buttons["details.favorite.button"]
        XCTAssertTrue(favorite.waitForExistence(timeout: 8))
    }

    func testSearchFlow() {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 8))
        searchField.tap()
        searchField.typeText("Nebula")

        let kindPicker = app.descendants(matching: .any)["search.kind.picker"]
        XCTAssertTrue(kindPicker.waitForExistence(timeout: 5))

        let list = app.scrollViews["media.search.list"]
        XCTAssertTrue(list.waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["media.list.row.101"].waitForExistence(timeout: 5))
    }

    func testOpenFavoritesFromToolbar() {
        let favorites = app.buttons["favorites.button"]
        XCTAssertTrue(favorites.waitForExistence(timeout: 5))
        favorites.tap()
        XCTAssertTrue(app.navigationBars["Favorites"].waitForExistence(timeout: 5))
    }
}
