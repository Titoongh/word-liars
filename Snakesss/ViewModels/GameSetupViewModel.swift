import Foundation

// MARK: - GameSetupViewModel

/// Manages player count selection and name entry before the game starts.
@Observable
@MainActor
final class GameSetupViewModel {

    var playerCount: Int = 4 {
        didSet {
            // Trim or extend names array to match new count
            if playerNames.count > playerCount {
                playerNames = Array(playerNames.prefix(playerCount))
            } else {
                while playerNames.count < playerCount {
                    playerNames.append("")
                }
            }
        }
    }

    var playerNames: [String] = Array(repeating: "", count: 4)

    var isValid: Bool {
        let trimmed = playerNames.map { $0.trimmingCharacters(in: .whitespaces) }
        return trimmed.count == playerCount &&
               trimmed.allSatisfy { !$0.isEmpty } &&
               Set(trimmed).count == playerCount
    }

    func createPlayers() -> [Player] {
        playerNames.map { name in
            Player(
                id: UUID(),
                name: name.trimmingCharacters(in: .whitespaces),
                role: nil,
                totalScore: 0,
                currentVote: nil
            )
        }
    }
}
