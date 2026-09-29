import XCTest
@testable import Tesseriss

/// Covers the v1.1 feel changes — wall kicks, lock delay, spawn normalisation and
/// the post-lock input lockout. The engine had no test coverage at all before this.
final class GameEngineTests: XCTestCase {

    private func makeEngine() -> GameEngine {
        // Isolated defaults so tests don't read or write the real settings.
        let suite = "tesseriss.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        let settings = SettingsStore(defaults: defaults)
        settings.hapticsEnabled = false
        settings.musicEnabled = false   // keep the test run silent

        return GameEngine(settings: settings,
                          highscoreStore: HighscoreStore(defaults: defaults),
                          randomizerFactory: { PieceRandomizer(pentominoChance: $0) })
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
}
