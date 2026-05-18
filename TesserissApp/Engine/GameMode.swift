import Foundation

enum GameMode: String, CaseIterable, Identifiable {
    case fast, og, hard

    var id: String { rawValue }

    var boardWidth: Int {
        switch self {
        case .fast: return 8
        case .og, .hard: return 10
        }
    }

    var boardHeight: Int {
        switch self {
        case .fast: return 15
        case .og, .hard: return 20
        }
    }

    var gravityScale: Double {
        switch self {
        case .fast: return 0.5
        case .og, .hard: return 1.0
        }
    }

    var pentominoChance: Double {
        switch self {
        case .hard: return 0.15
        case .fast, .og: return 0
        }
    }

    var highscoreKey: String { "tesseriss.highscore.\(rawValue)" }
}
