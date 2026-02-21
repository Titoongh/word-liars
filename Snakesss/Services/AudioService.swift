import AVFoundation

// MARK: - AudioService

/// Singleton audio service using AVAudioEngine with programmatically
/// synthesized PCM buffers. No audio asset files required.
/// Respects `SettingsManager.shared.soundEnabled`.
@MainActor
final class AudioService {

    static let shared = AudioService()

    // MARK: - Sound Effects

    enum SoundEffect: String, CaseIterable {
        case roleReveal
        case timerTick
        case timerWarning
        case voteConfirm
        case resultsReveal
        case celebration
    }

    // MARK: - Engine & Players

    private let engine = AVAudioEngine()
    private var buffers: [SoundEffect: AVAudioPCMBuffer] = [:]
    private var sfxPlayers: [AVAudioPlayerNode] = []
    private let bgMusicPlayer = AVAudioPlayerNode()
    private var bgMusicBuffer: AVAudioPCMBuffer?
    private var isEngineRunning = false

    // MARK: - Init

    private init() {
        configureSession()
        buildBuffers()
        attachNodes()
    }

    // MARK: - Public API

    func playSound(_ effect: SoundEffect) {
        guard SettingsManager.shared.soundEnabled else { return }
        ensureEngineRunning()
        guard let buffer = buffers[effect] else { return }

        // Reuse or create a player node
        let player = availablePlayer()
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        player.play()
    }

    func playBackgroundMusic() {
        guard SettingsManager.shared.soundEnabled else { return }
        ensureEngineRunning()
        guard let buffer = bgMusicBuffer else { return }
        bgMusicPlayer.volume = 0.08
        bgMusicPlayer.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        bgMusicPlayer.play()
    }

    func stopBackgroundMusic() {
        bgMusicPlayer.stop()
    }

    // MARK: - Audio Session

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, options: .mixWithOthers)
        try? session.setActive(true)
    }

    // MARK: - Engine Management

    private func ensureEngineRunning() {
        guard !isEngineRunning else { return }
        do {
            try engine.start()
            isEngineRunning = true
        } catch {
            // Silently fail — audio is non-critical
        }
    }

    private func attachNodes() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!

        // Pool of 4 SFX player nodes for concurrent playback
        for _ in 0..<4 {
            let node = AVAudioPlayerNode()
            engine.attach(node)
            engine.connect(node, to: engine.mainMixerNode, format: format)
            sfxPlayers.append(node)
        }

        // Background music player
        engine.attach(bgMusicPlayer)
        engine.connect(bgMusicPlayer, to: engine.mainMixerNode, format: format)
    }

    private func availablePlayer() -> AVAudioPlayerNode {
        // Find a player that isn't currently playing
        for player in sfxPlayers {
            if !player.isPlaying {
                return player
            }
        }
        // All busy — reuse the first one
        sfxPlayers[0].stop()
        return sfxPlayers[0]
    }

    // MARK: - Buffer Synthesis

    private func buildBuffers() {
        let sampleRate: Double = 44100

        buffers[.roleReveal] = synthesize(sampleRate: sampleRate) { t in
            // Rising shimmer: two sine waves with frequency sweep
            let freq1 = 400 + t * 600
            let freq2 = 600 + t * 800
            let env = min(1.0, t * 8) * max(0.0, 1.0 - (t - 0.3) * 3)
            return Float(sin(2 * .pi * freq1 * t) * 0.3 + sin(2 * .pi * freq2 * t) * 0.2) * Float(env)
        }

        buffers[.timerTick] = synthesize(sampleRate: sampleRate, duration: 0.05) { t in
            // Short click
            let env = max(0.0, 1.0 - t * 20)
            return Float(sin(2 * .pi * 800 * t)) * Float(env) * 0.3
        }

        buffers[.timerWarning] = synthesize(sampleRate: sampleRate, duration: 0.3) { t in
            // Urgent double beep
            let beep1 = t < 0.12
            let beep2 = t > 0.15 && t < 0.27
            let active = beep1 || beep2
            let env = active ? min(1.0, (beep1 ? t : (t - 0.15)) * 30) * 0.5 : 0.0
            return Float(sin(2 * .pi * 1000 * t)) * Float(env)
        }

        buffers[.voteConfirm] = synthesize(sampleRate: sampleRate, duration: 0.15) { t in
            // Short ascending tone
            let freq = 500 + t * 300
            let env = max(0.0, 1.0 - t * 6.67)
            return Float(sin(2 * .pi * freq * t)) * Float(env) * 0.4
        }

        buffers[.resultsReveal] = synthesize(sampleRate: sampleRate, duration: 0.6) { t in
            // Dramatic reveal: chord with fade-in
            let env = min(1.0, t * 4) * max(0.0, 1.0 - (t - 0.4) * 5)
            let c = sin(2 * .pi * 523.25 * t) // C5
            let e = sin(2 * .pi * 659.25 * t) // E5
            let g = sin(2 * .pi * 783.99 * t) // G5
            return Float((c + e + g) / 3.0) * Float(env) * 0.35
        }

        buffers[.celebration] = synthesize(sampleRate: sampleRate, duration: 1.2) { t in
            // Victory fanfare: ascending arpeggio
            let note: Double
            if t < 0.2 { note = 523.25 }       // C5
            else if t < 0.4 { note = 659.25 }   // E5
            else if t < 0.6 { note = 783.99 }   // G5
            else { note = 1046.5 }               // C6
            let env = min(1.0, fmod(t, 0.2) * 10) * max(0.0, 1.0 - (t - 0.8) * 2.5)
            return Float(sin(2 * .pi * note * t)) * Float(env) * 0.4
        }

        // Ambient background: soft pad drone
        bgMusicBuffer = synthesize(sampleRate: sampleRate, duration: 4.0) { t in
            // Soft C minor pad
            let c = sin(2 * .pi * 130.81 * t)  // C3
            let eb = sin(2 * .pi * 155.56 * t) // Eb3
            let g = sin(2 * .pi * 196.0 * t)   // G3
            let wobble = 1.0 + 0.02 * sin(2 * .pi * 0.5 * t) // slow vibrato
            return Float((c + eb * 0.7 + g * 0.5) / 3.0 * wobble) * 0.15
        }
    }

    private func synthesize(
        sampleRate: Double,
        duration: Double = 0.5,
        generator: (Double) -> Float
    ) -> AVAudioPCMBuffer? {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }
        buffer.frameLength = frameCount
        guard let data = buffer.floatChannelData?[0] else { return nil }
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            data[i] = generator(t)
        }
        return buffer
    }
}
