import SwiftUI

// MARK: - Onboarding Page 1: Game Concept

/// Page 1 — Trivia + Social Deduction concept introduction.
struct OnboardingPage1View: View {
    var body: some View {
        ScrollView {
            VStack(spacing: SnakesssSpacing.spacing8) {
                Spacer(minLength: SnakesssSpacing.spacing8)

                // Hero
                VStack(spacing: SnakesssSpacing.spacing4) {
                    Text("🐍")
                        .font(.system(size: 80))
                        .shadow(color: SnakesssTheme.accentPrimary.opacity(0.4), radius: 24)
                        .accessibilityHidden(true)

                    Text("Snakesss")
                        .font(SnakesssTypography.display)
                        .foregroundStyle(SnakesssTheme.accentPrimary)
                        .accentGlow()
                        .accessibilityAddTraits(.isHeader)

                    Text("TRUST NOBODY")
                        .microStyle(color: SnakesssTheme.textMuted)
                }

                // Divider
                Rectangle()
                    .fill(SnakesssTheme.borderSubtle)
                    .frame(height: 1)
                    .padding(.horizontal, SnakesssSpacing.screenPadding)
                    .accessibilityHidden(true)

                // Concept card
                VStack(alignment: .leading, spacing: SnakesssSpacing.spacing4) {
                    Text("WHAT IS THIS GAME?")
                        .microStyle(color: SnakesssTheme.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Trivia meets Social Deduction")
                        .font(SnakesssTypography.headline)
                        .foregroundStyle(SnakesssTheme.textPrimary)

                    Text("Answer trivia questions, vote on the right answer — but watch out. Some players secretly know the truth and will try to lead you astray.")
                        .font(SnakesssTypography.body)
                        .foregroundStyle(SnakesssTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(SnakesssSpacing.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                        .fill(SnakesssTheme.bgElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                                .strokeBorder(SnakesssTheme.borderSubtle, lineWidth: 1)
                        )
                )
                .padding(.horizontal, SnakesssSpacing.screenPadding)

                Spacer(minLength: SnakesssSpacing.spacing8)
            }
        }
        .scrollIndicators(.hidden)
        .accessibilityLabel("Page 1: Game concept. Snakesss is a trivia and social deduction game where some players secretly know the truth.")
    }
}

// MARK: - Onboarding Page 2: Roles

/// Page 2 — The three roles explained with role badges.
struct OnboardingPage2View: View {
    var body: some View {
        ScrollView {
            VStack(spacing: SnakesssSpacing.spacing6) {
                Spacer(minLength: SnakesssSpacing.spacing6)

                VStack(spacing: SnakesssSpacing.spacing2) {
                    Text("THE ROLES")
                        .microStyle(color: SnakesssTheme.textMuted)
                    Text("Who are you playing as?")
                        .font(SnakesssTypography.headline)
                        .foregroundStyle(SnakesssTheme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                }

                VStack(spacing: SnakesssSpacing.spacing3) {
                    RoleExplanationCard(role: .human, description: "You don't know the answer. Listen carefully, find clues, and vote for what you believe is correct.")
                    RoleExplanationCard(role: .snake, description: "You know the correct answer — but keep it secret! Mislead the group and vote snake to earn points.")
                    RoleExplanationCard(role: .mongoose, description: "You don't know the answer, but your identity is public. You're a trusted ally helping humans find the truth.")
                }
                .padding(.horizontal, SnakesssSpacing.screenPadding)

                Spacer(minLength: SnakesssSpacing.spacing8)
            }
        }
        .scrollIndicators(.hidden)
        .accessibilityLabel("Page 2: The three roles — Human, Snake, and Mongoose — and what each role does.")
    }
}

// MARK: - Role Explanation Card

/// A card explaining a single role with its badge and description.
private struct RoleExplanationCard: View {
    let role: Role
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: SnakesssSpacing.spacing4) {
            Text(role.emoji)
                .font(.system(size: 36))
                .frame(width: 48)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: SnakesssSpacing.spacing2) {
                RoleBadgeView(role: role)
                    .accessibilityLabel("\(role.displayName) role")

                Text(description)
                    .font(SnakesssTypography.body)
                    .foregroundStyle(SnakesssTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(SnakesssSpacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                .fill(SnakesssTheme.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                        .strokeBorder(role.color.opacity(0.25), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Onboarding Page 3: Round Flow

/// Page 3 — Visual summary of the 6 game phases.
struct OnboardingPage3View: View {
    private let phases: [(icon: String, title: String, description: String)] = [
        ("person.fill",            "Role Reveal",     "Each player secretly sees their role card."),
        ("questionmark.circle",    "Question",        "A trivia question is shown to everyone."),
        ("eye.slash.fill",         "Snake Reveal",    "Snakes secretly learn the correct answer."),
        ("timer",                  "Discussion",      "2 minutes to discuss and debate answers."),
        ("hand.point.up.left.fill","Voting",          "Each player votes for their chosen answer."),
        ("trophy.fill",            "Results",         "Votes, roles, and points are revealed."),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: SnakesssSpacing.spacing6) {
                Spacer(minLength: SnakesssSpacing.spacing6)

                VStack(spacing: SnakesssSpacing.spacing2) {
                    Text("EACH ROUND")
                        .microStyle(color: SnakesssTheme.textMuted)
                    Text("6 phases per round")
                        .font(SnakesssTypography.headline)
                        .foregroundStyle(SnakesssTheme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                }

                VStack(spacing: 0) {
                    ForEach(Array(phases.enumerated()), id: \.offset) { index, phase in
                        PhaseRow(
                            number: index + 1,
                            icon: phase.icon,
                            title: phase.title,
                            description: phase.description,
                            isLast: index == phases.count - 1
                        )
                    }
                }
                .padding(.horizontal, SnakesssSpacing.screenPadding)
                .background(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                        .fill(SnakesssTheme.bgElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                                .strokeBorder(SnakesssTheme.borderSubtle, lineWidth: 1)
                        )
                )
                .padding(.horizontal, SnakesssSpacing.screenPadding)

                Spacer(minLength: SnakesssSpacing.spacing8)
            }
        }
        .scrollIndicators(.hidden)
        .accessibilityLabel("Page 3: Each round has 6 phases — Role Reveal, Question, Snake Reveal, Discussion, Voting, and Results.")
    }
}

// MARK: - Phase Row

private struct PhaseRow: View {
    let number: Int
    let icon: String
    let title: String
    let description: String
    let isLast: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: SnakesssSpacing.spacing3) {
                // Step number badge
                ZStack {
                    Circle()
                        .fill(SnakesssTheme.accentPrimary.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Text("\(number)")
                        .font(SnakesssTypography.micro)
                        .foregroundStyle(SnakesssTheme.accentPrimary)
                        .tracking(0)
                }
                .accessibilityHidden(true)

                // Icon
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(SnakesssTheme.accentPrimary)
                    .frame(width: 24)
                    .accessibilityHidden(true)

                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(SnakesssTypography.label)
                        .foregroundStyle(SnakesssTheme.textPrimary)
                    Text(description)
                        .font(SnakesssTypography.caption)
                        .foregroundStyle(SnakesssTheme.textSecondary)
                }

                Spacer()
            }
            .padding(.vertical, SnakesssSpacing.spacing3)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Phase \(number): \(title). \(description)")

            if !isLast {
                Rectangle()
                    .fill(SnakesssTheme.borderSubtle)
                    .frame(height: 1)
                    .padding(.leading, 56)
                    .accessibilityHidden(true)
            }
        }
    }
}

// MARK: - Onboarding Page 4: Scoring

/// Page 4 — Scoring rules and "Let's Play!" CTA.
/// - Parameter onComplete: Called when user taps "Let's Play!"
struct OnboardingPage4View: View {
    var onComplete: (() -> Void)? = nil

    private let scoringRules: [(points: String, label: String, description: String, color: Color)] = [
        ("+4", "Correct Vote",       "Human or Mongoose votes the right answer.",         SnakesssTheme.truthGold),
        ("+1", "Snake Vote",         "Snakes automatically earn 1 point per round.",      SnakesssTheme.snakeColor),
        ("+2", "Mongoose Bonus",     "Mongoose earns extra points for a correct vote.",   SnakesssTheme.mongooseColor),
        ("+0", "Wrong Vote",         "No points for incorrect answers.",                  SnakesssTheme.textMuted),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: SnakesssSpacing.spacing6) {
                Spacer(minLength: SnakesssSpacing.spacing6)

                VStack(spacing: SnakesssSpacing.spacing2) {
                    Text("SCORING")
                        .microStyle(color: SnakesssTheme.textMuted)
                    Text("How to earn points")
                        .font(SnakesssTypography.headline)
                        .foregroundStyle(SnakesssTheme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                }

                VStack(spacing: 0) {
                    ForEach(Array(scoringRules.enumerated()), id: \.offset) { index, rule in
                        ScoringRow(
                            points: rule.points,
                            label: rule.label,
                            description: rule.description,
                            color: rule.color,
                            isLast: index == scoringRules.count - 1
                        )
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                        .fill(SnakesssTheme.bgElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                                .strokeBorder(SnakesssTheme.borderSubtle, lineWidth: 1)
                        )
                )
                .padding(.horizontal, SnakesssSpacing.screenPadding)

                // "Let's Play!" CTA — only in onboarding context
                if let onComplete {
                    Button {
                        SnakesssHaptic.success()
                        onComplete()
                    } label: {
                        Text("Let's Play! 🐍")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SnakesssPrimaryButtonStyle())
                    .padding(.horizontal, SnakesssSpacing.screenPadding)
                    .accessibilityLabel("Let's Play! Start the game.")
                }

                Spacer(minLength: SnakesssSpacing.spacing8)
            }
        }
        .scrollIndicators(.hidden)
        .accessibilityLabel("Page 4: Scoring rules — correct votes earn 4 points, snakes earn 1, and mongoose earns a 2-point bonus.")
    }
}

// MARK: - Scoring Row

private struct ScoringRow: View {
    let points: String
    let label: String
    let description: String
    let color: Color
    let isLast: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: SnakesssSpacing.spacing3) {
                // Points badge
                Text(points)
                    .font(SnakesssTypography.headline)
                    .foregroundStyle(color)
                    .frame(width: 44, alignment: .leading)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(SnakesssTypography.label)
                        .foregroundStyle(SnakesssTheme.textPrimary)
                    Text(description)
                        .font(SnakesssTypography.caption)
                        .foregroundStyle(SnakesssTheme.textSecondary)
                }

                Spacer()
            }
            .padding(SnakesssSpacing.spacing4)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(points) points: \(label). \(description)")

            if !isLast {
                Rectangle()
                    .fill(SnakesssTheme.borderSubtle)
                    .frame(height: 1)
                    .padding(.horizontal, SnakesssSpacing.spacing4)
                    .accessibilityHidden(true)
            }
        }
    }
}

// MARK: - Previews

#Preview("Page 1 — Concept") {
    OnboardingPage1View()
        .background(SnakesssTheme.bgBase)
}

#Preview("Page 2 — Roles") {
    OnboardingPage2View()
        .background(SnakesssTheme.bgBase)
}

#Preview("Page 3 — Round Flow") {
    OnboardingPage3View()
        .background(SnakesssTheme.bgBase)
}

#Preview("Page 4 — Scoring") {
    OnboardingPage4View(onComplete: {})
        .background(SnakesssTheme.bgBase)
}
