import XCTest

/// High-leverage XCUITests covering the menu / game / settings flow.
/// Each test launches the app fresh with `--ui-test` so UserDefaults are wiped
/// to a known baseline (default mode "og", theme classic, appearance day).
final class SmokeTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    private func launchedApp(extraArgs: [String] = [], env: [String: String] = [:]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-test"] + extraArgs
        app.launchEnvironment = env
        app.launch()
        return app
    }

    // MARK: - Menu

    func test_launch_shows_menu_with_start_and_settings() {
        let app = launchedApp()
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["settings-button"].exists)
        XCTAssertTrue(app.staticTexts["highscore-value"].exists)
        XCTAssertEqual(app.staticTexts["highscore-value"].label, "0",
                       "Fresh launch with --ui-test should show highscore 0")
    }

    func test_tap_start_opens_game_with_zero_score() {
        let app = launchedApp()
        app.buttons["start-button"].tap()
        XCTAssertTrue(app.buttons["hard-drop-button"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["rotate-button"].exists)
        XCTAssertTrue(app.buttons["menu-button"].exists)

        // Pre-localized stat labels: "skor" (tr default) or "score" (en).
        let scoreLabel = app.staticTexts["stat-skor"].exists
            ? app.staticTexts["stat-skor"]
            : app.staticTexts["stat-score"]
        XCTAssertTrue(scoreLabel.exists, "Score stat label must exist")
        XCTAssertEqual(scoreLabel.label, "0", "Fresh game should start at score 0")
    }

    // MARK: - Settings

    func test_open_settings_and_return() {
        let app = launchedApp()
        app.buttons["settings-button"].tap()
        XCTAssertTrue(app.buttons["back-button"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.otherElements["theme-picker"].exists
                      || app.segmentedControls.firstMatch.exists,
                      "Settings should show theme picker")
        app.buttons["back-button"].tap()
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 2),
                      "Back returns to menu")
    }

    func test_theme_picker_switches_to_hokusai() {
        let app = launchedApp()
        app.buttons["settings-button"].tap()
        // Both segments are present; tap Hokusai then re-open settings to verify.
        let hokusai = app.buttons["Hokusai"]
        XCTAssertTrue(hokusai.waitForExistence(timeout: 2))
        hokusai.tap()
        XCTAssertTrue(hokusai.isSelected, "Hokusai segment should be selected after tap")
    }

    func test_appearance_picker_switches_to_night() {
        let app = launchedApp()
        app.buttons["settings-button"].tap()
        // Night button label is localized; the underlying text contains "Gece" (tr) or "Night" (en).
        let night = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Gece' OR label CONTAINS[c] 'Night'")).firstMatch
        XCTAssertTrue(night.waitForExistence(timeout: 2))
        night.tap()
        XCTAssertTrue(night.isSelected, "Night should be selected after tap")
    }

    // MARK: - Settings persistence across launches

    func test_theme_choice_persists_across_relaunch() {
        // First launch: switch to Hokusai. Do NOT pass --ui-test on the second
        // launch so UserDefaults survive.
        let app = XCUIApplication()
        app.launchArguments = ["--ui-test"]
        app.launch()
        app.buttons["settings-button"].tap()
        app.buttons["Hokusai"].tap()
        app.terminate()

        // Relaunch without --ui-test: UserDefaults from prior run should persist.
        let app2 = XCUIApplication()
        app2.launchArguments = []
        app2.launch()
        app2.buttons["settings-button"].tap()
        XCTAssertTrue(app2.buttons["Hokusai"].waitForExistence(timeout: 2))
        XCTAssertTrue(app2.buttons["Hokusai"].isSelected,
                      "Hokusai theme should persist across launches")
    }

    // MARK: - Seeded gameplay

    /// With a fixed RNG seed, hard-dropping a sequence of pieces must complete
    /// without crashing or stalling. We don't assert exact board state (no
    /// per-cell identifiers) — but proving the engine handles N piece locks
    /// deterministically catches any randomization-path regression.
    func test_seeded_hard_drops_keep_game_alive() {
        let app = launchedApp(env: ["TESSERISS_RNG_SEED": "1337"])
        app.buttons["start-button"].tap()
        let hardDrop = app.buttons["hard-drop-button"]
        XCTAssertTrue(hardDrop.waitForExistence(timeout: 3))
        for _ in 0..<10 {
            hardDrop.tap()
        }
        // Still on the game screen, controls still responsive.
        XCTAssertTrue(app.buttons["menu-button"].exists,
                      "Should still be on game screen after 10 deterministic drops")
        XCTAssertTrue(hardDrop.exists)
    }

    /// Two runs with the same seed must produce the same gameplay outcome.
    /// We approximate "same outcome" by comparing the score after a fixed number
    /// of hard-drops — with no random divergence the scores must match.
    func test_same_seed_two_runs_same_score_after_n_drops() {
        func scoreAfterDrops(seed: String, drops: Int) -> String {
            let app = launchedApp(env: ["TESSERISS_RNG_SEED": seed])
            app.buttons["start-button"].tap()
            let hardDrop = app.buttons["hard-drop-button"]
            _ = hardDrop.waitForExistence(timeout: 3)
            for _ in 0..<drops { hardDrop.tap() }
            let stat = app.staticTexts["stat-skor"].exists
                ? app.staticTexts["stat-skor"]
                : app.staticTexts["stat-score"]
            let value = stat.label
            app.terminate()
            return value
        }

        let runA = scoreAfterDrops(seed: "424242", drops: 8)
        let runB = scoreAfterDrops(seed: "424242", drops: 8)
        XCTAssertEqual(runA, runB,
                       "Same seed must yield same score after the same input sequence")
    }
}
