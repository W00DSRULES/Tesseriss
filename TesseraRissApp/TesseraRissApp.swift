import SwiftUI

@main
struct TesseraRissApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var engine = GameEngine()
    @StateObject private var settings = SettingsStore.shared
    @StateObject private var highscore = HighscoreStore.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(engine)
                .environmentObject(settings)
                .environmentObject(highscore)
                .preferredColorScheme(.light)
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

    var body: some View {
        ZStack {
            Color("PaletteBackground").ignoresSafeArea()
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
