import SwiftUI

// MARK: - Animation Presets

/// Spring animation constants for consistent motion across Snakesss.
/// All interactive UI elements use spring physics — no .easeInOut or .linear.
enum SnakesssAnimation {
    /// Standard — 0.4s, 0.2 bounce. General UI transitions.
    static let standard    = Animation.spring(duration: 0.4, bounce: 0.2)

    /// Bouncy — 0.3s, 0.4 bounce. Button press rebounds, player name entry.
    static let bouncy      = Animation.spring(duration: 0.3, bounce: 0.4)

    /// Reveal — 0.6s, 0.3 bounce. Role card / answer reveal.
    static let reveal      = Animation.spring(duration: 0.6, bounce: 0.3)

    /// Celebration — 0.8s, 0.5 bounce. Winner screen trophy, confetti.
    static let celebration = Animation.spring(duration: 0.8, bounce: 0.5)

    /// Stagger step — 0.08s delay between list items in staggered reveals.
    static let staggerStep: Double = 0.08
}
