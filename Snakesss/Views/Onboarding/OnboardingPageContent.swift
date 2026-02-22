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
                    Text("onboarding.page1.section.label")
                        .microStyle(color: SnakesssTheme.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("onboarding.page1.headline")
                        .font(SnakesssTypography.headline)
                        .foregroundStyle(SnakesssTheme.textPrimary)

                    Text("onboarding.page1.body")
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
                    Text("onboarding.page2.section.label")
                        .microStyle(color: SnakesssTheme.textMuted)
                    Text("onboarding.page2.subtitle")
                        .font(SnakesssTypography.headline)
                        .foregroundStyle(SnakesssTheme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                }

                VStack(spacing: SnakesssSpacing.spacing3) {
                    RoleExplanationCard(role: .human, description: String(localized: "role.human.description"))
                    RoleExplanationCard(role: .snake, description: String(localized: "role.snake.description"))
                    RoleExplanationCard(role: .mongoose, description: String(localized: "role.mongoose.description"))
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
    private var phases: [(icon: String, title: String, description: String)] {[
        ("person.fill",            String(localized: "phase.roleReveal.title"),    String(localized: "phase.roleReveal.description")),
        ("questionmark.circle",    String(localized: "phase.question.title"),      String(localized: "phase.question.description")),
        ("eye.slash.fill",         String(localized: "phase.snakeReveal.title"),   String(localized: "phase.snakeReveal.description")),
        ("timer",                  String(localized: "phase.discussion.title"),    String(localized: "phase.discussion.description")),
        ("hand.point.up.left.fill",String(localized: "phase.voting.title"),        String(localized: "phase.voting.description")),
        ("trophy.fill",            String(localized: "phase.results.title"),       String(localized: "phase.results.description")),
    ]}

    var body: some View {
        ScrollView {
            VStack(spacing: SnakesssSpacing.spacing6) {
                Spacer(minLength: SnakesssSpacing.spacing6)

                VStack(spacing: SnakesssSpacing.spacing2) {
                    Text("onboarding.page3.section.label")
                        .microStyle(color: SnakesssTheme.textMuted)
                    Text("onboarding.page3.subtitle")
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

    private var scoringRules: [(points: String, label: String, description: String, color: Color)] {[
        ("+4", String(localized: "scoring.correctVote.label"),    String(localized: "scoring.correctVote.description"),    SnakesssTheme.truthGold),
        ("+1", String(localized: "scoring.snakeVote.label"),      String(localized: "scoring.snakeVote.description"),      SnakesssTheme.snakeColor),
        ("+2", String(localized: "scoring.mongooseBonus.label"),  String(localized: "scoring.mongooseBonus.description"),  SnakesssTheme.mongooseColor),
        ("+0", String(localized: "scoring.wrongVote.label"),      String(localized: "scoring.wrongVote.description"),      SnakesssTheme.textMuted),
    ]}

    var body: some View {
        ScrollView {
            VStack(spacing: SnakesssSpacing.spacing6) {
                Spacer(minLength: SnakesssSpacing.spacing6)

                VStack(spacing: SnakesssSpacing.spacing2) {
                    Text("onboarding.page4.section.label")
                        .microStyle(color: SnakesssTheme.textMuted)
                    Text("onboarding.page4.subtitle")
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
                        Text("onboarding.letsPlay.button")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SnakesssPrimaryButtonStyle())
                    .padding(.horizontal, SnakesssSpacing.screenPadding)
                    .accessibilityLabel(String(localized: "onboarding.letsPlay.button"))
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
