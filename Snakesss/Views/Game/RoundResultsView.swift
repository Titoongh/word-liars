import SwiftUI

// MARK: - RoundResultsView

/// Shows correct answer, all votes, all roles, and points earned this round.
struct RoundResultsView: View {
    let result: RoundResult
    let players: [Player]
    let isLastRound: Bool
    let onNext: () -> Void

    var body: some View {
        ZStack {
            SnakesssTheme.bgBase.ignoresSafeArea()
            SnakesssTheme.goldRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

            ScrollView {
                VStack(spacing: SnakesssSpacing.spacing6) {
                    // Header
                    VStack(spacing: SnakesssSpacing.spacing2) {
                        Text("Round \(result.roundNumber) Results")
                            .microStyle(color: SnakesssTheme.textMuted)
                            .padding(.top, SnakesssSpacing.spacing8)

                        Text("The Answer")
                            .font(SnakesssTypography.headline)
                            .foregroundStyle(SnakesssTheme.textPrimary)
                    }

                    // Correct answer card
                    correctAnswerCard

                    // Fun fact
                    if let fact = result.question.funFact {
                        funFactCard(fact)
                    }

                    // Player breakdown
                    VStack(spacing: SnakesssSpacing.spacing2) {
                        Text("How Everyone Did")
                            .font(SnakesssTypography.label)
                            .foregroundStyle(SnakesssTheme.textSecondary)

                        ForEach(Array(players.enumerated()), id: \.offset) { index, player in
                            playerResultRow(playerIndex: index, player: player)
                        }
                    }

                    // Scoreboard
                    scoreboardCard

                    // Continue button
                    Button(isLastRound ? "See Final Results" : "Next Round →") {
                        onNext()
                    }
                    .buttonStyle(SnakesssPrimaryButtonStyle())
                    .padding(.horizontal, SnakesssSpacing.screenPadding)
                    .padding(.bottom, SnakesssSpacing.spacing12)
                }
                .padding(.horizontal, SnakesssSpacing.screenPadding)
            }
        }
    }

    // MARK: - Correct Answer Card

    private var correctAnswerCard: some View {
        VStack(spacing: SnakesssSpacing.spacing3) {
            Text(result.question.question)
                .font(SnakesssTypography.body)
                .foregroundStyle(SnakesssTheme.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: SnakesssSpacing.spacing3) {
                Text("Correct:")
                    .font(SnakesssTypography.label)
                    .foregroundStyle(SnakesssTheme.textMuted)

                Text(result.question.answer.uppercased())
                    .font(SnakesssTypography.title)
                    .foregroundStyle(SnakesssTheme.truthGold)
                    .goldGlow()

                Text(correctAnswerText)
                    .font(SnakesssTypography.bodyLarge)
                    .foregroundStyle(SnakesssTheme.textPrimary)
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
    }

    private func funFactCard(_ fact: String) -> some View {
        HStack(alignment: .top, spacing: SnakesssSpacing.spacing3) {
            Text("💡")
                .font(.system(size: 20))
            Text(fact)
                .font(SnakesssTypography.caption)
                .foregroundStyle(SnakesssTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(SnakesssSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: SnakesssRadius.radiusMd)
                .fill(SnakesssTheme.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusMd)
                        .strokeBorder(SnakesssTheme.borderSubtle, lineWidth: 1)
                )
        )
    }

    // MARK: - Player Result Row

    private func playerResultRow(playerIndex: Int, player: Player) -> some View {
        let role = roleFor(playerIndex)
        let vote = voteFor(playerIndex)
        let points = pointsFor(playerIndex)
        let isSnakeVote = vote == .some(.snake)
        let isCorrect = voteIsCorrect(vote)
        let stripeColor: Color = isSnakeVote ? SnakesssTheme.snakeColor :
                                 isCorrect    ? SnakesssTheme.accentPrimary :
                                               SnakesssTheme.danger

        return HStack(spacing: 0) {
            // Left accent stripe
            Rectangle()
                .fill(stripeColor)
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            HStack(spacing: SnakesssSpacing.spacing3) {
                // Player name
                Text(player.name)
                    .font(SnakesssTypography.bodyLarge)
                    .foregroundStyle(SnakesssTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Role badge
                if let r = role {
                    RoleBadgeView(role: r)
                }

                // Vote
                if let v = vote {
                    Text(voteLabel(v))
                        .font(SnakesssTypography.label)
                        .foregroundStyle(isCorrect ? SnakesssTheme.truthGold : SnakesssTheme.danger)
                }

                // Points
                Text("+\(points)")
                    .font(SnakesssTypography.bodyLarge)
                    .foregroundStyle(points > 0 ? SnakesssTheme.accentPrimary : SnakesssTheme.textMuted)
                    .frame(minWidth: 40, alignment: .trailing)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, SnakesssSpacing.spacing4)
            .padding(.vertical, SnakesssSpacing.spacing3)
        }
        .background(
            RoundedRectangle(cornerRadius: SnakesssRadius.radiusMd)
                .fill(SnakesssTheme.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusMd)
                        .strokeBorder(SnakesssTheme.borderSubtle, lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: SnakesssRadius.radiusMd))
    }

    // MARK: - Scoreboard

    private var scoreboardCard: some View {
        VStack(spacing: SnakesssSpacing.spacing3) {
            Text("Scores After Round \(result.roundNumber)")
                .font(SnakesssTypography.label)
                .foregroundStyle(SnakesssTheme.textSecondary)

            ForEach(sortedPlayers, id: \.id) { player in
                HStack {
                    Text(player.name)
                        .font(SnakesssTypography.body)
                        .foregroundStyle(SnakesssTheme.textPrimary)
                    Spacer()
                    Text("\(player.totalScore) pts")
                        .font(SnakesssTypography.bodyLarge)
                        .foregroundStyle(SnakesssTheme.accentPrimary)
                        .contentTransition(.numericText())
                }
                .padding(.horizontal, SnakesssSpacing.spacing4)
                .padding(.vertical, SnakesssSpacing.spacing2)
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

    // MARK: - Helpers

    private var sortedPlayers: [Player] {
        players.sorted { $0.totalScore > $1.totalScore }
    }

    private var correctAnswerText: String {
        switch result.question.answer.uppercased() {
        case "A": return result.question.choices.a
        case "B": return result.question.choices.b
        case "C": return result.question.choices.c
        default: return ""
        }
    }

    private func roleFor(_ index: Int) -> Role? {
        result.roles.first(where: { $0.playerIndex == index })?.role
    }

    private func voteFor(_ index: Int) -> Vote? {
        result.votes.first(where: { $0.playerIndex == index })?.vote
    }

    private func pointsFor(_ index: Int) -> Int {
        result.pointsEarned.first(where: { $0.playerIndex == index })?.points ?? 0
    }

    private func voteLabel(_ vote: Vote) -> String {
        switch vote {
        case .a: return "A"
        case .b: return "B"
        case .c: return "C"
        case .snake: return "🐍"
        }
    }

    private func voteIsCorrect(_ vote: Vote?) -> Bool {
        guard let v = vote else { return false }
        let correct = result.question.answer.lowercased()
        switch v {
        case .a: return correct == "a"
        case .b: return correct == "b"
        case .c: return correct == "c"
        case .snake: return false
        }
    }
}
