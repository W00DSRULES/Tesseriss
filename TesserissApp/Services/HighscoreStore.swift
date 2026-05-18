import Foundation
import Combine

final class HighscoreStore: ObservableObject {
    static let shared = HighscoreStore()

    private let key = "tesseriss.highscore"
    @Published private(set) var highscore: Int

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.highscore = defaults.integer(forKey: key)
    }

    private let defaults: UserDefaults

    @discardableResult
    func maybeUpdate(with score: Int) -> Bool {
        if score > highscore {
            highscore = score
            defaults.set(score, forKey: key)
            return true
        }
        return false
    }

    func resetForTesting() {
        highscore = 0
        defaults.removeObject(forKey: key)
    }
}
