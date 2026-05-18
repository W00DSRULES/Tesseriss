import Foundation
import SwiftUI
import Combine

enum AppearanceMode: String, CaseIterable, Identifiable {
    case day, night
    var id: String { rawValue }
    var colorScheme: ColorScheme { self == .day ? .light : .dark }
    var label: String { self == .day ? "Day" : "Night" }
}

enum Language: String, CaseIterable, Identifiable {
    case tr, en
    var id: String { rawValue }
}

final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    private let musicKey = "tesseriss.settings.music"
    private let musicVolumeKey = "tesseriss.settings.musicVolume"
    private let hapticsKey = "tesseriss.settings.haptics"
    private let appearanceKey = "tesseriss.settings.appearance"
    private let languageKey = "tesseriss.settings.language"
    private let ghostKey = "tesseriss.settings.ghost"
    private let playlistKey = "tesseriss.settings.playlist"

    @Published var musicEnabled: Bool {
        didSet { defaults.set(musicEnabled, forKey: musicKey) }
    }

    @Published var musicVolume: Float {
        didSet { defaults.set(musicVolume, forKey: musicVolumeKey) }
    }

    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: hapticsKey) }
    }

    @Published var appearance: AppearanceMode {
        didSet { defaults.set(appearance.rawValue, forKey: appearanceKey) }
    }

    @Published var language: Language {
        didSet { defaults.set(language.rawValue, forKey: languageKey) }
    }

    @Published var ghostEnabled: Bool {
        didSet { defaults.set(ghostEnabled, forKey: ghostKey) }
    }

    @Published var playlistID: String {
        didSet { defaults.set(playlistID, forKey: playlistKey) }
    }

    var activePlaylist: MusicPlaylist { MusicPlaylist.playlist(forID: playlistID) }

    var strings: Strings { Strings.current(for: language) }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if defaults.object(forKey: musicKey) == nil { defaults.set(true, forKey: musicKey) }
        if defaults.object(forKey: musicVolumeKey) == nil { defaults.set(Float(0.5), forKey: musicVolumeKey) }
        if defaults.object(forKey: hapticsKey) == nil { defaults.set(true, forKey: hapticsKey) }
        if defaults.object(forKey: appearanceKey) == nil { defaults.set(AppearanceMode.day.rawValue, forKey: appearanceKey) }
        if defaults.object(forKey: languageKey) == nil { defaults.set(Language.tr.rawValue, forKey: languageKey) }
        if defaults.object(forKey: ghostKey) == nil { defaults.set(true, forKey: ghostKey) }
        if defaults.object(forKey: playlistKey) == nil { defaults.set(MusicPlaylist.impressionists.id, forKey: playlistKey) }
        self.musicEnabled = defaults.bool(forKey: musicKey)
        self.musicVolume = defaults.object(forKey: musicVolumeKey) as? Float ?? 0.5
        self.hapticsEnabled = defaults.bool(forKey: hapticsKey)
        let araw = defaults.string(forKey: appearanceKey) ?? AppearanceMode.day.rawValue
        self.appearance = AppearanceMode(rawValue: araw) ?? .day
        let lraw = defaults.string(forKey: languageKey) ?? Language.tr.rawValue
        self.language = Language(rawValue: lraw) ?? .tr
        self.ghostEnabled = defaults.bool(forKey: ghostKey)
        self.playlistID = defaults.string(forKey: playlistKey) ?? MusicPlaylist.impressionists.id
    }
}
