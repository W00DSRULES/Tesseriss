import XCTest
@testable import Tesseriss

final class RandomizerTests: XCTestCase {
    func test_seven_consecutive_draws_cover_all_tetrominoes() {
        var bag = SevenBag()
        var seen = Set<PieceKind>()
        for _ in 0..<7 {
            seen.insert(bag.next())
        }
        XCTAssertEqual(seen, Set(PieceKind.tetrominoes))
    }

    func test_each_piece_appears_exactly_once_per_bag_over_many_bags() {
        var bag = SevenBag()
        for bagIndex in 0..<200 {
            var seen = Set<PieceKind>()
            for _ in 0..<7 {
                seen.insert(bag.next())
            }
            XCTAssertEqual(seen, Set(PieceKind.tetrominoes),
                           "Bag #\(bagIndex) did not contain all 7 tetrominoes")
        }
    }

    func test_uniform_distribution_over_many_bags() {
        var bag = SevenBag()
        var counts: [PieceKind: Int] = [:]
        let bags = 1000
        for _ in 0..<(bags * 7) {
            counts[bag.next(), default: 0] += 1
        }
        for kind in PieceKind.tetrominoes {
            XCTAssertEqual(counts[kind] ?? 0, bags,
                           "\(kind) should appear exactly \(bags) times in \(bags) bags")
        }
    }

    func test_max_repeat_run_is_bounded() {
        var bag = SevenBag()
        var previous: PieceKind?
        var runLength = 1
        var maxRun = 1
        for _ in 0..<14_000 {
            let next = bag.next()
            if next == previous {
                runLength += 1
                maxRun = max(maxRun, runLength)
            } else {
                runLength = 1
            }
            previous = next
        }
        XCTAssertLessThanOrEqual(maxRun, 2)
    }

    func test_piece_randomizer_with_zero_pentomino_chance_never_spawns_pentominoes() {
        var rng = PieceRandomizer(pentominoChance: 0)
        for _ in 0..<1000 {
            let kind = rng.next()
            XCTAssertTrue(PieceKind.tetrominoes.contains(kind),
                          "Should never spawn \(kind) when chance is 0")
        }
    }

    func test_piece_randomizer_with_full_pentomino_chance_always_spawns_pentominoes() {
        var rng = PieceRandomizer(pentominoChance: 1)
        for _ in 0..<500 {
            let kind = rng.next()
            XCTAssertTrue(PieceKind.pentominoes.contains(kind),
                          "Should always spawn pentomino when chance is 1, got \(kind)")
        }
    }

    func test_same_seed_produces_identical_piece_sequence() {
        var a = PieceRandomizer(rng: SeededRandomNumberGenerator(seed: 1337))
        var b = PieceRandomizer(rng: SeededRandomNumberGenerator(seed: 1337))
        let aSeq = (0..<100).map { _ in a.next() }
        let bSeq = (0..<100).map { _ in b.next() }
        XCTAssertEqual(aSeq, bSeq, "Same seed must produce identical sequences")
    }

    func test_different_seeds_diverge() {
        var a = PieceRandomizer(rng: SeededRandomNumberGenerator(seed: 1))
        var b = PieceRandomizer(rng: SeededRandomNumberGenerator(seed: 2))
        let aSeq = (0..<50).map { _ in a.next() }
        let bSeq = (0..<50).map { _ in b.next() }
        XCTAssertNotEqual(aSeq, bSeq, "Different seeds should diverge within 50 draws")
    }
}
