import Foundation

final class ScoringService {
    func calculateRoundScores(
        players: [Player],
        roles: [(playerIndex: Int, role: Role)],
        votes: [(playerIndex: Int, vote: Vote)],
        correctAnswer: String
    ) -> [(playerIndex: Int, points: Int)] {
        var roleByIndex: [Int: Role] = [:]
        for entry in roles {
            roleByIndex[entry.playerIndex] = entry.role
        }

        var voteByIndex: [Int: Vote] = [:]
        for entry in votes {
            voteByIndex[entry.playerIndex] = entry.vote
        }

        let correctVote: Vote
        switch correctAnswer.lowercased() {
        case "a": correctVote = .a
        case "b": correctVote = .b
        case "c": correctVote = .c
        default:  correctVote = .a
        }

        let correctVoterCount = players.indices.filter { i in
            let role = roleByIndex[i] ?? .human
            let vote = voteByIndex[i]
            return role != .snake && vote == correctVote
        }.count

        let incorrectNonSnakeCount = players.indices.filter { i in
            let role = roleByIndex[i] ?? .human
            let vote = voteByIndex[i]
            return role != .snake && vote != correctVote
        }.count

        return players.indices.map { i in
            let role = roleByIndex[i] ?? .human
            let vote = voteByIndex[i]
            let points: Int
            switch role {
            case .human, .mongoose:
                points = vote == correctVote ? correctVoterCount : 0
            case .snake:
                points = incorrectNonSnakeCount
            }
            return (playerIndex: i, points: points)
        }
    }
}
