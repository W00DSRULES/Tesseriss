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

    /// Picks the in-app language by its picker label ("English" / "Türkçe"),
    /// which reads the same in both languages, then returns to the menu.
    private func selectLanguage(_ app: XCUIApplication, _ language: String) {
        app.buttons["settings-button"].tap()
        let button = app.buttons[language]
        XCTAssertTrue(button.waitForExistence(timeout: 3))
        button.tap()
        app.buttons["back-button"].tap()
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 3))
    }

    // MARK: - Menu

    func test_launch_shows_menu_with_start_and_settings() {
        let app = launchedApp()
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["settings-button"].exists)
        XCTAssertTrue(app.staticTexts["highscore-value"].exists)
        XCTAssertEqual(app.staticTexts["highscore-value"].value as? String, "0",
                       "Fresh launch with --ui-test should show highscore 0")
    }

    func test_tap_start_opens_game_with_zero_score() {
        let app = launchedApp()
        app.buttons["start-button"].tap()
        XCTAssertTrue(app.buttons["hard-drop-button"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["rotate-button"].exists)
        XCTAssertTrue(app.buttons["menu-button"].exists)

        let scoreLabel = app.staticTexts["stat-score"]
        XCTAssertTrue(scoreLabel.exists, "Score stat label must exist")
        XCTAssertEqual(scoreLabel.value as? String, "0", "Fresh game should start at score 0")
    }

    func test_mode_buttons_have_stable_ids_and_selected_trait() {
        let app = launchedApp()
        let og = app.buttons["mode-og"]
        let fast = app.buttons["mode-fast"]
        let hard = app.buttons["mode-hard"]
        XCTAssertTrue(og.waitForExistence(timeout: 3))
        XCTAssertTrue(fast.exists)
        XCTAssertTrue(hard.exists)
        XCTAssertTrue(og.isSelected, "--ui-test wipes to the default mode og")
        XCTAssertFalse(fast.isSelected)
        XCTAssertFalse(hard.isSelected)
        fast.tap()
        XCTAssertTrue(fast.isSelected, "Fast should be selected after tap")
        XCTAssertFalse(og.isSelected, "Only one mode is selected at a time")
    }

    // MARK: - Game screen

    /// Stat ids must not follow the app language: they used to be built from
    /// the localized label ("stat-skor" in Turkish).
    func test_stat_ids_are_language_independent() {
        for language in ["Türkçe", "English"] {
            let app = launchedApp()
            selectLanguage(app, language)
            app.buttons["start-button"].tap()
            XCTAssertTrue(app.buttons["hard-drop-button"].waitForExistence(timeout: 3))
            for id in ["stat-score", "stat-level", "stat-lines"] {
                XCTAssertTrue(app.staticTexts[id].exists, "\(id) missing in \(language)")
            }
            XCTAssertEqual(app.staticTexts["stat-score"].value as? String, "0", language)
        }
    }

    /// VoiceOver must read what each control does, in the app's language,
    /// not a glyph ("◀") or an SF Symbol name ("chevron.down.2").
    func test_control_buttons_have_spoken_labels() {
        let app = launchedApp()
        selectLanguage(app, "English")
        app.buttons["start-button"].tap()
        XCTAssertTrue(app.buttons["hard-drop-button"].waitForExistence(timeout: 3))
        let expected: [(id: String, label: String)] = [
            ("move-left-button", "Move left"),
            ("soft-drop-button", "Move down"),
            ("move-right-button", "Move right"),
            ("rotate-ccw-button", "Rotate counterclockwise"),
            ("hard-drop-button", "Drop to bottom"),
            ("rotate-button", "Rotate clockwise"),
            ("pause-button", "Pause"),
        ]
        for control in expected {
            XCTAssertEqual(app.buttons[control.id].label, control.label, control.id)
            XCTAssertGreaterThanOrEqual(app.buttons[control.id].frame.height, 44, control.id)
        }
        XCTAssertGreaterThanOrEqual(app.buttons["pause-button"].frame.width, 44, "pause-button")
        XCTAssertGreaterThanOrEqual(app.buttons["menu-button"].frame.height, 44, "menu-button")
    }

    func test_pause_overlay_resume_and_menu() {
        let app = launchedApp()
        app.buttons["start-button"].tap()
        let pause = app.buttons["pause-button"]
        XCTAssertTrue(pause.waitForExistence(timeout: 3))
        pause.tap()
        let resume = app.buttons["resume-button"]
        XCTAssertTrue(resume.waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["pause-menu-button"].exists)
        // Paused, the game behind the card leaves the accessibility tree.
        XCTAssertFalse(pause.exists, "The HUD is hidden from VoiceOver while paused")

        resume.tap()
        let closed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"),
                                               object: resume)
        XCTAssertEqual(XCTWaiter.wait(for: [closed], timeout: 2), .completed,
                       "Resume should close the pause overlay")
        // Pause only acts while playing, so pausing again proves play resumed.
        XCTAssertTrue(pause.isEnabled)
        pause.tap()
        XCTAssertTrue(resume.waitForExistence(timeout: 2),
                      "Game should respond to pause again after resuming")

        app.buttons["pause-menu-button"].tap()
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 2),
                      "Overlay MENU returns to the menu")
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

    /// The emoji are drawn, not spoken: each setting must read as its plain
    /// name ("Music", not "🎵 Music").
    func test_settings_labels_are_plain_text() {
        let app = launchedApp()
        selectLanguage(app, "English")
        app.buttons["settings-button"].tap()
        XCTAssertTrue(app.buttons["back-button"].waitForExistence(timeout: 2))
        for name in ["Music", "Sound effects", "Haptics", "Landing", "Colorblind mode"] {
            XCTAssertTrue(app.switches[name].exists, "\(name) switch")
        }
        for name in ["Appearance", "Theme", "Language"] {
            XCTAssertTrue(app.staticTexts[name].exists, "\(name) label")
        }
        for name in ["Day", "Night"] {
            XCTAssertTrue(app.buttons[name].exists, "\(name) segment")
        }

        let sfx = app.switches["Sound effects"]
        let before = sfx.value as? String
        sfx.tap()
        XCTAssertNotEqual(sfx.value as? String, before, "Tapping Sound effects should flip it")
    }

    /// Colour-blind mode is off by default, flips from Settings, and the game
    /// still runs with it on (the outlined cells and ghost are drawn).
    func test_colorblind_mode_toggles_and_game_runs_with_it() {
        let app = launchedApp(env: ["TESSERISS_RNG_SEED": "1337"])
        selectLanguage(app, "English")
        app.buttons["settings-button"].tap()
        XCTAssertTrue(app.buttons["back-button"].waitForExistence(timeout: 2))
        let colorblind = app.switches["colorblind-toggle"]
        XCTAssertTrue(colorblind.waitForExistence(timeout: 2))
        XCTAssertEqual(colorblind.value as? String, "0", "off by default")
        colorblind.tap()
        XCTAssertEqual(colorblind.value as? String, "1")
        app.buttons["back-button"].tap()
        app.buttons["start-button"].tap()
        let hardDrop = app.buttons["hard-drop-button"]
        XCTAssertTrue(hardDrop.waitForExistence(timeout: 3))
        hardDrop.tap()
        XCTAssertTrue(app.buttons["menu-button"].exists, "game keeps running in colour-blind mode")
    }

    /// Music and sound effects each have a volume slider, spoken by name,
    /// that only its own switch disables.
    func test_volume_sliders_follow_their_own_switch() {
        let app = launchedApp()
        selectLanguage(app, "English")
        app.buttons["settings-button"].tap()
        XCTAssertTrue(app.buttons["back-button"].waitForExistence(timeout: 2))
        let musicSlider = app.sliders["music-volume-slider"]
        let sfxSlider = app.sliders["sfx-volume-slider"]
        XCTAssertTrue(musicSlider.exists, "Music volume slider")
        XCTAssertTrue(sfxSlider.exists, "Sound effects volume slider")
        XCTAssertEqual(musicSlider.label, "Music volume")
        XCTAssertEqual(sfxSlider.label, "Sound effects volume")
        XCTAssertTrue(musicSlider.isEnabled)
        XCTAssertTrue(sfxSlider.isEnabled)

        let sfx = app.switches["Sound effects"]
        sfx.tap()
        XCTAssertFalse(sfxSlider.isEnabled, "Sound effects off disables its slider")
        XCTAssertTrue(musicSlider.isEnabled, "Sound effects off leaves the music slider enabled")
        sfx.tap()
        XCTAssertTrue(sfxSlider.isEnabled, "Sound effects on re-enables its slider")

        let music = app.switches["Music"]
        music.tap()
        XCTAssertFalse(musicSlider.isEnabled, "Music off disables its slider")
        XCTAssertTrue(sfxSlider.isEnabled, "Music off leaves the sound effects slider enabled")
        music.tap()
        XCTAssertTrue(musicSlider.isEnabled, "Music on re-enables its slider")
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
        let nightPredicate = NSPredicate(format: "label CONTAINS[c] 'Gece' OR label CONTAINS[c] 'Night'")
        app.buttons.matching(nightPredicate).firstMatch.tap()
        app.terminate()

        // Relaunch without --ui-test: UserDefaults from prior run should persist.
        let app2 = XCUIApplication()
        app2.launchArguments = []
        app2.launch()
        app2.buttons["settings-button"].tap()
        XCTAssertTrue(app2.buttons["Hokusai"].waitForExistence(timeout: 2))
        XCTAssertTrue(app2.buttons["Hokusai"].isSelected,
                      "Hokusai theme should persist across launches")
        XCTAssertTrue(app2.buttons.matching(nightPredicate).firstMatch.isSelected,
                      "Night appearance should persist across launches")
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
        // Default mode "og" is 10x20. Five pieces stacked in the spawn column
        // (~2 rows each) can't top out a 20-row board, so the game must stay
        // alive regardless of runner timing. A brief settle between taps lets
        // each piece lock and the next spawn, so no tap is swallowed by a
        // lock/clear frame (where hardDrop is a no-op) — keeping this test
        // deterministic instead of timing-dependent.
        for _ in 0..<5 {
            hardDrop.tap()
            Thread.sleep(forTimeInterval: 0.15)
        }
        // Still on the game screen, controls still responsive.
        XCTAssertTrue(app.buttons["menu-button"].exists,
                      "Should still be on game screen after 5 deterministic drops")
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
            // Settle between taps so every drop locks in both runs; otherwise a
            // tap swallowed by a lock/clear frame in one run but not the other
            // would diverge the scores and flake this comparison.
            for _ in 0..<drops { hardDrop.tap(); Thread.sleep(forTimeInterval: 0.15) }
            let value = app.staticTexts["stat-score"].value as? String ?? ""
            app.terminate()
            return value
        }

        let runA = scoreAfterDrops(seed: "424242", drops: 8)
        let runB = scoreAfterDrops(seed: "424242", drops: 8)
        XCTAssertEqual(runA, runB,
                       "Same seed must yield same score after the same input sequence")
    }
    // MARK: - Stats

    /// Drops the first I piece into the right-hand well for a four-row clear.
    /// Needs TESSERISS_TETRIS_SETUP, which prefills a four-row well and deals
    /// an I piece first, so one drop scores 4000.
    private func clearFourRows(_ app: XCUIApplication) {
        app.buttons["rotate-button"].tap()
        app.buttons["move-right-button"].press(forDuration: 1.5)
        app.buttons["hard-drop-button"].tap()
        let scored = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == '4000'"),
                                               object: app.staticTexts["stat-score"])
        XCTAssertEqual(XCTWaiter.wait(for: [scored], timeout: 3), .completed,
                       "The four-row clear should score 4000")
    }

    /// Hard drops in the spawn column stack up until the board tops out.
    /// Taps a fixed point, not the button: the button can leave mid-tap when
    /// the game ends, which fails an element tap.
    private func topOut(_ app: XCUIApplication) {
        let playAgain = app.buttons["play-again-button"]
        let frame = app.buttons["hard-drop-button"].frame
        let hardDrop = app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: frame.midX, dy: frame.midY))
        var drops = 0
        while !playAgain.waitForExistence(timeout: 0.3), drops < 60 {
            hardDrop.tap()
            drops += 1
        }
        XCTAssertTrue(playAgain.exists, "Hard drops should top out the board")
    }

    private func attachScreenshot(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "review-\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func test_settings_shows_stats_after_a_run() {
        let app = launchedApp(env: ["TESSERISS_RNG_SEED": "1337", "TESSERISS_TETRIS_SETUP": "1"])
        selectLanguage(app, "English")
        app.buttons["start-button"].tap()
        XCTAssertTrue(app.buttons["hard-drop-button"].waitForExistence(timeout: 3))
        clearFourRows(app)
        topOut(app)
        app.buttons["gameover-menu-button"].tap()
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 3))

        app.buttons["settings-button"].tap()
        XCTAssertTrue(app.buttons["back-button"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["how-to-play-button"].exists)
        XCTAssertEqual(app.buttons["how-to-play-button"].label, "How to play")
        let expected: [(id: String, label: String, value: String)] = [
            ("stat-games-played", "Games played", "1"),
            ("stat-rows-cleared", "Rows cleared", "4"),
            ("stat-four-row-clears", "Four-row clears", "1"),
            ("stat-best-fast", "Crack", "0"),
            ("stat-best-og", "Tear", "4000"),
            ("stat-best-hard", "Shatter", "0"),
        ]
        for stat in expected {
            let element = app.staticTexts[stat.id]
            XCTAssertTrue(element.exists, stat.id)
            XCTAssertEqual(element.label, stat.label, stat.id)
            XCTAssertEqual(element.value as? String, stat.value, stat.id)
        }
        let last = app.staticTexts["stat-best-hard"]
        var swipes = 0
        while !last.isHittable, swipes < 5 {
            app.scrollViews.firstMatch.swipeUp()
            swipes += 1
        }
        attachScreenshot(app, "settings-stats")
    }

    // MARK: - Onboarding

    private func waitUntilGone(_ element: XCUIElement, _ message: String) {
        let gone = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"),
                                             object: element)
        XCTAssertEqual(XCTWaiter.wait(for: [gone], timeout: 3), .completed, message)
    }

    /// Waits for step `n`'s title, lets the cross-fade finish, then attaches
    /// a screenshot named "review-onboarding-<n>".
    private func showsOnboardingStep(_ app: XCUIApplication, _ n: Int) {
        XCTAssertTrue(app.staticTexts["onboarding-step-\(n)"].waitForExistence(timeout: 3), "step \(n)")
        XCTAssertEqual(app.staticTexts["onboarding-progress"].label, "Step \(n) of 3")
        Thread.sleep(forTimeInterval: 0.5)
        attachScreenshot(app, "onboarding-\(n)")
    }

    func test_onboarding_shows_over_menu_and_skip_dismisses() {
        let app = launchedApp(extraArgs: ["--show-onboarding", "-AppleLanguages", "(en)"])
        XCTAssertTrue(app.otherElements["onboarding"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["start-button"].exists, "The menu is not shown under the onboarding")
        XCTAssertTrue(app.staticTexts["onboarding-step-1"].exists)
        XCTAssertEqual(app.buttons["onboarding-skip"].label, "SKIP")

        app.buttons["onboarding-skip"].tap()
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 3), "Skip returns to the menu")
        waitUntilGone(app.otherElements["onboarding"], "Skip closes the onboarding")
        XCTAssertFalse(app.buttons["hard-drop-button"].exists, "Skip doesn't start a game")
    }

    func test_onboarding_next_next_done_and_not_shown_on_relaunch() {
        let app = launchedApp(extraArgs: ["--show-onboarding", "-AppleLanguages", "(en)"])
        XCTAssertTrue(app.otherElements["onboarding"].waitForExistence(timeout: 5))
        showsOnboardingStep(app, 1)
        app.buttons["onboarding-next"].tap()
        showsOnboardingStep(app, 2)
        app.buttons["onboarding-next"].tap()
        showsOnboardingStep(app, 3)
        XCTAssertFalse(app.buttons["onboarding-skip"].exists, "The last step has Done only")
        XCTAssertFalse(app.buttons["onboarding-next"].exists)

        app.buttons["onboarding-done"].tap()
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 3), "Done returns to the menu")
        XCTAssertFalse(app.otherElements["onboarding"].exists)
        XCTAssertFalse(app.buttons["hard-drop-button"].exists, "Done doesn't start a game")
        app.terminate()

        // Without --ui-test the saved flag survives, so the menu comes first.
        let app2 = XCUIApplication()
        app2.launchArguments = []
        app2.launch()
        XCTAssertTrue(app2.buttons["start-button"].waitForExistence(timeout: 5))
        XCTAssertFalse(app2.otherElements["onboarding"].exists, "The onboarding shows once")
    }

    func test_how_to_play_reopens_onboarding_over_settings() {
        let app = launchedApp()
        app.buttons["settings-button"].tap()
        let back = app.buttons["back-button"]
        XCTAssertTrue(back.waitForExistence(timeout: 3))
        app.buttons["how-to-play-button"].tap()
        XCTAssertTrue(app.otherElements["onboarding"].waitForExistence(timeout: 3))
        waitUntilGone(back, "Settings is not shown under the onboarding")
        XCTAssertTrue(app.staticTexts["onboarding-step-1"].exists, "It reopens at step 1")

        app.buttons["onboarding-next"].tap()
        XCTAssertTrue(app.staticTexts["onboarding-step-2"].waitForExistence(timeout: 3))
        app.buttons["onboarding-next"].tap()
        XCTAssertTrue(app.staticTexts["onboarding-step-3"].waitForExistence(timeout: 3))
        app.buttons["onboarding-done"].tap()
        XCTAssertTrue(back.waitForExistence(timeout: 3), "Done returns to Settings")
        XCTAssertFalse(app.otherElements["onboarding"].exists)
    }
}
