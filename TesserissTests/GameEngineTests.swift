import XCTest
@testable import Tesseriss

/// Covers the v1.1 feel changes — wall kicks, lock delay, spawn normalisation and
/// the post-lock input lockout. The engine had no test coverage at all before this.
final class GameEngineTests: XCTestCase {

    private func makeEngine(highscoreStore: HighscoreStore? = nil,
                            randomizerFactory: @escaping (Double) -> PieceRandomizer = { PieceRandomizer(pentominoChance: $0) })
        -> GameEngine {
        // Isolated defaults so tests don't read or write the real settings.
        let suite = "tesseriss.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        let settings = SettingsStore(defaults: defaults)
        settings.hapticsEnabled = false
        settings.musicEnabled = false   // keep the test run silent
        settings.sfxEnabled = false

        return GameEngine(settings: settings,
                          highscoreStore: highscoreStore ?? HighscoreStore(defaults: defaults),
                          randomizerFactory: randomizerFactory)
    }

    /// Starts an og game on the TESSERISS_TETRIS_SETUP board (bottom four rows
    /// full except the right-hand column, an I dealt first), then stands the I
    /// up and hard-drops it into that column. Returns with the clear flashing.
    private func startGameAndDropAFourLineClear(_ engine: GameEngine) {
        setenv("TESSERISS_TETRIS_SETUP", "1", 1)
        defer { unsetenv("TESSERISS_TETRIS_SETUP") }
        engine.startNewGame(mode: .og)
        engine.rotateCW()
        for _ in 0..<10 { engine.moveRight(haptic: false) }
        engine.hardDrop()
    }

    /// Hard-drops every piece where it spawns until the game ends (at most 40
    /// drops). Every spawn covers the centre column and none reaches the
    /// left-hand columns, so no line can clear and the stack has to top out.
    private func hardDropUntilGameOver(_ engine: GameEngine) {
        var drops = 0
        while engine.screen != .gameOver, drops < 40 {
            engine.hardDrop()
            drops += 1
            // Wait out the post-lock lockout so the next hard drop is accepted.
            RunLoop.current.run(until: Date().addingTimeInterval(GameEngine.postLockInputLockout + 0.02))
        }
    }

    // MARK: - Spawn normalisation

    func test_spawn_putsEveryPieceTopRowOnRowZero() {
        for kind in PieceKind.allCases {
            let piece = Tetromino.spawn(kind: kind, boardWidth: 10, boardHeight: 20)
            let topRow = piece.cells.map(\.y).min()
            XCTAssertEqual(topRow, 0, "\(kind) should spawn with its top cell on row 0")
        }
    }

    func test_spawn_isHorizontallyCentered() {
        for kind in PieceKind.allCases {
            let piece = Tetromino.spawn(kind: kind, boardWidth: 10, boardHeight: 20)
            let xs = piece.cells.map(\.x)
            let left = xs.min()!
            let right = 10 - 1 - xs.max()!
            XCTAssertLessThanOrEqual(abs(left - right), 1,
                                     "\(kind) should be centered (left \(left), right \(right))")
            XCTAssertGreaterThanOrEqual(left, 0, "\(kind) should spawn inside the board")
        }
    }

    // MARK: - Wall kicks

    func test_rotation_kicksAroundAnObstacle() {
        var board = Board(width: 10, height: 20)
        // A vertical T against the left wall, with the cell its rotation wants to
        // occupy already filled — so the plain rotation has nowhere to go.
        let piece = Tetromino(kind: .T, rotation: 1, origin: GridPoint(x: 0, y: 5))
        board.grid[6][2] = .O
        XCTAssertFalse(board.collides(piece), "precondition: the piece itself is legally placed")
        XCTAssertTrue(board.collides(piece.rotated(by: 1)),
                      "precondition: the un-kicked rotation must collide")

        let result = Tetromino.rotatedWithKick(piece, by: 1, in: board)
        XCTAssertNotNil(result, "rotation should succeed via a kick")
        XCTAssertNotEqual(result?.kick, GridPoint(x: 0, y: 0), "it should have needed a kick")
        XCTAssertFalse(board.collides(result!.piece), "the kicked placement must be legal")
    }

