import SwiftUI

struct CellView: View {
    let kind: PieceKind?
    let isFlashing: Bool

    var body: some View {
        ZStack {
            Color("PaletteBackground")
            if let kind {
                Rectangle()
                    .fill(Color(kind.colorName))
                    .padding(0.5)
                    .overlay(
                        Rectangle()
                            .strokeBorder(Color.black.opacity(0.18), lineWidth: 1)
                            .padding(0.5)
                    )
            }
            Rectangle()
                .strokeBorder(Color("PaletteGrid"), lineWidth: 0.5)
            if isFlashing {
                Color.white.opacity(0.85)
            }
        }
    }
}
