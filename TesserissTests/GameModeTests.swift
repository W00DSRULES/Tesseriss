import XCTest
@testable import Tesseriss

final class GameModeTests: XCTestCase {
    func test_fast_mode_has_8x15_board() {
        XCTAssertEqual(GameMode.fast.boardWidth, 8)
        XCTAssertEqual(GameMode.fast.boardHeight, 15)
    }

    func test_og_mode_has_10x20_board() {
        XCTAssertEqual(GameMode.og.boardWidth, 10)
        XCTAssertEqual(GameMode.og.boardHeight, 20)
    }

    func test_hard_mode_keeps_og_dimensions() {
        XCTAssertEqual(GameMode.hard.boardWidth, 10)
        XCTAssertEqual(GameMode.hard.boardHeight, 20)
    }

    func test_fast_mode_gravity_is_half() {
        XCTAssertEqual(GameMode.fast.gravityScale, 0.5, accuracy: 0.0001)
    }

    func test_og_and_hard_use_baseline_gravity() {
        XCTAssertEqual(GameMode.og.gravityScale, 1.0, accuracy: 0.0001)
        XCTAssertEqual(GameMode.hard.gravityScale, 1.0, accuracy: 0.0001)
    }

    func test_only_hard_mode_spawns_pentominoes() {
        XCTAssertEqual(GameMode.fast.pentominoChance, 0)
        XCTAssertEqual(GameMode.og.pentominoChance, 0)
        XCTAssertGreaterThan(GameMode.hard.pentominoChance, 0)
    }

    func test_each_mode_has_distinct_highscore_key() {
        let keys = Set(GameMode.allCases.map(\.highscoreKey))
        XCTAssertEqual(keys.count, GameMode.allCases.count)
    }
}
