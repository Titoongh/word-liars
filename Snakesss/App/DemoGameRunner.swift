import SwiftUI
import SwiftData

/// Auto-advancing demo that walks through every game phase for screenshot capture.
/// Activated via launch argument: -demo
struct DemoGameRunner: View {
    @State private var coordinator = GameNavigationCoordinator()
    @State private var viewModel: GameViewModel?
    @State private var demoPhaseLabel = "Starting..."

    // Controls auto-advance timing
    private let phaseDelay: TimeInterval = 3.0

    var body: some View {
        NavigationStack {
            ZStack {
                if let vm = viewModel {
                    DemoGameView(viewModel: vm, phaseDelay: phaseDelay)
                } else {
                    SnakesssTheme.bgBase.ignoresSafeArea()
                    Text("Initializing demo...")
                        .foregroundStyle(SnakesssTheme.textPrimary)
                }
            }
        }
        .environment(coordinator)
        .onAppear { startDemo() }
    }

    private func startDemo() {
        let players = [
            Player(id: UUID(), name: "Alice", role: nil, totalScore: 0, currentVote: nil),
            Player(id: UUID(), name: "Bob", role: nil, totalScore: 0, currentVote: nil),
            Player(id: UUID(), name: "Charlie", role: nil, totalScore: 0, currentVote: nil),
            Player(id: UUID(), name: "Diana", role: nil, totalScore: 0, currentVote: nil),
        ]
        let vm = GameViewModel(
            players: players,
            totalRounds: 1,
            timerDuration: 10  // Short timer for demo
        )
        viewModel = vm
    }
}

/// Wraps GameView but auto-advances through each phase.
struct DemoGameView: View {
    @State var viewModel: GameViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(GameNavigationCoordinator.self) private var coordinator

    let phaseDelay: TimeInterval

    // Track internal reveal states for pass-and-play views
    @State private var autoAdvanceTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            SnakesssTheme.bgBase.ignoresSafeArea()
            phaseView
        }
        .animation(SnakesssAnimation.standard, value: viewModel.phase)
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.phase) { _, newPhase in
            scheduleAutoAdvance(for: newPhase)
            if newPhase == .gameEnd {
                viewModel.saveGame(to: modelContext)
            }
        }
        .onAppear {
            AudioService.shared.stopBackgroundMusic()
            scheduleAutoAdvance(for: viewModel.phase)
        }
        .onDisappear {
            viewModel.cancelTimer()
            autoAdvanceTask?.cancel()
        }
    }

    // MARK: - Phase Router (same as GameView but auto-reveals)

    @ViewBuilder
    private var phaseView: some View {
        switch viewModel.phase {
        case .setup:
            EmptyView()

        case .roleReveal(let playerIndex):
            // Show role directly (skip pass-phone overlay)
            DemoRoleRevealView(
                player: viewModel.players[playerIndex],
                playerIndex: playerIndex,
                totalPlayers: viewModel.players.count,
                roundNumber: viewModel.currentRound,
                totalRounds: viewModel.totalRounds
            )

        case .mongooseAnnouncement:
            MongooseAnnouncementView(
                mongooseName: mongooseName,
                onContinue: { }  // Auto-advanced
            )

        case .question:
            if let question = viewModel.currentQuestion {
                QuestionView(
                    question: question,
                    roundNumber: viewModel.currentRound,
                    mongooseName: mongooseName,
                    onContinue: { }
                )
            }

        case .snakeReveal(let snakeIndex):
            DemoSnakeRevealView(
                snake: viewModel.players[viewModel.snakeIndices[snakeIndex]],
                snakeIndex: snakeIndex,
                totalSnakes: viewModel.snakeIndices.count,
                allSnakeNames: viewModel.snakePlayerNames,
                correctAnswer: viewModel.currentQuestion?.answer ?? "",
                question: viewModel.currentQuestion
            )

        case .discussion:
            if let question = viewModel.currentQuestion {
                DiscussionTimerView(
                    question: question,
                    timeRemaining: viewModel.discussionTimeRemaining,
                    timerDuration: viewModel.timerDuration,
                    mongooseName: mongooseName,
                    onSkip: { }
                )
            }

        case .voting(let playerIndex):
            DemoVotingView(
                player: viewModel.players[playerIndex],
                playerIndex: playerIndex,
                totalPlayers: viewModel.players.count,
                question: viewModel.currentQuestion
            )

        case .roundResults:
            if let result = viewModel.roundResults.last {
                RoundResultsView(
                    result: result,
                    players: viewModel.players,
                    isLastRound: viewModel.currentRound >= viewModel.totalRounds,
                    onNext: { }
                )
            }

        case .gameEnd:
            GameEndView(
                players: viewModel.players,
                results: viewModel.roundResults,
                onPlayAgain: { },
                onNewGame: { },
                onHome: { }
            )
        }
    }

    // MARK: - Auto-Advance

    private func scheduleAutoAdvance(for phase: GamePhase) {
        autoAdvanceTask?.cancel()
        autoAdvanceTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(phaseDelay))
            guard !Task.isCancelled else { return }
            advancePhase(phase)
        }
    }

    private func advancePhase(_ phase: GamePhase) {
        switch phase {
        case .setup:
            break

        case .roleReveal(let playerIndex):
            viewModel.revealNextRole(currentIndex: playerIndex)

        case .mongooseAnnouncement:
            viewModel.showQuestion()

        case .question:
            viewModel.startSnakeReveal()

        case .snakeReveal(let snakeIndex):
            viewModel.revealNextSnake(currentSnakeIndex: snakeIndex)

        case .discussion:
            viewModel.skipDiscussion()

        case .voting(let playerIndex):
            // Auto-vote: snakes vote .snake, humans vote .a
            let player = viewModel.players[playerIndex]
            let vote: Vote = player.role == .snake ? .snake : .a
            viewModel.submitVote(vote, voterIndex: playerIndex)

        case .roundResults:
            viewModel.nextRound()

        case .gameEnd:
            break  // Stay on game end screen
        }
    }

    private var mongooseName: String {
        if let idx = viewModel.mongoosePlayerIndex {
            return viewModel.players[idx].name
        }
        return "???"
    }
}

