import Foundation

enum Screen: Equatable {
    case menu
    case game
    case gameOver
    case settings
}

enum PlayPhase: Equatable {
    case playing
    case paused
    case clearing(rows: [Int], isFourLine: Bool)
    case gameOver
}
