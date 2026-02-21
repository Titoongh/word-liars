import SwiftData
import Foundation

@Model
final class GameRecord {
    var date: Date
    var playerNames: [String]
    var finalScores: [Int]
    var winnerNames: [String]
    var roundCount: Int

    init(date: Date, playerNames: [String], finalScores: [Int], winnerNames: [String], roundCount: Int) {
        self.date = date
        self.playerNames = playerNames
        self.finalScores = finalScores
        self.winnerNames = winnerNames
        self.roundCount = roundCount
    }
}
