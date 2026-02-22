# Feature: Localization

## Overview
Snakesss supports French (primary) and English throughout — UI strings via Xcode's String Catalog, and questions via separate JSON files per language.

## Key Files
- `Snakesss/Resources/Localizable.xcstrings` — String Catalog with all UI strings in `en` and `fr`
- `Snakesss/Resources/questions.json` — French trivia question pool (~190 questions)
- `Snakesss/Resources/questions_en.json` — English trivia question pool (~130 questions)
- `Snakesss/Services/SettingsManager.swift` — `language` property and `AppleLanguages` override
- `Snakesss/Services/QuestionService.swift` — `localeQuestionsResource()` language routing

## How It Works

**UI strings:** All user-visible strings use `LocalizedStringKey` (SwiftUI) or `String(localized:)` (code). The `.xcstrings` String Catalog format manages translations in a single JSON-based file; Xcode handles extraction and merging.

**Language setting (`SettingsManager.language`):**
- `"auto"` — follows device locale; defaults to French for any non-English locale.
- `"fr"` or `"en"` — explicit override. Writing a non-auto value also sets `UserDefaults["AppleLanguages"]` to `[language]`, which causes iOS to apply the locale override after the next app launch.

**Question language routing (`QuestionService.localeQuestionsResource()`):**
- Reads `SettingsManager.shared.language`.
- If `"auto"`, checks `Bundle.main.preferredLocalizations.first`; English prefix → `questions_en`, otherwise → `questions`.
- Explicit language values route directly: `"en"` → `questions_en`, anything else → `questions`.

**Categories and difficulty labels** in `SettingsManager` use `String(localized:)` so they appear in the correct language at runtime.

## Notes
- French is treated as the primary language; the app was built French-first with English added as a secondary pool.
- Changing language in settings takes effect for question selection immediately (next `getQuestion()` call), but UI string changes require a restart due to `AppleLanguages` needing a relaunch to re-evaluate.
- The `.xcstrings` file should be edited in Xcode's String Catalog editor, not directly as text.
