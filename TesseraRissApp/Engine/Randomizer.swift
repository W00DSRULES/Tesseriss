import Foundation

struct SevenBag {
    private var bag: [PieceKind] = []

    mutating func next() -> PieceKind {
        if bag.isEmpty {
            bag = PieceKind.allCases.shuffled()
        }
        return bag.removeLast()
    }
}
