import Foundation

struct RoundResult {
    let roundNumber: Int
    let question: Question
    let roles: [(playerIndex: Int, role: Role)]
    let votes: [(playerIndex: Int, vote: Vote)]
    let pointsEarned: [(playerIndex: Int, points: Int)]
}
