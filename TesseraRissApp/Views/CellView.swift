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
                            .stroke(color.opacity(0.5).blendMode(.multiply), lineWidth: 1)
                            .padding(1)
                    )
                    .opacity(isFlashing ? 0.3 : 1.0)
                if isFlashing {
                    Color.white.opacity(0.8)
                }
            } else if isFlashing {
                Color.white.opacity(0.7)
            }
        }
    }
}
