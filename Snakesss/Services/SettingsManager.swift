import Foundation
import Observation
import os.log

// MARK: - SettingsManager

/// Singleton @Observable settings store backed by UserDefaults.
/// All properties auto-persist on set. Used by SettingsView (STORY-022)
/// and GameViewModel / SnakesssHaptic (STORY-023).
@Observable
@MainActor
final class SettingsManager {

    // MARK: - Singleton

    static let shared = SettingsManager()

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let roundCount         = "snakesss.settings.roundCount"
        static let timerDuration      = "snakesss.settings.timerDuration"
        static let soundEnabled       = "snakesss.settings.soundEnabled"
        static let hapticsEnabled     = "snakesss.settings.hapticsEnabled"
        static let enabledCategories  = "snakesss.settings.enabledCategories"
    }

    // MARK: - Available Values

    nonisolated static let roundCountOptions:    [Int] = [3, 6, 9]
    nonisolated static let timerDurationOptions: [Int] = [60, 90, 120, 180]

    /// All question categories available in the question pool.
    nonisolated static let allCategories: [String] = [
        "Science",
        "History",
        "Geography",
        "Nature",
        "Sports",
        "Culture",
        "Food & Drink",
        "Technology"
    ]

    // MARK: - Defaults

    private enum Defaults {
        static let roundCount        = 6
        static let timerDuration     = 120
        static let soundEnabled      = true
        static let hapticsEnabled    = true
        static let enabledCategories = Set(SettingsManager.allCategories)
    }

    // MARK: - Store

    private let store: UserDefaults

    // MARK: - Properties (UserDefaults-backed)

    /// Number of rounds per game. Valid values: 3, 6, 9. Default: 6.
    var roundCount: Int {
        didSet {
            store.set(roundCount, forKey: Keys.roundCount)
            AppLogger.settings.info("roundCount changed to \(self.roundCount)")
        }
    }

    /// Timer duration in seconds for the discussion phase. Valid values: 60, 90, 120, 180. Default: 120.
    var timerDuration: Int {
        didSet {
            store.set(timerDuration, forKey: Keys.timerDuration)
            AppLogger.settings.info("timerDuration changed to \(self.timerDuration)s")
        }
    }

    /// Whether sound effects are enabled. Default: true.
    var soundEnabled: Bool {
        didSet {
            store.set(soundEnabled, forKey: Keys.soundEnabled)
            AppLogger.settings.info("soundEnabled changed to \(self.soundEnabled)")
        }
    }

    /// Whether haptic feedback is enabled. Default: true.
    var hapticsEnabled: Bool {
        didSet {
            store.set(hapticsEnabled, forKey: Keys.hapticsEnabled)
            AppLogger.settings.info("hapticsEnabled changed to \(self.hapticsEnabled)")
        }
    }

    /// Set of enabled question category names. Default: all categories enabled.
    var enabledCategories: Set<String> {
        didSet {
            persistEnabledCategories()
            AppLogger.settings.info("enabledCategories updated: \(self.enabledCategories.count) categories active")
        }
    }

    // MARK: - Init

    private init() {
        self.store = .standard
        self.roundCount = Self.loadRoundCount(from: .standard)
        self.timerDuration = Self.loadTimerDuration(from: .standard)
        self.soundEnabled = Self.loadBool(forKey: Keys.soundEnabled, default: Defaults.soundEnabled, from: .standard)
        self.hapticsEnabled = Self.loadBool(forKey: Keys.hapticsEnabled, default: Defaults.hapticsEnabled, from: .standard)
        self.enabledCategories = Self.loadEnabledCategories(from: .standard)
    }

    /// Internal init for testing — accepts a custom UserDefaults store.
    init(store: UserDefaults) {
        self.store = store
        self.roundCount = Self.loadRoundCount(from: store)
        self.timerDuration = Self.loadTimerDuration(from: store)
        self.soundEnabled = Self.loadBool(forKey: Keys.soundEnabled, default: Defaults.soundEnabled, from: store)
        self.hapticsEnabled = Self.loadBool(forKey: Keys.hapticsEnabled, default: Defaults.hapticsEnabled, from: store)
        self.enabledCategories = Self.loadEnabledCategories(from: store)
    }

    // MARK: - Reset

    /// Restore all settings to their default values.
    func resetToDefaults() {
        roundCount        = Defaults.roundCount
        timerDuration     = Defaults.timerDuration
        soundEnabled      = Defaults.soundEnabled
        hapticsEnabled    = Defaults.hapticsEnabled
        enabledCategories = Defaults.enabledCategories
        AppLogger.settings.info("Settings reset to defaults")
    }

    // MARK: - Helpers

    private func persistEnabledCategories() {
        let array = Array(enabledCategories)
        if let data = try? JSONEncoder().encode(array) {
            store.set(data, forKey: Keys.enabledCategories)
        }
    }

    private static func loadRoundCount(from store: UserDefaults) -> Int {
        let saved = store.integer(forKey: Keys.roundCount)
        return roundCountOptions.contains(saved) ? saved : Defaults.roundCount
    }

    private static func loadTimerDuration(from store: UserDefaults) -> Int {
        let saved = store.integer(forKey: Keys.timerDuration)
        return timerDurationOptions.contains(saved) ? saved : Defaults.timerDuration
    }

    private static func loadBool(forKey key: String, default defaultValue: Bool, from store: UserDefaults) -> Bool {
        store.object(forKey: key) != nil ? store.bool(forKey: key) : defaultValue
    }

    private static func loadEnabledCategories(from store: UserDefaults) -> Set<String> {
        if let data = store.data(forKey: Keys.enabledCategories),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            return Set(decoded)
        }
        return Defaults.enabledCategories
    }

    /// Human-readable label for a timer duration value.
    nonisolated static func timerLabel(for seconds: Int) -> String {
        switch seconds {
        case 60:  return String(localized: "settings.timer.1min")
        case 90:  return String(localized: "settings.timer.1min30")
        case 120: return String(localized: "settings.timer.2min")
        case 180: return String(localized: "settings.timer.3min")
        default:  return "\(seconds)s"
        }
    }
}
