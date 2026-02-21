import SwiftUI
import SwiftData

// MARK: - GameView (Phase Router)

/// Root container for the active game. Switches child views based on `viewModel.phase`.
struct GameView: View {
    @State var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            SnakesssTheme.bgBase.ignoresSafeArea()

            phaseView
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
        .animation(SnakesssAnimation.standard, value: viewModel.phase)
        .onChange(of: viewModel.phase) { _, newPhase in
            if newPhase == .gameEnd {
                viewModel.saveGame(to: modelContext)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if viewModel.phase == .setup {
                    Button("← Back") { dismiss() }
                        .font(SnakesssTypography.caption)
                        .foregroundStyle(SnakesssTheme.textSecondary)
                }
            }
        }
        .onAppear {
            viewModel.startRound()
        }
    }

    // MARK: - Phase Router

    @ViewBuilder
    private var phaseView: some View {
        switch viewModel.phase {
        case .setup:
            EmptyView()

        case .roleReveal(let playerIndex):
            RoleRevealView(
                player: viewModel.players[playerIndex],
                playerIndex: playerIndex,
                totalPlayers: viewModel.players.count,
                roundNumber: viewModel.currentRound,
                onDone: { viewModel.revealNextRole(currentIndex: playerIndex) }
            )

        case .mongooseAnnouncement:
            MongooseAnnouncementView(
                mongooseName: mongooseName,
                onContinue: { viewModel.showQuestion() }
            )

        case .question:
            if let question = viewModel.currentQuestion {
                QuestionView(
                    question: question,
                    roundNumber: viewModel.currentRound,
                    mongooseName: mongooseName,
                    onContinue: { viewModel.startSnakeReveal() }
                )
            }

        case .snakeReveal(let snakeIndex):
            SnakeRevealView(
                snake: viewModel.players[viewModel.snakeIndices[snakeIndex]],
                snakeIndex: snakeIndex,
                totalSnakes: viewModel.snakeIndices.count,
                allSnakeNames: viewModel.snakePlayerNames,
                correctAnswer: viewModel.currentQuestion?.answer ?? "",
                question: viewModel.currentQuestion,
                onDone: { viewModel.revealNextSnake(currentSnakeIndex: snakeIndex) }
            )

        case .discussion:
            if let question = viewModel.currentQuestion {
                DiscussionTimerView(
                    question: question,
                    timeRemaining: viewModel.discussionTimeRemaining,
                    mongooseName: mongooseName,
                    onSkip: { viewModel.skipDiscussion() }
                )
            }

        case .voting(let playerIndex):
            VotingView(
                player: viewModel.players[playerIndex],
                playerIndex: playerIndex,
                totalPlayers: viewModel.players.count,
                question: viewModel.currentQuestion,
                onVote: { vote in viewModel.submitVote(vote, voterIndex: playerIndex) }
            )

        case .roundResults:
            if let result = viewModel.roundResults.last {
                RoundResultsView(
                    result: result,
                    players: viewModel.players,
                    isLastRound: viewModel.currentRound >= GameViewModel.totalRounds,
                    onNext: { viewModel.nextRound() }
                )
            }

        case .gameEnd:
            GameEndView(
                players: viewModel.players,
                results: viewModel.roundResults,
                onPlayAgain: { restartGame() },
                onNewGame: { dismiss() },
                onHome: { dismiss() }
            )
        }
    }

    // MARK: - Helpers

    private var mongooseName: String {
        if let idx = viewModel.mongoosePlayerIndex {
            return viewModel.players[idx].name
        }
        return "???"
    }

    private func restartGame() {
        // Reset to a fresh game with the same players
        let freshPlayers = viewModel.players.map { p in
            Player(id: UUID(), name: p.name, role: nil, totalScore: 0, currentVote: nil)
        }
        viewModel = GameViewModel(players: freshPlayers)
        viewModel.startRound()
    }
}
