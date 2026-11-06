import XCTest
@testable import Tesseriss

final class SettingsStoreTests: XCTestCase {
    // MARK: - Language.deviceDefault

    func testDeviceDefaultTurkishDevice() {
        XCTAssertEqual(Language.deviceDefault(preferredLanguages: ["tr-TR", "en-US"]), .tr)
        XCTAssertEqual(Language.deviceDefault(preferredLanguages: ["tr"]), .tr)
    }

    func testDeviceDefaultNonTurkishDevice() {
        XCTAssertEqual(Language.deviceDefault(preferredLanguages: ["en-US", "tr-TR"]), .en)
        XCTAssertEqual(Language.deviceDefault(preferredLanguages: ["de-DE"]), .en)
        XCTAssertEqual(Language.deviceDefault(preferredLanguages: []), .en)
    }

    func testFirstLaunchUsesDeviceDefault() {
        let suiteName = "test.tesseriss.firstlaunch"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let store = SettingsStore(defaults: defaults)
        XCTAssertEqual(store.language, Language.deviceDefault())

        defaults.removePersistentDomain(forName: suiteName)
    }

    func testStoredLanguageChoicePersists() {
        let suiteName = "test.tesseriss.storedlang"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set(Language.tr.rawValue, forKey: "tesseriss.settings.language")

        let store = SettingsStore(defaults: defaults)
        XCTAssertEqual(store.language, .tr)

        defaults.removePersistentDomain(forName: suiteName)
    }

    // MARK: - Sound effects

    func testSfxEnabledDefaultsOnAndIsIndependentOfMusic() {
        let suiteName = "test.tesseriss.sfx"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let store = SettingsStore(defaults: defaults)
        XCTAssertTrue(store.sfxEnabled)

        store.musicEnabled = false
        XCTAssertTrue(store.sfxEnabled, "Turning music off must not turn sound effects off")

        let reloaded = SettingsStore(defaults: defaults)
        XCTAssertFalse(reloaded.musicEnabled)
        XCTAssertTrue(reloaded.sfxEnabled)

        reloaded.musicEnabled = true
        reloaded.sfxEnabled = false
        let reloadedAgain = SettingsStore(defaults: defaults)
        XCTAssertTrue(reloadedAgain.musicEnabled)
        XCTAssertFalse(reloadedAgain.sfxEnabled)

        defaults.removePersistentDomain(forName: suiteName)
    }

    // MARK: - Strings

    func testSettingsLabelsHaveNoEmoji() {
        // SettingsView adds the emoji; the strings stay plain because VoiceOver reads them.
        for s in [Strings.tr, Strings.en] {
            let labels = [s.musicLabel, s.sfxLabel, s.hapticsLabel, s.dayLabel, s.nightLabel,
                          s.languageLabel, s.ghostLabel, s.volumeLabel, s.playlistLabel,
                          s.appearanceLabel, s.themeStyleLabel]
            for label in labels {
                XCTAssertTrue(label.unicodeScalars.allSatisfy { !$0.properties.isEmojiPresentation && $0 != "\u{FE0F}" },
                              "\"\(label)\" contains an emoji")
            }
        }
    }
}
