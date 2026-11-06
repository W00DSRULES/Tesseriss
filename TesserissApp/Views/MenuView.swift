import SwiftUI

struct MenuView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject private var hs = HighscoreStore.shared

    // Scale with Dynamic Type while keeping the same size at the default setting.
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize: CGFloat = 44
    @ScaledMetric(relativeTo: .title) private var scoreSize: CGFloat = 36

    private var s: Strings { settings.strings }
    private var theme: Theme { settings.activeTheme }
    private var mode: AppearanceMode { settings.appearance }
    private var ink: Color { theme.inkColor(appearance: mode) }
    private var card: Color { theme.cardColor(appearance: mode) }
    private var strokeColor: Color { theme.strokeColor(appearance: mode) }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 12)
                VStack(spacing: 8) {
                    Text("Tesseriss")
                        .font(.system(size: titleSize, weight: .semibold, design: .rounded))
                        .foregroundStyle(ink)
                    Text(s.tagline)
                        .font(.system(.callout, design: .rounded))
                        .foregroundStyle(ink.opacity(0.6))
                    scoringHint
                }
                .legibilityPanel(theme.backgroundIsArtwork, stroke: strokeColor)
                .padding(.horizontal, 20)
                Spacer(minLength: 24)
                VStack(spacing: 6) {
                    Text(s.highscore)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(ink.opacity(0.6))
                    Text("\(hs.highscore(for: settings.selectedMode))")
                        .font(.system(size: scoreSize, weight: .semibold, design: .rounded))
                        .foregroundStyle(ink)
                        .accessibilityIdentifier("highscore-value")
                }
                .legibilityPanel(theme.backgroundIsArtwork, stroke: strokeColor)
                VStack(spacing: 14) {
                    Button(action: { engine.startNewGame(mode: settings.selectedMode) }) {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                            Text(s.start)
                        }
                        .font(.system(.title2, design: .rounded).weight(.semibold))
                        .foregroundStyle(theme.onInkColor(appearance: mode))
                        .frame(maxWidth: .infinity, minHeight: 64)
                        .background(ink)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .accessibilityIdentifier("start-button")
                    modePicker
                    Button(action: { engine.openSettings() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "gearshape.fill")
                            Text(s.settings)
                        }
                        .font(.system(.title3, design: .rounded).weight(.medium))
                        .foregroundStyle(ink)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(card)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .accessibilityIdentifier("settings-button")
                }
                .padding(.horizontal, 32)
                Spacer(minLength: 24)
            }
            .frame(maxWidth: .infinity, minHeight: 0)
        }
        .scrollBounceBehavior(.basedOnSize)
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
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
        .foregroundStyle(ink.opacity(0.55))
        .padding(.top, 4)
    }

    private var modePicker: some View {
        HStack(spacing: 8) {
            ForEach(GameMode.allCases) { mode in
                modeButton(mode)
            }
        }
    }

    /// Language-independent glyph per mode: bolt = fast, grid = classic board, flame = hard.
    private func modeIcon(_ mode: GameMode) -> String {
        switch mode {
        case .fast: return "bolt.fill"
        case .og:   return "square.grid.3x3.fill"
        case .hard: return "flame.fill"
        }
    }

    private func modeButton(_ gameMode: GameMode) -> some View {
        let isSelected = settings.selectedMode == gameMode
        // Selected mode reads as a muted version of the theme's ink so it doesn't
        // compete with the ink-filled Start button above it.
        let selectedBg = ink.opacity(0.62)
        return Button(action: {
            guard settings.selectedMode != gameMode else { return }
            engine.haptics.light(enabled: settings.hapticsEnabled)
            settings.selectedMode = gameMode
        }) {
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: modeIcon(gameMode))
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                    Text(s.modeName(gameMode))
                        .font(.system(.callout, design: .rounded).weight(.semibold))
                }
                Text(s.modeSubtitle(gameMode))
                    .font(.system(.caption2, design: .rounded).weight(.medium))
                    .opacity(0.7)
            }
            .foregroundStyle(isSelected ? theme.onInkColor(appearance: mode) : ink)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(isSelected ? selectedBg : card)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? ink.opacity(0.8) : theme.strokeColor(appearance: mode),
                            lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        // `gameMode`, not `mode` — that's the appearance. Selection is otherwise color-only.
        .accessibilityIdentifier("mode-\(gameMode.rawValue)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
