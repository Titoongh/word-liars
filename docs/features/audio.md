# Feature: Audio

## Overview
`AudioService` provides all game sounds using `AVAudioEngine` with programmatically synthesized PCM buffers — no audio asset files are required. It also plays looping ambient background music.

## Key Files
- `Snakesss/Services/AudioService.swift` — Singleton audio engine (216 lines)

## How It Works

`AudioService.shared` is a `@MainActor` singleton initialized at app start. On init it:
1. Configures `AVAudioSession` in `.ambient` category (mixes with other audio).
2. Synthesizes all sound buffers upfront using `AVAudioPCMBuffer` with math-based waveform generators.
3. Attaches 4 SFX player nodes (for concurrent playback) and 1 background music node to the engine's mixer.

**Sound effects (`SoundEffect` enum):**

| Effect          | Description                             | Used when                  |
|-----------------|-----------------------------------------|----------------------------|
| `roleReveal`    | Rising shimmer (two swept sine waves)   | Role card shown            |
| `timerTick`     | Short 800 Hz click (0.05 s)             | Final 10 s of discussion   |
| `timerWarning`  | Urgent double beep at 1000 Hz           | 30 s remaining             |
| `voteConfirm`   | Short ascending tone                    | Vote submitted             |
| `resultsReveal` | C-E-G chord fade-in (0.6 s)             | Round results shown        |
| `celebration`   | C5-E5-G5-C6 arpeggio (1.2 s)           | Game end                   |

Background music is a soft C-minor pad drone (C3/Eb3/G3) synthesized as a 4-second looping buffer at 8% volume.

`playSound(_:)` checks `SettingsManager.shared.soundEnabled` before playing. Sounds are played by picking an idle player node from the pool; if all 4 are busy, the first is stopped and reused. Audio failures are silently swallowed — audio is non-critical.

## Notes
- Zero audio asset files: all waveforms are computed at init using `sin()` with envelope functions.
- The engine starts lazily (`ensureEngineRunning`) on first sound play to avoid unnecessary resource use.
- `GameViewModel` references `AudioService.shared` directly (not injected) — audio is a side effect, not game logic.
