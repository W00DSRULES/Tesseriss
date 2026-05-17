import XCTest
@testable import TesseraRiss

final class RandomizerTests: XCTestCase {
    func test_seven_consecutive_draws_cover_all_pieces() {
        var bag = SevenBag()
        var seen = Set<PieceKind>()
        for _ in 0..<7 {
            seen.insert(bag.next())
        }
        XCTAssertEqual(seen, Set(PieceKind.allCases))
    }

    func test_each_piece_appears_exactly_once_per_bag_over_many_bags() {
        var bag = SevenBag()
        for bagIndex in 0..<200 {
            var seen = Set<PieceKind>()
            for _ in 0..<7 {
                seen.insert(bag.next())
            }
            XCTAssertEqual(seen, Set(PieceKind.allCases),
                           "Bag #\(bagIndex) did not contain all 7 pieces")
        }
    }

    func test_uniform_distribution_over_many_bags() {
        var bag = SevenBag()
        var counts: [PieceKind: Int] = [:]
        let bags = 1000
        for _ in 0..<(bags * 7) {
            counts[bag.next(), default: 0] += 1
        }
        for kind in PieceKind.allCases {
            XCTAssertEqual(counts[kind] ?? 0, bags,
                           "\(kind) should appear exactly \(bags) times in \(bags) bags")
        }
    }

    func test_max_repeat_run_is_bounded() {
        // In a 7-bag, a piece can repeat at most twice in a row across bag boundaries
        // (last of one bag + first of next bag).
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
}
