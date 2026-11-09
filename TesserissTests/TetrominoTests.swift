import SwiftUI
import UIKit
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

private enum PaletteMath {
    typealias RGB = (Double, Double, Double)
    // WCAG 2.x, CIELAB D65, CIEDE2000, Machado 2009 severity 1.0
    static func lin(_ c: Double) -> Double { c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4) }
    static func enc(_ l: Double) -> Double { let l = min(max(l, 0), 1); return l <= 0.0031308 ? 12.92 * l : 1.055 * pow(l, 1 / 2.4) - 0.055 }
    static func lum(_ c: RGB) -> Double { 0.2126 * lin(c.0) + 0.7152 * lin(c.1) + 0.0722 * lin(c.2) }
    static func contrast(_ a: RGB, _ b: RGB) -> Double { let x = lum(a), y = lum(b); return (max(x, y) + 0.05) / (min(x, y) + 0.05) }
    static func lab(_ c: RGB) -> RGB {
        let r = lin(c.0), g = lin(c.1), b = lin(c.2)
        let X = (0.4124564 * r + 0.3575761 * g + 0.1804375 * b) / 0.95047
        let Y = (0.2126729 * r + 0.7151522 * g + 0.0721750 * b)
        let Z = (0.0193339 * r + 0.1191920 * g + 0.9503041 * b) / 1.08883
        func f(_ t: Double) -> Double { t > 216.0 / 24389 ? cbrt(t) : (24389.0 / 27 * t + 16) / 116 }
        return (116 * f(Y) - 16, 500 * (f(X) - f(Y)), 200 * (f(Y) - f(Z)))
    }
    static func de2000(_ l1: RGB, _ l2: RGB) -> Double {
        let rad = Double.pi / 180, p7 = pow(25.0, 7.0)
        let C1 = hypot(l1.1, l1.2), C2 = hypot(l2.1, l2.2), Cb = (C1 + C2) / 2
        let G = 0.5 * (1 - sqrt(pow(Cb, 7) / (pow(Cb, 7) + p7)))
        let a1 = (1 + G) * l1.1, a2 = (1 + G) * l2.1
        let C1p = hypot(a1, l1.2), C2p = hypot(a2, l2.2)
        func h(_ b: Double, _ a: Double) -> Double { (b == 0 && a == 0) ? 0 : (atan2(b, a) / rad + 360).truncatingRemainder(dividingBy: 360) }
        let h1 = h(l1.2, a1), h2 = h(l2.2, a2)
        var dh = h2 - h1
        if C1p * C2p == 0 { dh = 0 } else if dh > 180 { dh -= 360 } else if dh < -180 { dh += 360 }
        let dL = l2.0 - l1.0, dC = C2p - C1p, dH = 2 * sqrt(C1p * C2p) * sin(dh / 2 * rad)
        let Lb = (l1.0 + l2.0) / 2, Cbp = (C1p + C2p) / 2
        var hb = h1 + h2
        if C1p * C2p != 0 { hb = abs(h1 - h2) <= 180 ? hb / 2 : (hb < 360 ? (hb + 360) / 2 : (hb - 360) / 2) }
        let T = 1 - 0.17 * cos((hb - 30) * rad) + 0.24 * cos(2 * hb * rad) + 0.32 * cos((3 * hb + 6) * rad) - 0.20 * cos((4 * hb - 63) * rad)
        let dth = 30 * exp(-pow((hb - 275) / 25, 2))
        let Rc = 2 * sqrt(pow(Cbp, 7) / (pow(Cbp, 7) + p7))
        let Sl = 1 + 0.015 * pow(Lb - 50, 2) / sqrt(20 + pow(Lb - 50, 2)), Sc = 1 + 0.045 * Cbp, Sh = 1 + 0.015 * Cbp * T
        let Rt = -sin(2 * dth * rad) * Rc
        return sqrt(pow(dL / Sl, 2) + pow(dC / Sc, 2) + pow(dH / Sh, 2) + Rt * (dC / Sc) * (dH / Sh))
    }
    static let cvd: [String: [[Double]]] = [
        "deut": [[0.367322, 0.860646, -0.227968], [0.280085, 0.672501, 0.047413], [-0.011820, 0.042940, 0.968881]],
        "prot": [[0.152286, 1.052583, -0.204868], [0.114503, 0.786281, 0.099216], [-0.003882, -0.048116, 1.051998]],
        "trit": [[1.255528, -0.076749, -0.178779], [-0.078411, 0.930809, 0.147602], [0.004733, 0.691367, 0.303900]],
    ]
    static func simulate(_ c: RGB, _ vision: String) -> RGB {
        guard let m = cvd[vision] else { return c }
        let v = [lin(c.0), lin(c.1), lin(c.2)]
        func row(_ r: [Double]) -> Double { enc(r[0] * v[0] + r[1] * v[1] + r[2] * v[2]) }
        return (row(m[0]), row(m[1]), row(m[2]))
    }
    static func rgb(_ ui: UIColor) -> RGB { var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0; ui.getRed(&r, green: &g, blue: &b, alpha: &a); return (r, g, b) }
    static func rgb(_ c: Color) -> RGB { rgb(UIColor(c)) }
    /// Smallest pairwise dE00 between piece fills under one vision type.
    static func minDE(_ pal: [PieceKind: RGB], _ vision: String) -> Double {
        let ks = PieceKind.allCases
        var m = Double.infinity
        for i in ks.indices { for j in ks.indices where j > i {
            m = min(m, de2000(lab(simulate(pal[ks[i]]!, vision)), lab(simulate(pal[ks[j]]!, vision))))
        } }
        return m
    }
}

