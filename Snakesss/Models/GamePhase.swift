import Foundation

enum GamePhase: Equatable {
    case setup
    case roleReveal(playerIndex: Int)
    case mongooseAnnouncement
    case question
    case snakeReveal(snakeIndex: Int)
    case discussion
    case voting(playerIndex: Int)
    case roundResults
    case gameEnd
}
