import XCTest
@testable import Snakesss

// MARK: - GameFlowIntegrationTests

/// Integration tests that programmatically drive a complete game from player setup
/// through game end, exercising QuestionService, RoleService, ScoringService, and
/// GameViewModel together — no UI, no real timer waits.
@MainActor
final class GameFlowIntegrationTests: XCTestCase {

    // MARK: - Settings Restore

    private var savedRoundCount: Int = 6
    private var savedEnabledCategories: Set<String> = []

    override func setUp() {
        super.setUp()
        savedRoundCount = SettingsManager.shared.roundCount
        savedEnabledCategories = SettingsManager.shared.enabledCategories
        // Enable all categories so category tests start from a known baseline
        SettingsManager.shared.enabledCategories = Set(SettingsManager.allCategories)
    }

    override func tearDown() {
        SettingsManager.shared.roundCount = savedRoundCount
        SettingsManager.shared.enabledCategories = savedEnabledCategories
        super.tearDown()
    }

    // MARK: - Helpers: Stubs

    /// Deterministic role service — always returns the same ordered role list.
    private struct StubRoleService: RoleAssigning {
        let fixedRoles: [Role]
        func assignRoles(playerCount: Int) -> [Role] { fixedRoles }
    }

    /// Deterministic roles matching the real RoleService distribution for each player count.
    /// Order: humans first, then snakes, then mongoose — ensures predictable player indices.
    private func roles(for playerCount: Int) -> [Role] {
        switch playerCount {
        case 4: return [.human, .snake, .snake, .mongoose]
        case 5: return [.human, .human, .snake, .snake, .mongoose]
        case 6: return [.human, .human, .snake, .snake, .snake, .mongoose]
        case 7: return [.human, .human, .human, .snake, .snake, .snake, .mongoose]
        case 8: return [.human, .human, .human, .snake, .snake, .snake, .snake, .mongoose]
        default: preconditionFailure("Unsupported player count: \(playerCount)")
        }
    }

    // MARK: - Helpers: Factory

    private func makePlayers(count: Int) -> [Player] {
        (0..<count).map { i in
            Player(id: UUID(), name: "Player \(i + 1)", role: nil, totalScore: 0, currentVote: nil)
        }
    }

    /// Build questions with a fixed answer and optional category.
    private func makeQuestions(count: Int, answer: String = "A", category: String? = nil) -> [Question] {
        (0..<count).map { i in
            Question(
                id: "integration-q-\(i)",
                question: "Test question \(i)?",
                choices: .init(a: "Alpha", b: "Beta", c: "Gamma"),
                answer: answer,
                funFact: nil,
                category: category
            )
        }
    }

    /// Create a GameViewModel with deterministic roles and an in-memory question pool.
    /// - Note: GameViewModel.init() automatically calls startRound(), so after this call
    ///   vm.currentRound == 1 and vm.phase == .roleReveal(playerIndex: 0).
    private func makeVM(
        playerCount: Int = 4,
        roundCount: Int = 6,
        answer: String = "A",
        questions: [Question]? = nil
    ) -> GameViewModel {
        SettingsManager.shared.roundCount = roundCount
        let qs = QuestionService(questions: questions ?? makeQuestions(count: max(roundCount, 1), answer: answer))
        let rs = StubRoleService(fixedRoles: roles(for: playerCount))
        return GameViewModel(
            players: makePlayers(count: playerCount),
            questionService: qs,
            roleService: rs
        )
    }

    // MARK: - Helpers: Game Engine Driver

    /// Drive one complete round from .roleReveal(playerIndex: 0) through .roundResults.
    /// - Non-snake players all vote the correct answer (.a for answer "A").
    /// - Snake players vote .snake.
    /// - Uses skipDiscussion() — zero real timer waits.
    private func playRound(_ vm: GameViewModel) {
        let playerCount = vm.players.count
        let snakeCount = vm.snakeIndices.count

        // Phase: .roleReveal(playerIndex: 0) — reveal every player in sequence
        for i in 0..<playerCount {
            vm.revealNextRole(currentIndex: i)
        }
        // → .mongooseAnnouncement (after last player)

        vm.showQuestion()
        // → .question

        vm.startSnakeReveal()
        // → .snakeReveal(snakeIndex: 0)  OR  .discussion if no snakes exist

        for i in 0..<snakeCount {
            vm.revealNextSnake(currentSnakeIndex: i)
        }
        // → .discussion (last revealNextSnake triggers startDiscussion())

        vm.skipDiscussion()
        // → .voting(playerIndex: 0)

        for i in 0..<playerCount {
            let role = vm.players[i].role ?? .human
            vm.submitVote(role == .snake ? .snake : .a, voterIndex: i)
        }
        // → .roundResults (last submitVote triggers showResults())
    }

