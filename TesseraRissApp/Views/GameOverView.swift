import SwiftUI

struct GameOverView: View {
    @EnvironmentObject var engine: GameEngine
    @ObservedObject private var hs = HighscoreStore.shared

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            Text("GAME OVER")
                .font(.system(size: 36, weight: .semibold, design: .rounded))
                .foregroundStyle(Color("PaletteInk"))
            VStack(spacing: 8) {
                Text("SCORE")
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color("PaletteInk").opacity(0.6))
                Text("\(engine.score)")
                    .font(.system(size: 48, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color("PaletteInk"))
                if engine.score >= hs.highscore && engine.score > 0 {
                    Text("NEW BEST")
                        .font(.system(.callout, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color("PieceL"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color("PaletteGrid").opacity(0.35))
                        .clipShape(Capsule())
                }
            }
            Spacer()
            VStack(spacing: 14) {
                Button(action: { engine.startNewGame() }) {
                    Text("PLAY AGAIN")
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color("PaletteBackground"))
                        .frame(maxWidth: .infinity, minHeight: 64)
                        .background(Color("PaletteInk"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Button(action: { engine.returnToMenu() }) {
                    Text("MENU")
                        .font(.system(.body, design: .rounded).weight(.medium))
                        .foregroundStyle(Color("PaletteInk"))
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color("PaletteGrid").opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 32)
            Spacer()
        }
    }
}
