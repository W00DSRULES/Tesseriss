import SwiftUI

enum ThemeKind: String, CaseIterable, Identifiable {
    case classic
    case kanagawa
    var id: String { rawValue }
}

protocol Theme {
    var kind: ThemeKind { get }
    func pieceColor(_ piece: PieceKind, appearance: AppearanceMode) -> Color
    /// Colour-blind mode (Settings): its own piece palette, and pieces, the ghost
    /// and the preview are drawn with `pieceOutlineColor`. Off keeps the original look.
    var colorblind: Bool { get }
    /// Colour-blind mode only. Edge of a solid cell, the ghost piece and the
    /// next-piece preview. Each value is at least 1.6:1 against its fill (cells
    /// stay apart) and, where the fill alone is under 3:1, at least 3:1 against
    /// the board.
    func pieceOutlineColor(_ piece: PieceKind, appearance: AppearanceMode) -> Color
    func gridLineColor(appearance: AppearanceMode) -> Color
    func backgroundView(appearance: AppearanceMode) -> AnyView
    /// The view drawn behind the cells in the playfield (and next-piece preview).
    /// Can be a flat color or a textured view like a wooden board.
    func playfieldBoardView(appearance: AppearanceMode) -> AnyView
    func playfieldBorderColor(appearance: AppearanceMode) -> Color
    /// Banner shown on 4-line clear; nil = use default "ULTIMATE RISS" banner.
    func fourLineBanner(strings: Strings) -> AnyView?
    /// Color used to flash a cleared cell. Allows themes to tint the flash.
    func flashTint(appearance: AppearanceMode) -> Color
    /// When true, GameView overlays WaveSplashView during line clears.
    var usesWaveLineClear: Bool { get }

    // MARK: Chrome
    // Menus, HUD, controls and overlays draw through these so a theme skins the
    // whole app, not just the playfield.

    /// Primary text, and the fill of primary buttons.
    func inkColor(appearance: AppearanceMode) -> Color
    /// Text drawn on top of `inkColor` (i.e. inside a primary button).
    func onInkColor(appearance: AppearanceMode) -> Color
    /// Secondary button and card fill.
    func cardColor(appearance: AppearanceMode) -> Color
    /// Hairline borders.
    func strokeColor(appearance: AppearanceMode) -> Color
    /// Badges and selected states.
    func accentColor(appearance: AppearanceMode) -> Color
    /// True when the backdrop is artwork rather than a flat colour, so text laid
    /// over it needs a panel behind it to stay readable.
    var backgroundIsArtwork: Bool { get }
}

/// Classic palette assets are the default chrome, so a theme only overrides what
/// it actually restyles.
extension Theme {
    func inkColor(appearance: AppearanceMode) -> Color { Color("PaletteInk") }
    func onInkColor(appearance: AppearanceMode) -> Color { Color("PaletteBackground") }
    func cardColor(appearance: AppearanceMode) -> Color { Color("PaletteCard") }
    func strokeColor(appearance: AppearanceMode) -> Color { Color("PaletteGrid") }
    /// Its own colour, not a piece colour, so NEW BEST stays at 4.5:1 on the card
    /// whatever the piece palette does.
    func accentColor(appearance: AppearanceMode) -> Color {
        appearance == .day
            ? Color(red: 0.58, green: 0.29, blue: 0.18)
            : Color(red: 0.82, green: 0.53, blue: 0.40)
    }
    var backgroundIsArtwork: Bool { false }
}

/// Card-coloured panel that keeps a block of text readable when it sits over
/// artwork. A no-op on themes with a flat backdrop, so Classic is untouched.
struct LegibilityPanel: ViewModifier {
    let active: Bool
    let stroke: Color
    /// Opaque, not a material: the accessibility audit measured text on the
    /// frosted panel against the art behind it and failed text that reads
    /// at 7:1 or better on screen.
    let fill: Color

    @ViewBuilder
    func body(content: Content) -> some View {
        if active {
            content
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(fill, in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14).stroke(stroke, lineWidth: 1)
                )
        } else {
            content
        }
    }
}

extension View {
    func legibilityPanel(_ active: Bool, stroke: Color, fill: Color) -> some View {
        modifier(LegibilityPanel(active: active, stroke: stroke, fill: fill))
    }
}

struct ClassicTheme: Theme {
    let kind: ThemeKind = .classic
    var colorblind = false

    func pieceColor(_ piece: PieceKind, appearance: AppearanceMode) -> Color {
        colorblind ? Self.colorblindFill(piece) : Color(piece.colorName)
    }

