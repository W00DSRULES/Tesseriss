import XCTest

/// Captures App Store marketing screenshots. Not a correctness test — it drives
/// the app to each key screen and saves a full-screen screenshot as a
/// `.keepAlways` attachment. Extract them from the result bundle with:
///   xcrun xcresulttool export attachments --path <Result.xcresult> --output-path <dir>
///
/// Run on a 6.9" device (iPhone 17 Pro Max → 1320×2868, the size App Store
/// Connect requires) with a fixed RNG seed for a deterministic board:
///   xcodebuild test -only-testing:TesserissUITests/ScreenshotTests \
///     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'
final class ScreenshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    private func snap(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let a = XCTAttachment(screenshot: shot)
        a.name = name
        a.lifetime = .keepAlways
        add(a)
    }

    /// Launch fresh (wipes UserDefaults to defaults: Turkish, og mode, classic,
    /// day) with a fixed seed so the board is reproducible.
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-test"]
        app.launchEnvironment = ["TESSERISS_RNG_SEED": "1337"]
        app.launch()
        return app
    }

    private func switchToEnglish(_ app: XCUIApplication) {
        app.buttons["settings-button"].tap()
        let english = app.buttons["English"]
        XCTAssertTrue(english.waitForExistence(timeout: 3))
        english.tap()
        app.buttons["back-button"].tap()
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 3))
    }

    func test_capture_store_screenshots() {
        let app = launch()
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 5))
        switchToEnglish(app)

        // 1) Menu — title, tagline, scoring, modes, highscore.
        snap("01-menu")

        // 2) Gameplay — stack a few pieces so the board reads as a real game.
        app.buttons["start-button"].tap()
        let hardDrop = app.buttons["hard-drop-button"]
        XCTAssertTrue(hardDrop.waitForExistence(timeout: 5))
        let rotate = app.buttons["rotate-button"]
        for i in 0..<6 {
            if i % 2 == 0 && rotate.exists { rotate.tap() }
            hardDrop.tap()
            Thread.sleep(forTimeInterval: 0.2)
        }
        snap("02-game")

        // 3) Settings — toggles, theme/appearance/language pickers, about.
        app.buttons["menu-button"].tap()
        let settings = app.buttons["settings-button"]
        XCTAssertTrue(settings.waitForExistence(timeout: 3))
        settings.tap()
        XCTAssertTrue(app.buttons["back-button"].waitForExistence(timeout: 3))
        snap("03-settings")

        // 4) Hokusai + Night gameplay — show the alternate theme.
        if app.buttons["Hokusai"].exists { app.buttons["Hokusai"].tap() }
        let night = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'Night' OR label CONTAINS[c] 'Gece'")
        ).firstMatch
        if night.exists { night.tap() }
        app.buttons["back-button"].tap()
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 3))
        snap("04-menu-hokusai-night")

        app.buttons["start-button"].tap()
        XCTAssertTrue(hardDrop.waitForExistence(timeout: 5))
        for i in 0..<6 {
            if i % 2 == 1 && rotate.exists { rotate.tap() }
            hardDrop.tap()
            Thread.sleep(forTimeInterval: 0.2)
        }
        snap("05-game-hokusai-night")
    }
}
