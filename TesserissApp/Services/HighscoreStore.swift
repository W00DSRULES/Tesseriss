import Foundation
import Combine

final class HighscoreStore: ObservableObject {
    static let shared = HighscoreStore()

    @Published private(set) var highscores: [GameMode: Int] = [:]

    // Lifetime stats, over every mode and the daily challenge.
    @Published private(set) var gamesPlayed: Int
    @Published private(set) var rowsCleared: Int
    @Published private(set) var fourRowClears: Int

    // Daily challenge. Read the best through dailyBest(for:) and the streak
    // through currentStreak(today:): both depend on the day they are read.
    @Published private(set) var dailyBestScore: Int
    @Published private(set) var dailyBestDay: String?
    @Published private(set) var dailyStreak: Int
    @Published private(set) var longestDailyStreak: Int
    @Published private(set) var lastDailyDay: String?

    private enum Key {
        static let gamesPlayed = "tesseriss.stats.gamesPlayed"
        static let rowsCleared = "tesseriss.stats.rowsCleared"
        static let fourRowClears = "tesseriss.stats.fourRowClears"
        static let dailyBestScore = "tesseriss.daily.bestScore"
        static let dailyBestDay = "tesseriss.daily.bestDay"
        static let dailyStreak = "tesseriss.daily.streak"
        static let longestDailyStreak = "tesseriss.daily.longestStreak"
        static let lastDailyDay = "tesseriss.daily.lastDay"
        static let all = [gamesPlayed, rowsCleared, fourRowClears, dailyBestScore,
                          dailyBestDay, dailyStreak, longestDailyStreak, lastDailyDay]
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
        self.dailyBestScore = count(Key.dailyBestScore)
        self.dailyBestDay = defaults.string(forKey: Key.dailyBestDay)
        self.dailyStreak = count(Key.dailyStreak)
        self.longestDailyStreak = count(Key.longestDailyStreak)
        self.lastDailyDay = defaults.string(forKey: Key.lastDailyDay)
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

    /// The best daily score for `dayKey`; a best kept from another day reads as 0.
    func dailyBest(for dayKey: String) -> Int {
        dailyBestDay == dayKey ? dailyBestScore : 0
    }

    /// The streak to show on `today`: it lapses once a whole day goes unplayed.
    func currentStreak(today: String) -> Int {
        guard let last = lastDailyDay,
              last == today || last == DailyChallenge.previousDayKey(today) else { return 0 }
        return dailyStreak
    }

    /// Records a finished daily run for `dayKey`. Returns true if the score
    /// beats that day's best. A day earlier than the last one played is ignored.
    @discardableResult
    func recordDaily(score: Int, dayKey: String) -> Bool {
        // A day before the last one played (the clock was set back) would reset
        // the streak and overwrite the later best. Valid yyyyMMdd keys compare
        // as text; a corrupt last day is ignored and starts a new streak below.
        if let last = lastDailyDay, DailyChallenge.previousDayKey(last) != nil, dayKey < last {
            return false
        }
        if lastDailyDay != dayKey {
            dailyStreak = lastDailyDay != nil && lastDailyDay == DailyChallenge.previousDayKey(dayKey)
                ? dailyStreak + 1 : 1
            lastDailyDay = dayKey
            longestDailyStreak = max(longestDailyStreak, dailyStreak)
            defaults.set(dailyStreak, forKey: Key.dailyStreak)
            defaults.set(longestDailyStreak, forKey: Key.longestDailyStreak)
            defaults.set(dayKey, forKey: Key.lastDailyDay)
        }
        guard score > dailyBest(for: dayKey) else { return false }
        dailyBestScore = score
        dailyBestDay = dayKey
        defaults.set(score, forKey: Key.dailyBestScore)
        defaults.set(dayKey, forKey: Key.dailyBestDay)
        return true
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
        dailyBestScore = 0
        dailyBestDay = nil
        dailyStreak = 0
        longestDailyStreak = 0
        lastDailyDay = nil
    }
}
