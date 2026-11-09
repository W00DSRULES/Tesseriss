import XCTest

/// Captures App Store marketing screenshots. Not a correctness test — it drives
/// the app to each key screen and saves a full-screen screenshot as a
/// `.keepAlways` attachment. Extract them from the result bundle with:
///   xcrun xcresulttool export attachments --path <Result.xcresult> --output-path <dir>
///
/// Run on iPhone 17 Pro Max (1320×2868) with a fixed RNG seed for a
/// deterministic board:
///   xcodebuild test -only-testing:TesserissUITests/ScreenshotTests \
///     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'
/// scripts/make_store_screenshots.py then frames each shot at 1320×2868 for the
/// App Store Connect slot "iPhone with Dynamic Island (large display)" and
/// writes a 1206×2622 copy for the required "(medium display)" slot.
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
    private func launch(locale: String, extraEnv: [String: String] = [:]) -> XCUIApplication {
        let app = XCUIApplication()
        // Sample scores and stats so the menu and Settings don't show a row of
        // zeros. Launch arguments land in the argument domain, which the
        // --ui-test wipe leaves alone. -AppleLocale sets the number format
        // ("48,300" for en_US, "48.300" for tr_TR).
        let sample: [(String, String)] = [
            ("tesseriss.highscore.fast", "21400"), ("tesseriss.highscore.og", "48300"),
            ("tesseriss.highscore.hard", "15900"), ("tesseriss.stats.gamesPlayed", "64"),
            ("tesseriss.stats.rowsCleared", "1927"), ("tesseriss.stats.fourRowClears", "83"),
        ]
        app.launchArguments = ["--ui-test", "-AppleLocale", locale]
            + sample.flatMap { ["-\($0.0)", $0.1] }
        // TEST_RUNNER_TESSERISS_SHOTS_COLORBLIND=1 on the xcodebuild command line
        // captures the set in colour-blind mode.
        if ProcessInfo.processInfo.environment["TESSERISS_SHOTS_COLORBLIND"] == "1" {
            app.launchArguments += ["-tesseriss.settings.colorblind", "YES"]
        }
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

    // MARK: - 1.2 store set (10 shots per language)
    //
    // Every shot is its own fresh launch. Settings come in through the argument
    // domain (-tesseriss.settings.<key> <value>), which the --ui-test wipe
    // leaves alone, so no shot depends on taps made for an earlier one.

    func test_store_english() { captureStoreSet(lang: "en") }
    func test_store_turkish() { captureStoreSet(lang: "tr") }

    private struct Look {
        var theme = "kanagawa"      // ThemeKind raw value
        var appearance = "day"      // AppearanceMode raw value
        var colorblind = false
        var mode = "og"             // GameMode raw value
    }

    private func launchStore(lang: String, look: Look, extraArgs: [String] = [],
                             extraEnv: [String: String] = [:]) -> XCUIApplication {
        let app = XCUIApplication()
        let sample: [(String, String)] = [
            ("tesseriss.highscore.fast", "21400"), ("tesseriss.highscore.og", "48300"),
            ("tesseriss.highscore.hard", "15900"), ("tesseriss.stats.gamesPlayed", "64"),
            ("tesseriss.stats.rowsCleared", "1927"), ("tesseriss.stats.fourRowClears", "83"),
        ]
        let prefs: [(String, String)] = [
            ("tesseriss.settings.language", lang),
            ("tesseriss.settings.themeKind", look.theme),
            ("tesseriss.settings.appearance", look.appearance),
            ("tesseriss.settings.colorblind", look.colorblind ? "YES" : "NO"),
            ("tesseriss.settings.selectedMode", look.mode),
        ]
        app.launchArguments = ["--ui-test", "-AppleLocale", lang == "tr" ? "tr_TR" : "en_US",
                               "-AppleLanguages", lang == "tr" ? "(tr)" : "(en)"]
            + (sample + prefs).flatMap { ["-\($0.0)", $0.1] } + extraArgs
        var env = ["TESSERISS_RNG_SEED": "1337"]
        for (k, v) in extraEnv { env[k] = v }
        app.launchEnvironment = env
        app.launch()
        return app
    }

    private func startGame(_ app: XCUIApplication) {
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 5))
        app.buttons["start-button"].tap()
        XCTAssertTrue(app.buttons["hard-drop-button"].waitForExistence(timeout: 5))
    }

    // Designed mid-game boards (bottom rows, top to bottom; see
    // GameEngine.applyShotSetupIfRequested). No full rows, no stray holes.
    // boardA's bottom four rows are full but for the right-hand well, so an
    // I piece dropped there makes a four-line clear.
    private let boardA = ".Z........|ZZ.....TI.|ZLOO..TTI.|ILOOTZZTI.|ILLTTTZZI.|IOOLLLJJJ.|IOOLIIIIJ."
    private let boardB = ".....S....|..JJ.SS...|OOJOOTS...|OOJOOTTOO.|LIIIITJOO.|LTTTSSJJJ.|LLTSSIIII."
    private let boardC = "....J...T.|..SSJ..TTT|.SSJJOOSLL|.JJZZOOSSL|.JOOZZLJSL|.JOOLLLJJJ"
    /// 8 wide, for the Crack board.
    private let boardSmall = ".T...LL.|TT..JJL.|ITSSJSL.|ISSLJSS.|IOOLZZS.|IOOLLZZ."
    /// With five-square pieces, for Shatter.
    private let boardShatter = ".......X..|.PP...XXX.|LPPTS.UXU.|LPTTSSUUU.|LLUTUSFFP.|OOUUUFFPP.|OOIIIIFPP."

    private func shotEnv(board: String, stats: String, pieces: String) -> [String: String] {
        ["TESSERISS_SHOT_BOARD": board, "TESSERISS_SHOT_STATS": stats,
         "TESSERISS_SHOT_PIECES": pieces, "TESSERISS_SHOT_FREEZE": "1"]
    }

    /// Start a frozen game on a designed board, then place the falling piece.
    @discardableResult
    private func playShot(lang: String, look: Look, board: String, stats: String, pieces: String,
                          rotations: Int = 0, dx: Int = 0, down: Int = 0) -> XCUIApplication {
        let app = launchStore(lang: lang, look: look,
                              extraEnv: shotEnv(board: board, stats: stats, pieces: pieces))
        startGame(app)
        for _ in 0..<rotations { app.buttons["rotate-button"].tap() }
        let side = app.buttons[dx < 0 ? "move-left-button" : "move-right-button"]
        for _ in 0..<abs(dx) { side.tap() }
        for _ in 0..<down { app.buttons["soft-drop-button"].tap() }
        Thread.sleep(forTimeInterval: 0.4)
        return app
    }

    private func captureStoreSet(lang p: String) {
        let hokusaiDay = Look()
        let classicDay = Look(theme: "classic")

        // 01 core loop: Hokusai Day, mid-game.
        for (name, look) in [("hokusai", hokusaiDay), ("classic", classicDay)] {
            playShot(lang: p, look: look, board: boardA, stats: "12480,36,3", pieces: "TL",
                     rotations: 2, dx: -1, down: 3)
            snap("\(p)-s01-game-\(name)")
        }

        // 02 four-line clear: an I into boardA's well, flash held for the shot.
        for (name, look) in [("hokusai", hokusaiDay), ("classic", classicDay)] {
            var env = shotEnv(board: boardA, stats: "12480,36,3", pieces: "IT")
            env["TESSERISS_CLEAR_PAUSE"] = "4"
            let app = launchStore(lang: p, look: look, extraEnv: env)
            startGame(app)
            app.buttons["rotate-button"].tap()
            app.buttons["move-right-button"].press(forDuration: 1.5)
            app.buttons["hard-drop-button"].tap()
            Thread.sleep(forTimeInterval: 0.35)
            snap("\(p)-s02-fourline-\(name)")
        }

        // 03 ghost piece: an upright I over the well, its outline at the bottom.
        for (name, look) in [("classic", classicDay), ("hokusai", hokusaiDay)] {
            playShot(lang: p, look: look, board: boardA, stats: "12480,36,3", pieces: "IT",
                     rotations: 1, dx: 5, down: 2)
            snap("\(p)-s03-ghost-\(name)")
        }

        // 04 three modes: one game per mode.
        let modes: [(String, String, String, String)] = [
            ("fast", boardSmall, "6240,18,2", "OT"),
            ("og", boardC, "9860,29,2", "LS"),
            ("hard", boardShatter, "15200,41,4", "PX"),
        ]
        for (mode, board, stats, pieces) in modes {
            for (name, theme) in [("classic", "classic"), ("hokusai", "kanagawa")] {
                playShot(lang: p, look: Look(theme: theme, mode: mode), board: board,
                         stats: stats, pieces: pieces, down: 2)
                snap("\(p)-s04-mode-\(mode)-\(name)")
            }
        }

        // 05 Hokusai theme: the menu over the Great Wave.
        var app = launchStore(lang: p, look: hokusaiDay)
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 5))
        snap("\(p)-s05-menu-hokusai")

        // 06 Night: Hokusai Night and Classic Night gameplay.
        playShot(lang: p, look: Look(appearance: "night"), board: boardB, stats: "21730,52,5",
                 pieces: "ZJ", dx: 1, down: 3)
        snap("\(p)-s06-night-hokusai")
        playShot(lang: p, look: Look(theme: "classic", appearance: "night"), board: boardB,
                 stats: "21730,52,5", pieces: "ZJ", dx: 1, down: 3)
        snap("\(p)-s06-night-classic")

        // 07 colour-blind palette with outlines.
        for (name, theme) in [("classic", "classic"), ("hokusai", "kanagawa")] {
            playShot(lang: p, look: Look(theme: theme, colorblind: true), board: boardC,
                     stats: "9860,29,2", pieces: "TJ", rotations: 2, dx: -2, down: 3)
            snap("\(p)-s07-colorblind-\(name)")
        }

        // 08 stats in Settings (scrolled to the stats card).
        for (name, look) in [("classic", classicDay), ("hokusai", hokusaiDay)] {
            app = launchStore(lang: p, look: look)
            XCTAssertTrue(app.buttons["settings-button"].waitForExistence(timeout: 5))
            app.buttons["settings-button"].tap()
            XCTAssertTrue(app.buttons["back-button"].waitForExistence(timeout: 3))
            app.swipeUp(velocity: .slow)
            Thread.sleep(forTimeInterval: 0.8)
            snap("\(p)-s08-stats-\(name)")
        }

        // 09 first-launch guide, all three steps.
        app = launchStore(lang: p, look: hokusaiDay, extraArgs: ["--show-onboarding"])
        XCTAssertTrue(app.buttons["onboarding-next"].waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 0.6)
        snap("\(p)-s09-guide-1")
        app.buttons["onboarding-next"].tap()
        Thread.sleep(forTimeInterval: 0.6)
        snap("\(p)-s09-guide-2")
        app.buttons["onboarding-next"].tap()
        Thread.sleep(forTimeInterval: 0.6)
        snap("\(p)-s09-guide-3")

        // 10 no ads, offline: menus.
        for (name, look) in [("night", Look(theme: "classic", appearance: "night")),
                             ("hokusai-night", Look(appearance: "night")),
                             ("classic", classicDay)] {
            app = launchStore(lang: p, look: look)
            XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 5))
            snap("\(p)-s10-menu-\(name)")
        }
    }

    private func captureSet(language: String, prefix: String) {
        let locale = prefix == "tr" ? "tr_TR" : "en_US"
        let app = launch(locale: locale)
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
        let clearApp = launch(locale: locale, extraEnv: [
            "TESSERISS_TETRIS_SETUP": "1",
            "TESSERISS_CLEAR_PAUSE": "3",
        ])
        XCTAssertTrue(clearApp.buttons["start-button"].waitForExistence(timeout: 5))
        configure(clearApp, language: language, hokusai: true)
        clearApp.buttons["start-button"].tap()
        let drop = clearApp.buttons["hard-drop-button"]
        XCTAssertTrue(drop.waitForExistence(timeout: 5))
        clearApp.buttons["rotate-button"].tap()                       // I piece → vertical
        clearApp.buttons["move-right-button"].press(forDuration: 1.5) // auto-repeat to the right wall
        drop.tap()                                                     // into the gap → four-line clear
        Thread.sleep(forTimeInterval: 0.4)                             // let the flash render
        snap("\(prefix)-05-four-line-flash")
    }
}
