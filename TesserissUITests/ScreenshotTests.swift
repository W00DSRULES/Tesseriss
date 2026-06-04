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

    /// Select the language by its picker label ("English" / "Türkçe"), plus
    /// optionally the Hokusai theme (Day stays the wiped default).
    private func configure(_ app: XCUIApplication, language: String, hokusai: Bool) {
        app.buttons["settings-button"].tap()
        let button = app.buttons[language]
        XCTAssertTrue(button.waitForExistence(timeout: 3))
        button.tap()
        if hokusai && app.buttons["Hokusai"].exists { app.buttons["Hokusai"].tap() }
        app.buttons["back-button"].tap()
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 3))
    }

    private func tapTheme(_ app: XCUIApplication, _ predicate: String) {
        let button = app.buttons.matching(NSPredicate(format: predicate)).firstMatch
        if button.exists { button.tap() }
    }

    /// Stack pieces with per-piece rotation and sideways taps so the skyline
    /// looks like a real game, not a centered hard-drop pile.
    private func stackRealistic(_ app: XCUIApplication, pattern: [(rotations: Int, dx: Int)]) {
        let hardDrop = app.buttons["hard-drop-button"]
        XCTAssertTrue(hardDrop.waitForExistence(timeout: 5))
        let rotate = app.buttons["rotate-button"]
        let left = app.buttons["move-left-button"]
        let right = app.buttons["move-right-button"]
        for step in pattern {
            for _ in 0..<step.rotations where rotate.exists { rotate.tap() }
            if step.dx < 0 { for _ in 0..<(-step.dx) { left.tap() } }
            if step.dx > 0 { for _ in 0..<step.dx { right.tap() } }
            hardDrop.tap()
            Thread.sleep(forTimeInterval: 0.15)
        }
    }

    func test_screenshots_english() { captureSet(language: "English", prefix: "en") }
    func test_screenshots_turkish() { captureSet(language: "Türkçe", prefix: "tr") }

    private func captureSet(language: String, prefix: String) {
        let app = launch()
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 5))

        // 1) Settings — Classic Day, after the language is set.
        app.buttons["settings-button"].tap()
        let langButton = app.buttons[language]
        XCTAssertTrue(langButton.waitForExistence(timeout: 3))
        langButton.tap()
        snap("\(prefix)-03-settings")

        // 2) Menu — Hokusai Day.
        if app.buttons["Hokusai"].exists { app.buttons["Hokusai"].tap() }
        app.buttons["back-button"].tap()
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 3))
        snap("\(prefix)-01-menu")

        // 3) Gameplay — Hokusai Day, realistic skyline.
        app.buttons["start-button"].tap()
        stackRealistic(app, pattern: [
            (0, -4), (1, 3), (0, -2), (2, 4), (1, 0),
            (0, -5), (1, 2), (0, 4), (1, -1), (0, 1),
        ])
        snap("\(prefix)-02-game")

        // 4) Gameplay — Classic Night, a different realistic skyline.
        app.buttons["menu-button"].tap()
        let settings = app.buttons["settings-button"]
        XCTAssertTrue(settings.waitForExistence(timeout: 3))
        settings.tap()
        XCTAssertTrue(app.buttons["back-button"].waitForExistence(timeout: 3))
        tapTheme(app, "label CONTAINS[c] 'Classic' OR label CONTAINS[c] 'Klasik'")
        tapTheme(app, "label CONTAINS[c] 'Night' OR label CONTAINS[c] 'Gece'")
        app.buttons["back-button"].tap()
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 3))
        app.buttons["start-button"].tap()
        stackRealistic(app, pattern: [
            (1, 4), (0, -3), (0, 1), (2, -5), (1, 2),
            (0, -2), (1, 0), (0, 3), (2, -4), (0, 2),
        ])
        snap("\(prefix)-04-game-night")

        // 5) Four-line clear flash — fresh launch (Hokusai Day) with the
        //    prefilled board and a stretched flash so the screenshot lands
        //    inside the celebration.
        let tetrisApp = launch(extraEnv: [
            "TESSERISS_TETRIS_SETUP": "1",
            "TESSERISS_CLEAR_PAUSE": "3",
        ])
        XCTAssertTrue(tetrisApp.buttons["start-button"].waitForExistence(timeout: 5))
        configure(tetrisApp, language: language, hokusai: true)
        tetrisApp.buttons["start-button"].tap()
        let drop = tetrisApp.buttons["hard-drop-button"]
        XCTAssertTrue(drop.waitForExistence(timeout: 5))
        tetrisApp.buttons["rotate-button"].tap()                       // I piece → vertical
        tetrisApp.buttons["move-right-button"].press(forDuration: 1.5) // auto-repeat to the right wall
        drop.tap()                                                     // into the gap → four-line clear
        Thread.sleep(forTimeInterval: 0.4)                             // let the flash render
        snap("\(prefix)-05-four-line-flash")
    }
}