    /// Drive a complete game (all rounds) and advance to .gameEnd.
    private func playFullGame(_ vm: GameViewModel) {
        // vm is already in round 1 after init — play every round then call nextRound()
        for _ in 1...vm.totalRounds {
            playRound(vm)
            vm.nextRound()
            // - If more rounds remain: nextRound() calls startRound() → roleReveal(playerIndex: 0)
            // - After final round: nextRound() sets phase = .gameEnd
        }
    }

    // MARK: - Tests: Player Count Variants

    func testFourPlayerGameCompletesFullFlow() {
        let vm = makeVM(playerCount: 4, roundCount: 6)
        playFullGame(vm)
        XCTAssertEqual(vm.phase, .gameEnd, "4-player game should end in .gameEnd")
        XCTAssertEqual(vm.roundResults.count, 6, "Should accumulate 6 RoundResults")
    }

    func testSixPlayerGameCompletesFullFlow() {
        let vm = makeVM(playerCount: 6, roundCount: 6)
        playFullGame(vm)
        XCTAssertEqual(vm.phase, .gameEnd, "6-player game should end in .gameEnd")
        XCTAssertEqual(vm.roundResults.count, 6)
    }

    func testEightPlayerGameCompletesFullFlow() {
        let vm = makeVM(playerCount: 8, roundCount: 6)
        playFullGame(vm)
        XCTAssertEqual(vm.phase, .gameEnd, "8-player game should end in .gameEnd")
        XCTAssertEqual(vm.roundResults.count, 6)
    }

    // MARK: - Tests: Custom Round Counts (Settings)

    func testThreeRoundGameCompletesCorrectly() {
        let vm = makeVM(playerCount: 4, roundCount: 3)
        XCTAssertEqual(vm.totalRounds, 3, "totalRounds should reflect the settings value")
        playFullGame(vm)
        XCTAssertEqual(vm.phase, .gameEnd)
        XCTAssertEqual(vm.roundResults.count, 3, "Should have exactly 3 RoundResults")
    }

    func testNineRoundGameCompletesCorrectly() {
        let vm = makeVM(playerCount: 4, roundCount: 9)
        XCTAssertEqual(vm.totalRounds, 9, "totalRounds should reflect the settings value")
        playFullGame(vm)
        XCTAssertEqual(vm.phase, .gameEnd)
        XCTAssertEqual(vm.roundResults.count, 9, "Should have exactly 9 RoundResults")
    }

    // MARK: - Tests: Score Correctness

    /// 4 players: [human, snake, snake, mongoose]
    /// Non-snakes vote correctly every round → correctVoterCount = 2, incorrectNonSnakeCount = 0
    /// Each non-snake earns 2 pts/round. Total per round = 4. Over 6 rounds = 24.
    func testFinalScoresSumCorrectlyFourPlayers() {
        let vm = makeVM(playerCount: 4, roundCount: 6, answer: "A")
        playFullGame(vm)
        let total = vm.players.reduce(0) { $0 + $1.totalScore }
        XCTAssertEqual(total, 24, "4p×6r: 2 correct voters×2pts each = 4/round, ×6 = 24")
    }

    /// 6 players: [human, human, snake, snake, snake, mongoose]
    /// 3 correct non-snake voters → each earns 3 pts/round. Total per round = 9. Over 6 = 54.
    func testFinalScoresSumCorrectlySixPlayers() {
        let vm = makeVM(playerCount: 6, roundCount: 6, answer: "A")
        playFullGame(vm)
        let total = vm.players.reduce(0) { $0 + $1.totalScore }
        XCTAssertEqual(total, 54, "6p×6r: 3 correct voters×3pts each = 9/round, ×6 = 54")
    }

