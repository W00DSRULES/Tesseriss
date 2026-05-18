import Foundation

struct Board {
    static let width = 10
    static let height = 20

    var grid: [[PieceKind?]]

    init() {
        grid = Array(repeating: Array(repeating: nil, count: Board.width), count: Board.height)
    }

    func cell(_ p: GridPoint) -> PieceKind? {
        guard p.x >= 0, p.x < Board.width, p.y >= 0, p.y < Board.height else { return nil }
        return grid[p.y][p.x]
    }

    func collides(_ piece: Tetromino) -> Bool {
        for c in piece.cells {
            if c.x < 0 || c.x >= Board.width { return true }
            if c.y >= Board.height { return true }
            if c.y < 0 { continue }
            if grid[c.y][c.x] != nil { return true }
        }
        return false
    }

    mutating func lock(_ piece: Tetromino) {
        for c in piece.cells where c.y >= 0 && c.y < Board.height && c.x >= 0 && c.x < Board.width {
            grid[c.y][c.x] = piece.kind
        }
    }

    func fullRows() -> [Int] {
        var rows: [Int] = []
        for y in 0..<Board.height where grid[y].allSatisfy({ $0 != nil }) {
            rows.append(y)
        }
        return rows
    }

    mutating func clearRows(_ rows: [Int]) {
        let sorted = Set(rows).sorted()
        for r in sorted.reversed() {
            grid.remove(at: r)
        }
        for _ in 0..<sorted.count {
            grid.insert(Array(repeating: nil, count: Board.width), at: 0)
        }
    }

    var isEmpty: Bool {
        for row in grid where row.contains(where: { $0 != nil }) { return false }
        return true
    }
}
