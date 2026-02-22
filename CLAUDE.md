# CLAUDE.md

## Project Overview
Snakesss is a trivia + social deduction party game for iOS. 4-8 players share a single iPhone in pass-and-play mode. Snakes know the correct answer and try to manipulate others into choosing wrong. The app replaces the human moderator from the original board game.

## Tech Stack
- Language: Swift (iOS 17+)
- Framework: SwiftUI (100%)
- Architecture: MVVM with @Observable (Swift 5.9+)
- Build: Xcode (Snakesss.xcodeproj, object version 56)
- Test: XCTest (8 test files, 106+ tests)
- Persistence: SwiftData (game history), UserDefaults (@AppStorage for settings)
- Audio: AVFoundation + CoreHaptics (programmatic synthesis via AudioService)
- Logging: os.log (AppLogger utility)
- Dependencies: Zero external — Apple frameworks only

## Architecture
- Pattern: MVVM + Services
- Key components:
  - **Models**: Player, Question, Role, GamePhase, Vote, RoundResult (all value types)
  - **Services**: QuestionService, RoleService, ScoringService, AudioService, SettingsManager
  - **ViewModels**: GameViewModel (core state machine), GameSetupViewModel, GameNavigationCoordinator
  - **Views**: 16 SwiftUI views organized by feature (Home, Setup, Game, Results, History, Settings, Onboarding)
  - **Theme**: SnakesssTheme (3-tier color tokens), SnakesssTypography (SF Pro Rounded), SnakesssAnimation, custom ButtonStyles

## Development Commands
```bash
# Build
xcodebuild -project Snakesss.xcodeproj -scheme Snakesss -sdk iphonesimulator build

# Test
xcodebuild -project Snakesss.xcodeproj -scheme Snakesss -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' test

# Clean
xcodebuild -project Snakesss.xcodeproj -scheme Snakesss clean
```

## Code Conventions
- **Naming**: PascalCase types, camelCase properties, `Snakesss` prefix for theme types
- **Suffixes**: `Service` for services, `ViewModel` for view models, `View` for views
- **File organization**: MARK comments (`// MARK: - Section Name`)
- **Concurrency**: `@MainActor` on ViewModels and async code, `@Observable` for reactivity
- **Services**: `final class`, injectable via init (protocols for testability, e.g. `RoleAssigning`)
- **Models**: `struct` value types, `enum` for state machines
- **Settings**: `SettingsManager.shared` singleton with `@AppStorage`
- **Imports**: Foundation, SwiftUI, SwiftData, os.log, CoreHaptics, AVFoundation, Observation

## Key Files
- `Snakesss/App/SnakesssApp.swift` — @main entry point, ModelContainer setup, onboarding gate
- `Snakesss/App/DemoGameRunner.swift` — Demo mode for screenshot capture (`-demo` launch arg)
- `Snakesss/ViewModels/GameViewModel.swift` — Core game engine (305 lines), phase state machine
- `Snakesss/Services/QuestionService.swift` — Question loading, filtering by difficulty/language, used tracking
- `Snakesss/Theme/SnakesssTheme.swift` — Color primitives + semantic tokens
- `Snakesss/Resources/questions.json` — French question pool (~190 questions)
- `Snakesss/Resources/questions_en.json` — English question pool (~130 questions)
- `Snakesss/Resources/Localizable.xcstrings` — String catalog (en + fr)

## What Not to Modify
- `build/` — Xcode build artifacts (auto-generated)
- `Snakesss.xcodeproj/xcuserdata/` — Per-user Xcode workspace state
- `Snakesss/Resources/Assets.xcassets` — Edit via Xcode Asset Catalog editor, not text
- `Snakesss.xcodeproj/project.pbxproj` — Auto-managed by Xcode (edit with caution)

## Game State Machine
```
setup → roleReveal(playerIndex) → mongooseAnnouncement → question
→ snakeReveal(snakeIndex) → discussion → voting(playerIndex)
→ roundResults → [next round or gameEnd]
```

## Localization
- French (primary) and English supported
- Auto-detection based on device locale, manual override in settings
- Questions have separate JSON files per language with category + difficulty tags

## Documentation
All project documentation lives in `/docs/` at this repo's root:

### Feature Docs (`/docs/features/`)
- `game-engine.md` — GameViewModel state machine, phase transitions, timer logic
- `role-system.md` — RoleService, distribution table (4–8 players), RoleAssigning protocol
- `question-system.md` — QuestionService loading, filtering, deduplication, bilingual routing
- `scoring.md` — ScoringService round score calculation rules
- `settings.md` — SettingsManager singleton, all preferences and defaults
- `audio.md` — AudioService PCM synthesis, sound effects, background music
- `onboarding.md` — 4-page tutorial flow, completion gating, RulesSheetView
- `localization.md` — French/English support, String Catalog, language switching

### Architecture (`/docs/architecture/`)
- `overview.md` — MVVM layers, service descriptions, data flow, persistence

### Post-mortems (`/docs/postmortem/`)
(Added after story reviews)

Keep this section up to date when adding new docs.

## MAESTRO Context
- Part of project: GOBC-GAMES
- Role: Phase 1 MVP — Snakesss offline pass-and-play iOS game
- MAESTRO dir: /Users/clodpod/projects/GOBC-GAMES/_maestro/
