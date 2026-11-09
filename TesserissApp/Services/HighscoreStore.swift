import Foundation
import Combine

final class HighscoreStore: ObservableObject {
    static let shared = HighscoreStore()

    @Published private(set) var highscores: [GameMode: Int] = [:]

    // Lifetime stats, over every mode.
    @Published private(set) var gamesPlayed: Int
    @Published private(set) var rowsCleared: Int
    @Published private(set) var fourRowClears: Int

    private enum Key {
        static let gamesPlayed = "tesseriss.stats.gamesPlayed"
        static let rowsCleared = "tesseriss.stats.rowsCleared"
        static let fourRowClears = "tesseriss.stats.fourRowClears"
        static let all = [gamesPlayed, rowsCleared, fourRowClears]
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        var loaded: [GameMode: Int] = [:]
        for mode in GameMode.allCases {
            loaded[mode] = defaults.integer(forKey: mode.highscoreKey)
        }
        self.highscores = loaded
        // integer(forKey:) reads a missing or non-numeric value as 0.
        let count = { max(0, defaults.integer(forKey: $0)) }
        self.gamesPlayed = count(Key.gamesPlayed)
        self.rowsCleared = count(Key.rowsCleared)
        self.fourRowClears = count(Key.fourRowClears)
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

    /// Adds one finished run to the lifetime stats.
    func recordGame(rowsCleared rows: Int, fourRowClears fours: Int) {
        gamesPlayed += 1
        rowsCleared += rows
        fourRowClears += fours
        defaults.set(gamesPlayed, forKey: Key.gamesPlayed)
        defaults.set(rowsCleared, forKey: Key.rowsCleared)
        defaults.set(fourRowClears, forKey: Key.fourRowClears)
    }

    func resetForTesting() {
        for mode in GameMode.allCases {
            defaults.removeObject(forKey: mode.highscoreKey)
            highscores[mode] = 0
        }
        for key in Key.all { defaults.removeObject(forKey: key) }
        gamesPlayed = 0
        rowsCleared = 0
        fourRowClears = 0
    }
}