    func test_flatIPieceCanStandUpOffTheFloor() {
        let board = Board(width: 10, height: 20)
        // A horizontal I lying on the bottom row: the classic "why won't it turn".
        let piece = Tetromino(kind: .I, rotation: 0, origin: GridPoint(x: 3, y: 18))
        XCTAssertFalse(board.collides(piece), "precondition: resting legally on the floor")
        XCTAssertTrue(board.collides(piece.rotated(by: 1)),
                      "precondition: standing up in place would overflow the floor")

        let result = Tetromino.rotatedWithKick(piece, by: 1, in: board)
        XCTAssertNotNil(result, "an I on the floor should still be able to stand up")
        XCTAssertLessThan(result!.piece.origin.y, piece.origin.y,
                          "a floor kick should lift the piece, never push it down")
        XCTAssertFalse(board.collides(result!.piece))
    }

    func test_rotation_returnsNilWhenFullyBoxedIn() {
        var board = Board(width: 10, height: 20)
        // Fill everything except a single cell, so no offset can fit a rotation.
        for y in 0..<20 {
            for x in 0..<10 { board.grid[y][x] = .O }
        }
        board.grid[0][0] = nil
        let piece = Tetromino(kind: .T, rotation: 0, origin: GridPoint(x: 4, y: 10))
        XCTAssertNil(Tetromino.rotatedWithKick(piece, by: 1, in: board))
    }

    func test_kickOffsets_neverPushDown() {
        for offset in Tetromino.kickOffsets {
            XCTAssertLessThanOrEqual(offset.y, 0, "a kick must not shove a piece downward")
        }
    }

    func test_rotation_neverLiftsThePieceWhollyAboveTheBoard() {
        // Near the top: rows 0-2 are full except where a freshly spawned I lies.
        var board = Board(width: 10, height: 20)
        let spawned = Tetromino.spawn(kind: .I, boardWidth: 10, boardHeight: 20)
        for y in 0...2 {
            for x in 0..<10 where !spawned.cells.contains(GridPoint(x: x, y: y)) {
                board.grid[y][x] = .O
            }
        }
        // Standing up kicks the I two rows up, leaving its bottom cell on row 0.
        guard let standing = Tetromino.rotatedWithKick(spawned, by: 1, in: board)?.piece else {
            return XCTFail("precondition: the I can stand up")
        }
        XCTAssertTrue(standing.cells.contains(where: { $0.y >= 0 }), "precondition: the standing I shows on the board")

        // Lying flat again would fit only on row -1, since Board.collides treats
        // rows above the board as empty. Up there the piece can't be seen.
        if let flat = Tetromino.rotatedWithKick(standing, by: 1, in: board)?.piece {
            XCTAssertTrue(flat.cells.contains(where: { $0.y >= 0 }),
                          "a rotation must leave at least one cell on the board, got \(flat.cells)")
        }
    }

    // MARK: - Lock delay

    func test_landedPieceIsNotLockedImmediately() {
        let engine = makeEngine()
        engine.startNewGame(mode: .og)

        // Drop until the piece is resting on the floor.
        var guardCount = 0
        while let piece = engine.current,
              !engine.board.collides(piece.moved(dx: 0, dy: 1)),
              guardCount < 100 {
            engine.softDrop()
            guardCount += 1
        }

        XCTAssertNotNil(engine.current, "the piece should still be in play during lock delay")
        XCTAssertTrue(engine.board.isEmpty,
                      "nothing should be committed to the board until the lock delay elapses")
    }

    func test_lockDelayEventuallyCommitsThePiece() {
        let engine = makeEngine()
        engine.startNewGame(mode: .og)
        while let piece = engine.current,
              !engine.board.collides(piece.moved(dx: 0, dy: 1)) {
            engine.softDrop()
        }
        XCTAssertTrue(engine.board.isEmpty, "precondition: not locked yet")

        let locked = expectation(description: "piece locks after the delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + GameEngine.lockDelay + 0.25) {
            locked.fulfill()
        }
        wait(for: [locked], timeout: GameEngine.lockDelay + 1.0)

        XCTAssertFalse(engine.board.isEmpty, "the piece should be committed once the delay elapses")
    }

