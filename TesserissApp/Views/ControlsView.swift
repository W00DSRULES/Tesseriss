import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var settings: SettingsStore

    @State private var leftTask: Task<Void, Never>?
    @State private var rightTask: Task<Void, Never>?
    @State private var downTask: Task<Void, Never>?

    private let initialDelay: UInt64 = 270_000_000
    private let repeatDelay: UInt64 = 50_000_000

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
    }

    private func iconButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            engine.haptics.light(enabled: settings.hapticsEnabled)
            action()
        }) {
            Image(systemName: systemName)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color("PaletteInk"))
                .frame(maxWidth: .infinity, minHeight: 76)
                .background(Color("PaletteCard"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func pressableButton(_ title: String, onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        HoldButton(title: title, onPress: onPress, onRelease: onRelease)
    }

    private func startLeft() {
        guard leftTask == nil else { return }
        engine.moveLeft()
        leftTask = Task { [initialDelay, repeatDelay] in
            try? await Task.sleep(nanoseconds: initialDelay)
            while !Task.isCancelled {
                await MainActor.run { engine.moveLeft() }
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
                await MainActor.run { engine.moveRight() }
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
                await MainActor.run { engine.softDrop() }
                try? await Task.sleep(nanoseconds: repeatDelay)
            }
        }
    }
    private func stopDown() { downTask?.cancel(); downTask = nil }
}

private struct HoldButton: View {
    let title: String
    let onPress: () -> Void
    let onRelease: () -> Void
    @State private var isHeld: Bool = false

    var body: some View {
        Text(title)
            .font(.system(.title2, design: .rounded).weight(.semibold))
            .foregroundStyle(Color("PaletteInk"))
            .frame(maxWidth: .infinity, minHeight: 76)
            .background(Color("PaletteCard").opacity(isHeld ? 0.7 : 1.0))
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
