import SwiftUI

struct PlayfieldView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        let board = engine.board
        let bw = board.width
        let bh = board.height
        let theme = settings.activeTheme
        let appearance = settings.appearance
        let flashingRows = engine.flashingRows
        let overlay = pieceOverlay()
        return GeometryReader { geo in
            let cell = min(geo.size.width / CGFloat(bw),
                           geo.size.height / CGFloat(bh))
            let width = cell * CGFloat(bw)
            let height = cell * CGFloat(bh)
            ZStack(alignment: .topLeading) {
                theme.playfieldBoardView(appearance: appearance)
                    .frame(width: width, height: height)

                ForEach(0..<bh, id: \.self) { y in
                    ForEach(0..<bw, id: \.self) { x in
                        let flashing = flashingRows.contains(y)
                        let content = overlay[GridPoint(x: x, y: y)] ?? (board.grid[y][x], .solid)
                        CellView(
                            kind: content.0,
                            style: content.1,
                            isFlashing: flashing,
                            theme: theme,
                            appearance: appearance,
                            flashTint: theme.flashTint(appearance: appearance)
                        )
                        .frame(width: cell, height: cell)
                        .offset(x: CGFloat(x) * cell, y: CGFloat(y) * cell)
                    }
                }

                if theme.usesWaveLineClear && !engine.flashingRows.isEmpty {
                    WaveSplashView(
                        appearance: appearance,
                        rows: Array(engine.flashingRows),
                        cellSize: cell,
                        isFourLine: engine.celebrationActive
                    )
                    .frame(width: width, height: height)
                }
            }
            .frame(width: width, height: height)
            .overlay(
                Rectangle()
                    .stroke(theme.playfieldBorderColor(appearance: appearance), lineWidth: 2)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    /// Active-piece and ghost cells by position, built once per body instead of once
    /// per cell (`ghostPiece` runs a drop loop). The piece is written last so it wins.
    private func pieceOverlay() -> [GridPoint: (PieceKind?, CellStyle)] {
        var overlay: [GridPoint: (PieceKind?, CellStyle)] = [:]
        if settings.ghostEnabled, let ghost = engine.ghostPiece {
            for c in ghost.cells { overlay[c] = (ghost.kind, .ghost) }
        }
        if let piece = engine.current {
            for c in piece.cells { overlay[c] = (piece.kind, .solid) }
        }
        return overlay
    }
}

struct NextPieceView: View {
    let kind: PieceKind?
    let label: String
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        let theme = settings.activeTheme
        let appearance = settings.appearance
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(theme.inkColor(appearance: appearance).opacity(0.75))
            ZStack {
                theme.playfieldBoardView(appearance: appearance)
                Rectangle().strokeBorder(theme.gridLineColor(appearance: appearance), lineWidth: 0.5)
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
                                .fill(theme.pieceColor(kind, appearance: appearance))
                                .overlay {
                                    if theme.colorblind {
                                        Rectangle().strokeBorder(
                                            theme.pieceOutlineColor(kind, appearance: appearance),
                                            lineWidth: max(1, cellSize / 12)
                                        )
                                    }
                                }
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
            .overlay(Rectangle().stroke(theme.playfieldBorderColor(appearance: appearance), lineWidth: 1))
        }
    }
}
