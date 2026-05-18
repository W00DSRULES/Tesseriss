import Foundation
import Combine

final class HighscoreStore: ObservableObject {
    static let shared = HighscoreStore()

    @Published private(set) var highscores: [GameMode: Int] = [:]

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        var loaded: [GameMode: Int] = [:]
        for mode in GameMode.allCases {
            loaded[mode] = defaults.integer(forKey: mode.highscoreKey)
        }
        self.highscores = loaded
    }

    func highscore(for mode: GameMode) -> Int { highscores[mode] ?? 0 }

    @discardableResult
    func maybeUpdate(_ score: Int, for mode: GameMode) -> Bool {
        let current = highscore(for: mode)
        if score > current {
            highscores[mode] = score
            defaults.set(score, forKey: mode.highscoreKey)
            return true
        }
        return false
    }

    func resetForTesting() {
        for mode in GameMode.allCases {
            defaults.removeObject(forKey: mode.highscoreKey)
            highscores[mode] = 0
        }
    }
}
