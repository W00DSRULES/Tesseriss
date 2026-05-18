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

    static func spawn(kind: PieceKind, boardWidth: Int, boardHeight: Int) -> Tetromino {
        let local = cells(kind: kind, rotation: 0)
        let pieceWidth = (local.map(\.x).max() ?? 0) + 1
        let spawnX = (boardWidth - pieceWidth) / 2
        return Tetromino(kind: kind, rotation: 0, origin: GridPoint(x: spawnX, y: 0))
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
