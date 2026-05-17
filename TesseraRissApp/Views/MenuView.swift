import SwiftUI

struct MenuView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject private var hs = HighscoreStore.shared

    private var s: Strings { settings.strings }

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 12)
            Text("TesseraRiss")
                .font(.system(size: 44, weight: .semibold, design: .rounded))
                .foregroundStyle(Color("PaletteInk"))
            Text(s.tagline)
                .font(.system(.callout, design: .rounded))
                .foregroundStyle(Color("PaletteInk").opacity(0.6))
            scoringHint
            Spacer()
            VStack(spacing: 6) {
                Text(s.highscore)
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color("PaletteInk").opacity(0.6))
                Text("\(hs.highscore)")
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color("PaletteInk"))
            }
            VStack(spacing: 16) {
                Button(action: { engine.startNewGame() }) {
                    Text(s.start)
                        .font(.system(.title2, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color("PaletteBackground"))
                        .frame(maxWidth: .infinity, minHeight: 64)
                        .background(Color("PaletteInk"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Button(action: { engine.openSettings() }) {
                    Text(s.settings)
                        .font(.system(.title3, design: .rounded).weight(.medium))
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

    private var scoringHint: some View {
        VStack(spacing: 4) {
            HStack(spacing: 28) {
                Text(s.scoringRow1)
                Text(s.scoringRow2)
            }
            HStack(spacing: 28) {
                Text(s.scoringRow3)
                Text(s.scoringRow4)
            }
        }
        .font(.system(.footnote, design: .rounded).weight(.medium))
        .foregroundStyle(Color("PaletteInk").opacity(0.55))
        .padding(.top, 4)
    }
}
