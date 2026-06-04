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

    /// Launch fresh (wipes UserDefaults; language then follows the simulator's
    /// device language) with a fixed seed so the board is reproducible.
    private func launch(extraEnv: [String: String] = [:]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-test"]
        var env = ["TESSERISS_RNG_SEED": "1337"]
        for (k, v) in extraEnv { env[k] = v }
        app.launchEnvironment = env
        app.launch()
        return app
    }

    /// Select the language by its picker label ("English" / "Türkçe") and the
    /// Hokusai theme (Day stays the wiped default) — the marketing look.
    private func configure(_ app: XCUIApplication, language: String) {
        app.buttons["settings-button"].tap()
        let button = app.buttons[language]
        XCTAssertTrue(button.waitForExistence(timeout: 3))
        button.tap()
        if app.buttons["Hokusai"].exists { app.buttons["Hokusai"].tap() }
        app.buttons["back-button"].tap()
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 3))
    }

    func test_screenshots_english() { captureSet(language: "English", prefix: "en") }
    func test_screenshots_turkish() { captureSet(language: "Türkçe", prefix: "tr") }

    private func captureSet(language: String, prefix: String) {
        let app = launch()
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 5))
        configure(app, language: language)

        // 1) Menu — title, tagline, scoring, modes, highscore.
        snap("\(prefix)-01-menu")

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
        snap("\(prefix)-02-game")

        // 3) Settings — toggles, theme/appearance/language pickers, about.
        app.buttons["menu-button"].tap()
        let settings = app.buttons["settings-button"]
        XCTAssertTrue(settings.waitForExistence(timeout: 3))
        settings.tap()
        XCTAssertTrue(app.buttons["back-button"].waitForExistence(timeout: 3))
        snap("\(prefix)-03-settings")

        // 4) Four-line clear flash — fresh launch with the prefilled board and
        //    a stretched flash so the screenshot lands inside the celebration.
        let tetrisApp = launch(extraEnv: [
            "TESSERISS_TETRIS_SETUP": "1",
            "TESSERISS_CLEAR_PAUSE": "3",
        ])
        XCTAssertTrue(tetrisApp.buttons["start-button"].waitForExistence(timeout: 5))
        configure(tetrisApp, language: language)
        tetrisApp.buttons["start-button"].tap()
        let drop = tetrisApp.buttons["hard-drop-button"]
        XCTAssertTrue(drop.waitForExistence(timeout: 5))
        tetrisApp.buttons["rotate-button"].tap()                       // I piece → vertical
        tetrisApp.buttons["move-right-button"].press(forDuration: 1.5) // auto-repeat to the right wall
        drop.tap()                                                     // into the gap → four-line clear
        Thread.sleep(forTimeInterval: 0.4)                             // let the flash render
        snap("\(prefix)-04-four-line-flash")
    }
}
