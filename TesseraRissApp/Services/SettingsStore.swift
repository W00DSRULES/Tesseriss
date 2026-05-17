import Foundation
import Combine

final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    private let musicKey = "tesserariss.settings.music"
    private let hapticsKey = "tesserariss.settings.haptics"

    @Published var musicEnabled: Bool {
        didSet { defaults.set(musicEnabled, forKey: musicKey) }
    }

    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: hapticsKey) }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if defaults.object(forKey: musicKey) == nil {
            defaults.set(true, forKey: musicKey)
        }
        if defaults.object(forKey: hapticsKey) == nil {
            defaults.set(true, forKey: hapticsKey)
        }
        self.musicEnabled = defaults.bool(forKey: musicKey)
        self.hapticsEnabled = defaults.bool(forKey: hapticsKey)
    }
}
