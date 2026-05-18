import SwiftUI

struct GameOverView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject private var hs = HighscoreStore.shared

    private var s: Strings { settings.strings }

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            Text(s.gameOver)
                .font(.system(size: 36, weight: .semibold, design: .rounded))
                .foregroundStyle(Color("PaletteInk"))
            VStack(spacing: 8) {
                Text(s.score)
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color("PaletteInk").opacity(0.6))
                Text("\(engine.score)")
                    .font(.system(size: 48, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color("PaletteInk"))
                if engine.score >= hs.highscore(for: engine.mode) && engine.score > 0 {
                    Text(s.newBest)
                        .font(.system(.callout, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color("PieceL"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color("PaletteCard"))
                        .clipShape(Capsule())
                }
            }
            Spacer()
            VStack(spacing: 14) {
                Button(action: { engine.startNewGame(mode: engine.mode) }) {
                    Text(s.playAgain)
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color("PaletteBackground"))
                        .frame(maxWidth: .infinity, minHeight: 64)
                        .background(Color("PaletteInk"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Button(action: { engine.returnToMenu() }) {
                    Text(s.menu)
                        .font(.system(.body, design: .rounded).weight(.medium))
                        .foregroundStyle(Color("PaletteInk"))
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color("PaletteCard"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 32)
            Spacer()
        }
    }
}
