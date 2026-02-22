# Architecture Overview: Snakesss

## Summary

Snakesss is a SwiftUI iOS app using MVVM + Services. It has zero external dependencies — only Apple frameworks (SwiftUI, SwiftData, AVFoundation, CoreHaptics, Observation, os.log).

## MVVM Layers

```
Views  ──observe──▶  ViewModels  ──call──▶  Services
                         │
                         └──read/write──▶  Models (value types)
                                           Persistence (SwiftData / UserDefaults)
```

### Models (value types)
Pure data structs and enums. No logic, no side effects.

| Type          | Role                                                    |
|---------------|---------------------------------------------------------|
| `Player`      | Name, assigned role, current vote, running total score  |
| `Question`    | Trivia question with choices, answer, category, difficulty |
| `Role`        | Enum: `.human`, `.snake`, `.mongoose`                   |
| `GamePhase`   | Enum state machine with associated values (playerIndex, snakeIndex) |
| `Vote`        | Enum: `.a`, `.b`, `.c`                                  |
| `RoundResult` | Snapshot of one round (question, roles, votes, points)  |
| `GameRecord`  | SwiftData `@Model` for persisted game history           |

### Services (singletons and injectables)
Business logic classes. Injected into ViewModels via protocol or direct reference.

| Service            | Pattern    | Responsibility                                       |
|--------------------|------------|------------------------------------------------------|
| `QuestionService`  | Injectable | Load, filter, deduplicate, and vend trivia questions |
| `RoleService`      | Injectable | Assign roles per round using distribution table      |
| `ScoringService`   | Injectable | Calculate per-player point deltas per round          |
| `AudioService`     | Singleton  | Synthesize and play PCM audio; loop background music |
| `SettingsManager`  | Singleton  | Persist and expose all user preferences              |

### ViewModels (`@Observable @MainActor`)
Coordinate state between views and services.

| ViewModel                  | Responsibility                                         |
|----------------------------|--------------------------------------------------------|
| `GameViewModel`            | Full game phase state machine, timer, round results    |
| `GameSetupViewModel`       | Player name entry and validation before game start     |
| `GameNavigationCoordinator`| Top-level navigation between app sections              |

### Views (SwiftUI)
16 views organized by feature folder: Home, Setup, Game, Results, History, Settings, Onboarding.

Views are passive — they observe ViewModels via `@Observable` and call methods; they contain no business logic.

## Data Flow: One Round

```
GameViewModel.startRound()
  → RoleService.assignRoles()          → [Role] assigned to Players
  → phase = .roleReveal(0…N)           → RoleRevealView shown per player
  → phase = .mongooseAnnouncement      → MongooseAnnouncementView
  → QuestionService.getQuestion()      → Question loaded and filtered
  → phase = .question                  → QuestionView shown
  → phase = .snakeReveal(0…S)          → SnakeRevealView shown per snake
  → phase = .discussion                → DiscussionView + countdown Task
  → phase = .voting(0…N)              → VotingView per player
  → ScoringService.calculateRoundScores() → points delta
  → players[i].totalScore += delta
  → phase = .roundResults             → RoundResultsView
  → nextRound() or phase = .gameEnd   → GameEndView → saveGame()
```

## Persistence

| Store       | What                          | Key mechanism        |
|-------------|-------------------------------|----------------------|
| SwiftData   | Game history (`GameRecord`)   | `ModelContainer` in `SnakesssApp`, `ModelContext` injected via environment |
| UserDefaults| Settings, used question IDs, onboarding seen flag | `SettingsManager` (settings), `QuestionService` (used IDs), `SnakesssApp` (onboarding gate) |

## Theme System
`SnakesssTheme` provides a 3-tier color token system (primitives → semantic → component). `SnakesssTypography` uses SF Pro Rounded. Custom `ButtonStyle` implementations ensure consistent interactive elements. All theme types use the `Snakesss` prefix.

## Testing
XCTest with 8 test files and 106+ tests. Services are tested via protocol injection (`RoleAssigning`) or direct init with test data (`QuestionService(questions:)`, `SettingsManager(store:)`). `GameViewModel` is tested by injecting mock services.
