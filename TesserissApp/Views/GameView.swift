import SwiftUI

struct GameView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var s: Strings { settings.strings }

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                header
                HStack(alignment: .top, spacing: 16) {
                    PlayfieldView()
                        .aspectRatio(CGFloat(engine.board.width) / CGFloat(engine.board.height), contentMode: .fit)
                        .scaleEffect(celebrationScale)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: engine.celebrationActive)
                    sidebar
                }
                .padding(.horizontal, 12)
                Spacer(minLength: 0)
                ControlsView()
                    .padding(.bottom, 12)
            }
            .padding(.top, 8)
            if engine.phase == .paused {
                Color.black.opacity(0.25).ignoresSafeArea()
                pausedOverlay
            }
        }
    }

    private var celebrationScale: CGFloat {
        if reduceMotion { return 1.0 }
        return engine.celebrationActive ? 1.02 : 1.0
    }

    private var header: some View {
        HStack {
            Button(action: { engine.returnToMenu() }) {
                Text(s.menu)
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color("PaletteInk").opacity(0.8))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color("PaletteCard"))
                    .clipShape(Capsule())
            }
            Spacer()
            Button(action: {
                if engine.phase == .playing { engine.togglePause() }
            }) {
                Image(systemName: "pause.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color("PaletteInk").opacity(engine.phase == .paused ? 0.3 : 0.8))
                    .frame(width: 32, height: 32)
                    .background(Color("PaletteCard"))
                    .clipShape(Capsule())
            }
            .disabled(engine.phase == .paused)
        }
        .padding(.horizontal, 16)
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 16) {
            NextPieceView(kind: engine.nextKind, label: s.next)
            VStack(alignment: .leading, spacing: 8) {
                statRow(label: s.score, value: "\(engine.score)")
                statRow(label: s.level, value: "\(engine.level)")
                statRow(label: s.lines, value: "\(engine.lines)")
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
        VStack(spacing: 16) {
            Text(s.paused)
                .font(.system(.title, design: .rounded).weight(.semibold))
                .foregroundStyle(Color("PaletteInk"))
            Button(action: { engine.togglePause() }) {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                    Text(s.resume)
                }
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(Color("PaletteBackground"))
                .padding(.vertical, 14)
                .padding(.horizontal, 36)
                .frame(maxWidth: .infinity)
                .background(Color("PaletteInk"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            Button(action: { engine.returnToMenu() }) {
                HStack(spacing: 10) {
                    Image(systemName: "house.fill")
                    Text(s.menu)
                }
                .font(.system(.body, design: .rounded).weight(.medium))
                .foregroundStyle(Color("PaletteInk"))
                .padding(.vertical, 12)
                .padding(.horizontal, 28)
                .frame(maxWidth: .infinity)
                .background(Color("PaletteBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("PaletteGrid"), lineWidth: 1)
                )
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 28)
        .frame(maxWidth: 280)
        .background(Color("PaletteCard"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("PaletteGrid"), lineWidth: 1)
        )
        .transition(.opacity)
    }
}
