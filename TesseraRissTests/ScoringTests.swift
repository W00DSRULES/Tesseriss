import XCTest
@testable import TesseraRiss

final class ScoringTests: XCTestCase {
    func test_points_at_level_zero_matches_nes_table() {
        XCTAssertEqual(Scoring.points(linesCleared: 1, level: 0), 40)
        XCTAssertEqual(Scoring.points(linesCleared: 2, level: 0), 100)
        XCTAssertEqual(Scoring.points(linesCleared: 3, level: 0), 300)
        XCTAssertEqual(Scoring.points(linesCleared: 4, level: 0), 1200)
    }

    func test_points_double_at_level_one() {
        XCTAssertEqual(Scoring.points(linesCleared: 1, level: 1), 80)
        XCTAssertEqual(Scoring.points(linesCleared: 2, level: 1), 200)
        XCTAssertEqual(Scoring.points(linesCleared: 3, level: 1), 600)
        XCTAssertEqual(Scoring.points(linesCleared: 4, level: 1), 2400)
    }

    func test_zero_lines_award_zero_points() {
        XCTAssertEqual(Scoring.points(linesCleared: 0, level: 0), 0)
        XCTAssertEqual(Scoring.points(linesCleared: 0, level: 9), 0)
    }

    func test_gravity_table_anchor_values() {
        XCTAssertEqual(Scoring.gravityMs(level: 0), 800)
        XCTAssertEqual(Scoring.gravityMs(level: 9), 100)
        XCTAssertEqual(Scoring.gravityMs(level: 19), 33)
    }

    func test_gravity_saturation_curve_past_table() {
        XCTAssertEqual(Scoring.gravityMs(level: 20), 32)
        XCTAssertLessThanOrEqual(abs(Scoring.gravityMs(level: 60) - 20), 1)
        XCTAssertEqual(Scoring.gravityMs(level: 200), Scoring.gravityMs(level: 100))
    }

    func test_gravity_interval_matches_ms_table() {
        XCTAssertEqual(Scoring.gravityInterval(level: 0), 0.8, accuracy: 0.001)
        XCTAssertEqual(Scoring.gravityInterval(level: 19), 0.033, accuracy: 0.001)
    }
}
