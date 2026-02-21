import Foundation
import SwiftData

// MARK: - RoleAssigning Protocol

/// Abstraction over RoleService for testability (RoleService is final).
protocol RoleAssigning {
    func assignRoles(playerCount: Int) -> [Role]
}

extension RoleService: RoleAssigning {}

// MARK: - GameViewModel

/// Central game engine. Manages the full GamePhase state machine from round start
/// through game end. @Observable so SwiftUI views auto-update on every phase change.
@Observable
@MainActor
final class GameViewModel {

    // MARK: - Public State

    var players: [Player]
    var currentRound: Int = 0
    var phase: GamePhase = .setup
    var currentQuestion: Question?
    var roundResults: [RoundResult] = []
    var discussionTimeRemaining: Int

    // MARK: - Private State

    private(set) var snakeIndices: [Int] = []   // indices into players[] of snakes this round
    private var currentRoleAssignments: [Role] = []

    // MARK: - Dependencies

    private let questionService: QuestionService
    private let roleService: any RoleAssigning
    private let scoringService: ScoringService

    // MARK: - Timer

    private var timerTask: Task<Void, Never>?

    // MARK: - Settings-driven Constants

    /// Total rounds — read once from SettingsManager at game start.
    let totalRounds: Int

    /// Discussion timer duration — read once from SettingsManager at game start.
    let timerDuration: Int

    // MARK: - Init

    init(
        players: [Player],
        questionService: QuestionService = QuestionService(),
        roleService: any RoleAssigning = RoleService(),
        scoringService: ScoringService = ScoringService()
    ) {
        let settings = SettingsManager.shared
        self.totalRounds = settings.roundCount
        self.timerDuration = settings.timerDuration
        self.discussionTimeRemaining = settings.timerDuration
        self.players = players
        self.questionService = questionService
        self.roleService = roleService
        self.scoringService = scoringService
        startRound()
    }

    // MARK: - Computed Helpers

    /// Mongoose player index for the current round (nil if none assigned yet).
    var mongoosePlayerIndex: Int? {
        currentRoleAssignments.enumerated().first(where: { $0.element == .mongoose })?.offset
    }

    /// Snake player names for the current round.
    var snakePlayerNames: [String] {
        snakeIndices.map { players[$0].name }
    }

    /// Determine the winner(s) — highest total score. May be multiple on a tie.
    var winners: [Player] {
        guard let maxScore = players.map(\.totalScore).max() else { return [] }
        return players.filter { $0.totalScore == maxScore }
    }

    // MARK: - Phase Transitions

    /// Begin a new round: assign roles, set first role-reveal player.
    func startRound() {
        currentRound += 1
        let roles = roleService.assignRoles(playerCount: players.count)
        currentRoleAssignments = roles

        // Assign roles to players
        for i in players.indices {
            players[i].role = roles[i]
            players[i].currentVote = nil
        }

        // Derive snake indices for later (snake-reveal phase)
        snakeIndices = players.indices.filter { roles[$0] == .snake }

        phase = .roleReveal(playerIndex: 0)
        SnakesssHaptic.medium()
    }

    /// Advance through role reveals, then transition to mongooseAnnouncement.
    func revealNextRole(currentIndex: Int) {
        let nextIndex = currentIndex + 1
        if nextIndex < players.count {
            phase = .roleReveal(playerIndex: nextIndex)
            SnakesssHaptic.medium()
        } else {
            phase = .mongooseAnnouncement
            SnakesssHaptic.heavy()
        }
    }

    /// Transition from mongoose announcement to question display.
    func showQuestion() {
        guard let q = questionService.getQuestion() else { return }
        currentQuestion = q
        phase = .question
        SnakesssHaptic.medium()
    }

    /// Begin snake reveal phase (snakeIndex 0).
    func startSnakeReveal() {
        if snakeIndices.isEmpty {
            // No snakes (edge case) — skip straight to discussion
            startDiscussion()
        } else {
            phase = .snakeReveal(snakeIndex: 0)
            SnakesssHaptic.heavy()
        }
    }