    func test_hardDropLocksImmediately() {
        let engine = makeEngine()
        engine.startNewGame(mode: .og)
        engine.hardDrop()
        XCTAssertFalse(engine.board.isEmpty, "hard drop should commit at once, not wait")
    }

    // MARK: - Post-lock input lockout

    func test_dropInputIsIgnoredBrieflyAfterALock() {
        let engine = makeEngine()
        engine.startNewGame(mode: .og)
        engine.hardDrop()                       // locks, and starts the lockout
        let spawned = engine.current
        XCTAssertNotNil(spawned)

        // Holding soft-drop through a lock used to slam the next piece down.
        engine.softDrop()
        XCTAssertEqual(engine.current?.origin, spawned?.origin,
                       "the freshly spawned piece should not move during the lockout")
    }

    // MARK: - Top-out

    func test_stackingToTheTopEndsTheGame() {
        // Seed 5 deals an I as the first blocked spawn. An I spawns one row tall,
        // so any lift at all would put it wholly above the board.
        let engine = makeEngine(randomizerFactory: {
            PieceRandomizer(pentominoChance: $0, rng: SeededRandomNumberGenerator(seed: 5))
        })
        engine.startNewGame(mode: .og)
        // As in hardDropUntilGameOver, checking each piece as it comes into play.
        var drops = 0
        while engine.phase == .playing, drops < 40, let piece = engine.current {
            // A blocked spawn may be lifted, but never wholly above the board:
            // up there it can't collide, so the top-out could never fire.
            XCTAssertTrue(piece.cells.contains(where: { $0.y >= 0 }),
                          "drop \(drops): the piece in play must show on the board")
            engine.hardDrop()
            drops += 1
            RunLoop.current.run(until: Date().addingTimeInterval(GameEngine.postLockInputLockout + 0.02))
        }
        XCTAssertEqual(engine.screen, .gameOver, "a stack that reaches the top must end the game")
        XCTAssertEqual(engine.phase, .gameOver)
    }

    func test_lockedPieceKeepsEveryCellWhileTheGameGoesOn() {
        let engine = makeEngine()
        engine.startNewGame(mode: .fast)
        // Stack as in hardDropUntilGameOver, counting the board's cells around
        // each lock. No line clears, so each lock adds a whole piece.
        var drops = 0
        while engine.phase == .playing, drops < 40, let piece = engine.current {
            let before = engine.board.grid.joined().compactMap { $0 }.count
            engine.hardDrop()
            drops += 1
            if engine.phase == .playing {
                let after = engine.board.grid.joined().compactMap { $0 }.count
                XCTAssertEqual(after - before, piece.kind.cellCount,
                               "drop \(drops): a locked piece must keep every cell")
            }
            RunLoop.current.run(until: Date().addingTimeInterval(GameEngine.postLockInputLockout + 0.02))
        }
        XCTAssertEqual(engine.phase, .gameOver, "precondition: the stack should have reached the top")
    }

    func test_pieceLockedAboveTheBoardEndsTheGame() {
        // Every piece is stood up and pushed against the left wall, so columns
        // 0-1 fill to the top while the spawn columns stay empty. With seed 2 a
        // piece then locks partly above row 0 and the next one would still fit:
        // only the lock-out can end the game there.
        let engine = makeEngine(randomizerFactory: {
            PieceRandomizer(pentominoChance: $0, rng: SeededRandomNumberGenerator(seed: 2))
        })
        engine.startNewGame(mode: .og)
        var drops = 0
        while engine.phase == .playing, drops < 40 {
            engine.rotateCW()
            for _ in 0..<10 { engine.moveLeft(haptic: false) }
            guard var landed = engine.current, let nextKind = engine.nextKind else { break }
            while !engine.board.collides(landed.moved(dx: 0, dy: 1)) {
                landed = landed.moved(dx: 0, dy: 1)
            }
            var board = engine.board
            board.lock(landed)
            engine.hardDrop()
            drops += 1
            if landed.cells.contains(where: { $0.y < 0 }) {
                let next = Tetromino.spawn(kind: nextKind, boardWidth: board.width, boardHeight: board.height)
                XCTAssertFalse(board.collides(next), "precondition: the next piece would still fit")
                XCTAssertEqual(engine.phase, .gameOver,
                               "drop \(drops): a piece locked above the board must end the game")
                return
            }
            // Thread.sleep, not the run loop: a gravity tick would move the next
            // piece and change the seeded stack.
            Thread.sleep(forTimeInterval: GameEngine.postLockInputLockout + 0.02)
        }
        XCTFail("precondition: no piece locked above the board in \(drops) drops")
    }