    /// Colour-blind fills: pairwise CIEDE2000 >= 11 under simulated deutan,
    /// protan and tritan vision (TetrominoTests checks the floors).
    static func colorblindFill(_ piece: PieceKind) -> Color {
        switch piece {
        case .I:    return Color(red: 0.401, green: 0.490, blue: 0.619)
        case .O:    return Color(red: 0.960, green: 0.642, blue: 0.393)
        case .T:    return Color(red: 0.773, green: 0.721, blue: 0.882)
        case .S:    return Color(red: 0.702, green: 0.798, blue: 0.703)
        case .Z:    return Color(red: 0.692, green: 0.571, blue: 0.552)
        case .L:    return Color(red: 0.676, green: 0.401, blue: 0.197)
        case .J:    return Color(red: 0.999, green: 0.913, blue: 0.715)
        case .U:    return Color(red: 0.387, green: 0.652, blue: 0.679)
        case .P:    return Color(red: 0.469, green: 0.501, blue: 0.389)
        case .plus: return Color(red: 0.494, green: 0.309, blue: 0.452)
        case .F:    return Color(red: 0.393, green: 0.365, blue: 0.354)
        }
    }
    func pieceOutlineColor(_ piece: PieceKind, appearance: AppearanceMode) -> Color {
        // Night needs a lighter line where the day one is under 3:1 on the dark board.
        switch (piece, appearance) {
        case (.I, .day):      return Color(red: 0.263, green: 0.355, blue: 0.476)
        case (.I, .night):    return Color(red: 0.555, green: 0.643, blue: 0.779)
        case (.O, _):         return Color(red: 0.765, green: 0.472, blue: 0.232)
        case (.T, _):         return Color(red: 0.566, green: 0.518, blue: 0.670)
        case (.S, _):         return Color(red: 0.475, green: 0.565, blue: 0.476)
        case (.Z, _):         return Color(red: 0.535, green: 0.421, blue: 0.403)
        case (.L, .day):      return Color(red: 0.518, green: 0.268, blue: 0.065)
        case (.L, .night):    return Color(red: 0.850, green: 0.551, blue: 0.339)
        case (.J, _):         return Color(red: 0.606, green: 0.535, blue: 0.353)
        case (.U, _):         return Color(red: 0.227, green: 0.497, blue: 0.524)
        case (.P, .day):      return Color(red: 0.333, green: 0.365, blue: 0.259)
        case (.P, .night):    return Color(red: 0.622, green: 0.655, blue: 0.537)
        case (.plus, .day):   return Color(red: 0.355, green: 0.180, blue: 0.318)
        case (.plus, .night): return Color(red: 0.640, green: 0.445, blue: 0.593)
        case (.F, .day):      return Color(red: 0.263, green: 0.237, blue: 0.227)
        case (.F, .night):    return Color(red: 0.531, green: 0.501, blue: 0.490)
        }
    }
    func gridLineColor(appearance: AppearanceMode) -> Color { Color("PaletteGrid") }
    func backgroundView(appearance: AppearanceMode) -> AnyView {
        AnyView(Color("PaletteBackground"))
    }
    func playfieldBoardView(appearance: AppearanceMode) -> AnyView {
        AnyView(Color("PaletteBackground"))
    }
    func playfieldBorderColor(appearance: AppearanceMode) -> Color { Color("PaletteInk").opacity(0.55) }
    func fourLineBanner(strings: Strings) -> AnyView? { nil }
    func flashTint(appearance: AppearanceMode) -> Color { Color.white.opacity(0.85) }
    var usesWaveLineClear: Bool { false }
}

struct KanagawaTheme: Theme {
    let kind: ThemeKind = .kanagawa
    var colorblind = false

    func pieceColor(_ piece: PieceKind, appearance: AppearanceMode) -> Color {
        colorblind
            ? Self.colorblindPalette(for: piece, appearance: appearance)
            : Self.palette(for: piece, appearance: appearance)
    }

    func pieceOutlineColor(_ piece: PieceKind, appearance: AppearanceMode) -> Color {
        // Day: one sumi-indigo key line, as in a woodblock print.
        if appearance == .day { return Color(red: 0.075, green: 0.098, blue: 0.157) }
        // Night: a lighter edge per piece. One shared light line merged the cells
        // of the pale pieces (O, S, U, P).
        switch piece {
        case .I:    return Color(red: 0.364, green: 0.504, blue: 0.791)
        case .O:    return Color(red: 0.745, green: 0.692, blue: 0.572)
        case .T:    return Color(red: 0.519, green: 0.738, blue: 0.954)
        case .S:    return Color(red: 0.782, green: 0.936, blue: 0.999)
        case .Z:    return Color(red: 0.600, green: 0.753, blue: 0.788)
        case .L:    return Color(red: 1.000, green: 0.486, blue: 0.395)
        case .J:    return Color(red: 0.406, green: 0.507, blue: 0.738)
        case .U:    return Color(red: 0.628, green: 0.730, blue: 0.755)
        case .P:    return Color(red: 0.943, green: 0.891, blue: 0.799)
        case .plus: return Color(red: 0.996, green: 0.775, blue: 0.698)
        case .F:    return Color(red: 0.469, green: 0.511, blue: 0.590)
        }
    }

