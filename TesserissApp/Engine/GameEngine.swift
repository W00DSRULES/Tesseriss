import Foundation
import SwiftUI
import Combine

final class GameEngine: ObservableObject {
    @Published private(set) var board = Board()
    @Published private(set) var current: Tetromino?
    @Published private(set) var nextKind: PieceKind?
    @Published private(set) var score: Int = 0
    @Published private(set) var lines: Int = 0
    @Published private(set) var level: Int = 0
    @Published private(set) var phase: PlayPhase = .paused
    @Published var screen: Screen = .menu
    @Published private(set) var flashingRows: [Int] = []
    @Published private(set) var celebrationActive: Bool = false
    @Published private(set) var mode: GameMode = .og
    @Published private(set) var isNewHighscore = false

    private var randomizer = PieceRandomizer()
    private var timer: Timer?
    private var clearTimer: Timer?
    private var lastTickAt: Date = .distantPast

    /// Lock delay: a piece that has landed gets a moment to be slid or rotated
    /// before it commits. Bounded resets stop a player stalling forever.
    private var lockTimer: Timer?
    private var lockResets: Int = 0
    static let lockDelay: TimeInterval = 0.5
    static let maxLockResets = 15

    /// Brief deafness to drop input right after a lock, so holding soft-drop
    /// through a lock doesn't immediately slam the piece that spawns next.
    private var inputLockedUntil: Date = .distantPast
    static let postLockInputLockout: TimeInterval = 0.12
    private var acceptsDropInput: Bool { Date() >= inputLockedUntil }

    let audio: AudioController
    let haptics: HapticController
    private let settings: SettingsStore
    private let highscoreStore: HighscoreStore
    private let randomizerFactory: (Double) -> PieceRandomizer

    init(settings: SettingsStore = SettingsStore.shared,
         highscoreStore: HighscoreStore = HighscoreStore.shared,
         audio: AudioController = AudioController.shared,
         haptics: HapticController = HapticController.shared,
         randomizerFactory: @escaping (Double) -> PieceRandomizer = { PieceRandomizer(pentominoChance: $0) }) {
        self.settings = settings
        self.highscoreStore = highscoreStore
        self.audio = audio
        self.haptics = haptics
        self.randomizerFactory = randomizerFactory
    }

    var highscore: Int { highscoreStore.highscore(for: mode) }

    var ghostPiece: Tetromino? {
        guard phase == .playing, let piece = current else { return nil }
        var ghost = piece
        while !board.collides(ghost.moved(dx: 0, dy: 1)) {
            ghost = ghost.moved(dx: 0, dy: 1)
        }
        guard ghost.origin.y != piece.origin.y else { return nil }
        return ghost
    }

    // MARK: - Lifecycle

    func startNewGame(mode: GameMode = .og) {
        stopTimer()
        stopClearTimer()
        self.mode = mode
        board = Board(width: mode.boardWidth, height: mode.boardHeight)
        score = 0
        lines = 0
        level = 0
        randomizer = randomizerFactory(mode.pentominoChance)
        nextKind = randomizer.next()
        applyTetrisSetupIfRequested()
        flashingRows = []
        celebrationActive = false
        isNewHighscore = false
        screen = .game
        phase = .playing
        spawnNext()
        startTimer()
        audio.ensureMusicPlaying()
    }

    /// Screenshot hook (UI tests only): TESSERISS_TETRIS_SETUP prefills the
    /// bottom four rows with a one-column gap on the right and deals an I
    /// piece, so the screenshot test can trigger a four-line clear on demand.
    private func applyTetrisSetupIfRequested() {
        guard ProcessInfo.processInfo.environment["TESSERISS_TETRIS_SETUP"] != nil else { return }
        let fillKinds: [PieceKind] = [.J, .L, .S, .Z, .O, .T]
        for (i, y) in ((board.height - 4)..<board.height).enumerated() {
            for x in 0..<(board.width - 1) {
                board.grid[y][x] = fillKinds[(x + i) % fillKinds.count]
            }
        }
        nextKind = .I
    }

    func returnToMenu() {
        stopTimer()
        stopClearTimer()
        // Quitting counts as finishing the run, so its score can still be a best.
        highscoreStore.maybeUpdate(score, for: mode)
        // Music keeps playing across the menu (resumes if it was paused), so it
        // stays continuous when bouncing between the menu and a game.
        audio.resumeMusicIfEnabled()
        screen = .menu
        phase = .paused
    }

