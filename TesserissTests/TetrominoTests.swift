import XCTest
@testable import Tesseriss

final class TetrominoTests: XCTestCase {
    func test_four_rotations_return_to_identity() {
        for kind in PieceKind.allCases {
            let base = Set(Tetromino.cells(kind: kind, rotation: 0).map { GridPoint(x: $0.x, y: $0.y) })
            let rotated = Set(Tetromino.cells(kind: kind, rotation: 4).map { GridPoint(x: $0.x, y: $0.y) })
            XCTAssertEqual(base, rotated, "4 rotations should equal identity for \(kind)")
        }
    }

    func test_o_piece_is_rotation_invariant() {
        let base = Set(Tetromino.cells(kind: .O, rotation: 0).map { GridPoint(x: $0.x, y: $0.y) })
        for r in 1..<4 {
            let rotated = Set(Tetromino.cells(kind: .O, rotation: r).map { GridPoint(x: $0.x, y: $0.y) })
            XCTAssertEqual(base, rotated, "O-piece must be invariant at rotation \(r)")
        }
    }

    func test_plus_pentomino_is_rotation_invariant() {
        let base = Set(Tetromino.cells(kind: .plus, rotation: 0).map { GridPoint(x: $0.x, y: $0.y) })
        for r in 1..<4 {
            let rotated = Set(Tetromino.cells(kind: .plus, rotation: r).map { GridPoint(x: $0.x, y: $0.y) })
            XCTAssertEqual(base, rotated, "+ pentomino must be invariant at rotation \(r)")
        }
    }

    func test_every_tetromino_has_exactly_four_cells_in_every_rotation() {
        for kind in PieceKind.tetrominoes {
            for r in 0..<4 {
                XCTAssertEqual(Tetromino.cells(kind: kind, rotation: r).count, 4,
                               "\(kind) rotation \(r) does not have 4 cells")
            }
        }
    }

    func test_every_pentomino_has_exactly_five_cells_in_every_rotation() {
        for kind in PieceKind.pentominoes {
            for r in 0..<4 {
                XCTAssertEqual(Tetromino.cells(kind: kind, rotation: r).count, 5,
                               "\(kind) rotation \(r) does not have 5 cells")
            }
        }
    }

    func test_negative_rotation_is_well_defined() {
        for kind in PieceKind.allCases {
            let forward = Set(Tetromino.cells(kind: kind, rotation: 1).map { GridPoint(x: $0.x, y: $0.y) })
            let backward = Set(Tetromino.cells(kind: kind, rotation: -3).map { GridPoint(x: $0.x, y: $0.y) })
            XCTAssertEqual(forward, backward, "Rotation 1 must equal rotation -3 for \(kind)")
        }
    }

    func test_rotated_by_delta_is_consistent_with_static_table() {
        for kind in PieceKind.allCases {
            let piece = Tetromino(kind: kind, rotation: 0, origin: GridPoint(x: 0, y: 0))
            for delta in 0..<4 {
                let r = piece.rotated(by: delta)
                let staticCells = Set(Tetromino.cells(kind: kind, rotation: delta).map { GridPoint(x: $0.x, y: $0.y) })
                let memberCells = Set(r.cells.map { GridPoint(x: $0.x, y: $0.y) })
                XCTAssertEqual(staticCells, memberCells, "\(kind) delta \(delta) inconsistent")
            }
        }
    }
}
