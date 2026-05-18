import Foundation

struct Board {
    let width: Int
    let height: Int
    var grid: [[PieceKind?]]

    init(width: Int = 10, height: Int = 20) {
        self.width = width
        self.height = height
        self.grid = Array(repeating: Array(repeating: nil, count: width), count: height)
    }

    func cell(_ p: GridPoint) -> PieceKind? {
        guard p.x >= 0, p.x < width, p.y >= 0, p.y < height else { return nil }
        return grid[p.y][p.x]
    }

    func collides(_ piece: Tetromino) -> Bool {
        for c in piece.cells {
            if c.x < 0 || c.x >= width { return true }
            if c.y >= height { return true }
            if c.y < 0 { continue }
            if grid[c.y][c.x] != nil { return true }
        }
        return false
    }

    mutating func lock(_ piece: Tetromino) {
        for c in piece.cells where c.y >= 0 && c.y < height && c.x >= 0 && c.x < width {
            grid[c.y][c.x] = piece.kind
        }
    }

    func fullRows() -> [Int] {
        var rows: [Int] = []
        for y in 0..<height where grid[y].allSatisfy({ $0 != nil }) {
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
            grid.insert(Array(repeating: nil, count: width), at: 0)
        }
    }

    var isEmpty: Bool {
        for row in grid where row.contains(where: { $0 != nil }) { return false }
        return true
    }
}
