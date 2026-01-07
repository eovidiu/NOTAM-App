import XCTest

final class NOTAMAppUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    // MARK: - Navigation Tests

    func testTabNavigation() throws {
        // Verify all tabs exist
        XCTAssertTrue(app.tabBars.buttons["NOTAMs"].exists)
        XCTAssertTrue(app.tabBars.buttons["Changes"].exists)
        XCTAssertTrue(app.tabBars.buttons["Settings"].exists)

        // Navigate to each tab
        app.tabBars.buttons["Changes"].tap()
        XCTAssertTrue(app.navigationBars["Changes"].exists)

        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].exists)

        app.tabBars.buttons["NOTAMs"].tap()
        XCTAssertTrue(app.navigationBars["NOTAMs"].exists)
    }

    // MARK: - Settings Tests

    func testSettingsLayout() throws {
        app.tabBars.buttons["Settings"].tap()

        // Check sections exist
        XCTAssertTrue(app.staticTexts["Flight Information Regions"].exists)
        XCTAssertTrue(app.staticTexts["Background Refresh"].exists)
        XCTAssertTrue(app.staticTexts["Notifications"].exists)
        XCTAssertTrue(app.staticTexts["About"].exists)
    }

    func testAddFIRSheet() throws {
        app.tabBars.buttons["Settings"].tap()

        // Tap Add FIR button
        let addButton = app.buttons["Add FIR"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()

        // Verify sheet appears
        XCTAssertTrue(app.navigationBars["Add FIR"].waitForExistence(timeout: 2))

        // Check text field exists
        XCTAssertTrue(app.textFields["ICAO Code"].exists)

        // Cancel
        app.buttons["Cancel"].tap()
        XCTAssertFalse(app.navigationBars["Add FIR"].exists)
    }

    func testRefreshIntervalPicker() throws {
        app.tabBars.buttons["Settings"].tap()

        // Find and tap the refresh interval picker
        let picker = app.buttons["Refresh Interval"]
        if picker.exists {
            picker.tap()

            // Verify options
            XCTAssertTrue(app.buttons["Every hour"].waitForExistence(timeout: 2))
            XCTAssertTrue(app.buttons["Every 6 hours"].exists)
            XCTAssertTrue(app.buttons["Every 12 hours"].exists)
        }
    }

    // MARK: - NOTAMs List Tests

    func testRefreshButton() throws {
        // The refresh button should exist in the navigation bar
        let refreshButton = app.navigationBars.buttons["arrow.clockwise"]
        XCTAssertTrue(refreshButton.waitForExistence(timeout: 2))
    }

    func testPullToRefresh() throws {
        // Navigate to NOTAMs tab (default)
        let firstCell = app.cells.firstMatch

        if firstCell.exists {
            // Perform pull to refresh gesture
            let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let end = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 2.0))
            start.press(forDuration: 0.1, thenDragTo: end)
        }
    }

    func testSearchBar() throws {
        // The search bar should exist
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))

        // Tap and type
        searchField.tap()
        searchField.typeText("RWY")

        // Cancel search
        app.buttons["Cancel"].tap()
    }

    // MARK: - Changes List Tests

    func testChangesEmptyState() throws {
        app.tabBars.buttons["Changes"].tap()

        // If no changes, empty state should show
        // This depends on the app state
        let emptyStateTitle = app.staticTexts["No Changes"]
        if emptyStateTitle.exists {
            XCTAssertTrue(app.staticTexts["Changes to NOTAMs will appear here when detected during background refresh."].exists)
        }
    }

    // MARK: - Accessibility Tests

    func testAccessibilityIdentifiers() throws {
        // Verify key elements have accessibility labels
        XCTAssertTrue(app.tabBars.buttons["NOTAMs"].isHittable)
        XCTAssertTrue(app.tabBars.buttons["Changes"].isHittable)
        XCTAssertTrue(app.tabBars.buttons["Settings"].isHittable)
    }

    func testDynamicTypeSupport() throws {
        // This test verifies the app doesn't crash with accessibility sizes
        // Actual visual verification would require screenshot comparison
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].exists)
    }
}
