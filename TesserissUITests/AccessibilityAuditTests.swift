import XCTest

/// Accessibility audits (`performAccessibilityAudit`) of every screen:
/// Settings, Menu, the game, the pause card and Game Over. Each test launches
/// fresh with `--ui-test`, sets one language / theme / appearance, then walks
/// the screens in that order and audits each one. The onboarding tests at the
/// end audit its steps instead.
///
/// Every audit category runs, except `.dynamicType` on the game and pause
/// screens (the reason is at those calls). To accept one known issue, pass an
/// issue handler that matches both its audit type and its element (or the
/// lack of one, where the audit reports none), with a comment saying why.
final class AccessibilityAuditTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    // MARK: - Themes and appearances, default text size

    // --ui-test wipes to Classic, Day. Each test taps the Settings segments it
    // lists, language first, since the other segment labels follow it.

    func test_audit_classic_day_english() throws {
        try auditEveryScreen(launchedApp(), tapping: ["English"])
    }

    func test_audit_classic_night_turkish() throws {
        try auditEveryScreen(launchedApp(), tapping: ["Türkçe", "Gece"])
    }

    func test_audit_hokusai_day_english() throws {
        try auditEveryScreen(launchedApp(), tapping: ["English", "Hokusai"])
    }

    func test_audit_hokusai_night_turkish() throws {
        try auditEveryScreen(launchedApp(), tapping: ["Türkçe", "Hokusai", "Gece"])
    }

    // MARK: - Largest accessibility text size

    // Menu, Settings and Game Over must scale and scroll at this size. The
    // language comes from the launch arguments, so no picker is tapped here,
    // where Settings lays its pickers out differently.

    func test_audit_largest_text_english() throws {
        try auditEveryScreen(launchedApp(extraArgs: largestText(language: "en")))
    }

    func test_audit_largest_text_turkish() throws {
        try auditEveryScreen(launchedApp(extraArgs: largestText(language: "tr")))
    }

    // MARK: - Onboarding

    func test_audit_onboarding_classic_day_english() throws {
        let app = launchedApp(extraArgs: ["--show-onboarding", "-AppleLanguages", "(en)"])
        try auditOnboarding(app, steps: 3, over: app.buttons["start-button"])
        XCTAssertEqual(app.staticTexts["onboarding-progress"].label, "Step 3 of 3")
        // Done reveals the menu; it doesn't start a game.
        app.buttons["onboarding-done"].tap()
        XCTAssertTrue(app.buttons["start-button"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["hard-drop-button"].exists)
    }

    // Opened from Settings ("How to play") after the picks, so it also covers
    // the onboarding over Settings.
    func test_audit_onboarding_hokusai_night_turkish() throws {
        let app = launchedApp()
        app.buttons["settings-button"].tap()
        let back = app.buttons["back-button"]
        XCTAssertTrue(back.waitForExistence(timeout: 3))
        for label in ["Türkçe", "Hokusai", "Gece"] {
            let segment = app.buttons[label]
            XCTAssertTrue(segment.waitForExistence(timeout: 3), label)
            segment.tap()
        }
        app.buttons["how-to-play-button"].tap()
        try auditOnboarding(app, steps: 1, over: back)
        app.buttons["onboarding-skip"].tap()
        XCTAssertTrue(back.waitForExistence(timeout: 3))
    }

    // MARK: - Helpers

    /// Audits the onboarding's first `steps` steps, moving on with Next.
    /// `underneath` is an element of the screen the onboarding opened over,
    /// which must be out of the accessibility tree while it shows.
    private func auditOnboarding(_ app: XCUIApplication, steps: Int, over underneath: XCUIElement) throws {
        XCTAssertTrue(app.otherElements["onboarding"].waitForExistence(timeout: 5))
        waitUntilGone(underneath)
        for step in 1...steps {
            let title = app.staticTexts["onboarding-step-\(step)"]
            XCTAssertTrue(title.waitForExistence(timeout: 3), "step \(step)")
            try auditEveryPage(app, "onboarding, step \(step)")
            let ids = step < 3 ? ["onboarding-skip", "onboarding-next"] : ["onboarding-done"]
            for id in ids {
                XCTAssertGreaterThanOrEqual(app.buttons[id].frame.height, 44, "\(id) touch target")
            }
            if step < steps {
                app.buttons["onboarding-next"].tap()
                waitUntilGone(title)
            }
        }
    }

    /// TESSERISS_TETRIS_SETUP prefills a four-row well and deals an I piece
    /// first, so one drop scores and Game Over shows the NEW BEST badge in the
    /// accent colour. The seed keeps the pieces after it the same every run.
    private func launchedApp(extraArgs: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-test"] + extraArgs
        app.launchEnvironment = ["TESSERISS_RNG_SEED": "1337", "TESSERISS_TETRIS_SETUP": "1"]
        app.launch()
        return app
    }

    private func largestText(language: String) -> [String] {
        ["-AppleLanguages", "(\(language))",
         "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
    }

    private func auditEveryScreen(_ app: XCUIApplication, tapping segments: [String] = []) throws {
        let start = app.buttons["start-button"]
        XCTAssertTrue(start.waitForExistence(timeout: 5))

        // Settings, after applying the picks.
        app.buttons["settings-button"].tap()
        let back = app.buttons["back-button"]
        XCTAssertTrue(back.waitForExistence(timeout: 3))
        waitUntilGone(start)
        for label in segments {
            let segment = app.buttons[label]
            XCTAssertTrue(segment.waitForExistence(timeout: 3), label)
            segment.tap()
        }
        try auditEveryPage(app, "settings")
        XCTAssertGreaterThanOrEqual(back.frame.height, 44, "back-button touch target")

        // Menu.
        back.tap()
        XCTAssertTrue(start.waitForExistence(timeout: 3))
        waitUntilGone(back)
        // Text recognition reads the vertical stripes of the Hokusai wave
        // beside the highscore panel as "11" and reports it as text with no
        // element. The backdrop is a decorative image with no text in it, so
        // that one issue (no element) is accepted on the Hokusai menu.
        let hokusai = segments.contains("Hokusai")
        try auditEveryPage(app, "menu") { issue in
            hokusai && issue.auditType == .elementDetection && issue.element == nil
        }

        // Game. tap() scrolls the button into view first, so this also fails
        // if Start can't be reached at the largest text size.
        start.tap()
        let hardDrop = app.buttons["hard-drop-button"]
        XCTAssertTrue(hardDrop.waitForExistence(timeout: 3))
        waitUntilGone(start)
        // The four-line clear first, before gravity lands the I piece flat.
        app.buttons["rotate-button"].tap()
        app.buttons["move-right-button"].press(forDuration: 1.5)
        hardDrop.tap()
        let scored = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value != '0'"),
                                               object: app.staticTexts["stat-score"])
        XCTAssertEqual(XCTWaiter.wait(for: [scored], timeout: 3), .completed,
                       "The four-line clear should score")
        for id in ["stat-score", "stat-level", "stat-lines"] {
            XCTAssertTrue(app.staticTexts[id].exists, id)
        }
        // The game screen is a fixed arcade layout: board, sidebar and control
        // pad must fit one screen, so its text grows only up to xxxLarge and the
        // glyph buttons offer the Large Content Viewer beyond that. The
        // .dynamicType audit flags text that stops growing, so it is left out
        // here; .textClipped still runs. The board cells are shapes, not
        // accessibility elements, so the falling piece doesn't change what is
        // audited.
        try audit(app, "game", excluding: .dynamicType)

        // Pause card: same fixed layout and reason as the game screen.
        app.buttons["pause-button"].tap()
        let resume = app.buttons["resume-button"]
        XCTAssertTrue(resume.waitForExistence(timeout: 2))
        // The dimmed game behind the card is hidden from VoiceOver on purpose,
        // so focus stays on the card, but text recognition still reads its
        // labels (NEXT, SCORE, ...) and reports them as text with no element.
        // Only that issue (elementDetection, no element) is accepted here.
        try audit(app, "pause", excluding: .dynamicType) { issue in
            issue.auditType == .elementDetection && issue.element == nil
        }
        resume.tap()
        waitUntilGone(resume)

        // Game Over. Hard drops in the spawn column stack up and top out the
        // 20-row board; the pause between taps outlasts the post-lock lockout.
        let playAgain = app.buttons
            .matching(NSPredicate(format: "label IN %@", ["PLAY AGAIN", "TEKRAR OYNA"]))
            .firstMatch
        // Tap the button's position, not the element: the button leaves when the
        // game ends, and on a slow runner that can happen between two taps,
        // which fails an element tap.
        let frame = hardDrop.frame
        let dropPoint = app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: frame.midX, dy: frame.midY))
        var drops = 0
        while !playAgain.waitForExistence(timeout: 0.3), drops < 60 {
            dropPoint.tap()
            drops += 1
        }
        XCTAssertTrue(playAgain.exists, "Hard drops should top out the board")
        waitUntilGone(hardDrop)
        try auditEveryPage(app, "game over")
    }

    /// Audits a scrolling screen one page at a time, top to bottom: at the
    /// largest text sizes Menu, Settings and Game Over are taller than the
    /// screen, and an audit only checks what is on it. Each drag moves half a
    /// screen, so pages overlap. The text clipping and Dynamic Type audits
    /// change the text size, which scrolls the content back to the top, so on
    /// each page they run after the others, and each page is reached again
    /// from the top.
    private func auditEveryPage(_ app: XCUIApplication, _ screen: String,
                                ignoring known: @escaping (XCUIAccessibilityAuditIssue) -> Bool = { _ in false }) throws {
        let resizing: XCUIAccessibilityAuditType = [.textClipped, .dynamicType]
        let scrollView = app.scrollViews.firstMatch
        let content = scrollView.descendants(matching: .any).matching(
            NSPredicate(format: "elementType IN %@",
                        [XCUIElement.ElementType.staticText.rawValue, XCUIElement.ElementType.button.rawValue]))
        let first = content.element(boundBy: 0)
        let bottom = content.element(boundBy: content.count - 1)
        let top = first.frame.minY
        for page in 1...12 {
            var swipes = 0
            while first.frame.minY < top - 1, swipes < 3 {
                scrollView.swipeDown()
                Thread.sleep(forTimeInterval: 1)
                swipes += 1
            }
            for _ in 1..<page {
                // Near the left edge, clear of the switches and slider thumbs.
                // The hold before lifting stops the content from flinging.
                let from = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.08, dy: 0.75))
                let to = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.08, dy: 0.25))
                from.press(forDuration: 0.05, thenDragTo: to, withVelocity: .slow, thenHoldForDuration: 0.3)
            }
            // Text cut by the top or bottom edge is faded by the system's scroll
            // edge effect, which fails contrast. On iOS 26 the fade reaches a few
            // points inside the bounds, so text within 32pt of an edge counts as
            // cut too. Pages overlap by half a screen, so that text is audited
            // whole on the page before or after.
            try audit(app, "\(screen), page \(page)", excluding: resizing) { issue in
                if known(issue) { return true }
                guard issue.auditType == .contrast, let frame = issue.element?.frame else { return false }
                return frame.minY < scrollView.frame.minY + 32 || frame.maxY > scrollView.frame.maxY - 32
            }
            let lastPage = bottom.frame.maxY <= scrollView.frame.maxY + 1
            try audit(app, "\(screen), page \(page), text size",
                      excluding: XCUIAccessibilityAuditType.all.subtracting(resizing), ignoring: known)
            if lastPage { return }
        }
        XCTFail("\(screen): \"\(bottom.label)\" is still below the screen after 12 pages")
    }

    /// Reports every issue on the screen, not just the first; navigation
    /// still stops at its first failure.
    /// `known` returns true for an issue that is accepted; each caller says why.
    private func audit(_ app: XCUIApplication, _ screen: String,
                       excluding excluded: XCUIAccessibilityAuditType = [],
                       ignoring known: @escaping (XCUIAccessibilityAuditIssue) -> Bool = { _ in false }) throws {
        // Let cross-fades, theme changes and scrolling settle before measuring.
        Thread.sleep(forTimeInterval: 1)
        continueAfterFailure = true
        defer { continueAfterFailure = false }
        try XCTContext.runActivity(named: "Audit \(screen)") { _ in
            // On a slow CI runner the audit itself can run out of time (error
            // -56 "Audit failed to complete in time"). That says nothing about
            // the screen, so retry it; any other error still fails the test.
            for attempt in 1...3 {
                do {
                    try app.performAccessibilityAudit(for: XCUIAccessibilityAuditType.all.subtracting(excluded)) {
                        known($0)
                    }
                    return
                } catch let error as NSError
                            where error.domain == "com.apple.xcode.xctest.accessibilityAudit"
                            && error.code == -56 && attempt < 3 {
                    Thread.sleep(forTimeInterval: 2)
                }
            }
        }
    }

    /// Screens cross-fade. Waiting for the old one to leave keeps the audit
    /// from measuring contrast on half-faded text.
    private func waitUntilGone(_ element: XCUIElement) {
        let gone = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"),
                                             object: element)
        XCTAssertEqual(XCTWaiter.wait(for: [gone], timeout: 3), .completed,
                       "The previous screen should leave")
    }
}
