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
                    caption: "passPhone.tapToVote.caption",
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
                // Line 1: "NOW VOTING" — micro
                Text("voting.nowVoting.label")
                    .microStyle(color: SnakesssTheme.textMuted)
                // Line 2: player name — playerName typography (32pt Heavy)
                Text(player.name)
                    .font(SnakesssTypography.playerName)
                    .foregroundStyle(SnakesssTheme.textPrimary)
                // Line 3: "Player X of Y" — caption, muted
                Text(String(localized: "voting.playerBadge \(playerIndex + 1) \(totalPlayers)"))
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
            Button(LocalizedStringKey("voting.confirmVote.button")) {
                guard let vote = selectedVote else { return }
                SnakesssHaptic.medium()
                AudioService.shared.playSound(.voteConfirm)  // STORY-025
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
            Text("voting.question.label")
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
        .accessibilityLabel(String(localized: "voting.vote.accessibility \(letter) \(text)"))
    }

    // MARK: - Snake Voting (forced)

    private var snakeVotingContent: some View {
        VStack(spacing: SnakesssSpacing.spacing6) {
            Text("snakeReveal.youAreSnake.label")
                .font(SnakesssTypography.headline)
                .foregroundStyle(SnakesssTheme.snakeColor)

            Text("voting.snake.forced.body")
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
                    Text("voting.voteSnake.button")
                        .font(SnakesssTypography.bodyLarge)
                        .foregroundStyle(SnakesssTheme.snakeColor)
                }
                .frame(maxWidth: .infinity)
                .padding(SnakesssSpacing.spacing8)
            }
            .buttonStyle(SnakesssVoteButtonStyle(isSelected: selectedVote == .snake))
            .accessibilityLabel("Vote Snake")
            .padding(.horizontal, SnakesssSpacing.screenPadding)
        }
    }
}
