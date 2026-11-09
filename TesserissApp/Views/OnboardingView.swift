import SwiftUI

/// Three steps shown on first launch, and again from Settings ("How to play").
/// Skip or Done sets `hasSeenOnboarding`, and RootView brings back the screen
/// underneath. Neither starts a game.
struct OnboardingView: View {
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var step = 1
    @AccessibilityFocusState private var focusedTitle: Int?
    private let stepCount = 3

    private var s: Strings { settings.strings }
    private var theme: Theme { settings.activeTheme }
    private var appearance: AppearanceMode { settings.appearance }
    private var ink: Color { theme.inkColor(appearance: appearance) }
    private var card: Color { theme.cardColor(appearance: appearance) }
    private var stroke: Color { theme.strokeColor(appearance: appearance) }

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { proxy in
                ScrollView {
                    page
                        .legibilityPanel(theme.backgroundIsArtwork, stroke: stroke, fill: card)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            // A new scroll view per step, so each step starts at the top.
            .id(step)
            .transition(.opacity)
            buttons
        }
        // Cross-fade between steps; no sliding.
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: step)
        // Runs on appear and on every step change. The delay lets VoiceOver
        // finish its own screen change first, or it takes the focus back.
        .task(id: step) {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            focusedTitle = step
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("onboarding")
    }

    private var page: some View {
        VStack(spacing: 20) {
            // Read as "Step 1 of 3". The label is on a wrapper: set on the Text
            // itself, the clipping audit measures it against the shorter "1 of 3".
            HStack {
                Text(s.onboardingStep(step, of: stepCount))
                    .font(.system(.footnote, design: .rounded).weight(.semibold))
                    .foregroundStyle(ink.opacity(0.75))
            }
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits(.isStaticText)
            .accessibilityLabel(s.onboardingStepAccessibility(step, of: stepCount))
            .accessibilityIdentifier("onboarding-progress")
            illustration
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(.title2, design: .rounded).weight(.semibold))
                    .foregroundStyle(ink)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("onboarding-step-\(step)")
                    .accessibilityFocused($focusedTitle, equals: step)
                Text(message)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(ink.opacity(0.85))
            }
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var title: String {
        switch step {
        case 1: return s.onboardingMoveTitle
        case 2: return s.onboardingTearTitle
        default: return s.onboardingModesTitle
        }
    }

    private var message: String {
        switch step {
        case 1: return s.onboardingMoveBody
        case 2: return s.onboardingTearBody
        default: return s.onboardingModesBody
        }
    }

    @ViewBuilder
    private var illustration: some View {
        switch step {
        case 1: controlsPad
        case 2: boardRow
        default: modeList
        }
    }

    // MARK: Step 1: the control pad's glyphs, as in ControlsView

    private var controlsPad: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                padKey(Text("◀"), label: s.moveLeft)
                padKey(Text("▼"), label: s.softDrop)
                padKey(Text("▶"), label: s.moveRight)
            }
            HStack(spacing: 8) {
                padKey(Image(systemName: "arrow.counterclockwise"), label: s.rotateCCW)
                padKey(Image(systemName: "chevron.down.2"), label: s.hardDrop)
                padKey(Image(systemName: "arrow.clockwise"), label: s.rotateCW)
            }
        }
        .frame(maxWidth: 280)
    }

    /// Not a button: the key's name is read as text, so VoiceOver users meet
    /// the names the game's buttons use.
    private func padKey(_ glyph: some View, label: String) -> some View {
        glyph
            .font(.system(.title3, design: .rounded).weight(.semibold))
            .foregroundStyle(ink)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(card)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(stroke, lineWidth: 1))
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits(.isStaticText)
            .accessibilityLabel(label)
    }

    // MARK: Step 2: a few board rows, the full one outlined

    private static let boardRows: [[PieceKind?]] = [
        [nil, nil, nil, nil, .T, .T, .T, nil, nil, nil],
        [.O, .O, nil, nil, nil, .T, nil, nil, .S, .S],
        [.I, .I, .I, .I, .L, .L, .J, .J, .Z, .Z],
    ]

    private var boardRow: some View {
        VStack(spacing: 0) {
            ForEach(Self.boardRows.indices, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(Self.boardRows[row].indices, id: \.self) { column in
                        CellView(kind: Self.boardRows[row][column], style: .solid, isFlashing: false,
                                 theme: theme, appearance: appearance,
                                 flashTint: theme.flashTint(appearance: appearance))
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
                .overlay {
                    if row == Self.boardRows.count - 1 {
                        Rectangle().stroke(theme.accentColor(appearance: appearance), lineWidth: 3)
                    }
                }
            }
        }
        .background(theme.playfieldBoardView(appearance: appearance))
        .overlay(Rectangle().stroke(theme.playfieldBorderColor(appearance: appearance), lineWidth: 2))
        .frame(maxWidth: 260)
        // Shapes only; the text below says what it shows.
        .accessibilityHidden(true)
    }

    // MARK: Step 3: the three modes, with the menu's symbols

    private var modeList: some View {
        VStack(alignment: .leading, spacing: 8) {
            modeRow("bolt.fill", s.modeName(.fast))
            modeRow("square.grid.3x3.fill", s.modeName(.og))
            modeRow("flame.fill", s.modeName(.hard))
        }
        .frame(maxWidth: 280)
    }

    private func modeRow(_ symbol: String, _ name: String) -> some View {
        // A plain list, not tiles: tiles looked like buttons that did nothing.
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .frame(width: 24)  // symbols differ in width; keep the names aligned
                .accessibilityHidden(true)
            Text(name)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .font(.system(.callout, design: .rounded).weight(.semibold))
        .foregroundStyle(ink)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

    // MARK: Buttons

    /// Pinned below the scroll view so they never scroll away; stacked at
    /// accessibility sizes.
    private var buttons: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))
        return layout {
            if step < stepCount {
                button(s.onboardingSkip, id: "onboarding-skip", primary: false) { finish() }
                button(s.onboardingNext, id: "onboarding-next", primary: true) { step += 1 }
            } else {
                button(s.onboardingDone, id: "onboarding-done", primary: true) { finish() }
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 12)
    }

    private func button(_ label: String, id: String, primary: Bool,
                        action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(primary ? theme.onInkColor(appearance: appearance) : ink)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(primary ? ink : card)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(primary ? .clear : stroke, lineWidth: 1))
        }
        .accessibilityIdentifier(id)
    }

    private func finish() {
        settings.hasSeenOnboarding = true
    }
}