    func gridLineColor(appearance: AppearanceMode) -> Color {
        appearance == .day
            ? Color(red: 0.220, green: 0.125, blue: 0.055).opacity(0.40)
            : Color(red: 0.078, green: 0.047, blue: 0.027).opacity(0.65)
    }

    func backgroundView(appearance: AppearanceMode) -> AnyView {
        AnyView(KanagawaBackgroundView(appearance: appearance))
    }

    func playfieldBoardView(appearance: AppearanceMode) -> AnyView {
        AnyView(WoodenBoardView(appearance: appearance))
    }

    func playfieldBorderColor(appearance: AppearanceMode) -> Color {
        appearance == .day
            ? Color(red: 0.235, green: 0.137, blue: 0.063).opacity(0.85)
            : Color(red: 0.067, green: 0.039, blue: 0.020).opacity(0.92)
    }

    func fourLineBanner(strings: Strings) -> AnyView? {
        AnyView(GreatWaveBanner(text: strings.greatWave))
    }

    func flashTint(appearance: AppearanceMode) -> Color {
        Self.foamColor(appearance: appearance).opacity(0.55)
    }

    var usesWaveLineClear: Bool { true }
    var backgroundIsArtwork: Bool { true }

    // MARK: Chrome — ukiyo-e ink and paper, so menus and HUD sit with the artwork
    // instead of dropping Classic grey on top of it.

    func inkColor(appearance: AppearanceMode) -> Color {
        appearance == .day
            ? Self.waveDeepColor(appearance: .day)          // Prussian ink on paper
            : Self.foamColor(appearance: .night)            // foam on deep water
    }

    func onInkColor(appearance: AppearanceMode) -> Color {
        appearance == .day
            ? Color(red: 0.97, green: 0.94, blue: 0.86)     // banner cream
            : Color(red: 0.055, green: 0.102, blue: 0.188)  // deepest navy
    }

    func cardColor(appearance: AppearanceMode) -> Color {
        appearance == .day
            ? Color(red: 0.945, green: 0.918, blue: 0.847)  // aged paper
            : Color(red: 0.102, green: 0.180, blue: 0.310)  // shadowed wave
    }

    func strokeColor(appearance: AppearanceMode) -> Color {
        appearance == .day
            ? Color(red: 0.235, green: 0.137, blue: 0.063).opacity(0.35)
            : Self.foamColor(appearance: .night).opacity(0.22)
    }

    func accentColor(appearance: AppearanceMode) -> Color {
        appearance == .day
            ? Color(red: 0.70, green: 0.20, blue: 0.14)     // Fuji red, darkened for 4.5:1 on paper
            : Color(red: 0.929, green: 0.522, blue: 0.380)  // Fuji orange
    }

    static func palette(for piece: PieceKind, appearance: AppearanceMode) -> Color {
        switch appearance {
        case .day:
            switch piece {
            case .I:    return Color(red: 0.106, green: 0.227, blue: 0.420) // Prussian blue
            case .O:    return Color(red: 0.941, green: 0.902, blue: 0.800) // cream foam
            case .T:    return Color(red: 0.290, green: 0.482, blue: 0.659) // mid wave
            case .S:    return Color(red: 0.533, green: 0.710, blue: 0.773) // pale aqua
            case .Z:    return Color(red: 0.353, green: 0.545, blue: 0.620) // muted teal
            case .L:    return Color(red: 0.784, green: 0.255, blue: 0.180) // Fuji red
            case .J:    return Color(red: 0.075, green: 0.161, blue: 0.294) // deep navy
            case .U:    return Color(red: 0.659, green: 0.784, blue: 0.835) // light foam blue
            case .P:    return Color(red: 0.910, green: 0.863, blue: 0.769) // soft ivory
            case .plus: return Color(red: 0.847, green: 0.435, blue: 0.290) // Fuji orange
            case .F:    return Color(red: 0.173, green: 0.227, blue: 0.306) // ink slate
            }
        case .night:
            switch piece {
            case .I:    return Color(red: 0.180, green: 0.349, blue: 0.604)
            case .O:    return Color(red: 0.851, green: 0.804, blue: 0.694)
            case .T:    return Color(red: 0.376, green: 0.580, blue: 0.749)
            case .S:    return Color(red: 0.604, green: 0.776, blue: 0.835)
            case .Z:    return Color(red: 0.412, green: 0.620, blue: 0.694)
            case .L:    return Color(red: 0.875, green: 0.353, blue: 0.275)
            case .J:    return Color(red: 0.149, green: 0.275, blue: 0.451)
            case .U:    return Color(red: 0.722, green: 0.835, blue: 0.882)
            case .P:    return Color(red: 0.804, green: 0.749, blue: 0.643)
            case .plus: return Color(red: 0.929, green: 0.522, blue: 0.380)
            case .F:    return Color(red: 0.255, green: 0.314, blue: 0.404)
            }
        }
    }

