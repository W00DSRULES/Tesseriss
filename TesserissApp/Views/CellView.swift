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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            if let kind {
                let outline = theme.pieceOutlineColor(kind, appearance: appearance)
                switch style {
                case .solid:
                    Rectangle()
                        .fill(theme.pieceColor(kind, appearance: appearance))
                        .padding(0.5)
                        .overlay(
                            Rectangle()
                                .strokeBorder(outline, lineWidth: 2)
                                .padding(0.5)
                        )
                case .ghost:
                    // Full-strength outline colour: the old 55% fill colour was
                    // close to invisible on the board.
                    Rectangle()
                        .strokeBorder(outline, lineWidth: 2)
                        .padding(2)
                }
            }
            Rectangle()
                .strokeBorder(theme.gridLineColor(appearance: appearance), lineWidth: 0.5)
            // Fading the flash instead of hard-toggling it gives the Classic theme a
            // line-clear it can be seen to do, not just a one-frame blink.
            flashTint
                .opacity(isFlashing ? 1 : 0)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: isFlashing)
        }
    }
}
