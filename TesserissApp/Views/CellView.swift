import SwiftUI

enum CellStyle {
    case solid
    case ghost
}

struct CellView: View {
    let kind: PieceKind?
    let style: CellStyle
    let isFlashing: Bool
    let theme: Theme
    let appearance: AppearanceMode
    let flashTint: Color

    var body: some View {
        ZStack {
            if let kind {
                let color = theme.pieceColor(kind, appearance: appearance)
                switch style {
                case .solid:
                    Rectangle()
                        .fill(color)
                        .padding(0.5)
                        .overlay(
                            Rectangle()
                                .strokeBorder(Color.black.opacity(0.18), lineWidth: 1)
                                .padding(0.5)
                        )
                case .ghost:
                    Rectangle()
                        .strokeBorder(color.opacity(0.55), lineWidth: 2)
                        .padding(2)
                }
            }
            Rectangle()
                .strokeBorder(theme.gridLineColor(appearance: appearance), lineWidth: 0.5)
            if isFlashing {
                flashTint
            }
        }
    }
}
