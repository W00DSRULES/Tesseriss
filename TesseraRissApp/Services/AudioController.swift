import AVFoundation

final class AudioController: NSObject {
    static let shared = AudioController()

    static let musicTracks: [String] = [
        "01_satie_gymnopedie_1",
        "02_satie_gymnopedie_3",
        "03_satie_gnossienne_1",
        "04_satie_gnossienne_3",
        "05_debussy_clair_de_lune",
        "06_debussy_reverie",
        "07_debussy_arabesque_1",
        "08_ravel_pavane",
    ]

    private static let musicExtensions = ["m4a", "mp3", "wav", "caf", "aiff", "flac"]
    private static let sfxExtensions = ["wav", "caf", "aiff", "m4a"]

    private var musicPlaylist: [URL] = []
    private var musicPlayer: AVAudioPlayer?
    private var currentTrackIndex: Int = 0

    private var lineClearPlayer: AVAudioPlayer?
    private var tetrisPlayer: AVAudioPlayer?
    private var sessionConfigured = false

    private let settings: SettingsStore

    init(settings: SettingsStore = .shared) {
        self.settings = settings
        super.init()
        configureSession()
        loadPlaylist()
        loadSFX()
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

    private func loadPlaylist() {
        musicPlaylist = Self.musicTracks.compactMap { name in
            for ext in Self.musicExtensions {
                if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                    return url
                }
            }
            return nil
        }
    }

    private func loadSFX() {
        lineClearPlayer = makeSFXPlayer(named: "line_clear", volume: 1.0)
        tetrisPlayer = makeSFXPlayer(named: "tetris", volume: 1.0)
    }

    private func makeSFXPlayer(named name: String, volume: Float) -> AVAudioPlayer? {
        for ext in Self.sfxExtensions {
            guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { continue }
            if let player = try? AVAudioPlayer(contentsOf: url) {
                player.numberOfLoops = 0
                player.volume = volume
                player.prepareToPlay()
                return player
            }
        }
        return nil
    }

    private func loadTrack(at index: Int) -> AVAudioPlayer? {
        guard !musicPlaylist.isEmpty else { return nil }
        let i = ((index % musicPlaylist.count) + musicPlaylist.count) % musicPlaylist.count
        let url = musicPlaylist[i]
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return nil }
        player.delegate = self
        player.numberOfLoops = 0
        player.volume = 0.5
        player.prepareToPlay()
        return player
    }

    func startMusicIfEnabled() {
        guard settings.musicEnabled, !musicPlaylist.isEmpty else { return }
        if musicPlayer == nil {
            currentTrackIndex = 0
            musicPlayer = loadTrack(at: currentTrackIndex)
        }
        musicPlayer?.currentTime = 0
        musicPlayer?.play()
    }

    func resumeMusicIfEnabled() {
        guard settings.musicEnabled, let player = musicPlayer else { return }
        if !player.isPlaying { player.play() }
    }

    func pauseMusic() {
        musicPlayer?.pause()
    }

    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer?.currentTime = 0
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

extension AudioController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard player === musicPlayer, flag, !musicPlaylist.isEmpty else { return }
        currentTrackIndex = (currentTrackIndex + 1) % musicPlaylist.count
        musicPlayer = loadTrack(at: currentTrackIndex)
        if settings.musicEnabled {
            musicPlayer?.play()
        }
    }
}