    /// Colour-blind mode: the original palette nudged apart where pairs looked
    /// alike (O/P, T/Z), staying within the woodblock colours.
    static func colorblindPalette(for piece: PieceKind, appearance: AppearanceMode) -> Color {
        switch appearance {
        case .day:
            switch piece {
            case .I:    return Color(red: 0.175, green: 0.296, blue: 0.529) // Prussian blue
            case .O:    return Color(red: 0.969, green: 0.927, blue: 0.822) // cream foam
            case .T:    return Color(red: 0.264, green: 0.477, blue: 0.682) // mid wave
            case .S:    return Color(red: 0.533, green: 0.710, blue: 0.773) // pale aqua
            case .Z:    return Color(red: 0.394, green: 0.547, blue: 0.589) // muted teal
            case .L:    return Color(red: 0.766, green: 0.251, blue: 0.176) // Fuji red
            case .J:    return Color(red: 0.045, green: 0.146, blue: 0.291) // deep navy
            case .U:    return Color(red: 0.791, green: 0.909, blue: 0.941) // light foam blue
            case .P:    return Color(red: 0.751, green: 0.717, blue: 0.652) // stone paper
            case .plus: return Color(red: 0.887, green: 0.463, blue: 0.314) // Fuji orange
            case .F:    return Color(red: 0.249, green: 0.276, blue: 0.335) // ink slate
            }
        case .night:
            switch piece {
            case .I:    return Color(red: 0.174, green: 0.350, blue: 0.619)
            case .O:    return Color(red: 0.945, green: 0.888, blue: 0.762)
            case .T:    return Color(red: 0.340, green: 0.570, blue: 0.776)
            case .S:    return Color(red: 0.563, green: 0.742, blue: 0.813)
            case .Z:    return Color(red: 0.435, green: 0.584, blue: 0.618)
            case .L:    return Color(red: 0.816, green: 0.328, blue: 0.254)
            case .J:    return Color(red: 0.026, green: 0.209, blue: 0.408)
            case .U:    return Color(red: 0.822, green: 0.927, blue: 0.954)
            case .P:    return Color(red: 0.744, green: 0.695, blue: 0.607)
            case .plus: return Color(red: 0.947, green: 0.529, blue: 0.381)
            case .F:    return Color(red: 0.268, green: 0.309, blue: 0.381)
            }
        }
    }

    static func foamColor(appearance: AppearanceMode) -> Color {
        appearance == .day
            ? Color(red: 0.98, green: 0.97, blue: 0.93)
            : Color(red: 0.94, green: 0.96, blue: 1.00)
    }

    static func waveDeepColor(appearance: AppearanceMode) -> Color {
        appearance == .day
            ? Color(red: 0.075, green: 0.176, blue: 0.337)
            : Color(red: 0.118, green: 0.231, blue: 0.439)
    }

    static func waveMidColor(appearance: AppearanceMode) -> Color {
        appearance == .day
            ? Color(red: 0.227, green: 0.404, blue: 0.580)
            : Color(red: 0.314, green: 0.490, blue: 0.667)
    }
}

private struct GreatWaveBanner: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(.largeTitle, design: .serif).weight(.heavy).italic())
            .tracking(3)
            // TR "MUHTEŞEM DALGA" nearly fills a Pro Max width at the default size.
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .foregroundStyle(Color(red: 0.075, green: 0.176, blue: 0.337))
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                Color(red: 0.97, green: 0.94, blue: 0.86)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(red: 0.075, green: 0.176, blue: 0.337), lineWidth: 2)
            )
            .shadow(color: Color(red: 0.075, green: 0.176, blue: 0.337).opacity(0.45), radius: 18, y: 6)
            .padding(.horizontal, 12)
            .allowsHitTesting(false)
    }
}