    /// 8 players: [human, human, human, snake, snake, snake, snake, mongoose]
    /// 4 correct non-snake voters → each earns 4 pts/round. Total per round = 16. Over 6 = 96.
    func testFinalScoresSumCorrectlyEightPlayers() {
        let vm = makeVM(playerCount: 8, roundCount: 6, answer: "A")
        playFullGame(vm)
        let total = vm.players.reduce(0) { $0 + $1.totalScore }
        XCTAssertEqual(total, 96, "8p×6r: 4 correct voters×4pts each = 16/round, ×6 = 96")
    }

    func testRoundResultsAccumulateAcrossAllRounds() {
        let vm = makeVM(playerCount: 4, roundCount: 6)
        playFullGame(vm)
        XCTAssertEqual(vm.roundResults.count, 6)
        // Round numbers must be sequential 1…6
        let roundNumbers = vm.roundResults.map(\.roundNumber)
        XCTAssertEqual(roundNumbers, Array(1...6), "Round numbers should be sequential")
    }

    func testIndividualPlayerScoresAreCorrectAfterSixRounds() {
        // [human(0), snake(1), snake(2), mongoose(3)], answer = "A"
        // Each round: human +2, snakes +0, mongoose +2
        // After 6 rounds: human=12, snakes=0 each, mongoose=12
        let vm = makeVM(playerCount: 4, roundCount: 6, answer: "A")
        playFullGame(vm)
        XCTAssertEqual(vm.players[0].totalScore, 12, "Human should have 12 pts")
        XCTAssertEqual(vm.players[1].totalScore, 0,  "Snake 1 should have 0 pts")
        XCTAssertEqual(vm.players[2].totalScore, 0,  "Snake 2 should have 0 pts")
        XCTAssertEqual(vm.players[3].totalScore, 12, "Mongoose should have 12 pts")
    }

    // MARK: - Tests: Winner Determination

    func testMultipleWinnersInTieScenario() {
        // Human and Mongoose both vote correctly every round → tied at 12 pts after 6 rounds
        let vm = makeVM(playerCount: 4, roundCount: 6, answer: "A")
        playFullGame(vm)
        XCTAssertEqual(vm.winners.count, 2, "Human and Mongoose should be co-winners")
        let names = Set(vm.winners.map(\.name))
        XCTAssertTrue(names.contains("Player 1"), "Player 1 (human) should be a winner")
        XCTAssertTrue(names.contains("Player 4"), "Player 4 (mongoose) should be a winner")
    }

    func testSingleWinnerIdentifiedCorrectly() {
        // 3-round game. Roles: [human(0), snake(1), snake(2), mongoose(3)], answer = "A"
        //
        // Round 1 (playRound — both non-snakes correct):
        //   correctVoterCount=2, incorrectNonSnakeCount=0
        //   human +2, s1 +0, s2 +0, mongoose +2  → running: [2,0,0,2]
        //
        // Round 2 (manual — human correct alone, mongoose wrong):
        //   correctVoterCount=1, incorrectNonSnakeCount=1 (mongoose)
        //   human +1, s1 +1, s2 +1, mongoose +0  → running: [3,1,1,2]
        //
        // Round 3 (playRound — both non-snakes correct again):
        //   correctVoterCount=2, incorrectNonSnakeCount=0
        //   human +2, s1 +0, s2 +0, mongoose +2  → final: [5,1,1,4]
        //
        // Winner: Player 1 (human) with 5 pts.
        let vm = makeVM(playerCount: 4, roundCount: 3, answer: "A")

        // Round 1
        playRound(vm)
        // → .roundResults

        // Advance to round 2
        vm.nextRound()
        // → startRound() → currentRound=2, roleReveal(playerIndex:0)

        // Round 2: manual with mongoose voting wrong
        let pc = vm.players.count
        for i in 0..<pc { vm.revealNextRole(currentIndex: i) }
        vm.showQuestion()
        vm.startSnakeReveal()
        for i in 0..<vm.snakeIndices.count { vm.revealNextSnake(currentSnakeIndex: i) }
        vm.skipDiscussion()
        vm.submitVote(.a,     voterIndex: 0)  // human — correct
        vm.submitVote(.snake, voterIndex: 1)  // snake 1
        vm.submitVote(.snake, voterIndex: 2)  // snake 2
        vm.submitVote(.b,     voterIndex: 3)  // mongoose — WRONG
        // → .roundResults

        // Advance to round 3
        vm.nextRound()
        // → startRound() → currentRound=3, roleReveal(playerIndex:0)

        // Round 3
        playRound(vm)
        // → .roundResults

        // End game
        vm.nextRound()
        // currentRound(3) >= totalRounds(3) → .gameEnd

        XCTAssertEqual(vm.phase, .gameEnd)
        XCTAssertEqual(vm.winners.count, 1, "There should be exactly one winner")
        XCTAssertEqual(vm.winners[0].name, "Player 1", "Player 1 (human) should win")
        XCTAssertEqual(vm.winners[0].totalScore, 5, "Human should have 5 total points")
    }

