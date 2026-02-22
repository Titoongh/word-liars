import UIKit
import CoreHaptics

// MARK: - Haptic Feedback Helper

/// Centralized haptic feedback patterns for Snakesss.
/// Uses UIKit generators for standard patterns and CoreHaptics for complex sequences.
/// All calls check SettingsManager.shared.hapticsEnabled before firing.
enum SnakesssHaptic {

    // MARK: - Standard Impact Haptics

    /// Light impact — button press, list item tap
    @MainActor static func light() {
        guard SettingsManager.shared.hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// Medium impact — phase transitions, pass-phone handoff
    @MainActor static func medium() {
        guard SettingsManager.shared.hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// Heavy impact — role reveal, snake reveal
    @MainActor static func heavy() {
        guard SettingsManager.shared.hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    // MARK: - Notification Haptics

    /// Success pattern — correct answer, winning round
    @MainActor static func success() {
        guard SettingsManager.shared.hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Error pattern — wrong answer, invalid action
    @MainActor static func error() {
        guard SettingsManager.shared.hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    // MARK: - Game-Specific Patterns

    /// Timer warning — fired at 30-second mark.
    /// Distinct transient pop to alert players discussion is ending.
    @MainActor static func timerWarning() {
        guard SettingsManager.shared.hapticsEnabled else { return }
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            return
        }
        Task { @MainActor in
            guard let engine = try? CHHapticEngine() else { return }
            try? engine.start()
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9)
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [sharpness, intensity],
                relativeTime: 0
            )
            if let pattern = try? CHHapticPattern(events: [event], parameters: []) {
                let player = try? engine.makePlayer(with: pattern)
                try? player?.start(atTime: CHHapticTimeImmediate)
            }
        }
    }

    /// Timer end — fired when countdown reaches 0.
    /// Rising urgency: triple tap pattern to signal time's up.
    @MainActor static func timerEnd() {
        guard SettingsManager.shared.hapticsEnabled else { return }
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }
        Task { @MainActor in
            guard let engine = try? CHHapticEngine() else { return }
            try? engine.start()
            var events: [CHHapticEvent] = []
            for i in 0..<3 {
                let intensity = CHHapticEventParameter(
                    parameterID: .hapticIntensity,
                    value: Float(0.6 + Double(i) * 0.2)
                )
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: Double(i) * 0.12
                )
                events.append(event)
            }
            if let pattern = try? CHHapticPattern(events: events, parameters: []) {
                let player = try? engine.makePlayer(with: pattern)
                try? player?.start(atTime: CHHapticTimeImmediate)
            }
        }
    }

    /// Celebration — fired on winner reveal.
    /// Triple-tap triumph pattern with escalating intensity.
    @MainActor static func celebration() {
        guard SettingsManager.shared.hapticsEnabled else { return }
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return
        }
        Task { @MainActor in
            guard let engine = try? CHHapticEngine() else { return }
            try? engine.start()
            var events: [CHHapticEvent] = []
            let delays: [Double] = [0, 0.15, 0.30]
            let intensities: [Float] = [0.7, 0.85, 1.0]
            for (i, delay) in delays.enumerated() {
                let intensity = CHHapticEventParameter(
                    parameterID: .hapticIntensity,
                    value: intensities[i]
                )
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: delay
                )
                events.append(event)
            }
            if let pattern = try? CHHapticPattern(events: events, parameters: []) {
                let player = try? engine.makePlayer(with: pattern)
                try? player?.start(atTime: CHHapticTimeImmediate)
            }
        }
    }
}
