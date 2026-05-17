import SwiftUI

struct MenuView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject private var hs = HighscoreStore.shared

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("TesseraRiss")
                .font(.system(size: 44, weight: .semibold, design: .rounded))
                .foregroundStyle(Color("PaletteInk"))
            Text("tear the tiles")
                .font(.system(.callout, design: .rounded))
                .foregroundStyle(Color("PaletteInk").opacity(0.6))
            Spacer()
            VStack(spacing: 6) {
                Text("HIGHSCORE")
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color("PaletteInk").opacity(0.6))
                Text("\(hs.highscore)")
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color("PaletteInk"))
            }
            VStack(spacing: 16) {
                Button(action: { engine.startNewGame() }) {
                    Text("START")
                        .font(.system(.title2, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color("PaletteBackground"))
                        .frame(maxWidth: .infinity, minHeight: 64)
                        .background(Color("PaletteInk"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Button(action: { engine.openSettings() }) {
                    Text("SETTINGS")
                        .font(.system(.title3, design: .rounded).weight(.medium))
                        .foregroundStyle(Color("PaletteInk"))
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color("PaletteGrid"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 32)
            Spacer()
        }
    }
}
