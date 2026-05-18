import XCTest
@testable import Tesseriss

final class BoardTests: XCTestCase {
    func test_empty_board_has_no_collision_at_spawn() {
        let board = Board()
        for kind in PieceKind.allCases {
            let p = Tetromino.spawn(kind: kind, boardWidth: board.width, boardHeight: board.height)
            XCTAssertFalse(board.collides(p), "Spawn for \(kind) should not collide on an empty board")
        }
    }

    func test_piece_at_floor_collides_on_further_downward_shift() {
        let board = Board()
        var piece = Tetromino.spawn(kind: .O, boardWidth: board.width, boardHeight: board.height)
        while !board.collides(piece.moved(dx: 0, dy: 1)) {
            piece = piece.moved(dx: 0, dy: 1)
        }
        XCTAssertTrue(board.collides(piece.moved(dx: 0, dy: 1)))
    }

    func test_collides_with_left_wall() {
        let board = Board()
        let piece = Tetromino(kind: .O, rotation: 0, origin: GridPoint(x: -1, y: 5))
        XCTAssertTrue(board.collides(piece))
    }

    func test_collides_with_right_wall() {
        let board = Board()
        let piece = Tetromino(kind: .O, rotation: 0, origin: GridPoint(x: board.width - 1, y: 5))
        XCTAssertTrue(board.collides(piece))
    }

    func test_collides_with_locked_block() {
        var board = Board()
        board.grid[10][4] = .I
        let piece = Tetromino(kind: .O, rotation: 0, origin: GridPoint(x: 3, y: 9))
        XCTAssertTrue(board.collides(piece))
    }

    func test_full_row_detected() {
        var board = Board()
        for x in 0..<board.width { board.grid[board.height - 1][x] = .I }
        XCTAssertEqual(board.fullRows(), [board.height - 1])
    }

    func test_clearing_row_drops_rows_above() {
        var board = Board()
        for x in 0..<board.width { board.grid[board.height - 1][x] = .I }
        board.grid[board.height - 2][0] = .T
        board.clearRows([board.height - 1])
        XCTAssertEqual(board.grid[board.height - 1][0], .T)
        XCTAssertNil(board.grid[board.height - 2][0])
    }

    func test_four_line_clear_empties_when_only_filled_rows_exist() {
        var board = Board()
        for y in (board.height - 4)..<board.height {
            for x in 0..<board.width { board.grid[y][x] = .I }
        }
        let rows = board.fullRows()
        XCTAssertEqual(rows.count, 4)
        board.clearRows(rows)
        XCTAssertTrue(board.isEmpty)
    }

    func test_four_line_clear_with_blocks_above_drops_them_correctly() {
        var board = Board()
        for y in (board.height - 4)..<board.height {
            for x in 0..<board.width { board.grid[y][x] = .I }
        }
        board.grid[board.height - 5][3] = .T
        board.clearRows(board.fullRows())
        XCTAssertEqual(board.grid[board.height - 1][3], .T)
        for y in 0..<(board.height - 1) {
            XCTAssertNil(board.grid[y][3])
        }
    }

    func test_custom_dimensions_for_fast_mode() {
        let board = Board(width: 8, height: 15)
        XCTAssertEqual(board.width, 8)
        XCTAssertEqual(board.height, 15)
        XCTAssertEqual(board.grid.count, 15)
        XCTAssertEqual(board.grid[0].count, 8)
        let piece = Tetromino(kind: .O, rotation: 0, origin: GridPoint(x: 7, y: 5))
        XCTAssertTrue(board.collides(piece), "O at x=7 in 8-wide board must hit right wall")
    }
}
