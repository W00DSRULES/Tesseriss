import SwiftUI

@main
struct TesserissApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var engine = GameEngine()
    @StateObject private var settings = SettingsStore.shared
    @StateObject private var highscore = HighscoreStore.shared
    @AppStorage("tesseriss.settings.appearance") private var appearanceRaw: String = AppearanceMode.day.rawValue

    var body: some Scene {
        let appearance = AppearanceMode(rawValue: appearanceRaw) ?? .day
        WindowGroup {
            RootView()
                .environmentObject(engine)
                .environmentObject(settings)
                .environmentObject(highscore)
                .preferredColorScheme(appearance.colorScheme)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active {
                engine.autoPauseFromScenePhase()
            }
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var engine: GameEngine
    @EnvironmentObject private var settings: SettingsStore

    var body: some View {
        ZStack {
            settings.activeTheme
                .backgroundView(appearance: settings.appearance)
                .ignoresSafeArea()
            switch engine.screen {
            case .menu:
                MenuView()
            case .game:
                GameView()
            case .gameOver:
                GameOverView()
            case .settings:
                SettingsView()
            }
        }
    }
}
