import Foundation

enum PieceKind: CaseIterable, Equatable {
    case I, O, T, S, Z, L, J

    var colorName: String {
        switch self {
        case .I: return "PieceI"
        case .O: return "PieceO"
        case .T: return "PieceT"
        case .S: return "PieceS"
        case .Z: return "PieceZ"
        case .L: return "PieceL"
        case .J: return "PieceJ"
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
        let spawnX = (boardWidth / 2) - 2
        let spawnY = 0
        return Tetromino(kind: kind, rotation: 0, origin: GridPoint(x: spawnX, y: spawnY))
    }

    static func cells(kind: PieceKind, rotation: Int) -> [GridPoint] {
        let r = ((rotation % 4) + 4) % 4
        let coords: [[(Int, Int)]]
        switch kind {
        case .I:
            coords = [
                [(0,2),(1,2),(2,2),(3,2)],
                [(2,0),(2,1),(2,2),(2,3)],
                [(0,1),(1,1),(2,1),(3,1)],
                [(1,0),(1,1),(1,2),(1,3)],
            ]
        case .O:
            coords = [
                [(1,1),(2,1),(1,2),(2,2)],
                [(1,1),(2,1),(1,2),(2,2)],
                [(1,1),(2,1),(1,2),(2,2)],
                [(1,1),(2,1),(1,2),(2,2)],
            ]
        case .T:
            coords = [
                [(0,1),(1,1),(2,1),(1,2)],
                [(1,0),(1,1),(2,1),(1,2)],
                [(0,1),(1,1),(2,1),(1,0)],
                [(1,0),(1,1),(0,1),(1,2)],
            ]
        case .S:
            coords = [
                [(0,1),(1,1),(1,2),(2,2)],
                [(1,2),(1,1),(2,1),(2,0)],
                [(0,0),(1,0),(1,1),(2,1)],
                [(0,2),(0,1),(1,1),(1,0)],
            ]
        case .Z:
            coords = [
                [(0,2),(1,2),(1,1),(2,1)],
                [(2,2),(2,1),(1,1),(1,0)],
                [(0,1),(1,1),(1,0),(2,0)],
                [(1,2),(1,1),(0,1),(0,0)],
            ]
        case .L:
            coords = [
                [(0,1),(1,1),(2,1),(2,2)],
                [(1,0),(1,1),(1,2),(2,2)],
                [(0,1),(1,1),(2,1),(0,0)],
                [(0,0),(1,0),(1,1),(1,2)],
            ]
        case .J:
            coords = [
                [(0,1),(1,1),(2,1),(0,2)],
                [(1,0),(1,1),(1,2),(2,0)],
                [(0,1),(1,1),(2,1),(2,0)],
                [(0,2),(1,0),(1,1),(1,2)],
            ]
        }
        return coords[r].map { GridPoint(x: $0.0, y: $0.1) }
    }
}
