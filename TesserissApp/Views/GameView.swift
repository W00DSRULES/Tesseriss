import SwiftUI

struct GameView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var s: Strings { settings.strings }
    private var theme: Theme { settings.activeTheme }
    private var appearance: AppearanceMode { settings.appearance }
    private var ink: Color { theme.inkColor(appearance: appearance) }
    private var card: Color { theme.cardColor(appearance: appearance) }

    var body: some View {
        ZStack {
            // Paused, the dimmed HUD leaves the accessibility tree, so VoiceOver
            // stays on the pause card. accessibilityHidden alone, on the stack or
            // flipped on views already on screen, left the HUD's elements in the
            // tree; an empty representation on a freshly built copy removes them.
            // Rebuilding also ends any held-button repeat (ControlsView's
            // onDisappear).
            if engine.phase == .paused {
                hud.accessibilityRepresentation { EmptyView() }
                    .accessibilityHidden(true)
            } else {
                hud
            }
            if engine.phase == .paused {
                // Tapping anywhere on the scrim resumes — the button is still there
                // for anyone who reaches for it.
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { engine.togglePause() }
                pausedOverlay
            }
            if engine.celebrationActive {
                celebrationBanner
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.85)))
            }
        }
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: engine.celebrationActive)
        // Fixed arcade layout: text grows up to xxxLarge, and the glyph buttons
        // offer the Large Content Viewer beyond that.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    private var hud: some View {
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
    }

    @ViewBuilder
    private var celebrationBanner: some View {
        if let custom = theme.fourLineBanner(strings: s) {
            custom
        } else {
            ultimateRissBanner
        }
    }

    private var ultimateRissBanner: some View {
        Text(s.ultimateRiss)
            .font(.system(.largeTitle, design: .rounded).weight(.heavy))
            .tracking(2)
            .foregroundStyle(ink)
            .padding(.vertical, 14)
            .padding(.horizontal, 28)
            .background(card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(ink.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 10, y: 3)
            .allowsHitTesting(false)
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
                    .foregroundStyle(ink.opacity(0.8))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(card)
                    .clipShape(Capsule())
                    // Keep the small capsule look, but meet the 44pt touch minimum.
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityShowsLargeContentViewer()
            .accessibilityIdentifier("menu-button")
            Spacer()
            if engine.isDaily {
                Text(s.dailyButton)
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(ink.opacity(0.8))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(card)
                    .clipShape(Capsule())
                    .accessibilityLabel(s.dailyTitle)
                    .accessibilityIdentifier("daily-marker")
                Spacer()
            }
            Button(action: { engine.togglePause() }) {
                Image(systemName: "pause.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(ink.opacity(engine.phase == .paused ? 0.3 : 0.8))
                    .frame(width: 32, height: 32)
                    .background(card)
                    .clipShape(Capsule())
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .disabled(engine.phase == .paused)
            .accessibilityLabel(s.pause)
            .accessibilityShowsLargeContentViewer()
            .accessibilityIdentifier("pause-button")
        }
        .padding(.horizontal, 16)
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 16) {
            NextPieceView(kind: engine.nextKind, label: s.next)
                .legibilityPanel(theme.backgroundIsArtwork,
                                 stroke: theme.strokeColor(appearance: appearance),
                                 fill: card)
            VStack(alignment: .leading, spacing: 10) {
                statRow(id: "score", label: s.score, value: engine.score, prominent: true)
                Divider().overlay(theme.strokeColor(appearance: appearance))
                // Stacked, not side by side: half the narrow sidebar truncates
                // "LEVEL" / "SEVİYE" at large text sizes.
                VStack(alignment: .leading, spacing: 10) {
                    statRow(id: "level", label: s.level, value: engine.level)
                    statRow(id: "lines", label: s.lines, value: engine.lines)
                }
            }
            // Replaces a hardcoded 110pt top inset that was hand-tuned to dodge the
            // wave crest — and therefore only worked on one screen size.
            .legibilityPanel(theme.backgroundIsArtwork,
                             stroke: theme.strokeColor(appearance: appearance),
                             fill: card)
            Spacer(minLength: 0)
        }
        .frame(width: 124, alignment: .leading)
    }

    /// `id` keeps the accessibility identifier fixed; `label` follows the app language.
    private func statRow(id: String, label: String, value: Int, prominent: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.system(.caption2, design: .rounded).weight(.semibold))
                .foregroundStyle(ink.opacity(0.75))
                // "LEVEL" is wide enough to hyphenate in the narrow column; shrink
                // rather than wrap, and never break the word.
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
            // Monospaced digits so the numbers don't jiggle sideways as they tick up.
            Text("\(value)")
                .font(.system(prominent ? .title2 : .title3, design: .rounded)
                    .weight(.semibold)
                    .monospacedDigit())
                .foregroundStyle(ink)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        // One element, read as "Score, 4000": the number alone isn't a readable label.
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityLabel(label)
        .accessibilityValue(String(value))
        .accessibilityIdentifier("stat-\(id)")
    }

    private var pausedOverlay: some View {
        VStack(spacing: 16) {
            Text(s.paused)
                .font(.system(.title, design: .rounded).weight(.semibold))
                .foregroundStyle(ink)
            Button(action: { engine.togglePause() }) {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                    Text(s.resume)
                }
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(theme.onInkColor(appearance: appearance))
                .padding(.vertical, 14)
                .padding(.horizontal, 36)
                .frame(maxWidth: .infinity)
                .background(ink)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityIdentifier("resume-button")
            Button(action: { engine.returnToMenu() }) {
                HStack(spacing: 10) {
                    Image(systemName: "house.fill")
                    Text(s.menu)
                }
                .font(.system(.body, design: .rounded).weight(.medium))
                .foregroundStyle(ink)
                .padding(.vertical, 12)
                .padding(.horizontal, 28)
                .frame(maxWidth: .infinity)
                .background(theme.onInkColor(appearance: appearance))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.strokeColor(appearance: appearance), lineWidth: 1)
                )
            }
            // Not "menu-button": the header MENU keeps that id and stays on screen.
            .accessibilityIdentifier("pause-menu-button")
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 28)
        .frame(maxWidth: 280)
        .background(card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(theme.strokeColor(appearance: appearance), lineWidth: 1)
        )
        .transition(.opacity)
    }
}
