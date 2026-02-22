# Feature: Onboarding

## Overview
A 4-page swipeable tutorial shown on first app launch. It introduces the game concept, roles, round flow, and scoring rules, then gates entry to the main game.

## Key Files
- `Snakesss/Views/Onboarding/OnboardingView.swift` — Container with navigation chrome (skip, next, page dots)
- `Snakesss/Views/Onboarding/OnboardingPageContent.swift` — All 4 page views and their subcomponents
- `Snakesss/App/SnakesssApp.swift` — Reads `snakesss.hasSeenOnboarding` from UserDefaults to gate display

## How It Works

`OnboardingView` wraps a `TabView` with `.page` style to host the 4 pages. Navigation chrome:
- **Skip button** (top-right): visible on pages 1–3; taps call `completeOnboarding()`.
- **Next button** (bottom): visible on pages 1–3; increments `currentPage`.
- **Page dots** (bottom): custom capsule indicators that expand for the active page.
- Page 4 has its own "Let's Play!" CTA button instead of a Next button.

On completion (skip or "Let's Play!"), `UserDefaults.standard.set(true, forKey: "snakesss.hasSeenOnboarding")` is written. The app entry point gates on this key; once set, onboarding never shows again.

**Page content:**
- **Page 1** — Game concept ("TRUST NOBODY" tagline, brief description card)
- **Page 2** — Three roles with `RoleExplanationCard` components (emoji, badge, description)
- **Page 3** — 6-phase round flow as a numbered list (`PhaseRow` components)
- **Page 4** — Scoring rules as a table (`ScoringRow` components) + "Let's Play!" CTA

All string content is localized via `LocalizedStringKey` and `String(localized:)` — fully bilingual.

Animations respect `@Environment(\.accessibilityReduceMotion)`.

## Notes
- `RulesSheetView.swift` provides a condensed rules reference accessible from the Settings screen (not part of the initial onboarding flow).
- `OnboardingPage4View` can be rendered standalone (with `onComplete: nil`) for use in the rules sheet context — the CTA button is conditionally shown.
