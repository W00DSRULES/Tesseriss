import SwiftUI

struct GameOverView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject private var hs = HighscoreStore.shared
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ScaledMetric(relativeTo: .largeTitle) private var titleSize: CGFloat = 36
    @ScaledMetric(relativeTo: .largeTitle) private var scoreSize: CGFloat = 48

    private var s: Strings { settings.strings }
    private var theme: Theme { settings.activeTheme }
    private var appearance: AppearanceMode { settings.appearance }
    private var ink: Color { theme.inkColor(appearance: appearance) }
    private var card: Color { theme.cardColor(appearance: appearance) }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer(minLength: 24)
                VStack(spacing: 20) {
                if engine.isDaily {
                    Text(s.dailyTitle)
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .foregroundStyle(ink.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("gameover-daily-title")
                }
                Text(s.gameOver)
                    .font(.system(size: titleSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(ink)
                VStack(spacing: 8) {
                    VStack(spacing: 8) {
                        Text(s.score)
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .foregroundStyle(ink.opacity(0.75))
                        Text("\(engine.score)")
                            .font(.system(size: scoreSize, weight: .semibold, design: .rounded))
                            .foregroundStyle(ink)
                            // A big score at large text sizes shrinks rather than wrapping digits.
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    // One element, read as "Score, 4000": the number alone isn't a readable label.
                    .accessibilityElement(children: .ignore)
                    .accessibilityAddTraits(.isStaticText)
                    .accessibilityLabel(s.score)
                    .accessibilityValue(String(engine.score))
                    .accessibilityIdentifier("gameover-score")
                    if engine.isNewHighscore {
                        Text(s.newBest)
                            .font(.system(.callout, design: .rounded).weight(.semibold))
                            .foregroundStyle(theme.accentColor(appearance: appearance))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(card)
                            .clipShape(Capsule())
                            .accessibilityIdentifier("new-best-badge")
                    }
                }
                if engine.isDaily, let day = engine.dailyKey {
                    dailyResult(day: day)
                }
                }
                .legibilityPanel(theme.backgroundIsArtwork,
                                 stroke: theme.strokeColor(appearance: appearance),
                                 fill: card)
                .padding(.horizontal, 20)
                Spacer(minLength: 24)
                VStack(spacing: 14) {
                    // A daily run starts another daily attempt, not a plain Tear game.
                    Button(action: { engine.playAgain() }) {
                        Text(s.playAgain)
                            .font(.system(.title3, design: .rounded).weight(.semibold))
                            .foregroundStyle(theme.onInkColor(appearance: appearance))
                            .frame(maxWidth: .infinity, minHeight: 64)
                            .background(ink)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .accessibilityIdentifier("play-again-button")
                    Button(action: { engine.returnToMenu() }) {
                        Text(s.menu)
                            .font(.system(.body, design: .rounded).weight(.medium))
                            .foregroundStyle(ink)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .accessibilityIdentifier("gameover-menu-button")
                }
                .padding(.horizontal, 32)
                Spacer(minLength: 24)
            }
            .frame(maxWidth: .infinity, minHeight: 0)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    /// Today's best and the streak side by side (stacked at accessibility
    /// sizes), then when the day ends.
    private func dailyResult(day: String) -> some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 28))
        return VStack(spacing: 12) {
            layout {
                let best = hs.dailyBest(for: day)
                let streak = s.streakDays(hs.currentStreak(today: day))
                dailyStat(id: "gameover-daily-best", label: s.dailyBestLabel,
                          shown: Text("\(best)"), value: String(best))
                // Upper case to match TODAY'S BEST; the Turkish locale gives "SERİ".
                dailyStat(id: "gameover-streak",
                          label: s.streakLabel.uppercased(with: Locale(identifier: settings.language.rawValue)),
                          shown: Text(streak), value: streak)
            }
            Text(s.dailyResets)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(ink.opacity(0.75))
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("daily-resets")
        }
    }

    /// `shown` formats numbers like the score above it ("4.000" in Turkish);
    /// `value` is what VoiceOver reads.
    private func dailyStat(id: String, label: String, shown: Text, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(ink.opacity(0.75))
            shown
                .font(.system(.title2, design: .rounded).weight(.semibold).monospacedDigit())
                .foregroundStyle(ink)
        }
        .multilineTextAlignment(.center)
        // One element, read as "Streak, 3 days".
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityLabel(label)
        .accessibilityValue(value)
        .accessibilityIdentifier(id)
    }
}
