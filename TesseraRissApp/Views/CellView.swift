import SwiftUI

struct CellView: View {
    let kind: PieceKind?
    let isFlashing: Bool

    var body: some View {
        ZStack {
            Color("PaletteGrid")
            if let kind {
                let color = Color(kind.colorName)
                Rectangle()
                    .fill(color)
                    .overlay(
                        Rectangle()
                            .strokeBorder(Color.black.opacity(0.15), lineWidth: 1)
                    )
            }
            if isFlashing {
                Color.white.opacity(0.85)
            }
        }
    }
}
