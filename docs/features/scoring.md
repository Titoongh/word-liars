# Feature: Scoring

## Overview
`ScoringService` calculates per-player point deltas at the end of each round based on roles, votes, and the correct answer. Points reflect both individual performance and group outcomes.

## Key Files
- `Snakesss/Services/ScoringService.swift` — Round score calculation

## How It Works

`calculateRoundScores(players:roles:votes:correctAnswer:)` returns an array of `(playerIndex: Int, points: Int)` tuples. Scoring rules:

| Role              | Condition                        | Points earned              |
|-------------------|----------------------------------|----------------------------|
| Human / Mongoose  | Voted for the correct answer     | Equal to the count of correct voters (dynamic) |
| Human / Mongoose  | Voted for a wrong answer         | 0                          |
| Snake             | Always                           | Count of non-snake players who voted wrong |

**Key design:** correct-voter points are dynamic — the fewer people who get it right, the more each correct voter earns. Snakes earn one point per non-snake player they successfully misled.

The Mongoose role scores identically to Human in `ScoringService`; any bonus for Mongoose is handled at the display layer (onboarding page 4 shows "+2 bonus" label, which reflects the Mongoose's advantage of knowing snakes' identities, not a code-level scoring exception).

`GameViewModel.showResults()` calls `calculateRoundScores`, then adds each delta to `players[i].totalScore` (accumulating across rounds), and appends a `RoundResult` for the history display.

## Notes
- `ScoringService` is a pure `final class` with no stored state — safe to instantiate once and reuse across rounds.
- The `correctAnswer` parameter is the JSON answer letter string (`"a"`, `"b"`, `"c"`); `ScoringService` maps it to `Vote` enum internally.