// A separate XCTestCase in the same file: methods declared in an extension are not
// guaranteed to be picked up by XCTest discovery.
final class PiecePaletteTests: XCTestCase {
    private typealias M = PaletteMath

    // Classic: one universal colorset per piece; board = PaletteBackground (light / dark).
    private func classicFill(_ k: PieceKind) -> M.RGB { M.rgb(UIColor(named: k.colorName)!) }
    private func classicBoard(_ ap: AppearanceMode) -> M.RGB {
        let style: UIUserInterfaceStyle = ap == .day ? .light : .dark
        return M.rgb(UIColor(named: "PaletteBackground")!.resolvedColor(with: UITraitCollection(userInterfaceStyle: style)))
    }
    // Hokusai wood board references (palette3/emit.py; row means of WoodenBoardView).
    private static let woodDayMidDarkest: M.RGB = (0.537, 0.395, 0.248)     // rows 4-17
    private static let woodNightLightest: M.RGB = (0.286, 0.200, 0.139)     // all rows

    func test_classic_fills_stay_distinguishable() {
        let pal = Dictionary(uniqueKeysWithValues: PieceKind.allCases.map { ($0, classicFill($0)) })
        // achieved: normal 19.0, deut 11.4, prot 11.4, trit 14.0
        XCTAssertGreaterThanOrEqual(M.minDE(pal, "norm"), 18.0)
        XCTAssertGreaterThanOrEqual(M.minDE(pal, "deut"), 11.0)
        XCTAssertGreaterThanOrEqual(M.minDE(pal, "prot"), 11.0)
        XCTAssertGreaterThanOrEqual(M.minDE(pal, "trit"), 13.0)
    }

    func test_classic_outline_separates_cells_and_ghost_meets_3_to_1() {
        let theme = ClassicTheme()
        for ap in AppearanceMode.allCases {
            let board = classicBoard(ap)
            for k in PieceKind.allCases {
                let fill = classicFill(k), line = M.rgb(theme.pieceOutlineColor(k, appearance: ap))
                // achieved min outline:fill 1.66 (both appearances)
                XCTAssertGreaterThanOrEqual(M.contrast(line, fill), 1.6, "\(k) \(ap) outline:fill")
                // the ghost is drawn in the outline colour; achieved min 3.08 day, 4.09 night
                XCTAssertGreaterThanOrEqual(M.contrast(line, board), 3.0, "\(k) \(ap) outline/ghost:board")
            }
        }
    }

    func test_hokusai_fills_stay_distinguishable() {
        for ap in AppearanceMode.allCases {
            let pal = Dictionary(uniqueKeysWithValues: PieceKind.allCases.map { ($0, M.rgb(KanagawaTheme.palette(for: $0, appearance: ap))) })
            // achieved day 12.5 / 13.0 / 13.0 / 7.2, night 12.4 / 12.3 / 12.3 / 7.1
            XCTAssertGreaterThanOrEqual(M.minDE(pal, "norm"), 12.0, "\(ap)")
            XCTAssertGreaterThanOrEqual(M.minDE(pal, "deut"), 12.0, "\(ap)")
            XCTAssertGreaterThanOrEqual(M.minDE(pal, "prot"), 12.0, "\(ap)")
            XCTAssertGreaterThanOrEqual(M.minDE(pal, "trit"), 6.5, "\(ap)")
        }
    }

    func test_hokusai_outline_and_ghost_contrast() {
        let theme = KanagawaTheme()
        for k in PieceKind.allCases {
            // day: shared indigo key line vs the darkest middle wood row; achieved 3.33
            let day = M.rgb(theme.pieceOutlineColor(k, appearance: .day))
            XCTAssertGreaterThanOrEqual(M.contrast(day, Self.woodDayMidDarkest), 3.2, "\(k) day")
            // night: per-piece edge vs the lightest wood row (achieved 3.05) and vs its fill (achieved 1.66)
            let night = M.rgb(theme.pieceOutlineColor(k, appearance: .night))
            let fill = M.rgb(KanagawaTheme.palette(for: k, appearance: .night))
            XCTAssertGreaterThanOrEqual(M.contrast(night, Self.woodNightLightest), 3.0, "\(k) night board")
            XCTAssertGreaterThanOrEqual(M.contrast(night, fill), 1.6, "\(k) night outline:fill")
        }
    }
}
