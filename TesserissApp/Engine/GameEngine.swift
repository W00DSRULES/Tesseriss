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

    private var randomizer = PieceRandomizer()
    private var timer: Timer?
    private var clearTimer: Timer?
    private var lastTickAt: Date = .distantPast

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
        flashingRows = []
        celebrationActive = false
        screen = .game
        phase = .playing
        spawnNext()
        startTimer()
        audio.startMusicIfEnabled()
    }

    func returnToMenu() {
        stopTimer()
        stopClearTimer()
        audio.stopMusic()
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
        guard screen == .game, phase == .playing else { return }
        phase = .paused
        stopTimer()
        audio.pauseMusic()
    }

    // MARK: - Spawning

    private func spawnNext() {
        guard let kind = nextKind else { return }
        let piece = Tetromino.spawn(kind: kind, boardWidth: board.width, boardHeight: board.height)
        nextKind = randomizer.next()
        if board.collides(piece) {
            current = piece
            triggerGameOver()
            return
        }
        current = piece
    }

    private func triggerGameOver() {
        stopTimer()
        stopClearTimer()
        phase = .gameOver
        screen = .gameOver
        audio.stopMusic()
        haptics.gameOver(enabled: settings.hapticsEnabled)
        highscoreStore.maybeUpdate(score, for: mode)
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

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func stopClearTimer() {
        clearTimer?.invalidate()
        clearTimer = nil
    }

    private func gravityTick() {
        guard phase == .playing, let piece = current else { return }
        let dropped = piece.moved(dx: 0, dy: 1)
        if board.collides(dropped) {
            lockPiece()
        } else {
            current = dropped
        }
    }

    private func restartTimerForCurrentLevel() {
        guard phase == .playing else { return }
        startTimer()
    }

    // MARK: - Input

    func moveLeft()  { tryMove(dx: -1, dy: 0) }
    func moveRight() { tryMove(dx:  1, dy: 0) }

    func softDrop() {
        guard phase == .playing, let piece = current else { return }
        let next = piece.moved(dx: 0, dy: 1)
        if board.collides(next) {
            lockPiece()
        } else {
            current = next
        }
    }

    func rotateCW() {
        guard phase == .playing, let piece = current else { return }
        let rotated = piece.rotated(by: 1)
        if !board.collides(rotated) {
            current = rotated
            haptics.light(enabled: settings.hapticsEnabled)
        }
    }

    func hardDrop() {
        guard phase == .playing, let piece = current else { return }
        var dropped = piece
        while !board.collides(dropped.moved(dx: 0, dy: 1)) {
            dropped = dropped.moved(dx: 0, dy: 1)
        }
        current = dropped
        lockPiece()
    }

    private func tryMove(dx: Int, dy: Int) {
        guard phase == .playing, let piece = current else { return }
        let moved = piece.moved(dx: dx, dy: dy)
        if !board.collides(moved) {
            current = moved
            haptics.light(enabled: settings.hapticsEnabled)
        }
    }

    // MARK: - Lock + clear

    private func lockPiece() {
        guard let piece = current else { return }
        board.lock(piece)
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
            audio.playFourLineChime(enabled: settings.musicEnabled)
            haptics.success(enabled: settings.hapticsEnabled)
        } else {
            audio.playLineClear(enabled: settings.musicEnabled)
            haptics.medium(enabled: settings.hapticsEnabled)
        }

        let pauseSeconds: TimeInterval = isFourLine ? 0.5 : 0.2
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
