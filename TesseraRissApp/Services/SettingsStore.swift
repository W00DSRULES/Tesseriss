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

    private let musicKey = "tesserariss.settings.music"
    private let hapticsKey = "tesserariss.settings.haptics"
    private let appearanceKey = "tesserariss.settings.appearance"
    private let languageKey = "tesserariss.settings.language"
    private let ghostKey = "tesserariss.settings.ghost"

    @Published var musicEnabled: Bool {
        didSet { defaults.set(musicEnabled, forKey: musicKey) }
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

    var strings: Strings { Strings.current(for: language) }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if defaults.object(forKey: musicKey) == nil { defaults.set(true, forKey: musicKey) }
        if defaults.object(forKey: hapticsKey) == nil { defaults.set(true, forKey: hapticsKey) }
        if defaults.object(forKey: appearanceKey) == nil { defaults.set(AppearanceMode.day.rawValue, forKey: appearanceKey) }
        if defaults.object(forKey: languageKey) == nil { defaults.set(Language.tr.rawValue, forKey: languageKey) }
        if defaults.object(forKey: ghostKey) == nil { defaults.set(true, forKey: ghostKey) }
        self.musicEnabled = defaults.bool(forKey: musicKey)
        self.hapticsEnabled = defaults.bool(forKey: hapticsKey)
        let araw = defaults.string(forKey: appearanceKey) ?? AppearanceMode.day.rawValue
        self.appearance = AppearanceMode(rawValue: araw) ?? .day
        let lraw = defaults.string(forKey: languageKey) ?? Language.tr.rawValue
        self.language = Language(rawValue: lraw) ?? .tr
        self.ghostEnabled = defaults.bool(forKey: ghostKey)
    }
}
