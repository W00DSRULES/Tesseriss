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

/// The Daily Challenge: one piece sequence per UTC day, the same for every player.
enum DailyChallenge {
    private static let utcCalendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }()

    /// TESSERISS_NOW (ISO 8601, UI tests only) fixes the clock; otherwise the real time.
    static func now(environment: [String: String] = ProcessInfo.processInfo.environment) -> Date {
        environment["TESSERISS_NOW"].flatMap { ISO8601DateFormatter().date(from: $0) } ?? Date()
    }

    /// yyyyMMdd of `date` in UTC, whatever the device's calendar, locale or time zone.
    static func dayKey(for date: Date) -> String {
        let c = utcCalendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d%02d%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    /// Today's key, honouring TESSERISS_NOW.
    static func todayKey(environment: [String: String] = ProcessInfo.processInfo.environment) -> String {
        dayKey(for: now(environment: environment))
    }

    /// 00:00 UTC of the day after `date`.
    static func nextDayStart(after date: Date) -> Date {
        utcCalendar.date(byAdding: .day, value: 1, to: utcCalendar.startOfDay(for: date))!
    }

    /// The key of the day before `dayKey`, or nil if `dayKey` isn't a valid yyyyMMdd date.
    static func previousDayKey(_ dayKey: String) -> String? {
        guard dayKey.count == 8, let n = Int(dayKey) else { return nil }
        let parts = DateComponents(year: n / 10000, month: n / 100 % 100, day: n % 100)
        guard parts.isValidDate(in: utcCalendar),
              let date = utcCalendar.date(from: parts),
              let previous = utcCalendar.date(byAdding: .day, value: -1, to: date) else { return nil }
        return self.dayKey(for: previous)
    }

    /// splitmix64 of the yyyyMMdd integer. Seeded with the raw date, a small
    /// number, xorshift dealt I as the 7th piece of the first bag every day.
    static func seed(for dayKey: String) -> UInt64 {
        var z = (UInt64(dayKey) ?? 0) &+ 0x9E37_79B9_7F4A_7C15
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    /// Tear rules: tetrominoes only, from a 7-bag seeded by the day.
    static func makeRandomizer(dayKey: String) -> PieceRandomizer {
        PieceRandomizer(pentominoChance: 0, rng: SeededRandomNumberGenerator(seed: seed(for: dayKey)))
    }
}
