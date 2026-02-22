# SPRINT-006 — Localization & Question Expansion

**Goal:** Make Snakesss bilingual (FR + EN) and deepen the question pool with difficulty levels.

**Epics:** EPIC-013 (Localization), EPIC-014 (Question Content Expansion & Difficulty)
**Stories:** 7
**Duration:** 2 weeks

---

## Stories

| ID | Title | Size | Track | Depends On |
|----|-------|------|-------|------------|
| STORY-031 | Extract hardcoded strings to String Catalog | M | A — Localization | — |
| STORY-032 | Add English translations | M | A — Localization | STORY-031 |
| STORY-033 | Create English question bank (130+ questions) | L | A — Localization | — |
| STORY-034 | Add difficulty field to Question model & tag existing questions | M | B — Difficulty | — |
| STORY-035 | Add difficulty setting & QuestionService filtering | M | B — Difficulty | STORY-034 |
| STORY-036 | Write 120+ new French trivia questions | L | C — Content | — |
| STORY-037 | Write 120+ new English trivia questions | L | C — Content | — |

---

## Parallel Tracks

```
Track A — Localization          Track B — Difficulty          Track C — Content (independent)
─────────────────────           ────────────────────          ─────────────────────────────────
STORY-031 (extract strings)     STORY-034 (model + tags)      STORY-036 (FR questions)
    │                               │                         STORY-037 (EN questions)
    ▼                               ▼                           (can run in parallel)
STORY-032 (EN translations)     STORY-035 (setting + filter)
    │
    ▼
STORY-033 (EN question bank)
```

**Track A — Localization (sequential)**
1. **STORY-031** — Audit all SwiftUI views + services for hardcoded French strings. Create `Localizable.xcstrings` String Catalog (Xcode 15+). Replace all strings with `String(localized:)` keys. Currently there are ~15 view files with user-facing text.
2. **STORY-032** — Add English locale to the String Catalog. Translate all extracted keys to English. Verify layout with longer English strings.
3. **STORY-033** — Write 130+ English trivia questions in the same JSON format (`id`, `question`, `choices`, `answer`, `funFact`, `category`). Must cover all 8 existing categories. Merge into `questions.json` or create `questions_en.json` keyed by locale.

**Track B — Difficulty (sequential)**
1. **STORY-034** — Add `difficulty: Difficulty` enum (`easy`, `medium`, `hard`) to `Question` model. Tag all 130 existing French questions with appropriate difficulty. Update JSON schema. Ensure backward-compatible decoding (default to `medium` if missing).
2. **STORY-035** — Add difficulty picker to `SettingsView`. Extend `QuestionService.filteredPool()` to filter by selected difficulty levels. Store preference in `SettingsManager`.

**Track C — Content (independent, parallelizable)**
- **STORY-036** — Write 120+ new French trivia questions with difficulty tags and all 8 categories.
- **STORY-037** — Write 120+ new English trivia questions with difficulty tags and all 8 categories.

---

## Dependencies & Ordering

```
STORY-031 ──▶ STORY-032 ──▶ STORY-033
STORY-034 ──▶ STORY-035
STORY-036 (independent)
STORY-037 (independent)
```

- Tracks A, B, and C are fully independent and can run in parallel.
- Within Track A: strings must be extracted (031) before translating (032), and translations done before the EN question bank (033) since 033 needs the localized JSON loading mechanism.
- Within Track B: model changes (034) must land before the UI/filtering (035).
- Track C stories (036, 037) have no blockers — they just need the final difficulty enum from 034 to tag correctly, but question writing can start immediately and tags added at the end.

---

## Technical Notes

- **Current state:** 130 French questions in `Snakesss/Resources/questions.json`. No String Catalog exists yet (no `.xcstrings` files). All UI strings are hardcoded in French.
- **Question model:** `Question` struct in `Snakesss/Models/Question.swift` — fields: `id`, `question`, `choices` (a/b/c), `answer`, `funFact?`, `category?`. No `difficulty` field yet.
- **QuestionService:** Loads from bundle JSON, filters by `SettingsManager.enabledCategories`. Will need locale-aware loading + difficulty filtering.
- **SettingsManager:** Singleton `@Observable`, UserDefaults-backed. Has `enabledCategories: Set<String>`. Will need `difficulty` and `language` settings.
- **Target question count post-sprint:** ~500+ questions (130 existing FR + 120 new FR + 130 EN base + 120 new EN).

---

## Acceptance Criteria

- [ ] App runs fully in English when device language is English
- [ ] App runs fully in French when device language is French
- [ ] 250+ French questions available (130 existing + 120 new)
- [ ] 250+ English questions available (130 base + 120 new)
- [ ] All questions tagged with difficulty (easy/medium/hard)
- [ ] Difficulty filter in Settings works correctly
- [ ] Existing tests pass; new tests for difficulty filtering
- [ ] No regressions in game flow
