import SwiftUI

enum CellStyle {
    case solid
    case ghost
}

struct CellView: View {
    let kind: PieceKind?
    let style: CellStyle
    let isFlashing: Bool

    var body: some View {
        ZStack {
            Color("PaletteBackground")
            if let kind {
                switch style {
                case .solid:
                    Rectangle()
                        .fill(Color(kind.colorName))
                        .padding(0.5)
                        .overlay(
                            Rectangle()
                                .strokeBorder(Color.black.opacity(0.18), lineWidth: 1)
                                .padding(0.5)
                        )
                case .ghost:
                    Rectangle()
                        .strokeBorder(Color(kind.colorName).opacity(0.55), lineWidth: 2)
                        .padding(2)
                }
            }
            Rectangle()
                .strokeBorder(Color("PaletteGrid"), lineWidth: 0.5)
            if isFlashing {
                Color.white.opacity(0.85)
            }
        }
    }
}