    // MARK: - New best flag

    func test_newHighscoreFlagIsSetOnlyByAStrictBeat() {
        let engine = makeEngine()
        startGameAndDropAFourLineClear(engine)
        RunLoop.current.run(until: Date().addingTimeInterval(0.75))   // past the 0.5 s flash
        XCTAssertEqual(engine.score, 4000, "precondition: the four-line clear scored")
        hardDropUntilGameOver(engine)
        XCTAssertEqual(engine.screen, .gameOver, "precondition: the game ended")
        XCTAssertTrue(engine.isNewHighscore, "4000 beats the empty best of 0")

        engine.startNewGame(mode: .og)
        XCTAssertFalse(engine.isNewHighscore, "a new game must start without the flag")

        startGameAndDropAFourLineClear(engine)
        RunLoop.current.run(until: Date().addingTimeInterval(0.75))
        XCTAssertEqual(engine.score, 4000, "precondition: the four-line clear scored")
        hardDropUntilGameOver(engine)
        XCTAssertEqual(engine.screen, .gameOver, "precondition: the game ended")
        XCTAssertFalse(engine.isNewHighscore, "matching the best is not a new best")
    }

    func test_newHighscoreFlagStaysOffBelowTheBestAndAtZero() {
        let store = HighscoreStore(defaults: UserDefaults(suiteName: "tesseriss.tests.\(UUID().uuidString)")!)
        store.maybeUpdate(9000, for: .og)
        let engine = makeEngine(highscoreStore: store)
        startGameAndDropAFourLineClear(engine)
        RunLoop.current.run(until: Date().addingTimeInterval(0.75))   // past the 0.5 s flash
        XCTAssertEqual(engine.score, 4000, "precondition: the four-line clear scored")
        hardDropUntilGameOver(engine)
        XCTAssertEqual(engine.screen, .gameOver, "precondition: the game ended")
        XCTAssertFalse(engine.isNewHighscore, "4000 is below the best of 9000")

        let fresh = makeEngine()
        fresh.startNewGame(mode: .og)
        hardDropUntilGameOver(fresh)
        XCTAssertEqual(fresh.screen, .gameOver, "precondition: the game ended")
        XCTAssertEqual(fresh.score, 0, "precondition: nothing was cleared")
        XCTAssertFalse(fresh.isNewHighscore, "a score of 0 is never a new best")
    }

    // MARK: - Quitting to the menu

    func test_returnToMenuSavesTheBestSoFar() {
        let defaults = UserDefaults(suiteName: "tesseriss.tests.\(UUID().uuidString)")!
        let engine = makeEngine(highscoreStore: HighscoreStore(defaults: defaults))
        startGameAndDropAFourLineClear(engine)
        RunLoop.current.run(until: Date().addingTimeInterval(0.75))   // past the 0.5 s flash
        XCTAssertEqual(engine.score, 4000, "precondition: the four-line clear scored")

        engine.returnToMenu()
        // A fresh store reads what was written to defaults, as on the next launch.
        XCTAssertEqual(HighscoreStore(defaults: defaults).highscore(for: .og), 4000,
                       "quitting mid-game must still record the score as a best")
    }

