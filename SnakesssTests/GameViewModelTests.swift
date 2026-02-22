import XCTest
@testable import Snakesss

// MARK: - GameViewModelTests

@MainActor
final class GameViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeQuestion(answer: String = "A") -> Question {
        Question(
            id: UUID().uuidString,
            question: "Test question?",
            choices: Question.Choices(a: "Alpha", b: "Beta", c: "Gamma"),
            answer: answer,
            funFact: nil,
            category: nil
        )
    }

    private func makePlayers(count: Int = 4) -> [Player] {
        (0..<count).map { i in
            Player(id: UUID(), name: "Player \(i + 1)", role: nil, totalScore: 0, currentVote: nil)
        }
    }

    /// Stub QuestionService that always returns a fixed question
    private func makeQuestionService(answer: String = "A") -> QuestionService {
        let q = makeQuestion(answer: answer)
        return QuestionService(questions: [q])
    }

    /// Stub role assigner with deterministic roles (for testing).
    private struct StubRoleService: RoleAssigning {
        let fixedRoles: [Role]
        func assignRoles(playerCount: Int) -> [Role] { fixedRoles }
    }

    private func makeVM(
        playerCount: Int = 4,
        roles: [Role]? = nil,
        answer: String = "A"
    ) -> GameViewModel {
        let players = makePlayers(count: playerCount)
        let qs = makeQuestionService(answer: answer)
        if let roles = roles {
            return GameViewModel(players: players, questionService: qs, roleService: StubRoleService(fixedRoles: roles))
        } else {
            return GameViewModel(players: players, questionService: qs)
        }
    }

    // MARK: - startRound()

    func testStartRoundSetsPhaseToRoleReveal() {
        // GameViewModel.init() calls startRound() automatically — round 1 begins immediately.
        let vm = makeVM()
        XCTAssertEqual(vm.phase, .roleReveal(playerIndex: 0))
        XCTAssertEqual(vm.currentRound, 1)
    }

    func testStartRoundAssignsRolesToAllPlayers() {
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles)
        vm.startRound()
        for i in vm.players.indices {
            XCTAssertNotNil(vm.players[i].role)
        }
    }

    func testStartRoundClearsVotes() {
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles)
        vm.startRound()
        // Pre-set a vote to verify it's cleared on next round
        vm.players[0].currentVote = .a
        vm.startRound()  // Round 2
        XCTAssertNil(vm.players[0].currentVote)
    }

    // MARK: - revealNextRole()

    func testRevealNextRoleAdvancesPlayerIndex() {
        let vm = makeVM()
        vm.startRound()
        vm.revealNextRole(currentIndex: 0)
        XCTAssertEqual(vm.phase, .roleReveal(playerIndex: 1))
    }

    func testRevealNextRoleTransitionsToMongooseAfterLastPlayer() {
        let vm = makeVM(playerCount: 4)
        vm.startRound()
        // Advance through all 4 players
        for i in 0..<3 {
            vm.revealNextRole(currentIndex: i)
        }
        vm.revealNextRole(currentIndex: 3)
        XCTAssertEqual(vm.phase, .mongooseAnnouncement)
    }

    // MARK: - showQuestion()

    func testShowQuestionSetsQuestionAndPhase() {
        let vm = makeVM()
        vm.startRound()
        vm.revealNextRole(currentIndex: 0)
        vm.revealNextRole(currentIndex: 1)
        vm.revealNextRole(currentIndex: 2)
        vm.revealNextRole(currentIndex: 3)
        // Now in mongooseAnnouncement
        vm.showQuestion()
        XCTAssertNotNil(vm.currentQuestion)
        XCTAssertEqual(vm.phase, .question)
    }

    // MARK: - Snake Reveal

    func testStartSnakeRevealSetsCorrectPhase() {
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles)
        vm.startRound()
        vm.showQuestion()
        vm.startSnakeReveal()
        XCTAssertEqual(vm.phase, .snakeReveal(snakeIndex: 0))
        XCTAssertEqual(vm.snakeIndices.count, 2)
    }

    func testRevealNextSnakeAdvancesSnakeIndex() {
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles)
        vm.startRound()
        vm.showQuestion()
        vm.startSnakeReveal()
        vm.revealNextSnake(currentSnakeIndex: 0)
        XCTAssertEqual(vm.phase, .snakeReveal(snakeIndex: 1))
    }

    func testRevealNextSnakeTransitionsToDiscussionAfterLastSnake() {
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles)
        vm.startRound()
        vm.showQuestion()
        vm.startSnakeReveal()
        vm.revealNextSnake(currentSnakeIndex: 0)
        vm.revealNextSnake(currentSnakeIndex: 1)
        XCTAssertEqual(vm.phase, .discussion)
    }

    // MARK: - Discussion

    func testSkipDiscussionTransitionsToVoting() {
        let vm = makeVM()
        vm.startRound()
        vm.showQuestion()
        vm.startSnakeReveal()
        // Skip all snake reveals by going straight to discussion
        vm.startDiscussion()
        XCTAssertEqual(vm.phase, .discussion)
        vm.skipDiscussion()
        XCTAssertEqual(vm.phase, .voting(playerIndex: 0))
    }

    func testStartDiscussionResetsTimer() {
        let vm = makeVM()
        vm.startDiscussion()
        XCTAssertEqual(vm.discussionTimeRemaining, 120)
    }

    // MARK: - Voting

    func testSubmitVoteAdvancesVoterIndex() {
        let vm = makeVM(playerCount: 4)
        vm.startVoting()
        vm.submitVote(.a, voterIndex: 0)
        XCTAssertEqual(vm.phase, .voting(playerIndex: 1))
    }

    func testSubmitVoteRecordsVote() {
        let vm = makeVM(playerCount: 4)
        vm.startVoting()
        vm.submitVote(.b, voterIndex: 0)
        XCTAssertEqual(vm.players[0].currentVote, .b)
    }

    func testSubmitAllVotesTransitionsToRoundResults() {
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles)
        vm.startRound()
        vm.showQuestion()
        vm.startVoting()
        vm.submitVote(.a, voterIndex: 0)
        vm.submitVote(.snake, voterIndex: 1)
        vm.submitVote(.snake, voterIndex: 2)
        vm.submitVote(.a, voterIndex: 3)
        XCTAssertEqual(vm.phase, .roundResults)
    }

    // MARK: - showResults()

    func testShowResultsCreatesRoundResult() {
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        // init auto-starts round 1; no explicit startRound needed
        let vm = makeVM(roles: roles, answer: "A")
        vm.showQuestion()
        vm.startVoting()
        vm.submitVote(.a, voterIndex: 0)
        vm.submitVote(.snake, voterIndex: 1)
        vm.submitVote(.snake, voterIndex: 2)
        vm.submitVote(.a, voterIndex: 3)

        XCTAssertEqual(vm.roundResults.count, 1)
        XCTAssertEqual(vm.roundResults[0].roundNumber, 1)
    }

    func testShowResultsUpdatesTotalScores() {
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles, answer: "A")
        vm.startRound()
        vm.showQuestion()
        vm.startVoting()
        // Human correct, both snakes vote snake, mongoose correct
        vm.submitVote(.a, voterIndex: 0)
        vm.submitVote(.snake, voterIndex: 1)
        vm.submitVote(.snake, voterIndex: 2)
        vm.submitVote(.a, voterIndex: 3)

        // 2 correct non-snake voters → each earns 2 pts
        XCTAssertEqual(vm.players[0].totalScore, 2)  // human correct
        XCTAssertEqual(vm.players[3].totalScore, 2)  // mongoose correct
        // 0 incorrect non-snakes → snakes earn 0
        XCTAssertEqual(vm.players[1].totalScore, 0)
        XCTAssertEqual(vm.players[2].totalScore, 0)
    }

    // MARK: - Full Round Lifecycle

    func testFullRoundLifecycle() {
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles)

        // 1. Start round → role reveal
        vm.startRound()
        XCTAssertEqual(vm.phase, .roleReveal(playerIndex: 0))

        // 2. Reveal all roles → mongoose announcement
        for i in 0..<4 { vm.revealNextRole(currentIndex: i) }
        XCTAssertEqual(vm.phase, .mongooseAnnouncement)

        // 3. Show question
        vm.showQuestion()
        XCTAssertEqual(vm.phase, .question)
        XCTAssertNotNil(vm.currentQuestion)

        // 4. Snake reveal (2 snakes)
        vm.startSnakeReveal()
        XCTAssertEqual(vm.phase, .snakeReveal(snakeIndex: 0))
        vm.revealNextSnake(currentSnakeIndex: 0)
        XCTAssertEqual(vm.phase, .snakeReveal(snakeIndex: 1))
        vm.revealNextSnake(currentSnakeIndex: 1)
        XCTAssertEqual(vm.phase, .discussion)

        // 5. Skip discussion → voting
        vm.skipDiscussion()
        XCTAssertEqual(vm.phase, .voting(playerIndex: 0))

        // 6. Vote for all players → round results
        vm.submitVote(.a, voterIndex: 0)
        vm.submitVote(.snake, voterIndex: 1)
        vm.submitVote(.snake, voterIndex: 2)
        vm.submitVote(.a, voterIndex: 3)
        XCTAssertEqual(vm.phase, .roundResults)
        XCTAssertEqual(vm.roundResults.count, 1)
    }

    // MARK: - Game Ends After 6 Rounds

    func testGameEndsAfterSixRounds() {
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles)

        for _ in 1...6 {
            vm.startRound()
            vm.showQuestion()
            vm.startVoting()
            vm.submitVote(.a, voterIndex: 0)
            vm.submitVote(.snake, voterIndex: 1)
            vm.submitVote(.snake, voterIndex: 2)
            vm.submitVote(.a, voterIndex: 3)
            // At round results, call nextRound
            if vm.currentRound < 6 {
                vm.nextRound()
            }
        }

        // After round 6 results, nextRound should transition to gameEnd
        XCTAssertEqual(vm.phase, .roundResults)
        vm.nextRound()
        XCTAssertEqual(vm.phase, .gameEnd)
        XCTAssertEqual(vm.roundResults.count, 6)
    }

    // MARK: - Winner Determination

    func testWinnerDeterminedByHighestScore() {
        // Round 1: player 0 + player 3 both correct → each earns 2 pts, snakes earn 0
        // Round 2: player 0 correct, player 3 wrong → player 0 earns 1 pt, snakes earn 1 pt
        // Totals: Player 0 = 3, Player 3 = 2, Snakes = 1 → Player 0 uniquely wins
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles, answer: "A")

        // Round 1
        vm.startRound()
        vm.showQuestion()
        vm.startVoting()
        vm.submitVote(.a, voterIndex: 0)     // human correct
        vm.submitVote(.snake, voterIndex: 1)
        vm.submitVote(.snake, voterIndex: 2)
        vm.submitVote(.a, voterIndex: 3)     // mongoose correct
        // phase == .roundResults; player0 = 2 pts, player3 = 2 pts, snakes = 0

        // Round 2
        vm.nextRound()
        vm.showQuestion()
        vm.startVoting()
        vm.submitVote(.a, voterIndex: 0)     // human correct alone
        vm.submitVote(.snake, voterIndex: 1)
        vm.submitVote(.snake, voterIndex: 2)
        vm.submitVote(.b, voterIndex: 3)     // mongoose wrong
        // player0 = +1 (3 total), player3 = +0 (2 total), snakes = +1 (1 total)

        XCTAssertEqual(vm.winners.count, 1)
        XCTAssertEqual(vm.winners[0].name, "Player 1")
    }

    func testTieResultsInMultipleWinners() {
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles, answer: "A")
        vm.startRound()
        vm.showQuestion()
        vm.startVoting()
        // Both human and mongoose vote correctly → both earn same points
        vm.submitVote(.a, voterIndex: 0)
        vm.submitVote(.snake, voterIndex: 1)
        vm.submitVote(.snake, voterIndex: 2)
        vm.submitVote(.a, voterIndex: 3)

        // Both earn 2 pts → tie
        XCTAssertGreaterThanOrEqual(vm.winners.count, 2)
        let winnerNames = vm.winners.map(\.name)
        XCTAssertTrue(winnerNames.contains("Player 1"))
        XCTAssertTrue(winnerNames.contains("Player 4"))
    }

    // MARK: - nextRound()

    func testNextRoundIncrementsRound() {
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        // init auto-starts round 1
        let vm = makeVM(roles: roles)
        vm.showQuestion()
        vm.startVoting()
        vm.submitVote(.a, voterIndex: 0)
        vm.submitVote(.snake, voterIndex: 1)
        vm.submitVote(.snake, voterIndex: 2)
        vm.submitVote(.a, voterIndex: 3)

        XCTAssertEqual(vm.currentRound, 1)
        vm.nextRound()  // starts round 2
        XCTAssertEqual(vm.currentRound, 2)
        XCTAssertEqual(vm.phase, .roleReveal(playerIndex: 0))
    }

    func testMongoosePlayerIndexCorrect() {
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles)
        vm.startRound()
        // Player index 3 should be mongoose
        XCTAssertEqual(vm.mongoosePlayerIndex, 3)
    }

    func testSnakeIndicesCorrect() {
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles)
        vm.startRound()
        XCTAssertEqual(vm.snakeIndices, [1, 2])
    }

    // MARK: - STORY-046: Scoring Edge Cases

    /// All non-snake players vote correctly → snakes earn 0, humans share points.
    func testAllCorrectVotesScenario() {
        // 4 players: H, S, S, M — answer A
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles, answer: "A")
        vm.showQuestion()
        vm.startVoting()
        vm.submitVote(.a, voterIndex: 0)     // human correct
        vm.submitVote(.snake, voterIndex: 1) // snake must vote snake
        vm.submitVote(.snake, voterIndex: 2) // snake must vote snake
        vm.submitVote(.a, voterIndex: 3)     // mongoose correct

        // 2 correct non-snake voters → each earns 2 pts
        XCTAssertEqual(vm.players[0].totalScore, 2)  // human
        XCTAssertEqual(vm.players[3].totalScore, 2)  // mongoose
        // 0 incorrect non-snakes → snakes earn 0
        XCTAssertEqual(vm.players[1].totalScore, 0)
        XCTAssertEqual(vm.players[2].totalScore, 0)
    }

    /// All non-snake players vote incorrectly → snakes earn maximum points.
    func testAllIncorrectVotesScenario() {
        // 4 players: H, S, S, M — answer A, everyone votes B
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles, answer: "A")
        vm.showQuestion()
        vm.startVoting()
        vm.submitVote(.b, voterIndex: 0)     // human incorrect
        vm.submitVote(.snake, voterIndex: 1) // snake votes snake
        vm.submitVote(.snake, voterIndex: 2) // snake votes snake
        vm.submitVote(.b, voterIndex: 3)     // mongoose incorrect

        // 2 incorrect non-snakes → each snake earns 2 pts
        XCTAssertEqual(vm.players[0].totalScore, 0)
        XCTAssertEqual(vm.players[3].totalScore, 0)
        XCTAssertEqual(vm.players[1].totalScore, 2)  // snake
        XCTAssertEqual(vm.players[2].totalScore, 2)  // snake
    }

    // MARK: - Player Count Edge Cases

    func testFourPlayerGame() {
        // 4 = minimum player count per RoleService distribution table
        let vm = makeVM(playerCount: 4)
        XCTAssertEqual(vm.players.count, 4)
        XCTAssertNotNil(vm.players[0].role)
    }

    func testEightPlayerGame() {
        // 8 = maximum player count per RoleService distribution table: 3H, 4S, 1M
        let players = makePlayers(count: 8)
        let qs = makeQuestionService()
        let vm = GameViewModel(players: players, questionService: qs)

        XCTAssertEqual(vm.players.count, 8)
        // All roles must be assigned
        for player in vm.players {
            XCTAssertNotNil(player.role)
        }
        // Distribution: 3 humans + 4 snakes + 1 mongoose = 8
        let humanCount = vm.players.filter { $0.role == .human }.count
        let snakeCount = vm.players.filter { $0.role == .snake }.count
        let mongooseCount = vm.players.filter { $0.role == .mongoose }.count
        XCTAssertEqual(humanCount, 3)
        XCTAssertEqual(snakeCount, 4)
        XCTAssertEqual(mongooseCount, 1)
    }

    // MARK: - Custom Round Count

    func testThreeRoundGameEndsAfterThreeRounds() {
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let players = makePlayers(count: 4)
        let qs = makeQuestionService()
        let vm = GameViewModel(
            players: players,
            questionService: qs,
            roleService: StubRoleService(fixedRoles: roles),
            totalRounds: 3
        )
        XCTAssertEqual(vm.totalRounds, 3)

        // Play 3 rounds
        for round in 1...3 {
            if round > 1 { vm.nextRound() }  // startRound for rounds 2+
            vm.showQuestion()
            vm.startVoting()
            vm.submitVote(.a, voterIndex: 0)
            vm.submitVote(.snake, voterIndex: 1)
            vm.submitVote(.snake, voterIndex: 2)
            vm.submitVote(.a, voterIndex: 3)
        }
        XCTAssertEqual(vm.phase, .roundResults)
        vm.nextRound()
        XCTAssertEqual(vm.phase, .gameEnd)
        XCTAssertEqual(vm.roundResults.count, 3)
    }

    func testNineRoundGameEndsAfterNineRounds() {
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let players = makePlayers(count: 4)
        let qs = makeQuestionService()
        let vm = GameViewModel(
            players: players,
            questionService: qs,
            roleService: StubRoleService(fixedRoles: roles),
            totalRounds: 9
        )
        XCTAssertEqual(vm.totalRounds, 9)

        for round in 1...9 {
            if round > 1 { vm.nextRound() }
            vm.showQuestion()
            vm.startVoting()
            vm.submitVote(.a, voterIndex: 0)
            vm.submitVote(.snake, voterIndex: 1)
            vm.submitVote(.snake, voterIndex: 2)
            vm.submitVote(.a, voterIndex: 3)
        }
        vm.nextRound()
        XCTAssertEqual(vm.phase, .gameEnd)
        XCTAssertEqual(vm.roundResults.count, 9)
    }

    // MARK: - Custom Timer Duration

    func testCustomTimerDurationSetsDiscussionRemaining() {
        let players = makePlayers(count: 4)
        let qs = makeQuestionService()
        let vm = GameViewModel(
            players: players,
            questionService: qs,
            timerDuration: 60
        )
        XCTAssertEqual(vm.timerDuration, 60)
        XCTAssertEqual(vm.discussionTimeRemaining, 60)
    }

    func testStartDiscussionResetsToCustomTimer() {
        let players = makePlayers(count: 4)
        let qs = makeQuestionService()
        let vm = GameViewModel(
            players: players,
            questionService: qs,
            totalRounds: 6,
            timerDuration: 90
        )
        vm.startDiscussion()
        XCTAssertEqual(vm.discussionTimeRemaining, 90)
        vm.cancelTimer()
    }

    // MARK: - Phase Transition Ordering

    func testPhasesTransitionInValidOrder() {
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles)

        // Post-init: roleReveal
        XCTAssertEqual(vm.phase, .roleReveal(playerIndex: 0))

        // Reveal all 4 roles → mongooseAnnouncement
        for i in 0..<4 { vm.revealNextRole(currentIndex: i) }
        XCTAssertEqual(vm.phase, .mongooseAnnouncement)

        // Show question
        vm.showQuestion()
        XCTAssertEqual(vm.phase, .question)

        // Snake reveal → all snakes
        vm.startSnakeReveal()
        XCTAssertEqual(vm.phase, .snakeReveal(snakeIndex: 0))
        vm.revealNextSnake(currentSnakeIndex: 0)
        XCTAssertEqual(vm.phase, .snakeReveal(snakeIndex: 1))
        vm.revealNextSnake(currentSnakeIndex: 1)
        XCTAssertEqual(vm.phase, .discussion)

        // Skip to voting
        vm.skipDiscussion()
        XCTAssertEqual(vm.phase, .voting(playerIndex: 0))

        // Vote all players → roundResults
        vm.submitVote(.a, voterIndex: 0)
        vm.submitVote(.snake, voterIndex: 1)
        vm.submitVote(.snake, voterIndex: 2)
        vm.submitVote(.a, voterIndex: 3)
        XCTAssertEqual(vm.phase, .roundResults)
    }

    // MARK: - Snake Forced Vote (Scoring)

    func testSnakeForcedVoteEarnsPointsWhenNonSnakesVoteWrong() {
        // Verify snakes benefit when non-snakes vote incorrectly
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles, answer: "A")
        vm.showQuestion()
        vm.startVoting()
        vm.submitVote(.c, voterIndex: 0)     // human incorrect
        vm.submitVote(.snake, voterIndex: 1) // snake
        vm.submitVote(.snake, voterIndex: 2) // snake
        vm.submitVote(.c, voterIndex: 3)     // mongoose incorrect

        // 2 incorrect non-snakes → each snake earns 2
        XCTAssertEqual(vm.players[1].totalScore, 2)
        XCTAssertEqual(vm.players[2].totalScore, 2)
    }

    func testSnakeVotingSnakeEarnsPointsBasedOnWrongNonSnakes() {
        // Only 1 non-snake player wrong → each snake earns 1
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles, answer: "A")
        vm.showQuestion()
        vm.startVoting()
        vm.submitVote(.b, voterIndex: 0)     // human incorrect
        vm.submitVote(.snake, voterIndex: 1) // snake
        vm.submitVote(.snake, voterIndex: 2) // snake
        vm.submitVote(.a, voterIndex: 3)     // mongoose correct

        // 1 incorrect non-snake → each snake earns 1
        XCTAssertEqual(vm.players[1].totalScore, 1)
        XCTAssertEqual(vm.players[2].totalScore, 1)
    }

    // MARK: - Question Uniqueness

    func testQuestionUniquenessWithinGame() {
        // Build a pool of 6 distinct questions
        let pool: [Question] = (1...6).map { i in
            Question(
                id: "q\(i)",
                question: "Question \(i)?",
                choices: Question.Choices(a: "A\(i)", b: "B\(i)", c: "C\(i)"),
                answer: "A",
                funFact: nil,
                category: nil
            )
        }
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let qs = QuestionService(questions: pool)
        let players = makePlayers(count: 4)
        let vm = GameViewModel(
            players: players,
            questionService: qs,
            roleService: StubRoleService(fixedRoles: roles),
            totalRounds: 6
        )

        var seenIDs: Set<String> = []
        for round in 1...6 {
            if round > 1 { vm.nextRound() }
            vm.showQuestion()
            guard let qID = vm.currentQuestion?.id else {
                XCTFail("No question set in round \(round)")
                return
            }
            XCTAssertFalse(seenIDs.contains(qID), "Duplicate question in round \(round): \(qID)")
            seenIDs.insert(qID)

            vm.startVoting()
            vm.submitVote(.a, voterIndex: 0)
            vm.submitVote(.snake, voterIndex: 1)
            vm.submitVote(.snake, voterIndex: 2)
            vm.submitVote(.a, voterIndex: 3)
        }
        XCTAssertEqual(seenIDs.count, 6)
    }

    // MARK: - Play-Again Resets State

    func testPlayAgainResetsStateCorrectly() {
        // Simulate "play again" by creating a fresh VM with the same players (as GameView does)
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let originalVM = makeVM(roles: roles)
        originalVM.showQuestion()
        originalVM.startVoting()
        originalVM.submitVote(.a, voterIndex: 0)
        originalVM.submitVote(.snake, voterIndex: 1)
        originalVM.submitVote(.snake, voterIndex: 2)
        originalVM.submitVote(.a, voterIndex: 3)
        // originalVM is in roundResults, players have scores

        // Fresh game — same players, new VM (mirrors GameView.restartGame())
        let freshPlayers = makePlayers(count: 4)
        let qs = makeQuestionService()
        let freshVM = GameViewModel(
            players: freshPlayers,
            questionService: qs,
            roleService: StubRoleService(fixedRoles: roles)
        )

        // State is fully reset
        XCTAssertEqual(freshVM.currentRound, 1)
        XCTAssertEqual(freshVM.roundResults.count, 0)
        XCTAssertEqual(freshVM.phase, .roleReveal(playerIndex: 0))
        for player in freshVM.players {
            XCTAssertEqual(player.totalScore, 0)
            XCTAssertNil(player.currentVote)
        }
    }

    // MARK: - New-Game from GameEnd

    func testNewGameFromGameEndViaFreshVM() {
        // New-game creates an entirely fresh VM — verify initial state is clean
        let players = makePlayers(count: 4)
        let qs = makeQuestionService()
        let vm = GameViewModel(players: players, questionService: qs)

        XCTAssertEqual(vm.currentRound, 1)
        XCTAssertTrue(vm.roundResults.isEmpty)
        XCTAssertEqual(vm.phase, .roleReveal(playerIndex: 0))
    }

    // MARK: - Votes Recorded Correctly

    func testAllVotesRecordedCorrectlyForEachPlayer() {
        let roles: [Role] = [.human, .snake, .snake, .mongoose]
        let vm = makeVM(roles: roles)
        vm.showQuestion()
        vm.startVoting()
        vm.submitVote(.a, voterIndex: 0)
        vm.submitVote(.snake, voterIndex: 1)
        vm.submitVote(.c, voterIndex: 2)
        vm.submitVote(.b, voterIndex: 3)

        XCTAssertEqual(vm.players[0].currentVote, .a)
        XCTAssertEqual(vm.players[1].currentVote, .snake)
        XCTAssertEqual(vm.players[2].currentVote, .c)
        XCTAssertEqual(vm.players[3].currentVote, .b)
    }
}
