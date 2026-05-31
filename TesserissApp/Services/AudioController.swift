import AVFoundation

final class AudioController: NSObject {
    static let shared = AudioController()

    private static let musicExtensions = ["m4a", "mp3", "wav", "caf", "aiff", "flac"]
    private static let sfxExtensions = ["wav", "caf", "aiff", "m4a"]

    private var loadedPlaylistID: String?
    private var musicPlaylist: [URL] = []
    private var musicPlayer: AVAudioPlayer?
    private var currentTrackIndex: Int = 0

    private var lineClearPlayer: AVAudioPlayer?
    private var fourLinePlayer: AVAudioPlayer?
    private var sessionConfigured = false

    private let settings: SettingsStore

    init(settings: SettingsStore = .shared) {
        self.settings = settings
        super.init()
        configureSession()
        loadPlaylist(settings.activePlaylist)
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

    private func loadPlaylist(_ playlist: MusicPlaylist) {
        musicPlaylist = playlist.tracks.compactMap { name in
            for ext in Self.musicExtensions {
                if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                    return url
                }
            }
            return nil
        }
        loadedPlaylistID = playlist.id
        currentTrackIndex = 0
    }

    private func reloadIfPlaylistChanged() {
        let current = settings.activePlaylist
        if loadedPlaylistID != current.id {
            stopMusic()
            musicPlayer = nil
            loadPlaylist(current)
        }
    }

    private func loadSFX() {
        lineClearPlayer = makeSFXPlayer(named: "line_clear", volume: 1.0)
        fourLinePlayer = makeSFXPlayer(named: "four_line", volume: 1.0)
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
        player.volume = settings.musicVolume
        player.prepareToPlay()
        return player
    }

    func applyVolume() {
        musicPlayer?.volume = settings.musicVolume
    }

    /// Starts the playlist the first time it's called, then keeps it going across
    /// menu/game transitions: it never rewinds an already-loaded track and only
    /// resumes if paused. Music therefore plays continuously for the life of the
    /// app process and only resets (back to track 1) when the app is relaunched.
    func ensureMusicPlaying() {
        reloadIfPlaylistChanged()
        guard settings.musicEnabled, !musicPlaylist.isEmpty else { return }
        if musicPlayer == nil {
            currentTrackIndex = 0
            musicPlayer = loadTrack(at: currentTrackIndex)
        }
        if musicPlayer?.isPlaying == false {
            musicPlayer?.play()
        }
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

    func playFourLineChime(enabled: Bool) {
        guard enabled, let p = fourLinePlayer else { return }
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
