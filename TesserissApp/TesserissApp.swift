import SwiftUI

@main
struct TesserissApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var engine: GameEngine
    @StateObject private var settings = SettingsStore.shared
    @StateObject private var highscore = HighscoreStore.shared
    @AppStorage("tesseriss.settings.appearance") private var appearanceRaw: String = AppearanceMode.day.rawValue

    init() {
        let args = ProcessInfo.processInfo.arguments
        let env = ProcessInfo.processInfo.environment
        // UI-test mode: wipe persisted state so each test starts from a known baseline.
        if args.contains("--ui-test"), let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            // Tests start at the menu unless they ask for the onboarding. Saved,
            // not just set, because a relaunch without --ui-test reads it back.
            SettingsStore.shared.hasSeenOnboarding = !args.contains("--show-onboarding")
        }
        // Seeded RNG (UI tests): same seed -> same piece sequence every game.
        let factory: (Double) -> PieceRandomizer
        if let seedStr = env["TESSERISS_RNG_SEED"], let seed = UInt64(seedStr) {
            factory = { chance in
                PieceRandomizer(pentominoChance: chance,
                                rng: SeededRandomNumberGenerator(seed: seed))
            }
        } else {
            factory = { PieceRandomizer(pentominoChance: $0) }
        }
        _engine = StateObject(wrappedValue: GameEngine(randomizerFactory: factory))
    }

    var body: some Scene {
        let appearance = AppearanceMode(rawValue: appearanceRaw) ?? .day
        WindowGroup {
            RootView()
                .environmentObject(engine)
                .environmentObject(settings)
                .environmentObject(highscore)
                .preferredColorScheme(appearance.colorScheme)
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active {
                engine.refreshToday()
            } else {
                engine.autoPauseFromScenePhase()
            }
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var engine: GameEngine
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            settings.activeTheme
                .backgroundView(appearance: settings.appearance)
                .ignoresSafeArea()
            // The onboarding replaces the screen rather than covering it: a
            // screen left on display stays in the accessibility tree (see the
            // comment on GameView's hud). engine.screen doesn't change, so Skip
            // or Done brings back the same screen.
            if settings.hasSeenOnboarding {
                screen.transition(.opacity)
            } else {
                OnboardingView().transition(.opacity)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: settings.hasSeenOnboarding)
    }

    private var screen: some View {
        // Cross-fade instead of a hard cut, which read as a glitch.
        ZStack {
            switch engine.screen {
            case .menu:
                MenuView().transition(.opacity)
            case .game:
                GameView().transition(.opacity)
            case .gameOver:
                GameOverView().transition(.opacity)
            case .settings:
                SettingsView().transition(.opacity)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: engine.screen)
    }
}