    func testWinnersHaveHighestScore() {
        let vm = makeVM(playerCount: 4, roundCount: 6, answer: "A")
        playFullGame(vm)
        let maxScore = vm.players.map(\.totalScore).max() ?? 0
        XCTAssertTrue(vm.winners.allSatisfy { $0.totalScore == maxScore }, "All winners must have the maximum score")
        XCTAssertFalse(vm.winners.isEmpty, "There must be at least one winner")
    }

    // MARK: - Tests: Phase Transition Order

    func testAllPhaseTransitionsOccurInCorrectOrder() {
        let vm = makeVM(playerCount: 4, roundCount: 6)
        let snakeCount = vm.snakeIndices.count  // 2 for 4-player game

        // ── Round start (from init) ──────────────────────────────────────────
        XCTAssertEqual(vm.phase, .roleReveal(playerIndex: 0))
        XCTAssertEqual(vm.currentRound, 1)

        // ── Role reveals (4 players) ─────────────────────────────────────────
        vm.revealNextRole(currentIndex: 0)
        XCTAssertEqual(vm.phase, .roleReveal(playerIndex: 1))
        vm.revealNextRole(currentIndex: 1)
        XCTAssertEqual(vm.phase, .roleReveal(playerIndex: 2))
        vm.revealNextRole(currentIndex: 2)
        XCTAssertEqual(vm.phase, .roleReveal(playerIndex: 3))
        vm.revealNextRole(currentIndex: 3)
        XCTAssertEqual(vm.phase, .mongooseAnnouncement)

        // ── Question ─────────────────────────────────────────────────────────
        vm.showQuestion()
        XCTAssertEqual(vm.phase, .question)
        XCTAssertNotNil(vm.currentQuestion)

        // ── Snake reveals (2 snakes) ─────────────────────────────────────────
        vm.startSnakeReveal()
        XCTAssertEqual(vm.phase, .snakeReveal(snakeIndex: 0))
        for i in 0..<snakeCount - 1 {
            vm.revealNextSnake(currentSnakeIndex: i)
            XCTAssertEqual(vm.phase, .snakeReveal(snakeIndex: i + 1))
        }
        vm.revealNextSnake(currentSnakeIndex: snakeCount - 1)
        XCTAssertEqual(vm.phase, .discussion)

        // ── Skip discussion ───────────────────────────────────────────────────
        vm.skipDiscussion()
        XCTAssertEqual(vm.phase, .voting(playerIndex: 0))

        // ── Voting (4 players) ───────────────────────────────────────────────
        vm.submitVote(.a,     voterIndex: 0)
        XCTAssertEqual(vm.phase, .voting(playerIndex: 1))
        vm.submitVote(.snake, voterIndex: 1)
        XCTAssertEqual(vm.phase, .voting(playerIndex: 2))
        vm.submitVote(.snake, voterIndex: 2)
        XCTAssertEqual(vm.phase, .voting(playerIndex: 3))
        vm.submitVote(.a,     voterIndex: 3)
        XCTAssertEqual(vm.phase, .roundResults)

        // ── Advance to round 2 ───────────────────────────────────────────────
        vm.nextRound()
        XCTAssertEqual(vm.currentRound, 2)
        XCTAssertEqual(vm.phase, .roleReveal(playerIndex: 0))

        // ── Play remaining rounds and reach game end ──────────────────────────
        for round in 2...6 {
            playRound(vm)
            vm.nextRound()
            if round < 6 {
                XCTAssertEqual(vm.currentRound, round + 1)
                XCTAssertEqual(vm.phase, .roleReveal(playerIndex: 0))
            } else {
                XCTAssertEqual(vm.phase, .gameEnd)
            }
        }
    }