    /// Advance through snake reveals, then transition to discussion.
    func revealNextSnake(currentSnakeIndex: Int) {
        let nextSnakeIndex = currentSnakeIndex + 1
        if nextSnakeIndex < snakeIndices.count {
            phase = .snakeReveal(snakeIndex: nextSnakeIndex)
            SnakesssHaptic.medium()
        } else {
            startDiscussion()
        }
    }

    /// Start the discussion timer and enter discussion phase.
    func startDiscussion() {
        phase = .discussion
        startTimer()
        SnakesssHaptic.medium()
    }

    /// Cancel the timer early and jump straight to voting.
    func skipDiscussion() {
        timerTask?.cancel()
        timerTask = nil
        startVoting()
    }

    /// Begin pass-and-play voting starting with player 0.
    func startVoting() {
        phase = .voting(playerIndex: 0)
        SnakesssHaptic.medium()
    }

    /// Record a vote for the current voter, then advance or show results.
    func submitVote(_ vote: Vote, voterIndex: Int) {
        players[voterIndex].currentVote = vote
        SnakesssHaptic.light()

        let nextVoterIndex = voterIndex + 1
        if nextVoterIndex < players.count {
            phase = .voting(playerIndex: nextVoterIndex)
        } else {
            showResults()
        }
    }

    /// Calculate scores via ScoringService, create RoundResult, update running totals.
    func showResults() {
        guard let question = currentQuestion else { return }

        let roles: [(playerIndex: Int, role: Role)] = players.indices.compactMap { i in
            guard let role = players[i].role else { return nil }
            return (playerIndex: i, role: role)
        }

        let votes: [(playerIndex: Int, vote: Vote)] = players.indices.compactMap { i in
            guard let vote = players[i].currentVote else { return nil }
            return (playerIndex: i, vote: vote)
        }

        let pointsEarned = scoringService.calculateRoundScores(
            players: players,
            roles: roles,
            votes: votes,
            correctAnswer: question.answer
        )

        // Update running totals
        for entry in pointsEarned {
            players[entry.playerIndex].totalScore += entry.points
        }

        let result = RoundResult(
            roundNumber: currentRound,
            question: question,
            roles: roles,
            votes: votes,
            pointsEarned: pointsEarned
        )
        roundResults.append(result)

        phase = .roundResults
        SnakesssHaptic.success()
    }

    /// After viewing results: start next round or end the game.
    func nextRound() {
        if currentRound >= totalRounds {
            AudioService.shared.stopBackgroundMusic()  // STORY-025
            phase = .gameEnd
            SnakesssHaptic.celebration()
        } else {
            startRound()
        }
    }

    // MARK: - Persistence

    /// Creates a GameRecord and inserts it into the SwiftData model context.
    /// Call once when transitioning to .gameEnd phase.
    func saveGame(to modelContext: ModelContext) {
        let record = GameRecord(
            date: Date(),
            playerNames: players.map(\.name),
            finalScores: players.map(\.totalScore),
            winnerNames: winners.map(\.name),
            roundCount: currentRound
        )
        modelContext.insert(record)
    }

    // MARK: - Timer

    func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    func startTimer() {
        discussionTimeRemaining = timerDuration
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            while !Task.isCancelled && discussionTimeRemaining > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                discussionTimeRemaining -= 1
                if discussionTimeRemaining == 30 {
                    SnakesssHaptic.timerWarning()
                    AudioService.shared.playSound(.timerWarning)  // STORY-025
                } else if discussionTimeRemaining <= 10 && discussionTimeRemaining > 0 {
                    SnakesssHaptic.medium()
                    AudioService.shared.playSound(.timerTick)     // STORY-025
                }
            }
            if !Task.isCancelled {
                SnakesssHaptic.timerEnd()
                startVoting()
            }
        }
    }
}
