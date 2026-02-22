# Feature: Role System

## Overview
Each round, every player is secretly assigned one of three roles — Human, Snake, or Mongoose — according to a fixed distribution table keyed on player count.

## Key Files
- `Snakesss/Services/RoleService.swift` — Role assignment logic and distribution table
- `Snakesss/Models/Role.swift` — `Role` enum (`human`, `snake`, `mongoose`)

## How It Works

`RoleService.assignRoles(playerCount:)` looks up the player count in a static distribution table and returns a shuffled `[Role]` array:

| Players | Humans | Snakes | Mongoose |
|---------|--------|--------|----------|
| 4       | 1      | 2      | 1        |
| 5       | 2      | 2      | 1        |
| 6       | 2      | 3      | 1        |
| 7       | 3      | 3      | 1        |
| 8       | 3      | 4      | 1        |

There is always exactly one Mongoose regardless of player count. Snakes scale from 2 to 4 as the table grows.

`GameViewModel` calls `assignRoles` at the start of each round, stores the results in `currentRoleAssignments`, and assigns each role to the corresponding `Player` struct. Snake player indices are derived immediately for use in the later `snakeReveal` phase.

`RoleService` conforms to the `RoleAssigning` protocol (declared in `GameViewModel.swift`) to allow injection of a mock during testing.

## Notes
- `Role` is a plain `String`-backed enum — no behaviour, just identity. All role-specific display logic (colors, labels, emoji) lives in view extensions.
- Player counts outside 4–8 return an empty array from `assignRoles`.