// MARK: - Demo Role Reveal (auto-revealed, no pass-phone)

struct DemoRoleRevealView: View {
    let player: Player
    let playerIndex: Int
    let totalPlayers: Int
    let roundNumber: Int
    let totalRounds: Int

    var body: some View {
        ZStack {
            SnakesssTheme.bgBase.ignoresSafeArea()
                .scaleTexture()
            SnakesssTheme.greenRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: 0) {
                // Header
                VStack(spacing: SnakesssSpacing.spacing2) {
                    Text(String(localized: "roleReveal.roundBadge \(roundNumber) \(totalRounds)"))
                        .microStyle(color: SnakesssTheme.textMuted)
                    Text(String(localized: "roleReveal.playerBadge \(playerIndex + 1) \(totalPlayers)"))
                        .microStyle(color: SnakesssTheme.textSecondary)
                }
                .padding(.top, SnakesssSpacing.spacing8)

                Spacer()

                // Role card (always revealed)
                if let role = player.role {
                    VStack(spacing: SnakesssSpacing.spacing4) {
                        Text(role.emoji)
                            .font(.system(size: 72))
                            .shadow(color: role.glowColor, radius: 24)

                        Text("roleReveal.yourRole.label")
                            .microStyle(color: SnakesssTheme.textMuted)

                        Text(role.displayName.uppercased())
                            .font(SnakesssTypography.title)
                            .foregroundStyle(role.color)
                            .shadow(color: role.glowColor, radius: 12)

                        Text(player.name)
                            .font(SnakesssTypography.playerName)
                            .foregroundStyle(SnakesssTheme.textPrimary)

                        Text(role.flavorText)
                            .font(SnakesssTypography.body)
                            .foregroundStyle(SnakesssTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, SnakesssSpacing.spacing8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(SnakesssSpacing.spacing8)
                    .background(
                        RoundedRectangle(cornerRadius: SnakesssRadius.radiusLargeCard)
                            .fill(SnakesssTheme.bgCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: SnakesssRadius.radiusLargeCard)
                                    .strokeBorder(role.color.opacity(0.40), lineWidth: 2)
                            )
                    )
                    .shadow(color: role.glowColor, radius: 24)
                    .padding(.horizontal, SnakesssSpacing.screenPadding)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Demo Snake Reveal (auto-revealed)

struct DemoSnakeRevealView: View {
    let snake: Player
    let snakeIndex: Int
    let totalSnakes: Int
    let allSnakeNames: [String]
    let correctAnswer: String
    let question: Question?

    var body: some View {
        ZStack {
            SnakesssTheme.bgBase.ignoresSafeArea()
                .scaleTexture()
            SnakesssTheme.greenRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: SnakesssSpacing.spacing6) {
                    VStack(spacing: SnakesssSpacing.spacing2) {
                        Text(snake.name)
                            .font(SnakesssTypography.headline)
                            .foregroundStyle(SnakesssTheme.textPrimary)
                        Text("snakeReveal.youAreSnake.label")
                            .font(SnakesssTypography.label)
                            .foregroundStyle(SnakesssTheme.snakeColor)
                    }

                    // Correct answer card
                    VStack(spacing: SnakesssSpacing.spacing2) {
                        Text("snakeReveal.correctAnswer.label")
                            .microStyle(color: SnakesssTheme.textMuted)
                        Text(correctAnswer.uppercased())
                            .font(SnakesssTypography.title)
                            .foregroundStyle(SnakesssTheme.truthGold)
                            .goldGlow()
                        if let text = answerText {
                            Text(text)
                                .font(SnakesssTypography.body)
                                .foregroundStyle(SnakesssTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(SnakesssSpacing.cardPadding)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                            .fill(SnakesssTheme.truthGoldDim)
                            .overlay(
                                RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                                    .strokeBorder(SnakesssTheme.truthGold.opacity(0.30), lineWidth: 1.5)
                            )
                    )

                    if allSnakeNames.count > 1 {
                        VStack(spacing: SnakesssSpacing.spacing2) {
                            Text("snakeReveal.fellowSnakes.label")
                                .microStyle(color: SnakesssTheme.textMuted)
                            let otherSnakes = allSnakeNames.indices
                                .filter { $0 != snakeIndex }
                                .map { allSnakeNames[$0] }
                            ForEach(otherSnakes, id: \.self) { name in
                                Text("🐍 \(name)")
                                    .font(SnakesssTypography.bodyLarge)
                                    .foregroundStyle(SnakesssTheme.snakeColor)
                            }
                        }
                    }
                }
                .padding(SnakesssSpacing.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusLargeCard)
                        .fill(SnakesssTheme.bgCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: SnakesssRadius.radiusLargeCard)
                                .strokeBorder(SnakesssTheme.snakeColor.opacity(0.25), lineWidth: 1.5)
                        )
                )
                .snakesssGlow(SnakesssShadow.glowAccent)
                .padding(.horizontal, SnakesssSpacing.screenPadding)

                Spacer()
            }
        }
    }

    private var answerText: String? {
        guard let q = question else { return nil }
        switch correctAnswer.uppercased() {
        case "A": return q.choices.a
        case "B": return q.choices.b
        case "C": return q.choices.c
        default: return nil
        }
    }
}

// MARK: - Demo Voting View (auto-revealed, shows vote UI)

struct DemoVotingView: View {
    let player: Player
    let playerIndex: Int
    let totalPlayers: Int
    let question: Question?

    var body: some View {
        ZStack {
            SnakesssTheme.bgBase.ignoresSafeArea()
                .scaleTexture()
            SnakesssTheme.greenRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: 0) {
                // Header
                VStack(spacing: SnakesssSpacing.spacing2) {
                    Text("voting.nowVoting.label")
                        .microStyle(color: SnakesssTheme.textMuted)
                    Text(player.name)
                        .font(SnakesssTypography.playerName)
                        .foregroundStyle(SnakesssTheme.textPrimary)
                    Text(String(localized: "voting.playerBadge \(playerIndex + 1) \(totalPlayers)"))
                        .font(SnakesssTypography.caption)
                        .foregroundStyle(SnakesssTheme.textMuted)
                }
                .padding(.top, SnakesssSpacing.spacing8)

                Spacer()

                if player.role == .snake {
                    VStack(spacing: SnakesssSpacing.spacing6) {
                        Text("snakeReveal.youAreSnake.label")
                            .font(SnakesssTypography.headline)
                            .foregroundStyle(SnakesssTheme.snakeColor)
                        Text("voting.snake.forced.body")
                            .font(SnakesssTypography.body)
                            .foregroundStyle(SnakesssTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, SnakesssSpacing.spacing8)
                        VStack(spacing: SnakesssSpacing.spacing2) {
                            Text("🐍").font(.system(size: 48))
                            Text("voting.voteSnake.button")
                                .font(SnakesssTypography.bodyLarge)
                                .foregroundStyle(SnakesssTheme.snakeColor)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(SnakesssSpacing.spacing8)
                        .background(
                            RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                                .fill(SnakesssTheme.bgElevated)
                                .overlay(
                                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                                        .strokeBorder(SnakesssTheme.snakeColor, lineWidth: 2)
                                )
                        )
                        .padding(.horizontal, SnakesssSpacing.screenPadding)
                    }
                } else {
                    VStack(spacing: SnakesssSpacing.spacing6) {
                        Text("voting.question.label")
                            .font(SnakesssTypography.label)
                            .foregroundStyle(SnakesssTheme.textSecondary)
                            .multilineTextAlignment(.center)
                        if let q = question {
                            HStack(spacing: SnakesssSpacing.spacing3) {
                                demoVoteButton(letter: "A", text: q.choices.a)
                                demoVoteButton(letter: "B", text: q.choices.b)
                                demoVoteButton(letter: "C", text: q.choices.c)
                            }
                            .padding(.horizontal, SnakesssSpacing.screenPadding)
                        }
                    }
                }

                Spacer()
            }
        }
    }

    private func demoVoteButton(letter: String, text: String) -> some View {
        VStack(spacing: SnakesssSpacing.spacing2) {
            Text(letter)
                .font(SnakesssTypography.headline)
                .foregroundStyle(SnakesssTheme.accentPrimary)
            Text(text)
                .font(SnakesssTypography.caption)
                .foregroundStyle(SnakesssTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity)
        .padding(SnakesssSpacing.spacing4)
        .background(
            RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                .fill(SnakesssTheme.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                        .strokeBorder(SnakesssTheme.borderSubtle, lineWidth: 1.5)
                )
        )
    }
}
