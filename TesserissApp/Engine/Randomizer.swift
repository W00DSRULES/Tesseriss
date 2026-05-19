import Foundation

/// Class-based seedable RNG so tests can produce identical piece sequences
/// across runs. xorshift64 — fast, deterministic, no external dependencies.
final class SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 0xDEADBEEF : seed }
    func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

/// Class-backed system RNG wrapper so PieceRandomizer can hold a single
/// `any RandomNumberGenerator` existential regardless of source.
final class SystemRNGWrapper: RandomNumberGenerator {
    private var sys = SystemRandomNumberGenerator()
    func next() -> UInt64 { sys.next() }
}

struct SevenBag {
    private var bag: [PieceKind] = []

    mutating func next() -> PieceKind {
        var sys = SystemRandomNumberGenerator()
        return next(using: &sys)
    }

    mutating func next<G: RandomNumberGenerator>(using gen: inout G) -> PieceKind {
        if bag.isEmpty {
            bag = PieceKind.tetrominoes.shuffled(using: &gen)
        }
        return bag.removeLast()
    }
}

struct PieceRandomizer {
    private var bag = SevenBag()
    private let rng: any RandomNumberGenerator
    let pentominoChance: Double

    init(pentominoChance: Double = 0,
         rng: any RandomNumberGenerator = SystemRNGWrapper()) {
        self.pentominoChance = max(0, min(1, pentominoChance))
        self.rng = rng
    }

    mutating func next() -> PieceKind {
        var local = rng  // class-backed existential: shares state with self.rng
        if pentominoChance > 0, Double.random(in: 0..<1, using: &local) < pentominoChance {
            return PieceKind.pentominoes.randomElement(using: &local) ?? bag.next(using: &local)
        }
        return bag.next(using: &local)
    }
}
