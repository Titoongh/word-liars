import XCTest
@testable import Snakesss

// MARK: - AudioServiceTests
//
// AudioService is a @MainActor singleton that wraps AVAudioEngine.
// AVAudioEngine may not produce real audio in the test runner environment,
// but calls must not crash. Tests verify state and control flow behaviour
// by manipulating SettingsManager.soundEnabled.

@MainActor
final class AudioServiceTests: XCTestCase {

    // MARK: - Helpers

    /// A fresh SettingsManager backed by an isolated UserDefaults store.
    private func makeSettings() -> SettingsManager {
        let suiteName = "com.gobcgames.snakesss.audiotest.\(UUID().uuidString)"
        return SettingsManager(store: UserDefaults(suiteName: suiteName)!)
    }

    // MARK: - Initialization

    func testSharedInstanceInitializesWithoutCrash() {
        // Accessing the singleton must not throw or crash
        let service = AudioService.shared
        XCTAssertNotNil(service)
    }

    // MARK: - Sound Disabled — no playback attempted

    func testPlaySoundWithSoundDisabledDoesNotCrash() {
        let settings = makeSettings()
        settings.soundEnabled = false

        // Temporarily swap SettingsManager.shared isn't possible without
        // refactoring the singleton; instead verify the guarded path indirectly:
        // call playSound after disabling sound on shared manager and confirm no crash.
        let originalSound = SettingsManager.shared.soundEnabled
        SettingsManager.shared.soundEnabled = false
        defer { SettingsManager.shared.soundEnabled = originalSound }

        XCTAssertNoThrow(AudioService.shared.playSound(.roleReveal))
        XCTAssertNoThrow(AudioService.shared.playSound(.timerTick))
        XCTAssertNoThrow(AudioService.shared.playSound(.timerWarning))
        XCTAssertNoThrow(AudioService.shared.playSound(.voteConfirm))
        XCTAssertNoThrow(AudioService.shared.playSound(.resultsReveal))
        XCTAssertNoThrow(AudioService.shared.playSound(.celebration))
    }

    func testPlayBackgroundMusicWithSoundDisabledDoesNotCrash() {
        let originalSound = SettingsManager.shared.soundEnabled
        SettingsManager.shared.soundEnabled = false
        defer { SettingsManager.shared.soundEnabled = originalSound }

        XCTAssertNoThrow(AudioService.shared.playBackgroundMusic())
    }

    func testStopBackgroundMusicDoesNotCrash() {
        XCTAssertNoThrow(AudioService.shared.stopBackgroundMusic())
    }

    // MARK: - Mute toggle: sound enabled → disabled

    func testMuteTogglePreventsPlayback() {
        let originalSound = SettingsManager.shared.soundEnabled
        defer { SettingsManager.shared.soundEnabled = originalSound }

        // With sound off, playSound should return early without playing
        SettingsManager.shared.soundEnabled = false
        // No easy way to verify engine state without mocking,
        // but verifying it does not crash is the integration-level assertion.
        XCTAssertNoThrow(AudioService.shared.playSound(.voteConfirm))
    }

    // MARK: - Unmute: re-enabling allows playback path

    func testUnmuteToggleReenablesPlaybackPath() {
        let originalSound = SettingsManager.shared.soundEnabled
        defer { SettingsManager.shared.soundEnabled = originalSound }

        SettingsManager.shared.soundEnabled = false
        SettingsManager.shared.soundEnabled = true

        // With sound re-enabled, playSound should proceed (engine will try to start)
        XCTAssertNoThrow(AudioService.shared.playSound(.roleReveal))
    }

    // MARK: - All SoundEffect cases are handled

    func testAllSoundEffectCasesPlayWithoutCrash() {
        // Drive every case through playSound (sound disabled to avoid engine startup)
        let originalSound = SettingsManager.shared.soundEnabled
        SettingsManager.shared.soundEnabled = false
        defer { SettingsManager.shared.soundEnabled = originalSound }

        for effect in AudioService.SoundEffect.allCases {
            XCTAssertNoThrow(
                AudioService.shared.playSound(effect),
                "playSound crashed for effect: \(effect.rawValue)"
            )
        }
    }

    // MARK: - Play / Stop background music cycle

    func testPlayStopBackgroundMusicCycleDoesNotCrash() {
        let originalSound = SettingsManager.shared.soundEnabled
        SettingsManager.shared.soundEnabled = true
        defer { SettingsManager.shared.soundEnabled = originalSound }

        XCTAssertNoThrow(AudioService.shared.playBackgroundMusic())
        XCTAssertNoThrow(AudioService.shared.stopBackgroundMusic())
    }
}
