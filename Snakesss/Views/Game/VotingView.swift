import SwiftUI

// MARK: - VotingView

/// Pass-and-play secret voting for one player. Snakes are forced to vote "Snake".
struct VotingView: View {
    let player: Player
    let playerIndex: Int
    let totalPlayers: Int
    let question: Question?
    let onVote: (Vote) -> Void

    @State private var isRevealed = false
    @State private var selectedVote: Vote? = nil

    var body: some View {
        ZStack {
            SnakesssTheme.bgBase.ignoresSafeArea()
                .scaleTexture() // M1
            SnakesssTheme.greenRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

            if isRevealed {
                votingContent
                    .transition(.opacity.combined(with: .scale(scale: 0.94)))
            } else {
                PassPhoneOverlay(
                    playerName: player.name,
                    caption: "Tap to begin voting",
                    onTap: {
                        withAnimation(SnakesssAnimation.reveal) {
                            isRevealed = true
                            selectedVote = nil
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(SnakesssAnimation.reveal, value: isRevealed)
        .onChange(of: player.id) { _, _ in
            isRevealed = false
            selectedVote = nil
        }
    }

    // MARK: - Voting Content

    private var votingContent: some View {
        VStack(spacing: 0) {
            // S2: 3-line header — micro + playerName + caption
            VStack(spacing: SnakesssSpacing.spacing2) {
                Text("NOW VOTING")
                    .microStyle(color: SnakesssTheme.textMuted)
                Text(player.name)
                    .font(SnakesssTypography.playerName)
                    .foregroundStyle(SnakesssTheme.textPrimary)
                Text("Player \(playerIndex + 1) of \(totalPlayers)")
                    .font(SnakesssTypography.caption)
                    .foregroundStyle(SnakesssTheme.textMuted)
            }
            .padding(.top, SnakesssSpacing.spacing8)

            Spacer()

            if player.role == .snake {
                snakeVotingContent
            } else {
                humanVotingContent
            }

            Spacer()

            // Confirm button (active only when a vote is selected)
            Button("Confirm Vote") {
                guard let vote = selectedVote else { return }
                SnakesssHaptic.medium()
                withAnimation(SnakesssAnimation.standard) {
                    isRevealed = false
                }
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(150))
                    onVote(vote)
                }
            }
            .buttonStyle(SnakesssPrimaryButtonStyle())
            .disabled(selectedVote == nil)
            .padding(.horizontal, SnakesssSpacing.screenPadding)
            .padding(.bottom, SnakesssSpacing.spacing12)
        }
    }

    // MARK: - Human / Mongoose Voting (A/B/C)

    private var humanVotingContent: some View {
        VStack(spacing: SnakesssSpacing.spacing6) {
            Text("What is the correct answer?")
                .font(SnakesssTypography.label)
                .foregroundStyle(SnakesssTheme.textSecondary)
                .multilineTextAlignment(.center)

            if let q = question {
                HStack(spacing: SnakesssSpacing.spacing3) {
                    voteButton(vote: .a, letter: "A", text: q.choices.a)
                    voteButton(vote: .b, letter: "B", text: q.choices.b)
                    voteButton(vote: .c, letter: "C", text: q.choices.c)
                }
                .padding(.horizontal, SnakesssSpacing.screenPadding)
            }
        }
    }

    private func voteButton(vote: Vote, letter: String, text: String) -> some View {
        Button {
            SnakesssHaptic.light()
            withAnimation(SnakesssAnimation.bouncy) {
                selectedVote = vote
            }
        } label: {
            VoteButtonContent(letter: letter, answer: text)
        }
        .buttonStyle(SnakesssVoteButtonStyle(isSelected: selectedVote == vote))
    }

    // MARK: - Snake Voting (forced)

    private var snakeVotingContent: some View {
        VStack(spacing: SnakesssSpacing.spacing6) {
            Text("You are a Snake 🐍")
                .font(SnakesssTypography.headline)
                .foregroundStyle(SnakesssTheme.snakeColor)

            Text("You must vote Snake.\nThe humans cannot know you're a Snake until results.")
                .font(SnakesssTypography.body)
                .foregroundStyle(SnakesssTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, SnakesssSpacing.spacing8)

            Button {
                SnakesssHaptic.heavy()
                withAnimation(SnakesssAnimation.bouncy) {
                    selectedVote = .snake
                }
            } label: {
                VStack(spacing: SnakesssSpacing.spacing2) {
                    Text("🐍")
                        .font(.system(size: 48))
                    Text("Vote Snake")
                        .font(SnakesssTypography.bodyLarge)
                        .foregroundStyle(SnakesssTheme.snakeColor)
                }
                .frame(maxWidth: .infinity)
                .padding(SnakesssSpacing.spacing8)
            }
            .buttonStyle(SnakesssVoteButtonStyle(isSelected: selectedVote == .snake))
            .padding(.horizontal, SnakesssSpacing.screenPadding)
        }
    }
}
