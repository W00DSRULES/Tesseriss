import Foundation

enum PieceKind: CaseIterable, Equatable {
    case I, O, T, S, Z, L, J
    case U, P, plus, F

    static let tetrominoes: [PieceKind] = [.I, .O, .T, .S, .Z, .L, .J]
    static let pentominoes: [PieceKind] = [.U, .P, .plus, .F]

    var cellCount: Int { Self.pentominoes.contains(self) ? 5 : 4 }

    var colorName: String {
        switch self {
        case .I: return "PieceI"
        case .O: return "PieceO"
        case .T: return "PieceT"
        case .S: return "PieceS"
        case .Z: return "PieceZ"
        case .L: return "PieceL"
        case .J: return "PieceJ"
        case .U: return "PieceU"
        case .P: return "PieceP"
        case .plus: return "PiecePlus"
        case .F: return "PieceF"
        }
    }
}

struct GridPoint: Hashable {
    var x: Int
    var y: Int
}

struct Tetromino: Equatable {
    var kind: PieceKind
    var rotation: Int
    var origin: GridPoint

    var cells: [GridPoint] {
        Tetromino.cells(kind: kind, rotation: rotation).map {
            GridPoint(x: origin.x + $0.x, y: origin.y + $0.y)
        }
    }

    func rotated(by delta: Int) -> Tetromino {
        var copy = self
        copy.rotation = ((rotation + delta) % 4 + 4) % 4
        return copy
    }

    func moved(dx: Int, dy: Int) -> Tetromino {
        var copy = self
        copy.origin = GridPoint(x: origin.x + dx, y: origin.y + dy)
        return copy
    }

    /// Spawns centred, with the piece's topmost occupied cell on board row 0.
    ///
    /// The rotation tables don't all start at local y = 0 (I sits at y = 1, T spans
    /// y = 1...2), so spawning every piece at origin y = 0 used to place them at
    /// different heights — and top-out then triggered at a different stack height
    /// depending on which piece happened to be next. Normalising by the piece's own
    /// bounding box makes the spawn height identical for every kind.
    static func spawn(kind: PieceKind, boardWidth: Int, boardHeight: Int) -> Tetromino {
        let local = cells(kind: kind, rotation: 0)
        let minX = local.map(\.x).min() ?? 0
        let maxX = local.map(\.x).max() ?? 0
        let minY = local.map(\.y).min() ?? 0
        let spawnX = (boardWidth - (maxX - minX + 1)) / 2 - minX
        return Tetromino(kind: kind, rotation: 0, origin: GridPoint(x: spawnX, y: -minY))
    }

    /// Offsets tried, in order, when a rotation lands on something. A negative dy
    /// lifts the piece, which is what allows rotating while resting on the floor.
    static let kickOffsets: [GridPoint] = [
        GridPoint(x:  0, y:  0),
        GridPoint(x: -1, y:  0),
        GridPoint(x:  1, y:  0),
        GridPoint(x: -2, y:  0),
        GridPoint(x:  2, y:  0),
        GridPoint(x:  0, y: -1),
        GridPoint(x: -1, y: -1),
        GridPoint(x:  1, y: -1),
        // A flat I needs two rows of clearance to stand up, so a single-row lift
        // can never rotate it off the floor. Tried last, so it only ever applies
        // when nothing gentler fits.
        GridPoint(x:  0, y: -2),
    ]

    /// Rotates against `board`, nudging the piece by the first of `kickOffsets`
    /// that fits. Returns the placed piece and the offset used, or nil when no
    /// offset works. Without this a piece flush to a wall, or resting on the
    /// floor, simply refuses to turn.
    static func rotatedWithKick(_ piece: Tetromino, by delta: Int, in board: Board)
        -> (piece: Tetromino, kick: GridPoint)? {
        let rotated = piece.rotated(by: delta)
        for offset in kickOffsets {
            let candidate = rotated.moved(dx: offset.x, dy: offset.y)
            // Board.collides treats rows above the board as empty, so a placement
            // wholly above row 0 would fit but leave the piece out of sight.
            if !board.collides(candidate), candidate.cells.contains(where: { $0.y >= 0 }) {
                return (candidate, offset)
            }
        }
        return nil
    }

    static func cells(kind: PieceKind, rotation: Int) -> [GridPoint] {
        let r = ((rotation % 4) + 4) % 4
        let coords: [[(Int, Int)]]
        switch kind {
        case .I:
            coords = [
                [(0,1),(1,1),(2,1),(3,1)],
                [(2,0),(2,1),(2,2),(2,3)],
                [(0,2),(1,2),(2,2),(3,2)],
                [(1,0),(1,1),(1,2),(1,3)],
            ]
        case .O:
            coords = [
                [(0,0),(0,1),(1,0),(1,1)],
                [(0,0),(0,1),(1,0),(1,1)],
                [(0,0),(0,1),(1,0),(1,1)],
                [(0,0),(0,1),(1,0),(1,1)],
            ]
        case .T:
            coords = [
                [(0,1),(1,1),(1,2),(2,1)],
                [(0,1),(1,0),(1,1),(1,2)],
                [(0,1),(1,0),(1,1),(2,1)],
                [(1,0),(1,1),(1,2),(2,1)],
            ]
        case .S:
            coords = [
                [(0,1),(1,0),(1,1),(2,0)],
                [(1,0),(1,1),(2,1),(2,2)],
                [(0,2),(1,1),(1,2),(2,1)],
                [(0,0),(0,1),(1,1),(1,2)],
            ]
        case .Z:
            coords = [
                [(0,0),(1,0),(1,1),(2,1)],
                [(1,1),(1,2),(2,0),(2,1)],
                [(0,1),(1,1),(1,2),(2,2)],
                [(0,1),(0,2),(1,0),(1,1)],
            ]
        case .L:
            coords = [
                [(0,1),(1,1),(2,0),(2,1)],
                [(1,0),(1,1),(1,2),(2,2)],
                [(0,1),(0,2),(1,1),(2,1)],
                [(0,0),(1,0),(1,1),(1,2)],
            ]
        case .J:
            coords = [
                [(0,0),(0,1),(1,1),(2,1)],
                [(1,0),(1,1),(1,2),(2,0)],
                [(0,1),(1,1),(2,1),(2,2)],
                [(0,2),(1,0),(1,1),(1,2)],
            ]
        case .U:
            coords = [
                [(0,0),(2,0),(0,1),(1,1),(2,1)],
                [(0,0),(1,0),(0,1),(0,2),(1,2)],
                [(0,0),(1,0),(2,0),(0,1),(2,1)],
                [(0,0),(1,0),(1,1),(0,2),(1,2)],
            ]
        case .P:
            coords = [
                [(0,0),(1,0),(0,1),(1,1),(0,2)],
                [(0,0),(1,0),(2,0),(1,1),(2,1)],
                [(1,0),(0,1),(1,1),(0,2),(1,2)],
                [(0,0),(1,0),(0,1),(1,1),(2,1)],
            ]
        case .plus:
            let same: [(Int,Int)] = [(1,0),(0,1),(1,1),(2,1),(1,2)]
            coords = [same, same, same, same]
        case .F:
            coords = [
                [(1,0),(2,0),(0,1),(1,1),(1,2)],
                [(1,0),(0,1),(1,1),(2,1),(2,2)],
                [(1,0),(1,1),(2,1),(0,2),(1,2)],
                [(0,0),(0,1),(1,1),(2,1),(1,2)],
            ]
        }
        return coords[r].map { GridPoint(x: $0.0, y: $0.1) }
    }
}