    // MARK: - Tests: Settings Integration

    func testSettingsRoundCountIsReadFromSettingsManager() {
        // Create two VMs with different round counts via SettingsManager
        let vm3 = makeVM(playerCount: 4, roundCount: 3)
        XCTAssertEqual(vm3.totalRounds, 3, "totalRounds must equal SettingsManager.roundCount at init")

        let vm9 = makeVM(playerCount: 4, roundCount: 9)
        XCTAssertEqual(vm9.totalRounds, 9, "totalRounds must equal SettingsManager.roundCount at init")
    }

    func testCategoryFilterAppliedByQuestionService() {
        // Build a mixed pool: 5 Science (answer "A") + 5 History (answer "B")
        let scienceQs = makeQuestions(count: 5, answer: "A", category: "Science")
        let historyQs  = makeQuestions(count: 5, answer: "B", category: "History")

        // Enable only Science
        SettingsManager.shared.enabledCategories = ["Science"]
        let qs = QuestionService(questions: scienceQs + historyQs)

        // Draw 5 questions — all must be Science
        var drawn: [Question] = []
        for _ in 0..<5 {
            if let q = qs.getQuestion() { drawn.append(q) }
        }

        XCTAssertEqual(drawn.count, 5, "Should draw 5 questions")
        XCTAssertTrue(
            drawn.allSatisfy { $0.category == "Science" },
            "All drawn questions must be from the Science category"
        )
        XCTAssertFalse(
            drawn.contains { $0.category == "History" },
            "No History questions should appear when category is filtered out"
        )
    }

    func testCategoryFilterIntegrationInFullGame() {
        // Only "Science" questions enabled; answer = "A"
        let scienceQs = makeQuestions(count: 9, answer: "A", category: "Science")
        let historyQs  = makeQuestions(count: 9, answer: "B", category: "History")
        SettingsManager.shared.enabledCategories = ["Science"]
        SettingsManager.shared.roundCount = 6

        let qs = QuestionService(questions: scienceQs + historyQs)
        let rs = StubRoleService(fixedRoles: roles(for: 4))
        let vm = GameViewModel(players: makePlayers(count: 4), questionService: qs, roleService: rs)

        playFullGame(vm)

        XCTAssertEqual(vm.phase, .gameEnd)
        // All questions used in the 6 rounds must be Science category
        let usedCategories = vm.roundResults.map { $0.question.category }
        XCTAssertTrue(
            usedCategories.allSatisfy { $0 == "Science" },
            "All questions in a Science-only session should be from Science category"
        )
    }

    // MARK: - Tests: Robustness

    func testAllSupportedPlayerCountsCompleteWithoutCrash() {
        // Exercise every valid player count from 4 to 8
        for playerCount in [4, 5, 6, 7, 8] {
            let vm = makeVM(playerCount: playerCount, roundCount: 6)
            playFullGame(vm)
            XCTAssertEqual(vm.phase, .gameEnd, "\(playerCount)-player game must reach .gameEnd")
            XCTAssertEqual(vm.roundResults.count, 6, "\(playerCount)-player game must have 6 round results")
        }
    }

    func testGameHandlesQuestionPoolExhaustionGracefully() {
        // Only 1 unique question provided — QuestionService must recycle it for 6 rounds
        let vm = makeVM(
            playerCount: 4,
            roundCount: 6,
            questions: makeQuestions(count: 1, answer: "A")
        )
        playFullGame(vm)
        XCTAssertEqual(vm.phase, .gameEnd, "Game must complete even when question pool is recycled")
        XCTAssertEqual(vm.roundResults.count, 6)
    }

    func testRoundResultsContainCorrectRoundNumbers() {
        let vm = makeVM(playerCount: 4, roundCount: 6)
        playFullGame(vm)
        for (index, result) in vm.roundResults.enumerated() {
            XCTAssertEqual(result.roundNumber, index + 1, "Round result at index \(index) should have roundNumber \(index + 1)")
        }
    }

    func testAllPlayersHaveVotesRecordedInEveryRound() {
        let vm = makeVM(playerCount: 4, roundCount: 6)
        playFullGame(vm)
        for result in vm.roundResults {
            XCTAssertEqual(result.votes.count, 4, "Every round result must contain a vote for each player")
        }
    }
}
