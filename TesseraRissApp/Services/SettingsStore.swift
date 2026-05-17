import Foundation
import SwiftUI
import Combine

enum AppearanceMode: String, CaseIterable, Identifiable {
    case day, night
    var id: String { rawValue }
    var colorScheme: ColorScheme { self == .day ? .light : .dark }
    var label: String { self == .day ? "Day" : "Night" }
}

final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    private let musicKey = "tesserariss.settings.music"
    private let hapticsKey = "tesserariss.settings.haptics"
    private let appearanceKey = "tesserariss.settings.appearance"

    @Published var musicEnabled: Bool {
        didSet { defaults.set(musicEnabled, forKey: musicKey) }
    }

    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: hapticsKey) }
    }

    @Published var appearance: AppearanceMode {
        didSet { defaults.set(appearance.rawValue, forKey: appearanceKey) }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if defaults.object(forKey: musicKey) == nil { defaults.set(true, forKey: musicKey) }
        if defaults.object(forKey: hapticsKey) == nil { defaults.set(true, forKey: hapticsKey) }
        if defaults.object(forKey: appearanceKey) == nil { defaults.set(AppearanceMode.day.rawValue, forKey: appearanceKey) }
        self.musicEnabled = defaults.bool(forKey: musicKey)
        self.hapticsEnabled = defaults.bool(forKey: hapticsKey)
        let raw = defaults.string(forKey: appearanceKey) ?? AppearanceMode.day.rawValue
        self.appearance = AppearanceMode(rawValue: raw) ?? .day
    }
}
