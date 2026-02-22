# Feature: Settings

## Overview
`SettingsManager` is a singleton that persists all user preferences to `UserDefaults` and exposes them as `@Observable` properties so views react to changes automatically.

## Key Files
- `Snakesss/Services/SettingsManager.swift` — Singleton settings store (261 lines)

## How It Works

`SettingsManager.shared` is the single access point. Each property uses `didSet` to immediately write to `UserDefaults`. The `@Observable` macro means any SwiftUI view reading a property will re-render when it changes.

**Settings and defaults:**

| Setting            | Type       | Options              | Default  |
|--------------------|------------|----------------------|----------|
| `roundCount`       | `Int`      | 3, 6, 9              | 6        |
| `timerDuration`    | `Int` (s)  | 60, 90, 120, 180     | 120      |
| `soundEnabled`     | `Bool`     | —                    | true     |
| `hapticsEnabled`   | `Bool`     | —                    | true     |
| `enabledCategories`| `Set<String>` | 8 categories      | all on   |
| `difficulty`       | `String`   | easy/medium/hard/mixed | mixed  |
| `language`         | `String`   | auto/fr/en           | auto     |

**Language override:** When `language` is set to `"fr"` or `"en"`, `SettingsManager` also writes to `UserDefaults` key `"AppleLanguages"` so the system locale override takes effect after next launch.

**Categories:** Stored as JSON-encoded `[String]` in UserDefaults. The 8 available categories are: Science, History, Geography, Nature, Sports, Culture, Food & Drink, Technology.

**Testing:** A secondary `init(store: UserDefaults)` accepts a custom store, enabling isolated unit tests without touching the real `UserDefaults.standard`.

`resetToDefaults()` restores all settings at once; logged via `os.log`.

## Notes
- `GameViewModel` reads `roundCount` and `timerDuration` once at init — changing settings mid-game has no effect until the next game.
- `QuestionService` reads `language`, `enabledCategories`, and `difficulty` on each `getQuestion()` call, so question filter changes take effect next round.
