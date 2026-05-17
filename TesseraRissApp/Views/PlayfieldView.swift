import SwiftUI

struct PlayfieldView: View {
    @EnvironmentObject var engine: GameEngine

    var body: some View {
        GeometryReader { geo in
            let cell = min(geo.size.width / CGFloat(Board.width),
                           geo.size.height / CGFloat(Board.height))
            let width = cell * CGFloat(Board.width)
            let height = cell * CGFloat(Board.height)
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color("PaletteBackground"))
                    .frame(width: width, height: height)

                ForEach(0..<Board.height, id: \.self) { y in
                    ForEach(0..<Board.width, id: \.self) { x in
                        let flashing = engine.flashingRows.contains(y)
                        CellView(kind: cellKind(x: x, y: y), isFlashing: flashing)
                            .frame(width: cell, height: cell)
                            .offset(x: CGFloat(x) * cell, y: CGFloat(y) * cell)
                    }
                }
            }
            .frame(width: width, height: height)
            .overlay(
                Rectangle()
                    .stroke(Color("PaletteInk").opacity(0.55), lineWidth: 2)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func cellKind(x: Int, y: Int) -> PieceKind? {
        if let piece = engine.current {
            for c in piece.cells where c.x == x && c.y == y {
                return piece.kind
            }
        }
        if y < 0 || y >= Board.height { return nil }
        return engine.board.grid[y][x]
    }
}

struct NextPieceView: View {
    let kind: PieceKind?
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(Color("PaletteInk").opacity(0.7))
            ZStack {
                Rectangle().fill(Color("PaletteBackground"))
                Rectangle().strokeBorder(Color("PaletteGrid"), lineWidth: 0.5)
                if let kind {
                    let cells = Tetromino.cells(kind: kind, rotation: 0)
                    let minX = cells.map(\.x).min() ?? 0
                    let maxX = cells.map(\.x).max() ?? 0
                    let minY = cells.map(\.y).min() ?? 0
                    let maxY = cells.map(\.y).max() ?? 0
                    let w = CGFloat(maxX - minX + 1)
                    let h = CGFloat(maxY - minY + 1)
                    GeometryReader { geo in
                        let cellSize = min(geo.size.width / w, geo.size.height / h) * 0.85
                        let gridWidth = cellSize * w
                        let gridHeight = cellSize * h
                        let originX = (geo.size.width - gridWidth) / 2
                        let originY = (geo.size.height - gridHeight) / 2
                        ForEach(0..<cells.count, id: \.self) { i in
                            let c = cells[i]
                            Rectangle()
                                .fill(Color(kind.colorName))
                                .frame(width: cellSize, height: cellSize)
                                .position(
                                    x: originX + (CGFloat(c.x - minX) + 0.5) * cellSize,
                                    y: originY + (CGFloat(c.y - minY) + 0.5) * cellSize
                                )
                        }
                    }
                }
            }
            .frame(width: 80, height: 60)
            .overlay(Rectangle().stroke(Color("PaletteInk").opacity(0.45), lineWidth: 1))
        }
    }
}
