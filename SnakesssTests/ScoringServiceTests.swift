import XCTest
@testable import Snakesss

final class ScoringServiceTests: XCTestCase {

    let service = ScoringService()

    private func makePlayers(count: Int) -> [Player] {
        (0..<count).map { i in
            Player(id: UUID(), name: "Player \(i + 1)", role: nil, totalScore: 0, currentVote: nil)
        }
    }

    private func scoreDict(_ scores: [(playerIndex: Int, points: Int)]) -> [Int: Int] {
        Dictionary(uniqueKeysWithValues: scores.map { ($0.playerIndex, $0.points) })
    }

    // All 4 humans vote correctly → each gets N points (N = 4 correct voters)
    func testAllHumansCorrect() {
        let players = makePlayers(count: 4)
        let roles = [
            (playerIndex: 0, role: Role.human),
            (playerIndex: 1, role: Role.human),
            (playerIndex: 2, role: Role.human),
            (playerIndex: 3, role: Role.human)
        ]
        let votes = [
            (playerIndex: 0, vote: Vote.a),
            (playerIndex: 1, vote: Vote.a),
            (playerIndex: 2, vote: Vote.a),
            (playerIndex: 3, vote: Vote.a)
        ]
        let scores = scoreDict(service.calculateRoundScores(
            players: players, roles: roles, votes: votes, correctAnswer: "A"
        ))
        XCTAssertEqual(scores[0], 4)
        XCTAssertEqual(scores[1], 4)
        XCTAssertEqual(scores[2], 4)
        XCTAssertEqual(scores[3], 4)
    }

    // All non-snakes wrong → humans/mongoose get 0, snakes get points
    func testAllHumansWrong() {
        let players = makePlayers(count: 4)
        let roles = [
            (playerIndex: 0, role: Role.human),
            (playerIndex: 1, role: Role.snake),
            (playerIndex: 2, role: Role.snake),
            (playerIndex: 3, role: Role.mongoose)
        ]
        let votes = [
            (playerIndex: 0, vote: Vote.b),
            (playerIndex: 1, vote: Vote.snake),
            (playerIndex: 2, vote: Vote.snake),
            (playerIndex: 3, vote: Vote.b)
        ]
        let scores = scoreDict(service.calculateRoundScores(
            players: players, roles: roles, votes: votes, correctAnswer: "A"
        ))
        XCTAssertEqual(scores[0], 0, "Human with wrong vote should get 0")
        XCTAssertEqual(scores[3], 0, "Mongoose with wrong vote should get 0")
        XCTAssertEqual(scores[1], 2, "Snake should get 2 (2 incorrect non-snakes)")
        XCTAssertEqual(scores[2], 2, "Snake should get 2 (2 incorrect non-snakes)")
    }

    // Mixed results: some correct, some wrong
    func testMixedResults() {
        let players = makePlayers(count: 5)
        let roles = [
            (playerIndex: 0, role: Role.human),
            (playerIndex: 1, role: Role.human),
            (playerIndex: 2, role: Role.snake),
            (playerIndex: 3, role: Role.snake),
            (playerIndex: 4, role: Role.mongoose)
        ]
        let votes = [
            (playerIndex: 0, vote: Vote.a),
            (playerIndex: 1, vote: Vote.b),
            (playerIndex: 2, vote: Vote.snake),
            (playerIndex: 3, vote: Vote.snake),
            (playerIndex: 4, vote: Vote.a)
        ]
        let scores = scoreDict(service.calculateRoundScores(
            players: players, roles: roles, votes: votes, correctAnswer: "A"
        ))
        // 2 correct non-snake voters (players 0, 4)
        XCTAssertEqual(scores[0], 2, "Human correct: 2 correct voters")
        XCTAssertEqual(scores[1], 0, "Human wrong: 0 points")
        // 1 incorrect non-snake (player 1)
        XCTAssertEqual(scores[2], 1, "Snake: 1 incorrect non-snake")
        XCTAssertEqual(scores[3], 1, "Snake: 1 incorrect non-snake")
        XCTAssertEqual(scores[4], 2, "Mongoose correct: 2 correct voters")
    }

    // Mongoose with correct vote earns same as human
    func testMongooseCorrectScoring() {
        let players = makePlayers(count: 4)
        let roles = [
            (playerIndex: 0, role: Role.human),
            (playerIndex: 1, role: Role.snake),
            (playerIndex: 2, role: Role.snake),
            (playerIndex: 3, role: Role.mongoose)
        ]
        let votes = [
            (playerIndex: 0, vote: Vote.a),
            (playerIndex: 1, vote: Vote.snake),
            (playerIndex: 2, vote: Vote.snake),
            (playerIndex: 3, vote: Vote.a)
        ]
        let scores = scoreDict(service.calculateRoundScores(
            players: players, roles: roles, votes: votes, correctAnswer: "A"
        ))
        // 2 correct non-snake voters (human + mongoose)
        XCTAssertEqual(scores[0], 2, "Human correct: 2 correct voters")
        XCTAssertEqual(scores[3], 2, "Mongoose correct: same as human")
        // 0 incorrect non-snakes → snakes get 0
        XCTAssertEqual(scores[1], 0, "Snake: 0 incorrect non-snakes")
        XCTAssertEqual(scores[2], 0, "Snake: 0 incorrect non-snakes")
    }

    // All non-snakes correct → snakes get 0
    func testAllNonSnakesCorrectSnakesGetZero() {
        let players = makePlayers(count: 4)
        let roles = [
            (playerIndex: 0, role: Role.human),
            (playerIndex: 1, role: Role.human),
            (playerIndex: 2, role: Role.snake),
            (playerIndex: 3, role: Role.mongoose)
        ]
        let votes = [
            (playerIndex: 0, vote: Vote.a),
            (playerIndex: 1, vote: Vote.a),
            (playerIndex: 2, vote: Vote.snake),
            (playerIndex: 3, vote: Vote.a)
        ]
        let scores = scoreDict(service.calculateRoundScores(
            players: players, roles: roles, votes: votes, correctAnswer: "A"
        ))
        XCTAssertEqual(scores[2], 0, "Snake gets 0 when all non-snakes correct")
        XCTAssertEqual(scores[0], 3)
        XCTAssertEqual(scores[1], 3)
        XCTAssertEqual(scores[3], 3)
    }
}
