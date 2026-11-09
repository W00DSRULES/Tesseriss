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

    // MARK: - Daily challenge

    private func date(_ iso: String) -> Date { ISO8601DateFormatter().date(from: iso)! }

    /// The first bag of `dayKey`, in the order the pieces are dealt.
    private func firstBag(_ dayKey: String) -> [PieceKind] {
        var r = DailyChallenge.makeRandomizer(dayKey: dayKey)
        return (0..<7).map { _ in r.next() }
    }

    /// Every day key from `first` to `last`, inclusive.
    private func days(from first: String, to last: String) -> [String] {
        var keys = [last]
        while keys[0] != first { keys.insert(DailyChallenge.previousDayKey(keys[0])!, at: 0) }
        return keys
    }

    func test_dailyDayKey_turnsOverAtMidnightUTC() {
        XCTAssertEqual(DailyChallenge.dayKey(for: date("2026-11-09T23:59:59Z")), "20261109")
        XCTAssertEqual(DailyChallenge.dayKey(for: date("2026-11-10T00:00:00Z")), "20261110")
    }

    func test_dailyDayKey_ignoresTheDeviceTimeZone() {
        let saved = ProcessInfo.processInfo.environment["TZ"]
        defer {
            if let saved { setenv("TZ", saved, 1) } else { unsetenv("TZ") }
            NSTimeZone.resetSystemTimeZone()
        }
        for zone in ["Pacific/Kiritimati", "Pacific/Pago_Pago", "Europe/Istanbul"] {
            setenv("TZ", zone, 1)
            NSTimeZone.resetSystemTimeZone()
            XCTAssertEqual(TimeZone.current.identifier, zone, "precondition: the device zone changed")
            XCTAssertEqual(DailyChallenge.dayKey(for: date("2026-11-09T23:59:59Z")), "20261109", zone)
            XCTAssertEqual(DailyChallenge.dayKey(for: date("2026-11-10T00:00:00Z")), "20261110", zone)
        }
    }

    func test_dailyPreviousDayKey_crossesMonthsYearsAndLeapDays() {
        XCTAssertEqual(DailyChallenge.previousDayKey("20261110"), "20261109")
        XCTAssertEqual(DailyChallenge.previousDayKey("20261201"), "20261130")
        XCTAssertEqual(DailyChallenge.previousDayKey("20270101"), "20261231")
        XCTAssertEqual(DailyChallenge.previousDayKey("20280301"), "20280229")
        for bad in ["", "2026110", "202611090", "abcdefgh", "20261340", "20260230"] {
            XCTAssertNil(DailyChallenge.previousDayKey(bad), "\"\(bad)\" is not a day")
        }
    }

    func test_dailyNextDayStartIsTheNextUTCMidnight() {
        XCTAssertEqual(DailyChallenge.nextDayStart(after: date("2026-11-09T12:00:00Z")), date("2026-11-10T00:00:00Z"))
        XCTAssertEqual(DailyChallenge.nextDayStart(after: date("2026-11-09T00:00:00Z")), date("2026-11-10T00:00:00Z"))
        XCTAssertEqual(DailyChallenge.nextDayStart(after: date("2026-12-31T23:59:59Z")), date("2027-01-01T00:00:00Z"))
    }

    func test_dailyNow_readsTESSERISS_NOW() {
        XCTAssertEqual(DailyChallenge.now(environment: ["TESSERISS_NOW": "2026-11-09T12:00:00Z"]),
                       date("2026-11-09T12:00:00Z"))
        XCTAssertEqual(DailyChallenge.todayKey(environment: ["TESSERISS_NOW": "2026-11-10T00:00:00Z"]), "20261110")
        let envs: [[String: String]] = [[:], ["TESSERISS_NOW": "tomorrow"]]
        for env in envs {
            XCTAssertEqual(DailyChallenge.now(environment: env).timeIntervalSinceNow, 0, accuracy: 5,
                           "falls back to the real time for \(env)")
        }
    }

    func test_dailySameDayDealsTheSameSequence() {
        var a = DailyChallenge.makeRandomizer(dayKey: "20261109")
        var b = DailyChallenge.makeRandomizer(dayKey: "20261109")
        XCTAssertEqual((0..<50).map { _ in a.next() }, (0..<50).map { _ in b.next() })
    }

    func test_dailyConsecutiveDaysDealDifferentFirstBags() {
        let keys = days(from: "20261101", to: "20270131")
        for (yesterday, today) in zip(keys, keys.dropFirst()) {
            XCTAssertNotEqual(firstBag(yesterday), firstBag(today), "\(yesterday) and \(today)")
        }
    }

    /// Seeded with the raw yyyyMMdd integer, every day's first bag ended in I.
    func test_dailyFirstBagDoesNotAlwaysEndInI() {
        let lastPieces = Set(days(from: "20261101", to: "20261130").map { firstBag($0)[6] })
        XCTAssertGreaterThan(lastPieces.count, 1, "the 7th piece is \(lastPieces) every day")
        XCTAssertNotEqual(DailyChallenge.seed(for: "20261109"), 20261109)
    }

    func test_dailyDealsTetrominoesOnlyInSevenBags() {
        var r = DailyChallenge.makeRandomizer(dayKey: "20261109")
        XCTAssertEqual(r.pentominoChance, 0)
        for _ in 0..<100 {
            XCTAssertEqual(Set((0..<7).map { _ in r.next() }), Set(PieceKind.tetrominoes))
        }
    }
}
