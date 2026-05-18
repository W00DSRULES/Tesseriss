import SwiftUI

struct MenuView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject private var hs = HighscoreStore.shared

    private var s: Strings { settings.strings }

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 12)
            Text("Tesseriss")
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
                Text("\(hs.highscore(for: settings.selectedMode))")
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color("PaletteInk"))
            }
            VStack(spacing: 14) {
                Button(action: { engine.startNewGame(mode: settings.selectedMode) }) {
                    Text(s.start)
                        .font(.system(.title2, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color("PaletteBackground"))
                        .frame(maxWidth: .infinity, minHeight: 64)
                        .background(Color("PaletteInk"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                modePicker
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

    private var modePicker: some View {
        HStack(spacing: 8) {
            ForEach(GameMode.allCases) { mode in
                modeButton(mode)
            }
        }
    }

    private func modeButton(_ mode: GameMode) -> some View {
        let isSelected = settings.selectedMode == mode
        return Button(action: { settings.selectedMode = mode }) {
            VStack(spacing: 2) {
                Text(s.modeName(mode))
                    .font(.system(.callout, design: .rounded).weight(.semibold))
                Text(s.modeSubtitle(mode))
                    .font(.system(.caption2, design: .rounded).weight(.medium))
                    .opacity(0.7)
            }
            .foregroundStyle(isSelected ? Color("PaletteBackground") : Color("PaletteInk"))
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(isSelected ? Color("PaletteInk") : Color("PaletteCard"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color("PaletteInk") : Color("PaletteGrid"), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
