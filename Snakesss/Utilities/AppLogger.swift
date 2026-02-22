import os.log

// MARK: - AppLogger

/// Centralized OSLog loggers for Snakesss.
/// Use the static category loggers directly rather than instantiating.
///
/// Subsystem: "com.gobcgames.snakesss"
/// Categories: game · scoring · audio · settings
enum AppLogger {
    static let game     = Logger(subsystem: "com.gobcgames.snakesss", category: "game")
    static let scoring  = Logger(subsystem: "com.gobcgames.snakesss", category: "scoring")
    static let audio    = Logger(subsystem: "com.gobcgames.snakesss", category: "audio")
    static let settings = Logger(subsystem: "com.gobcgames.snakesss", category: "settings")
}
