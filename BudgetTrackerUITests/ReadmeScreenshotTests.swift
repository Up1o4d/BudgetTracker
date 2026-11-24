import XCTest

/// Captures the README screenshots into `docs/screenshots/`. Run via `scripts/capture-screenshots.sh`,
/// which sets dark mode, a clean status bar and `SCREENSHOT_DIR`. Skipped when `SCREENSHOT_DIR` is unset.
final class ReadmeScreenshotTests: XCTestCase {
    private let timeout: TimeInterval = 10

    @MainActor
    func testCaptureReadmeScreenshots() throws {
        guard let outputDir = ProcessInfo.processInfo.environment["SCREENSHOT_DIR"], !outputDir.isEmpty else {
            throw XCTSkip("Set TEST_RUNNER_SCREENSHOT_DIR to capture README screenshots")
        }
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launch()

        // Set a budget so the summary card shows progress instead of "Set budget"
        let budgetButtons = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'BUDGET'"))
        visible(in: budgetButtons).tap()
        XCTAssertTrue(app.staticTexts["MONTHLY BUDGET"].waitForExistence(timeout: timeout))
        // Cents-based entry; type one key at a time so the reformatting field doesn't drop input
        for digit in "200000" {
            app.typeText(String(digit))
            Thread.sleep(forTimeInterval: 0.3)
        }
        capture("edit-budget", to: outputDir)
        app.buttons["Save"].tap()

        // Home, once the budget is applied and data is loaded
        XCTAssertTrue(app.staticTexts["$2,000.00"].firstMatch.waitForExistence(timeout: timeout))
        settle()
        capture("home", to: outputDir)

        // Home, scrolled to the category breakdown
        app.swipeUp()
        settle()
        capture("home-categories", to: outputDir)

        // Month Category Spending
        visible(in: app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Groceries'"))).tap()
        XCTAssertTrue(app.staticTexts["Total"].waitForExistence(timeout: timeout))
        settle()
        capture("category", to: outputDir)
        app.navigationBars.buttons.firstMatch.tap()

        // Activity
        app.staticTexts["Activity"].tap()
        XCTAssertTrue(app.staticTexts["Steakhouse"].firstMatch.waitForExistence(timeout: timeout))
        settle()
        capture("activity", to: outputDir)

        // Add transaction
        app.buttons["Add"].tap()
        XCTAssertTrue(app.staticTexts["Add transaction"].waitForExistence(timeout: timeout))
        settle()
        capture("add", to: outputDir)
    }

    /// The Home pager keeps neighbouring months in the hierarchy; returns the match that's on screen.
    @MainActor
    private func visible(in query: XCUIElementQuery) -> XCUIElement {
        let deadline = Date.now.addingTimeInterval(timeout)
        while Date.now < deadline {
            if let match = query.allElementsBoundByIndex.first(where: { $0.isHittable }) {
                return match
            }
            Thread.sleep(forTimeInterval: 0.25)
        }
        XCTFail("No visible element matching \(query)")
        return query.firstMatch
    }

    /// Lets loading shimmers, charts and sheet animations finish before capturing.
    private func settle() {
        Thread.sleep(forTimeInterval: 2.5)
    }

    @MainActor
    private func capture(_ name: String, to directory: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let url = URL(fileURLWithPath: directory).appendingPathComponent("\(name).png")
        do {
            try screenshot.pngRepresentation.write(to: url)
        } catch {
            XCTFail("Failed to write \(url.path): \(error)")
        }

        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
