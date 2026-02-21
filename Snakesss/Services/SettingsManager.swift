import Foundation
import Observation

// MARK: - SettingsManager

/// Singleton @Observable settings store backed by UserDefaults.
/// All properties auto-persist on set. Used by SettingsView (STORY-022)
/// and GameViewModel / SnakesssHaptic (STORY-023).
@Observable
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

    static let roundCountOptions:    [Int] = [3, 6, 9]
    static let timerDurationOptions: [Int] = [60, 90, 120, 180]

    /// All question categories available in the question pool.
    static let allCategories: [String] = [
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
        static var enabledCategories = Set(SettingsManager.allCategories)
    }

    // MARK: - Properties (UserDefaults-backed)

    /// Number of rounds per game. Valid values: 3, 6, 9. Default: 6.
    var roundCount: Int {
        didSet {
            UserDefaults.standard.set(roundCount, forKey: Keys.roundCount)
        }
    }

    /// Timer duration in seconds for the discussion phase. Valid values: 60, 90, 120, 180. Default: 120.
    var timerDuration: Int {
        didSet {
            UserDefaults.standard.set(timerDuration, forKey: Keys.timerDuration)
        }
    }

    /// Whether sound effects are enabled. Default: true.
    var soundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: Keys.soundEnabled)
        }
    }

    /// Whether haptic feedback is enabled. Default: true.
    var hapticsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticsEnabled, forKey: Keys.hapticsEnabled)
        }
    }

    /// Set of enabled question category names. Default: all categories enabled.
    var enabledCategories: Set<String> {
        didSet {
            persistEnabledCategories()
        }
    }

    // MARK: - Init

    private init() {
        let defaults = UserDefaults.standard

        // roundCount — only valid if one of the allowed values
        let savedRoundCount = defaults.integer(forKey: Keys.roundCount)
        roundCount = SettingsManager.roundCountOptions.contains(savedRoundCount)
            ? savedRoundCount
            : Defaults.roundCount

        // timerDuration — only valid if one of the allowed values
        let savedTimer = defaults.integer(forKey: Keys.timerDuration)
        timerDuration = SettingsManager.timerDurationOptions.contains(savedTimer)
            ? savedTimer
            : Defaults.timerDuration

        // Booleans — use stored value only if key exists
        if defaults.object(forKey: Keys.soundEnabled) != nil {
            soundEnabled = defaults.bool(forKey: Keys.soundEnabled)
        } else {
            soundEnabled = Defaults.soundEnabled
        }

        if defaults.object(forKey: Keys.hapticsEnabled) != nil {
            hapticsEnabled = defaults.bool(forKey: Keys.hapticsEnabled)
        } else {
            hapticsEnabled = Defaults.hapticsEnabled
        }

        // enabledCategories — JSON-encoded [String] in UserDefaults
        if let data = defaults.data(forKey: Keys.enabledCategories),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            enabledCategories = Set(decoded)
        } else {
            enabledCategories = Defaults.enabledCategories
        }
    }

    // MARK: - Reset

    /// Restore all settings to their default values.
    func resetToDefaults() {
        roundCount        = Defaults.roundCount
        timerDuration     = Defaults.timerDuration
        soundEnabled      = Defaults.soundEnabled
        hapticsEnabled    = Defaults.hapticsEnabled
        enabledCategories = Defaults.enabledCategories
    }

    // MARK: - Helpers

    private func persistEnabledCategories() {
        let array = Array(enabledCategories)
        if let data = try? JSONEncoder().encode(array) {
            UserDefaults.standard.set(data, forKey: Keys.enabledCategories)
        }
    }

    /// Human-readable label for a timer duration value.
    static func timerLabel(for seconds: Int) -> String {
        switch seconds {
        case 60:  return "1 min"
        case 90:  return "1:30"
        case 120: return "2 min"
        case 180: return "3 min"
        default:  return "\(seconds)s"
        }
    }
}
