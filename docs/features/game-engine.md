# Feature: Game Engine

## Overview
The game engine drives the full lifecycle of a Snakesss session through a linear phase state machine, from initial setup through final scores. `GameViewModel` is the single source of truth for all in-progress game state.

## Key Files
- `Snakesss/ViewModels/GameViewModel.swift` — Core state machine, timer logic, persistence (305 lines)
- `Snakesss/Models/GamePhase.swift` — `GamePhase` enum defining all possible states

## How It Works

`GameViewModel` is an `@Observable @MainActor` class. SwiftUI views observe it directly; any phase change triggers a re-render.

**Phase state machine:**
```
setup
  → roleReveal(playerIndex: 0…N-1)
  → mongooseAnnouncement
  → question
  → snakeReveal(snakeIndex: 0…S-1)   (skipped if no snakes)
  → discussion                        (countdown timer runs here)
  → voting(playerIndex: 0…N-1)
  → roundResults
  → [next round OR gameEnd]
```

Each transition is a named method (`startRound`, `revealNextRole`, `showQuestion`, etc.). The discussion timer runs as a Swift structured-concurrency `Task`; it fires haptics at 30 s and ticks at ≤10 s, then auto-advances to voting on expiry.

Settings (`roundCount`, `timerDuration`) are read once from `SettingsManager.shared` at `init` and stored as `let` constants so mid-game setting changes don't disrupt play.

On `gameEnd`, `saveGame(to:)` inserts a `GameRecord` into the SwiftData model context for history tracking.

## Notes
- `RoleAssigning` protocol on `RoleService` allows dependency injection for testing without changing `GameViewModel`'s public API.
- `AudioService.shared.stopBackgroundMusic()` is called explicitly on game end (tagged STORY-025).
- `winners` computed property supports ties (multiple players at max score).
