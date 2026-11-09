import SwiftUI

struct MenuView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject private var hs = HighscoreStore.shared
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(s.tagline)
                        .font(.system(.callout, design: .rounded))
                        .foregroundStyle(ink.opacity(0.75))
                    scoringHint
                }
                .legibilityPanel(theme.backgroundIsArtwork, stroke: strokeColor, fill: card)
                .padding(.horizontal, 20)
                Spacer(minLength: 24)
                VStack(spacing: 6) {
                    Text(s.highscore)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(ink.opacity(0.75))
                    Text("\(hs.highscore(for: settings.selectedMode))")
                        .font(.system(size: scoreSize, weight: .semibold, design: .rounded))
                        .foregroundStyle(ink)
                }
                // One element, read as "Highscore, 4000": the number alone isn't a readable label.
                .accessibilityElement(children: .ignore)
                .accessibilityAddTraits(.isStaticText)
                .accessibilityLabel(s.highscore)
                .accessibilityValue(String(hs.highscore(for: settings.selectedMode)))
                .accessibilityIdentifier("highscore-value")
                .legibilityPanel(theme.backgroundIsArtwork, stroke: strokeColor, fill: card)
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
                    dailyButton
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
    }

    /// Secondary style, like Settings. The caption reports today's result once
    /// the daily has been played today, else says what the daily is.
    private var dailyButton: some View {
        let today = engine.todayKey
        let played = hs.lastDailyDay == today
        let best = hs.dailyBest(for: today)
        let streak = s.dailyStreak(hs.currentStreak(today: today))
        // The best is grouped like the Game Over and Stats numbers ("4.000" in
        // Turkish); the streak's spaces don't break, so "Seri: 12 gün" stays on one line.
        let caption = played
            ? s.dailyBest(best.formatted()) + " · " + streak.replacingOccurrences(of: " ", with: "\u{00A0}")
            : s.dailySubtitle
        return Button(action: { engine.startDailyChallenge() }) {
            VStack(spacing: 2) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                    Text(s.dailyButton)
                }
                .font(.system(.title3, design: .rounded).weight(.medium))
                Text(caption)
                    .font(.system(.caption, design: .rounded).weight(.medium))
                    .opacity(0.85)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(ink)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(card)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .accessibilityLabel(s.dailyTitle)
        .accessibilityValue(played ? s.dailyBest(String(best)) + ", " + streak : s.dailySubtitle)
        .accessibilityIdentifier("daily-button")
    }

    private var scoringHint: some View {
        // Pairs side by side; one per line at accessibility text sizes.
        let row = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 4))
            : AnyLayout(HStackLayout(spacing: 28))
        return VStack(spacing: 4) {
            row {
                Text(s.scoringRow1)
                Text(s.scoringRow2)
            }
            row {
                Text(s.scoringRow3)
                Text(s.scoringRow4)
            }
        }
        .font(.system(.footnote, design: .rounded).weight(.medium))
        .foregroundStyle(ink.opacity(0.75))
        .padding(.top, 4)
    }

    private var modePicker: some View {
        // Three across; one per row from xLarge up, where the names no longer
        // fit a third of the screen (TR "Parçalanma" would truncate).
        let layout = modesStacked
            ? AnyLayout(VStackLayout(spacing: 8))
            : AnyLayout(HStackLayout(spacing: 8))
        return layout {
            ForEach(GameMode.allCases) { mode in
                modeButton(mode)
            }
        }
    }

    private var modesStacked: Bool { dynamicTypeSize >= .xLarge }

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
        // compete with the ink-filled Start button above it. It sits on an opaque
        // card (below) so the Hokusai art never shows through behind the text.
        let selectedBg = ink.opacity(0.8)
        return Button(action: {
            guard settings.selectedMode != gameMode else { return }
            engine.haptics.light(enabled: settings.hapticsEnabled)
            settings.selectedMode = gameMode
        }) {
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: modeIcon(gameMode))
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        // Decoration: VoiceOver reads the mode name, not the symbol name.
                        .accessibilityHidden(true)
                    Text(s.modeName(gameMode))
                        .font(.system(.callout, design: .rounded).weight(.semibold))
                        // Long names (TR "Parçalanma") shrink rather than touch the border.
                        // Stacked full-width buttons have room to wrap instead.
                        .lineLimit(modesStacked ? nil : 1)
                        .minimumScaleFactor(0.8)
                }
                // .caption, not .caption2: caption2 stops shrinking below the default
                // size, which the Dynamic Type audit reports as partial support.
                Text(s.modeSubtitle(gameMode))
                    .font(.system(.caption, design: .rounded).weight(.medium))
                    .opacity(0.85)
            }
            .foregroundStyle(isSelected ? theme.onInkColor(appearance: mode) : ink)
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(isSelected ? selectedBg : card)
            .background(card)
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
