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
}