    func openSettings() { screen = .settings }
    func closeSettings() { screen = .menu }

    func togglePause() {
        guard screen == .game else { return }
        switch phase {
        case .playing:
            phase = .paused
            stopTimer()
            audio.pauseMusic()
        case .paused:
            phase = .playing
            startTimer()
            audio.resumeMusicIfEnabled()
        default:
            return
        }
    }

    func autoPauseFromScenePhase() {
        guard screen == .game else { return }
        // A clear still flashing would finish on its timer and resume play
        // while the app is inactive; settle it now so the pause below sticks.
        if case let .clearing(rows, _) = phase {
            stopClearTimer()
            completeClearAnimation(rows: rows)
        }
        guard phase == .playing else { return }
        phase = .paused
        stopTimer()
        audio.pauseMusic()
    }

    // MARK: - Spawning

    private func spawnNext() {
        guard let kind = nextKind else { return }
        let spawned = Tetromino.spawn(kind: kind, boardWidth: board.width, boardHeight: board.height)
        nextKind = randomizer.next()
        stopLockTimer()
        lockResets = 0

        // A blocked spawn may be nudged up, but only until its bottom row sits on
        // row 0. Board.collides treats rows above the board as empty, so a piece
        // lifted any higher always fits and the top-out below could never fire.
        // Those rows aren't stored either: lockPiece ends the game if cells lock there.
        let local = Tetromino.cells(kind: kind, rotation: 0)
        let pieceHeight = (local.map(\.y).max() ?? 0) - (local.map(\.y).min() ?? 0) + 1
        var piece = spawned
        var lift = 0
        while board.collides(piece), lift < pieceHeight - 1 {
            lift += 1
            piece = spawned.moved(dx: 0, dy: -lift)
        }
        current = piece
        if board.collides(piece) {
            triggerGameOver()
        }
    }

    private func triggerGameOver() {
        stopTimer()
        stopClearTimer()
        phase = .gameOver
        screen = .gameOver
        // Leave music playing on the game-over screen for continuity.
        haptics.gameOver(enabled: settings.hapticsEnabled)
        isNewHighscore = highscoreStore.maybeUpdate(score, for: mode)
    }

    // MARK: - Timer

