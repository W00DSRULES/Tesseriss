import SwiftUI

struct GameView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 12) {
            header
            HStack(alignment: .top, spacing: 16) {
                PlayfieldView()
                    .aspectRatio(CGFloat(Board.width) / CGFloat(Board.height), contentMode: .fit)
                    .scaleEffect(celebrationScale)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: engine.celebrationActive)
                sidebar
            }
            .padding(.horizontal, 12)
            Spacer(minLength: 0)
            ControlsView()
                .padding(.bottom, 12)
            if engine.phase == .paused {
                pausedOverlay
            }
        }
        .padding(.top, 8)
    }

    private var celebrationScale: CGFloat {
        if reduceMotion { return 1.0 }
        return engine.celebrationActive ? 1.02 : 1.0
    }

    private var header: some View {
        HStack {
            Button(action: { engine.returnToMenu() }) {
                Text("MENU")
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color("PaletteInk").opacity(0.7))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color("PaletteGrid"))
                    .clipShape(Capsule())
            }
            Spacer()
            Button(action: { engine.togglePause() }) {
                Text(engine.phase == .paused ? "RESUME" : "PAUSE")
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color("PaletteInk").opacity(0.7))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color("PaletteGrid"))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 16) {
            NextPieceView(kind: engine.nextKind)
            VStack(alignment: .leading, spacing: 8) {
                statRow(label: "SCORE", value: "\(engine.score)")
                statRow(label: "LEVEL", value: "\(engine.level)")
                statRow(label: "LINES", value: "\(engine.lines)")
            }
        }
        .frame(maxWidth: 100, alignment: .leading)
    }

    private func statRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(.caption2, design: .rounded).weight(.semibold))
                .foregroundStyle(Color("PaletteInk").opacity(0.6))
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(Color("PaletteInk"))
        }
    }

    private var pausedOverlay: some View {
        Text("PAUSED")
            .font(.system(.title, design: .rounded).weight(.semibold))
            .foregroundStyle(Color("PaletteInk"))
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(Color("PaletteGrid"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .transition(.opacity)
    }
}
