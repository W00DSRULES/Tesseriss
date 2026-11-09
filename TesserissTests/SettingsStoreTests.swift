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

    func testSfxVolumeDefaultsToHalfOnFreshInstall() {
        let suiteName = "test.tesseriss.sfxvolume.fresh"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let store = SettingsStore(defaults: defaults)
        XCTAssertEqual(store.sfxVolume, 0.5)
        XCTAssertEqual(store.musicVolume, 0.5)

        defaults.removePersistentDomain(forName: suiteName)
    }

    /// Music volume was the only volume setting before 1.1.1: sound effects start at that level.
    func testSfxVolumeStartsAtTheStoredMusicVolume() {
        let suiteName = "test.tesseriss.sfxvolume.migrate"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set(Float(0.25), forKey: "tesseriss.settings.musicVolume")

        let store = SettingsStore(defaults: defaults)
        XCTAssertEqual(store.musicVolume, 0.25)
        XCTAssertEqual(store.sfxVolume, 0.25)

        // Copied once: later music changes don't follow into sound effects.
        store.musicVolume = 0.75
        XCTAssertEqual(SettingsStore(defaults: defaults).sfxVolume, 0.25)

        defaults.removePersistentDomain(forName: suiteName)
    }

    func testSfxVolumePersistsAndIsIndependentOfMusicVolume() {
        let suiteName = "test.tesseriss.sfxvolume"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let store = SettingsStore(defaults: defaults)
        store.sfxVolume = 0.125
        XCTAssertEqual(store.musicVolume, 0.5, "Moving the sound effects slider must not move music")
        store.musicVolume = 0.875
        XCTAssertEqual(store.sfxVolume, 0.125, "Moving the music slider must not move sound effects")

        let reloaded = SettingsStore(defaults: defaults)
        XCTAssertEqual(reloaded.sfxVolume, 0.125)
        XCTAssertEqual(reloaded.musicVolume, 0.875)

        defaults.removePersistentDomain(forName: suiteName)
    }

    // MARK: - Corrupt stored values

    func testCorruptStoredValuesFallBackToDefaults() {
        let suiteName = "test.tesseriss.corrupt"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set("not-a-mode", forKey: "tesseriss.settings.appearance")
        defaults.set("xx", forKey: "tesseriss.settings.language")
        defaults.set("nope", forKey: "tesseriss.settings.themeKind")
        defaults.set("zzz", forKey: "tesseriss.settings.selectedMode")
        defaults.set("not-float", forKey: "tesseriss.settings.musicVolume")
        defaults.set("bogus", forKey: "tesseriss.settings.playlist")

        let store = SettingsStore(defaults: defaults)
        XCTAssertEqual(store.appearance, .day)
        XCTAssertEqual(store.language, Language.deviceDefault())
        XCTAssertEqual(store.themeKind, .classic)
        XCTAssertEqual(store.selectedMode, .og)
        XCTAssertEqual(store.musicVolume, 0.5)
        XCTAssertEqual(store.sfxVolume, 0.5, "Sound effects start at the music volume, which failed to load")
        XCTAssertEqual(MusicPlaylist.playlist(forID: store.playlistID).id, MusicPlaylist.impressionists.id)

        defaults.removePersistentDomain(forName: suiteName)
    }

    // MARK: - Strings

    func testVoiceOverAnnouncements() {
        XCTAssertEqual(Strings.en.clearAnnouncement(rows: 1, newLevel: nil), "1 row cleared")
        XCTAssertEqual(Strings.en.clearAnnouncement(rows: 4, newLevel: 2), "4 rows cleared, Level 2")
        XCTAssertEqual(Strings.tr.clearAnnouncement(rows: 1, newLevel: nil), "1 sıra temizlendi")
        XCTAssertEqual(Strings.tr.clearAnnouncement(rows: 3, newLevel: 1), "3 sıra temizlendi, Seviye 1")
        XCTAssertEqual(Strings.en.gameOverAnnouncement(score: 4000, isNewBest: false), "Game over. Score 4000.")
        XCTAssertEqual(Strings.en.gameOverAnnouncement(score: 4000, isNewBest: true), "Game over. Score 4000. NEW BEST")
        XCTAssertEqual(Strings.tr.gameOverAnnouncement(score: 1200, isNewBest: true), "Oyun bitti. Skor 1200. YENİ REKOR")
    }

    func testSettingsLabelsHaveNoEmoji() {
        // SettingsView adds the emoji; the strings stay plain because VoiceOver reads them.
        for s in [Strings.tr, Strings.en] {
            let labels = [s.musicLabel, s.sfxLabel, s.hapticsLabel, s.dayLabel, s.nightLabel,
                          s.languageLabel, s.ghostLabel, s.volumeLabel, s.musicVolumeLabel,
                          s.sfxVolumeLabel, s.playlistLabel, s.appearanceLabel, s.themeStyleLabel]
            for label in labels {
                XCTAssertTrue(label.unicodeScalars.allSatisfy { !$0.properties.isEmojiPresentation && $0 != "\u{FE0F}" },
                              "\"\(label)\" contains an emoji")
            }
        }
    }

    // MARK: - Onboarding flag

    func testOnboardingFlagDefaultsOffAndPersists() {
        let suiteName = "test.tesseriss.onboarding"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let store = SettingsStore(defaults: defaults)
        XCTAssertFalse(store.hasSeenOnboarding, "a fresh install shows the onboarding")
        store.hasSeenOnboarding = true
        XCTAssertTrue(SettingsStore(defaults: defaults).hasSeenOnboarding)
        XCTAssertTrue(defaults.bool(forKey: "tesseriss.onboarding.seen"))

        defaults.removePersistentDomain(forName: suiteName)
    }

    func testOnboardingSkippedForPlayersUpdatingFromAnEarlierVersion() {
        let suiteName = "test.tesseriss.onboarding.upgrade"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set(true, forKey: "tesseriss.settings.music")  // written by every earlier launch

        let store = SettingsStore(defaults: defaults)
        XCTAssertTrue(store.hasSeenOnboarding, "an existing player does not get the first-launch guide")
        // Reopening it from Settings must still work after the migration.
        store.hasSeenOnboarding = false
        XCTAssertFalse(SettingsStore(defaults: defaults).hasSeenOnboarding)

        defaults.removePersistentDomain(forName: suiteName)
    }

    // MARK: - Stats

    private func freshHighscoreStore(_ suiteName: String) -> (HighscoreStore, UserDefaults) {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return (HighscoreStore(defaults: defaults), defaults)
    }

    func testLifetimeStatsAccumulateAndPersist() {
        let (store, defaults) = freshHighscoreStore("test.tesseriss.stats")
        XCTAssertEqual([store.gamesPlayed, store.rowsCleared, store.fourRowClears], [0, 0, 0])
        store.recordGame(rowsCleared: 6, fourRowClears: 1)
        store.recordGame(rowsCleared: 4, fourRowClears: 0)
        let reloaded = HighscoreStore(defaults: defaults)
        XCTAssertEqual([reloaded.gamesPlayed, reloaded.rowsCleared, reloaded.fourRowClears], [2, 10, 1])
        defaults.removePersistentDomain(forName: "test.tesseriss.stats")
    }

    func testCorruptStatsValuesReadAsZero() {
        let (_, defaults) = freshHighscoreStore("test.tesseriss.corruptstats")
        defaults.set("lots", forKey: "tesseriss.stats.gamesPlayed")
        defaults.set(-3, forKey: "tesseriss.stats.rowsCleared")
        defaults.set(Data([1, 2]), forKey: "tesseriss.stats.fourRowClears")

        let store = HighscoreStore(defaults: defaults)
        XCTAssertEqual([store.gamesPlayed, store.rowsCleared, store.fourRowClears], [0, 0, 0])
        defaults.removePersistentDomain(forName: "test.tesseriss.corruptstats")
    }

    func testResetForTestingClearsStats() {
        let (store, defaults) = freshHighscoreStore("test.tesseriss.reset")
        store.maybeUpdate(900, for: .og)
        store.recordGame(rowsCleared: 4, fourRowClears: 1)
        store.resetForTesting()
        for reloaded in [store, HighscoreStore(defaults: defaults)] {
            XCTAssertEqual(reloaded.highscore(for: .og), 0)
            XCTAssertEqual([reloaded.gamesPlayed, reloaded.rowsCleared, reloaded.fourRowClears], [0, 0, 0])
        }
        defaults.removePersistentDomain(forName: "test.tesseriss.reset")
    }

    // MARK: - Round 3 strings

    func testOnboardingFormats() {
        XCTAssertEqual(Strings.en.onboardingStep(1, of: 3), "1 of 3")
        XCTAssertEqual(Strings.tr.onboardingStep(2, of: 3), "2 / 3")
        XCTAssertEqual(Strings.en.onboardingStepAccessibility(3, of: 3), "Step 3 of 3")
        XCTAssertEqual(Strings.tr.onboardingStepAccessibility(1, of: 3), "Adım 1, toplam 3")
    }

    func testNoStringIsEmpty() {
        for s in [Strings.tr, Strings.en] {
            for child in Mirror(reflecting: s).children {
                XCTAssertFalse((child.value as? String)?.isEmpty ?? true, "\(child.label ?? "?") is empty")
            }
        }
    }
}
