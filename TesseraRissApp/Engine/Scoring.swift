import Foundation

enum Scoring {
    static func points(linesCleared n: Int, level: Int) -> Int {
        let multiplier = level + 1
        switch n {
        case 1: return 40 * multiplier
        case 2: return 100 * multiplier
        case 3: return 300 * multiplier
        case 4: return 1200 * multiplier
        default: return 0
        }
    }

    static func gravityInterval(level: Int) -> TimeInterval {
        return Double(gravityMs(level: level)) / 1000.0
    }

    static func gravityMs(level: Int) -> Int {
        if level <= 19 {
            return nesTable[min(max(level, 0), 19)]
        }
        let extra = 13.0 * pow(0.92, Double(level - 19))
        return Int((20.0 + extra).rounded())
    }

    private static let nesTable: [Int] = [
        800, 717, 633, 550, 467, 383, 300, 217, 133, 100,
        83, 83, 83, 67, 67, 67, 50, 50, 50, 33
    ]
}
