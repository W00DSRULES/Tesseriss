import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var settings: SettingsStore

    @State private var leftTask: Task<Void, Never>?
    @State private var rightTask: Task<Void, Never>?
    @State private var downTask: Task<Void, Never>?

    private let initialDelay: UInt64 = 270_000_000
    private let repeatDelay: UInt64 = 50_000_000

    private var theme: Theme { settings.activeTheme }
    private var appearance: AppearanceMode { settings.appearance }
    private var ink: Color { theme.inkColor(appearance: appearance) }
    private var card: Color { theme.cardColor(appearance: appearance) }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                pressableButton("◀", onPress: startLeft, onRelease: stopLeft)
                    .accessibilityIdentifier("move-left-button")
                pressableButton("▼", onPress: startDown, onRelease: stopDown)
                    .accessibilityIdentifier("soft-drop-button")
                pressableButton("▶", onPress: startRight, onRelease: stopRight)
                    .accessibilityIdentifier("move-right-button")
            }
            HStack(spacing: 12) {
                iconButton(systemName: "arrow.counterclockwise") { engine.rotateCCW() }
                    .accessibilityIdentifier("rotate-ccw-button")
                iconButton(systemName: "chevron.down.2") { engine.hardDrop() }
                    .accessibilityIdentifier("hard-drop-button")
                iconButton(systemName: "arrow.clockwise") { engine.rotateCW() }
                    .accessibilityIdentifier("rotate-button")
            }
        }
        .padding(.horizontal, 16)
        // A hold that is interrupted by the view going away (game over, or
        // returning to the menu mid-press) would otherwise never get its release,
        // leaving the repeat task spinning for the life of the process.
        .onDisappear {
            stopLeft()
            stopRight()
            stopDown()
        }
    }

    /// No haptic here — the engine fires one for whatever the action actually did,
    /// so buttons that both tap and land a piece don't double up.
    private func iconButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(ink)
                .frame(maxWidth: .infinity, minHeight: 76)
                .background(card)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func pressableButton(_ title: String, onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        HoldButton(title: title, ink: ink, card: card, onPress: onPress, onRelease: onRelease)
    }

    private func startLeft() {
        guard leftTask == nil else { return }
        engine.moveLeft()
        leftTask = Task { [initialDelay, repeatDelay] in
            try? await Task.sleep(nanoseconds: initialDelay)
            while !Task.isCancelled {
                await MainActor.run { engine.moveLeft(haptic: false) }
                try? await Task.sleep(nanoseconds: repeatDelay)
            }
        }
    }
    private func stopLeft() { leftTask?.cancel(); leftTask = nil }

    private func startRight() {
        guard rightTask == nil else { return }
        engine.moveRight()
        rightTask = Task { [initialDelay, repeatDelay] in
            try? await Task.sleep(nanoseconds: initialDelay)
            while !Task.isCancelled {
                await MainActor.run { engine.moveRight(haptic: false) }
                try? await Task.sleep(nanoseconds: repeatDelay)
            }
        }
    }
    private func stopRight() { rightTask?.cancel(); rightTask = nil }

    private func startDown() {
        guard downTask == nil else { return }
        engine.softDrop()
        downTask = Task { [initialDelay, repeatDelay] in
            try? await Task.sleep(nanoseconds: initialDelay)
            while !Task.isCancelled {
                await MainActor.run { engine.softDrop(haptic: false) }
                try? await Task.sleep(nanoseconds: repeatDelay)
            }
        }
    }
    private func stopDown() { downTask?.cancel(); downTask = nil }
}

private struct HoldButton: View {
    let title: String
    let ink: Color
    let card: Color
    let onPress: () -> Void
    let onRelease: () -> Void
    @State private var isHeld: Bool = false

    var body: some View {
        Text(title)
            .font(.system(.title2, design: .rounded).weight(.semibold))
            .foregroundStyle(ink)
            .frame(maxWidth: .infinity, minHeight: 76)
            .background(card.opacity(isHeld ? 0.7 : 1.0))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .contentShape(Rectangle())
            .accessibilityAddTraits(.isButton)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isHeld {
                            isHeld = true
                            onPress()
                        }
                    }
                    .onEnded { _ in
                        if isHeld {
                            isHeld = false
                            onRelease()
                        }
                    }
            )
    }
}
