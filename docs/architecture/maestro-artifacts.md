# MAESTRO Project Artifacts

## Overview
All project management artifacts live in `_maestro/` at the multi-repo root (`/Users/clodpod/projects/GOBC-GAMES/_maestro/`).

## Artifacts

| File | Purpose | Status |
|------|---------|--------|
| `brief.md` | Project discovery brief — vision, game concept, tech stack, design direction | Complete |
| `prd.md` | Product Requirements Document — FRs, NFRs, screen inventory, data model | Complete |
| `architecture.md` | Technical architecture — MVVM layers, services, routing, file structure | Complete (updated) |
| `design.md` | Design system and wireframes — color tokens, typography, components, 11 screens | Complete |
| `state.md` | Project state tracker — current sprint, repo list, history log | Active |

## Epics (17)

| ID | Title | Status |
|----|-------|--------|
| EPIC-001 | Project Foundation & Design System | Completed |
| EPIC-002 | Home Screen & Player Setup | Completed |
| EPIC-003 | Game Engine & Services | Completed |
| EPIC-004 | Role Reveal & Snake Reveal | Completed |
| EPIC-005 | Question Display & Discussion Timer | Completed |
| EPIC-006 | Voting & Round Results | Completed |
| EPIC-007 | Game End & History | Completed |
| EPIC-008 | Question Content | Completed |
| EPIC-009 | Settings Screen | Completed |
| EPIC-010 | Sound Effects & Music | Completed |
| EPIC-011 | App Icon & Launch Screen | Completed |
| EPIC-012 | Onboarding & Tutorial | Completed |
| EPIC-013 | Localization (French + English) | Completed |
| EPIC-014 | Question Content Expansion & Difficulty | Completed |
| EPIC-015 | Share Results & Social Features | Planned (future) |
| EPIC-016 | App Store Preparation | Planned (future) |
| EPIC-017 | Test Coverage & Quality Assurance | Completed |

## Sprints (6)

| Sprint | Name | Status | Stories |
|--------|------|--------|---------|
| Sprint 1 | Foundation & Game Engine | Completed | 9/9 (100%) |
| Sprint 2 | UI Screens, Content & Polish | Completed | 11/11 (100%) |
| Sprint 3 | Polish & QA | Completed | 25 fixes applied |
| Sprint 4 | Settings, Sound & Branding | Completed | 8/8 (100%) |
| Sprint 5 | Onboarding & Quality | Completed | 6/6 (100%) |
| Sprint 6 | Localization & Question Expansion | Completed | 7/7 (100%) |

## Key Outcomes

- **MVP complete** after Sprint 2: full pass-and-play game, 130 French questions, SwiftData history
- **Post-MVP additions** (Sprints 4-6): settings, sound effects, app icon, onboarding, localization (FR+EN), difficulty levels, 370 total questions, 106 unit tests
- **Bilingual app**: French + English UI (String Catalog) + questions
- **Architecture**: MVVM + @Observable, zero external dependencies, AVAudioEngine programmatic audio

## Sprint Files

Sprint documents live in `_maestro/sprints/`:
- `SPRINT-001.md` through `SPRINT-006.md`

## Story Files

48 stories in `_maestro/stories/`:
- `STORY-001.md` through `STORY-048.md`

## Related Documentation

- [word-liars CLAUDE.md](../../CLAUDE.md) — iOS project context and conventions
- [word-liars docs/](../) — Feature and post-mortem documentation
