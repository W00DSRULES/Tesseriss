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

    func test_ccw_rotation_inverts_cw_rotation() {
        for kind in PieceKind.allCases {
            for start in 0..<4 {
                let piece = Tetromino(kind: kind, rotation: start, origin: GridPoint(x: 3, y: 5))
                XCTAssertEqual(piece.rotated(by: 1).rotated(by: -1), piece,
                               "CCW must invert CW for \(kind) at rotation \(start)")
                XCTAssertEqual(piece.rotated(by: -1).rotation, ((start - 1) % 4 + 4) % 4,
                               "CCW from rotation \(start) must land on \((start + 3) % 4) for \(kind)")
            }
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

    // MARK: - Rotation table geometry

    /// The rotation tables are typed by hand. Turning state 0 by 90° in code and
    /// comparing shapes catches a wrong entry that reading the table would miss.
    func test_each_rotation_state_is_state_zero_turned_clockwise() {
        for kind in PieceKind.allCases {
            var turned = Tetromino.cells(kind: kind, rotation: 0)
            // State 4 wraps to state 0, so the last turn checks that four turns return to the start.
            for state in 1...4 {
                turned = turnedClockwise(turned)
                XCTAssertEqual(normalized(turned), normalized(Tetromino.cells(kind: kind, rotation: state)),
                               "\(kind) rotation \(state) is not rotation 0 turned \(state) × 90°")
            }
        }
    }

    func test_no_rotation_state_repeats_a_cell() {
        for kind in PieceKind.allCases {
            for r in 0..<4 {
                let cells = Tetromino.cells(kind: kind, rotation: r)
                XCTAssertEqual(Set(cells).count, cells.count, "\(kind) rotation \(r) repeats a cell")
            }
        }
    }

    func test_every_rotation_state_is_edge_connected() {
        for kind in PieceKind.allCases {
            for r in 0..<4 {
                XCTAssertTrue(isEdgeConnected(Tetromino.cells(kind: kind, rotation: r)),
                              "\(kind) rotation \(r) has a cell that shares no edge with the rest")
            }
        }
    }

    /// U, P and F have no rotational symmetry, so all four states must differ. Without
    /// this, a table that repeats one symmetric shape four times (as `plus` does on
    /// purpose) would still pass the clockwise-turn test above.
    func test_u_p_f_pentominoes_have_four_distinct_rotation_states() {
        for kind: PieceKind in [.U, .P, .F] {
            let shapes = Set((0..<4).map { normalized(Tetromino.cells(kind: kind, rotation: $0)) })
            XCTAssertEqual(shapes.count, 4, "\(kind) must have four distinct rotation states")
        }
    }

    /// Turns cells 90° clockwise on screen (y grows downward): (x, y) -> (maxY - y, x).
    private func turnedClockwise(_ cells: [GridPoint]) -> [GridPoint] {
        let maxY = cells.map(\.y).max() ?? 0
        return cells.map { GridPoint(x: maxY - $0.y, y: $0.x) }
    }

    /// Shifts cells so their bounding box starts at (0, 0), leaving only the shape.
    private func normalized(_ cells: [GridPoint]) -> Set<GridPoint> {
        let minX = cells.map(\.x).min() ?? 0
        let minY = cells.map(\.y).min() ?? 0
        return Set(cells.map { GridPoint(x: $0.x - minX, y: $0.y - minY) })
    }

    /// True when every cell can be reached from the first through shared edges.
    private func isEdgeConnected(_ cells: [GridPoint]) -> Bool {
        guard let start = cells.first else { return true }
        let all = Set(cells)
        var seen: Set<GridPoint> = [start]
        var stack = [start]
        while let cell = stack.popLast() {
            for (dx, dy) in [(1, 0), (-1, 0), (0, 1), (0, -1)] {
                let neighbour = GridPoint(x: cell.x + dx, y: cell.y + dy)
                if all.contains(neighbour), seen.insert(neighbour).inserted {
                    stack.append(neighbour)
                }
            }
        }
        return seen.count == all.count
    }
}
