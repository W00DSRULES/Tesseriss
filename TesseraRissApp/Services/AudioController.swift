import AVFoundation

final class AudioController {
    static let shared = AudioController()

    private var music: AVAudioPlayer?
    private var lineClearPlayer: AVAudioPlayer?
    private var tetrisPlayer: AVAudioPlayer?
    private var sessionConfigured = false

    private let settings: SettingsStore

    init(settings: SettingsStore = .shared) {
        self.settings = settings
        configureSession()
        preload()
    }

    private func configureSession() {
        guard !sessionConfigured else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            sessionConfigured = true
        } catch {
            // Audio session activation can fail in simulator; non-fatal.
        }
    }

    private func preload() {
        music = makePlayer(named: "korobeiniki", ext: "wav", loops: -1, volume: 0.5)
        lineClearPlayer = makePlayer(named: "line_clear", ext: "wav", loops: 0, volume: 1.0)
        tetrisPlayer = makePlayer(named: "tetris", ext: "wav", loops: 0, volume: 1.0)
    }

    private func makePlayer(named name: String, ext: String, loops: Int, volume: Float) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = loops
            player.volume = volume
            player.prepareToPlay()
            return player
        } catch {
            return nil
        }
    }

    func startMusicIfEnabled() {
        guard settings.musicEnabled, let music else { return }
        music.currentTime = 0
        music.play()
    }

    func resumeMusicIfEnabled() {
        guard settings.musicEnabled, let music else { return }
        if !music.isPlaying { music.play() }
    }

    func pauseMusic() {
        music?.pause()
    }

    func stopMusic() {
        music?.stop()
        music?.currentTime = 0
    }

    func playLineClear(enabled: Bool) {
        guard enabled, let p = lineClearPlayer else { return }
        p.currentTime = 0
        p.play()
    }

    func playTetrisChime(enabled: Bool) {
        guard enabled, let p = tetrisPlayer else { return }
        p.currentTime = 0
        p.play()
    }
}
