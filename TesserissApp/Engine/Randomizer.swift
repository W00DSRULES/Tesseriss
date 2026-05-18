import Foundation

struct SevenBag {
    private var bag: [PieceKind] = []

    mutating func next() -> PieceKind {
        if bag.isEmpty {
            bag = PieceKind.tetrominoes.shuffled()
        }
        return bag.removeLast()
    }
}

struct PieceRandomizer {
    private var bag = SevenBag()
    let pentominoChance: Double

    init(pentominoChance: Double = 0) {
        self.pentominoChance = max(0, min(1, pentominoChance))
    }

    mutating func next() -> PieceKind {
        if pentominoChance > 0, Double.random(in: 0..<1) < pentominoChance {
            return PieceKind.pentominoes.randomElement() ?? bag.next()
        }
        return bag.next()
    }
}
