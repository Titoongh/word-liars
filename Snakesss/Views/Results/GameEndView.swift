import SwiftUI

// MARK: - GameEndView

/// Final scoreboard with winner celebration. Shown after all 6 rounds.
struct GameEndView: View {
    let players: [Player]
    let results: [RoundResult]
    let onPlayAgain: () -> Void
    let onNewGame: () -> Void
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

            // Confetti particle system
            ConfettiView()

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
            SnakesssHaptic.celebration()
        }
    }

    // MARK: - Winner Section

    private var winnerSection: some View {
        VStack(spacing: SnakesssSpacing.spacing4) {
            Text("🏆")
                .font(.system(size: 72))
                .scaleEffect(isAnimating ? 1.0 : 0.3)
                .shadow(color: SnakesssTheme.truthGold.opacity(0.5), radius: 30)
                .goldGlow()

            Text("WINNER")
                .microStyle(color: SnakesssTheme.truthGold)

            if winners.count == 1 {
                VStack(spacing: SnakesssSpacing.spacing2) {
                    Text(winners[0].name)
                        .font(SnakesssTypography.playerName)
                        .foregroundStyle(SnakesssTheme.truthGold)
                        .goldGlow()
                        .scaleEffect(isAnimating ? 1.0 : 0.8)

                    Text("\(winners[0].totalScore) pts")
                        .font(SnakesssTypography.score)
                        .foregroundStyle(SnakesssTheme.truthGold)
                        .contentTransition(.numericText())
                }
            } else {
                VStack(spacing: SnakesssSpacing.spacing2) {
                    Text("It's a Tie!")
                        .font(SnakesssTypography.title)
                        .foregroundStyle(SnakesssTheme.truthGold)
                        .goldGlow()
                    Text(winners.map(\.name).joined(separator: " & "))
                        .font(SnakesssTypography.playerName)
                        .foregroundStyle(SnakesssTheme.truthGold)
                        .goldGlow()
                    Text("\(winners[0].totalScore) pts each")
                        .font(SnakesssTypography.bodyLarge)
                        .foregroundStyle(SnakesssTheme.textSecondary)
                        .contentTransition(.numericText())
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
                .contentTransition(.numericText())
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

            Button("New Game") {
                onNewGame()
            }
            .buttonStyle(SnakesssSecondaryButtonStyle())

            Button("Home") {
                onHome()
            }
            .font(SnakesssTypography.label)
            .foregroundStyle(SnakesssTheme.textMuted)
            .padding(.top, SnakesssSpacing.spacing2)
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

// MARK: - Confetti Particle System

private struct ConfettiView: View {
    struct Particle {
        let startX: Double       // 0–1 normalized
        let color: Color
        let size: Double
        let speed: Double        // pts/sec falling
        let drift: Double        // pts horizontal drift over 3s
        let spinRate: Double     // degrees/sec
        let delay: Double        // seconds before appearing
    }

    private let particles: [Particle] = (0..<60).map { i in
        Particle(
            startX: Double.random(in: 0.05...0.95),
            color: i % 3 == 0 ? ColorPrimitive.gold500 : ColorPrimitive.green400,
            size: Double.random(in: 5...10),
            speed: Double.random(in: 120...280),
            drift: Double.random(in: -40...40),
            spinRate: Double.random(in: 90...360),
            delay: Double.random(in: 0...0.8)
        )
    }

    @State private var startDate = Date.now

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startDate)
            Canvas { context, size in
                for p in particles {
                    let t = elapsed - p.delay
                    guard t > 0 && t < 3.5 else { continue }
                    let x = p.startX * Double(size.width) + t * p.drift
                    let y = t * p.speed
                    let rotation = p.spinRate * t
                    let fade = min(1.0, (3.5 - t) / 0.5)

                    let rect = CGRect(
                        x: x - p.size / 2,
                        y: y - p.size / 2,
                        width: p.size,
                        height: p.size * 0.5
                    )
                    let transform = CGAffineTransform(translationX: x, y: y)
                        .rotated(by: rotation * .pi / 180)
                        .translatedBy(x: -x, y: -y)

                    context.fill(
                        Path(rect).applying(transform),
                        with: .color(p.color.opacity(fade))
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
