import XCTest
@testable import Snakesss

// MARK: - SettingsManagerTests

@MainActor
final class SettingsManagerTests: XCTestCase {

    // MARK: - Helpers

    /// Creates an isolated SettingsManager backed by a fresh in-memory UserDefaults suite.
    private func makeManager() -> SettingsManager {
        let suiteName = "com.gobcgames.snakesss.test.\(UUID().uuidString)"
        let store = UserDefaults(suiteName: suiteName)!
        return SettingsManager(store: store)
    }

    // MARK: - Default Values

    func testDefaultRoundCount() {
        let manager = makeManager()
        XCTAssertEqual(manager.roundCount, 6)
    }

    func testDefaultTimerDuration() {
        let manager = makeManager()
        XCTAssertEqual(manager.timerDuration, 120)
    }

    func testDefaultSoundEnabled() {
        let manager = makeManager()
        XCTAssertTrue(manager.soundEnabled)
    }

    func testDefaultHapticsEnabled() {
        let manager = makeManager()
        XCTAssertTrue(manager.hapticsEnabled)
    }

    func testDefaultEnabledCategoriesContainsAll() {
        let manager = makeManager()
        XCTAssertEqual(manager.enabledCategories, Set(SettingsManager.allCategories))
    }

    // MARK: - Persistence Round-Trip

    func testRoundCountPersistsAndRoundTrips() {
        let suiteName = "com.gobcgames.snakesss.test.\(UUID().uuidString)"
        let store = UserDefaults(suiteName: suiteName)!

        let manager1 = SettingsManager(store: store)
        manager1.roundCount = 3

        // Re-read from same store
        let manager2 = SettingsManager(store: store)
        XCTAssertEqual(manager2.roundCount, 3)
    }

    func testTimerDurationPersistsAndRoundTrips() {
        let suiteName = "com.gobcgames.snakesss.test.\(UUID().uuidString)"
        let store = UserDefaults(suiteName: suiteName)!

        let manager1 = SettingsManager(store: store)
        manager1.timerDuration = 60

        let manager2 = SettingsManager(store: store)
        XCTAssertEqual(manager2.timerDuration, 60)
    }

    func testSoundEnabledPersistsAndRoundTrips() {
        let suiteName = "com.gobcgames.snakesss.test.\(UUID().uuidString)"
        let store = UserDefaults(suiteName: suiteName)!

        let manager1 = SettingsManager(store: store)
        manager1.soundEnabled = false

        let manager2 = SettingsManager(store: store)
        XCTAssertFalse(manager2.soundEnabled)
    }

    func testHapticsEnabledPersistsAndRoundTrips() {
        let suiteName = "com.gobcgames.snakesss.test.\(UUID().uuidString)"
        let store = UserDefaults(suiteName: suiteName)!

        let manager1 = SettingsManager(store: store)
        manager1.hapticsEnabled = false

        let manager2 = SettingsManager(store: store)
        XCTAssertFalse(manager2.hapticsEnabled)
    }

    // MARK: - enabledCategories Persistence (JSON encoding)

    func testEnabledCategoriesPersistsAndRoundTrips() {
        let suiteName = "com.gobcgames.snakesss.test.\(UUID().uuidString)"
        let store = UserDefaults(suiteName: suiteName)!

        let subset: Set<String> = ["Science", "History", "Nature"]
        let manager1 = SettingsManager(store: store)
        manager1.enabledCategories = subset

        let manager2 = SettingsManager(store: store)
        XCTAssertEqual(manager2.enabledCategories, subset)
    }

    func testEnabledCategoriesEmptySetPersists() {
        let suiteName = "com.gobcgames.snakesss.test.\(UUID().uuidString)"
        let store = UserDefaults(suiteName: suiteName)!

        let manager1 = SettingsManager(store: store)
        manager1.enabledCategories = []

        let manager2 = SettingsManager(store: store)
        XCTAssertTrue(manager2.enabledCategories.isEmpty)
    }

    // MARK: - Invalid Stored Values Fall Back to Defaults

    func testInvalidRoundCountFallsBackToDefault() {
        let suiteName = "com.gobcgames.snakesss.test.\(UUID().uuidString)"
        let store = UserDefaults(suiteName: suiteName)!
        store.set(99, forKey: "snakesss.settings.roundCount")

        let manager = SettingsManager(store: store)
        XCTAssertEqual(manager.roundCount, 6)
    }

    func testInvalidTimerDurationFallsBackToDefault() {
        let suiteName = "com.gobcgames.snakesss.test.\(UUID().uuidString)"
        let store = UserDefaults(suiteName: suiteName)!
        store.set(999, forKey: "snakesss.settings.timerDuration")

        let manager = SettingsManager(store: store)
        XCTAssertEqual(manager.timerDuration, 120)
    }

    // MARK: - Reset to Defaults

    func testResetToDefaultsRestoresAllValues() {
        let manager = makeManager()
        manager.roundCount = 9
        manager.timerDuration = 60
        manager.soundEnabled = false
        manager.hapticsEnabled = false
        manager.enabledCategories = ["Science"]

        manager.resetToDefaults()

        XCTAssertEqual(manager.roundCount, 6)
        XCTAssertEqual(manager.timerDuration, 120)
        XCTAssertTrue(manager.soundEnabled)
        XCTAssertTrue(manager.hapticsEnabled)
        XCTAssertEqual(manager.enabledCategories, Set(SettingsManager.allCategories))
    }

    // MARK: - @Observable Updates

    func testSettingRoundCountUpdatesProperty() {
        let manager = makeManager()
        manager.roundCount = 9
        XCTAssertEqual(manager.roundCount, 9)
    }

    func testSettingSoundEnabledToggles() {
        let manager = makeManager()
        XCTAssertTrue(manager.soundEnabled)
        manager.soundEnabled = false
        XCTAssertFalse(manager.soundEnabled)
        manager.soundEnabled = true
        XCTAssertTrue(manager.soundEnabled)
    }

    // MARK: - timerLabel

    func testTimerLabelFor60() {
        XCTAssertEqual(SettingsManager.timerLabel(for: 60), "1 min")
    }

    func testTimerLabelFor90() {
        XCTAssertEqual(SettingsManager.timerLabel(for: 90), "1:30")
    }

    func testTimerLabelFor120() {
        XCTAssertEqual(SettingsManager.timerLabel(for: 120), "2 min")
    }

    func testTimerLabelFor180() {
        XCTAssertEqual(SettingsManager.timerLabel(for: 180), "3 min")
    }

    func testTimerLabelForUnknown() {
        XCTAssertEqual(SettingsManager.timerLabel(for: 45), "45s")
    }
}