    private func startTimer() {
        stopTimer()
        let interval = Scoring.gravityInterval(level: level) * mode.gravityScale
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.gravityTick()
        }
        lastTickAt = Date()
    }

    /// Also drops any pending lock delay — every caller (pause, menu, game over,
    /// line clear, level change) wants the landed piece's grace period to end too.
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        stopLockTimer()
    }

    private func stopClearTimer() {
        clearTimer?.invalidate()
        clearTimer = nil
    }

    private func gravityTick() {
        guard phase == .playing, let piece = current else { return }
        let dropped = piece.moved(dx: 0, dy: 1)
        if board.collides(dropped) {
            updateLockDelay(playerMoved: false)
        } else {
            current = dropped
            stopLockTimer()
            lockResets = 0
        }
    }

    private func restartTimerForCurrentLevel() {
        guard phase == .playing else { return }
        startTimer()
    }

    // MARK: - Input

    /// `haptic: false` is passed by the controls' auto-repeat, so holding a
    /// direction taps once on press instead of buzzing ~20 times a second.
    func moveLeft(haptic: Bool = true)  { tryMove(dx: -1, dy: 0, haptic: haptic) }
    func moveRight(haptic: Bool = true) { tryMove(dx:  1, dy: 0, haptic: haptic) }

    func softDrop(haptic: Bool = true) {
        guard phase == .playing, acceptsDropInput, let piece = current else { return }
        let next = piece.moved(dx: 0, dy: 1)
        if board.collides(next) {
            // Resting: let the lock delay decide, rather than committing here.
            updateLockDelay(playerMoved: false)
        } else {
            current = next
            if haptic { haptics.light(enabled: settings.hapticsEnabled) }
            updateLockDelay(playerMoved: false)
        }
    }

    func rotateCW()  { rotate(by:  1) }
    func rotateCCW() { rotate(by: -1) }

    private func rotate(by delta: Int) {
        guard phase == .playing, let piece = current else { return }
        guard let result = Tetromino.rotatedWithKick(piece, by: delta, in: board) else { return }
        current = result.piece
        let kicked = result.kick != GridPoint(x: 0, y: 0)
        if kicked {
            haptics.soft(enabled: settings.hapticsEnabled)
        } else {
            haptics.light(enabled: settings.hapticsEnabled)
        }
        updateLockDelay(playerMoved: true)
    }

    func hardDrop() {
        guard phase == .playing, acceptsDropInput, let piece = current else { return }
        var dropped = piece
        while !board.collides(dropped.moved(dx: 0, dy: 1)) {
            dropped = dropped.moved(dx: 0, dy: 1)
        }
        current = dropped
        lockPiece()
    }

    private func tryMove(dx: Int, dy: Int, haptic: Bool = true) {
        guard phase == .playing, let piece = current else { return }
        let moved = piece.moved(dx: dx, dy: dy)
        if !board.collides(moved) {
            current = moved
            if haptic { haptics.light(enabled: settings.hapticsEnabled) }
            updateLockDelay(playerMoved: true)
        }
    }

    // MARK: - Lock delay

    /// Keeps the lock timer in step with the piece: arm it once the piece is
    /// resting, reset it when the player nudges a resting piece (bounded by
    /// `maxLockResets`), cancel it when the piece is free to fall again.
    private func updateLockDelay(playerMoved: Bool) {
        guard phase == .playing, let piece = current else {
            stopLockTimer()
            return
        }
        guard board.collides(piece.moved(dx: 0, dy: 1)) else {
            stopLockTimer()
            lockResets = 0
            return
        }
        if lockTimer == nil {
            armLockTimer()
        } else if playerMoved, lockResets < Self.maxLockResets {
            lockResets += 1
            armLockTimer()
        }
    }

    private func armLockTimer() {
        lockTimer?.invalidate()
        lockTimer = Timer.scheduledTimer(withTimeInterval: Self.lockDelay, repeats: false) { [weak self] _ in
            self?.lockDelayElapsed()
        }
    }

    private func lockDelayElapsed() {
        stopLockTimer()
        guard phase == .playing, let piece = current else { return }
        // Still resting? Commit. Otherwise gravity has more work to do.
        if board.collides(piece.moved(dx: 0, dy: 1)) {
            lockPiece()
        }
    }

    private func stopLockTimer() {
        lockTimer?.invalidate()
        lockTimer = nil
    }

    // MARK: - Lock + clear

    private func lockPiece() {
        guard let piece = current else { return }
        stopLockTimer()
        lockResets = 0
        inputLockedUntil = Date().addingTimeInterval(Self.postLockInputLockout)
        board.lock(piece)
        // Lock-out: the board keeps no rows above 0, so cells locked there would
        // vanish. The stack has topped out.
        if piece.cells.contains(where: { $0.y < 0 }) {
            triggerGameOver()
            return
        }
        haptics.medium(enabled: settings.hapticsEnabled)
        let rows = board.fullRows()
        if rows.isEmpty {
            current = nil
            spawnNext()
            return
        }
        let isFourLine = rows.count == 4
        beginClearAnimation(rows: rows, isFourLine: isFourLine)
    }

    private func beginClearAnimation(rows: [Int], isFourLine: Bool) {
        stopTimer()
        current = nil
        flashingRows = rows
        celebrationActive = isFourLine
        phase = .clearing(rows: rows, isFourLine: isFourLine)

        if isFourLine {
            audio.playFourLineChime(enabled: settings.sfxEnabled)
            haptics.success(enabled: settings.hapticsEnabled)
        } else {
            audio.playLineClear(enabled: settings.sfxEnabled)
            haptics.medium(enabled: settings.hapticsEnabled)
        }

        // TESSERISS_CLEAR_PAUSE (UI tests only) stretches the flash so the
        // screenshot test can capture it.
        let pauseSeconds = ProcessInfo.processInfo.environment["TESSERISS_CLEAR_PAUSE"]
            .flatMap(TimeInterval.init) ?? (isFourLine ? 0.5 : 0.2)
        clearTimer = Timer.scheduledTimer(withTimeInterval: pauseSeconds, repeats: false) { [weak self] _ in
            self?.completeClearAnimation(rows: rows)
        }
    }

    private func completeClearAnimation(rows: [Int]) {
        let count = rows.count
        board.clearRows(rows)
        score += Scoring.points(linesCleared: count, level: level)
        let prevLevel = level
        lines += count
        level = lines / 10
        flashingRows = []
        celebrationActive = false
        phase = .playing
        spawnNext()
        if level != prevLevel {
            restartTimerForCurrentLevel()
        } else {
            startTimer()
        }
    }
}
