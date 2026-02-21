import SwiftUI

// MARK: - GameEndView

/// Final scoreboard with winner celebration. Shown after all 6 rounds.
struct GameEndView: View {
    let players: [Player]
    let results: [RoundResult]
    let onPlayAgain: () -> Void
    let onHome: () -> Void

    @State private var isAnimating = false

    var winners: [Player] {
        guard let maxScore = players.map(\.totalScore).max() else { return [] }
        return players.filter { $0.totalScore == maxScore }
    }

    var sortedPlayers: [Player] {
        players.sorted { $0.totalScore > $1.totalScore }
    }

    var body: some View {
        ZStack {
            SnakesssTheme.bgBase.ignoresSafeArea()
            SnakesssTheme.goldRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

            ScrollView {
                VStack(spacing: SnakesssSpacing.spacing8) {
                    // Trophy + winner announcement
                    winnerSection

                    // Final scoreboard
                    scoreboardSection

                    // Action buttons
                    actionButtons
                        .padding(.bottom, SnakesssSpacing.spacing12)
                }
                .padding(.horizontal, SnakesssSpacing.screenPadding)
                .padding(.top, SnakesssSpacing.spacing8)
            }
        }
        .onAppear {
            withAnimation(SnakesssAnimation.celebration) {
                isAnimating = true
            }
        }
    }

    // MARK: - Winner Section

    private var winnerSection: some View {
        VStack(spacing: SnakesssSpacing.spacing4) {
            Text("🏆")
                .font(.system(size: 80))
                .scaleEffect(isAnimating ? 1.0 : 0.3)
                .shadow(color: SnakesssTheme.truthGold.opacity(0.5), radius: 30)
                .goldGlow()

            Text("Game Over!")
                .microStyle(color: SnakesssTheme.textMuted)

            if winners.count == 1 {
                VStack(spacing: SnakesssSpacing.spacing2) {
                    Text(winners[0].name)
                        .font(SnakesssTypography.title)
                        .foregroundStyle(SnakesssTheme.truthGold)
                        .goldGlow()
                    Text("wins with \(winners[0].totalScore) points!")
                        .font(SnakesssTypography.bodyLarge)
                        .foregroundStyle(SnakesssTheme.textSecondary)
                }
            } else {
                VStack(spacing: SnakesssSpacing.spacing2) {
                    Text("It's a Tie!")
                        .font(SnakesssTypography.title)
                        .foregroundStyle(SnakesssTheme.truthGold)
                        .goldGlow()
                    Text(winners.map(\.name).joined(separator: " & "))
                        .font(SnakesssTypography.bodyLarge)
                        .foregroundStyle(SnakesssTheme.textSecondary)
                    Text("all won with \(winners[0].totalScore) points!")
                        .font(SnakesssTypography.body)
                        .foregroundStyle(SnakesssTheme.textMuted)
                }
            }
        }
        .scaleEffect(isAnimating ? 1.0 : 0.85)
    }

    // MARK: - Scoreboard

    private var scoreboardSection: some View {
        VStack(spacing: SnakesssSpacing.spacing3) {
            Text("Final Scores")
                .font(SnakesssTypography.label)
                .foregroundStyle(SnakesssTheme.textSecondary)

            ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { rank, player in
                scoreRow(rank: rank + 1, player: player)
            }
        }
        .padding(SnakesssSpacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                .fill(SnakesssTheme.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                        .strokeBorder(SnakesssTheme.borderSubtle, lineWidth: 1)
                )
        )
    }

    private func scoreRow(rank: Int, player: Player) -> some View {
        let isWinner = winners.contains(where: { $0.id == player.id })
        return HStack(spacing: SnakesssSpacing.spacing3) {
            // Rank
            Text(rankEmoji(rank: rank, isWinner: isWinner))
                .font(.system(size: 24))
                .frame(width: 32)

            // Name
            Text(player.name)
                .font(SnakesssTypography.bodyLarge)
                .foregroundStyle(isWinner ? SnakesssTheme.truthGold : SnakesssTheme.textPrimary)

            Spacer()

            // Score
            Text("\(player.totalScore)")
                .font(SnakesssTypography.headline)
                .foregroundStyle(isWinner ? SnakesssTheme.truthGold : SnakesssTheme.textPrimary)
                .goldGlow()
        }
        .padding(.vertical, SnakesssSpacing.spacing2)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: SnakesssSpacing.spacing3) {
            Button("Play Again (Same Players)") {
                onPlayAgain()
            }
            .buttonStyle(SnakesssPrimaryButtonStyle())

            Button("Back to Home") {
                onHome()
            }
            .buttonStyle(SnakesssSecondaryButtonStyle())
        }
    }

    // MARK: - Helpers

    private func rankEmoji(rank: Int, isWinner: Bool) -> String {
        if isWinner { return "🏆" }
        switch rank {
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)."
        }
    }
}
