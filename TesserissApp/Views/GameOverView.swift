import SwiftUI

struct GameOverView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var settings: SettingsStore

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
                    }
                }
                }
                .legibilityPanel(theme.backgroundIsArtwork,
                                 stroke: theme.strokeColor(appearance: appearance),
                                 fill: card)
                .padding(.horizontal, 20)
                Spacer(minLength: 24)
                VStack(spacing: 14) {
                    Button(action: { engine.startNewGame(mode: engine.mode) }) {
                        Text(s.playAgain)
                            .font(.system(.title3, design: .rounded).weight(.semibold))
                            .foregroundStyle(theme.onInkColor(appearance: appearance))
                            .frame(maxWidth: .infinity, minHeight: 64)
                            .background(ink)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Button(action: { engine.returnToMenu() }) {
                        Text(s.menu)
                            .font(.system(.body, design: .rounded).weight(.medium))
                            .foregroundStyle(ink)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 32)
                Spacer(minLength: 24)
            }
            .frame(maxWidth: .infinity, minHeight: 0)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}
