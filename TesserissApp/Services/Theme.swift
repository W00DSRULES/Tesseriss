import SwiftUI

enum ThemeKind: String, CaseIterable, Identifiable {
    case classic
    case kanagawa
    var id: String { rawValue }
}

protocol Theme {
    var kind: ThemeKind { get }
    func pieceColor(_ piece: PieceKind, appearance: AppearanceMode) -> Color
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
}

struct ClassicTheme: Theme {
    let kind: ThemeKind = .classic

    func pieceColor(_ piece: PieceKind, appearance: AppearanceMode) -> Color {
        Color(piece.colorName)
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

    func pieceColor(_ piece: PieceKind, appearance: AppearanceMode) -> Color {
        Self.palette(for: piece, appearance: appearance)
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
            .foregroundStyle(Color(red: 0.075, green: 0.176, blue: 0.337))
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background(
                Color(red: 0.97, green: 0.94, blue: 0.86)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(red: 0.075, green: 0.176, blue: 0.337), lineWidth: 2)
            )
            .shadow(color: Color(red: 0.075, green: 0.176, blue: 0.337).opacity(0.45), radius: 18, y: 6)
            .allowsHitTesting(false)
    }
}