    func test_returnToMenuDuringALineClearCountsTheClear() {
        let defaults = UserDefaults(suiteName: "tesseriss.tests.\(UUID().uuidString)")!
        let engine = makeEngine(highscoreStore: HighscoreStore(defaults: defaults))
        startGameAndDropAFourLineClear(engine)
        guard case .clearing = engine.phase else { return XCTFail("precondition: a clear is in flight") }

        engine.returnToMenu()   // quit mid-flash

        XCTAssertEqual(HighscoreStore(defaults: defaults).highscore(for: .og), 4000,
                       "the best saved on quit must include the clear that was still flashing")
        XCTAssertEqual(engine.screen, .menu)
        XCTAssertNil(engine.current, "no next piece is dealt on the way to the menu")
        RunLoop.current.run(until: Date().addingTimeInterval(0.75))   // past the 0.5 s flash
        XCTAssertEqual(engine.screen, .menu, "the flash timer must not pull the game back")
        XCTAssertEqual(engine.lines, 4, "the clear is credited once")
    }

    // MARK: - Pausing mid-clear

    func test_pauseDuringALineClearCreditsItAndStaysPaused() {
        let engine = makeEngine()
        startGameAndDropAFourLineClear(engine)
        guard case .clearing = engine.phase else { return XCTFail("precondition: a clear is in flight") }

        engine.togglePause()   // the player tapped pause mid-flash

        XCTAssertEqual(engine.phase, .paused, "a pause mid-flash must not be ignored")
        XCTAssertEqual(engine.lines, 4, "the clear is credited at once")
        XCTAssertEqual(engine.score, 4000)
        XCTAssertTrue(engine.flashingRows.isEmpty, "no rows left flashing under the pause overlay")
        XCTAssertFalse(engine.celebrationActive, "no celebration banner over the pause overlay")
        XCTAssertNotNil(engine.current, "the next piece is dealt, ready for resume")

        RunLoop.current.run(until: Date().addingTimeInterval(0.75))   // past the 0.5 s flash
        XCTAssertEqual(engine.phase, .paused, "the flash timer must not resume play")
        XCTAssertEqual(engine.lines, 4, "the clear is credited once")
    }

    // MARK: - Scene-phase auto-pause

    func test_autoPauseDuringALineClearKeepsTheGamePaused() {
        let engine = makeEngine()
        startGameAndDropAFourLineClear(engine)
        guard case .clearing = engine.phase else { return XCTFail("precondition: a clear is in flight") }

        engine.autoPauseFromScenePhase()   // the scene went inactive mid-flash
        RunLoop.current.run(until: Date().addingTimeInterval(0.75))   // past the 0.5 s flash

        XCTAssertEqual(engine.phase, .paused, "a finishing clear must not resume play behind the user's back")
        XCTAssertEqual(engine.lines, 4, "the clear is still credited")
    }

    // MARK: - Sound effects

    func test_fourLineChimeFollowsTheSfxSettingNotMusic() {
        for sfxOn in [true, false] {
            let defaults = UserDefaults(suiteName: "tesseriss.tests.\(UUID().uuidString)")!
            let settings = SettingsStore(defaults: defaults)
            settings.hapticsEnabled = false
            settings.musicEnabled = false
            settings.sfxEnabled = sfxOn
            let audio = AudioSpy(settings: settings)
            let engine = GameEngine(settings: settings,
                                    highscoreStore: HighscoreStore(defaults: defaults),
                                    audio: audio)
            startGameAndDropAFourLineClear(engine)
            XCTAssertEqual(audio.fourLineChimes, [sfxOn],
                           "with music off, the chime must follow the sound effects setting (sfx \(sfxOn))")
        }
    }

    func test_lineClearSoundFollowsTheSfxSettingNotMusic() {
        for sfxOn in [true, false] {
            let defaults = UserDefaults(suiteName: "tesseriss.tests.\(UUID().uuidString)")!
            let settings = SettingsStore(defaults: defaults)
            settings.hapticsEnabled = false
            settings.musicEnabled = false
            settings.sfxEnabled = sfxOn
            let audio = AudioSpy(settings: settings)
            let engine = GameEngine(settings: settings,
                                    highscoreStore: HighscoreStore(defaults: defaults),
                                    audio: audio,
                                    randomizerFactory: {
                                        PieceRandomizer(pentominoChance: $0, rng: SeededRandomNumberGenerator(seed: 1))
                                    })
            setenv("TESSERISS_TETRIS_SETUP", "1", 1)
            engine.startNewGame(mode: .og)
            unsetenv("TESSERISS_TETRIS_SETUP")
            // Lay the setup's I flat on the stack. Seed 1 deals an S next: stood
            // up against the right wall, it fills the gap in one row only.
            engine.hardDrop()
            Thread.sleep(forTimeInterval: GameEngine.postLockInputLockout + 0.02)
            engine.rotateCW()
            for _ in 0..<10 { engine.moveRight(haptic: false) }
            engine.hardDrop()
            guard case .clearing(_, isFourLine: false) = engine.phase else {
                return XCTFail("precondition: a 1-3-line clear is in flight (sfx \(sfxOn))")
            }
            XCTAssertEqual(audio.lineClears, [sfxOn],
                           "with music off, the line-clear sound must follow the sound effects setting (sfx \(sfxOn))")
        }
    }

