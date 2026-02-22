# Feature: Question System

## Overview
`QuestionService` loads trivia questions from bundled JSON files, filters them by language/category/difficulty, tracks which questions have been used, and vends one question per round without repeating until the pool is exhausted.

## Key Files
- `Snakesss/Services/QuestionService.swift` — Loading, filtering, used-tracking, selection logic
- `Snakesss/Models/Question.swift` — `Question` struct (Codable, Identifiable)
- `Snakesss/Resources/questions.json` — French question pool (~190 questions)
- `Snakesss/Resources/questions_en.json` — English question pool (~130 questions)

## How It Works

**Language selection:** On init, `QuestionService` calls `localeQuestionsResource()` which reads `SettingsManager.shared.language`. If set to `"auto"`, it falls back to `Bundle.main.preferredLocalizations`; any non-English locale loads `questions.json` (French), English loads `questions_en.json`.

**Filtering pipeline (applied each call to `getQuestion`):**
1. Category filter — only questions whose `category` field is in `SettingsManager.shared.enabledCategories` (questions with no category always pass).
2. Difficulty filter — if difficulty is not `"mixed"`, only questions matching the selected level. Falls back to the full category-filtered pool if the filtered count is less than `roundCount`.

**Selection:**
- Non-mixed mode: picks a random unused question; if all are used, resets used-IDs for the current pool and picks again.
- Mixed mode: weighted random difficulty — 30% easy, 50% medium, 20% hard. Same reset logic if pool exhausted.

Used question IDs persist across app launches via `UserDefaults` (key `"usedQuestionIDs"`).

**`Question` model fields:** `id`, `question`, `choices` (a, b, c), `answer` (letter string), `funFact?`, `category?`, `difficulty` (defaults to `"medium"` for backward compat).

## Notes
- The init that accepts `[Question]` directly bypasses bundle loading and UserDefaults — used in unit tests.
- `resetPool()` clears persisted used IDs; exposed for a future "reset questions" settings action.