    // MARK: - Random input

    /// Plays seeded random input until game over and checks the engine's state
    /// after every step.
    func test_randomInputsKeepTheBoardConsistent() {
        let games: [(GameMode, UInt64)] = [(.og, 0xC0FFEE), (.hard, 0xBADC0DE), (.fast, 99)]
        for (mode, seed) in games {
            let engine = makeEngine(randomizerFactory: {
                PieceRandomizer(pentominoChance: $0, rng: SeededRandomNumberGenerator(seed: seed))
            })
            engine.startNewGame(mode: mode)
            let rng = SeededRandomNumberGenerator(seed: seed &+ 1)
            var step = 0, locks = 0, lastScore = 0, lastLines = 0
            while engine.phase != .gameOver, step < 400 {
                // Settle a flashing clear and resume, so the input reaches a falling piece.
                if case .clearing = engine.phase { engine.togglePause() }
                if engine.phase == .paused { engine.togglePause() }
                let gridBefore = engine.board.grid
                let input = Int(rng.next() % 7)
                switch input {
                case 0: engine.moveLeft(haptic: false)
                case 1: engine.moveRight(haptic: false)
                case 2: engine.rotateCW()
                case 3: engine.rotateCCW()
                case 4: engine.softDrop(haptic: false)
                case 5: engine.hardDrop()
                default: engine.togglePause()
                }
                if input == 5 {
                    // A lock adds cells, or starts a clear or the game over. Comparing
                    // pieces would miss a respawn of the same kind at the same spot.
                    if engine.board.grid != gridBefore || engine.phase != .playing { locks += 1 }
                    // Wait out the post-lock lockout, or every later drop is ignored.
                    // Thread.sleep, not the run loop: a gravity tick would break the seeded replay.
                    Thread.sleep(forTimeInterval: GameEngine.postLockInputLockout + 0.02)
                }
                step += 1

                let tag = "\(mode) seed \(seed) step \(step)"
                let board = engine.board
                XCTAssertEqual(board.grid.count, board.height, tag)
                XCTAssertTrue(board.grid.allSatisfy { $0.count == board.width }, tag)
                XCTAssertGreaterThanOrEqual(engine.score, lastScore, "\(tag): score went down")
                XCTAssertGreaterThanOrEqual(engine.lines, lastLines, "\(tag): lines went down")
                XCTAssertEqual(engine.level, engine.lines / 10, tag)
                lastScore = engine.score
                lastLines = engine.lines

                // The blocked spawn that ends the game overlaps the stack by design.
                guard engine.phase != .gameOver, let piece = engine.current else { continue }
                for c in piece.cells {
                    XCTAssertTrue((0..<board.width).contains(c.x) && c.y < board.height, "\(tag): \(c) is off the board")
                    XCTAssertNil(board.cell(c), "\(tag): \(c) overlaps the stack")
                }
                XCTAssertTrue(piece.cells.contains(where: { $0.y >= 0 }), "\(tag): the piece is wholly above the board")
            }
            XCTAssertGreaterThan(locks, 5, "\(mode) seed \(seed): the input must play a real game")
        }
    }
}

/// Records sound effect requests instead of playing them.
private final class AudioSpy: AudioController {
    var fourLineChimes: [Bool] = []
    var lineClears: [Bool] = []
    override func playFourLineChime(enabled: Bool) { fourLineChimes.append(enabled) }
    override func playLineClear(enabled: Bool) { lineClears.append(enabled) }
}
