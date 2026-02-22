import SwiftUI

// MARK: - RulesSheetView

/// "How to Play" sheet presenting rules content as a single-page scrollable view.
/// Reuses the same page content views from the onboarding flow.
/// Tapping this does NOT reset the hasSeenOnboarding flag.
struct RulesSheetView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SnakesssSpacing.spacing8) {
                    // Roles section
                    RulesSectionHeader(title: "THE ROLES", subtitle: "Who are you playing as?")

                    VStack(spacing: SnakesssSpacing.spacing3) {
                        ForEach([Role.human, .snake, .mongoose], id: \.self) { role in
                            RulesRoleCard(role: role)
                        }
                    }
                    .padding(.horizontal, SnakesssSpacing.screenPadding)

                    // Divider
                    Rectangle()
                        .fill(SnakesssTheme.borderSubtle)
                        .frame(height: 1)
                        .padding(.horizontal, SnakesssSpacing.screenPadding)
                        .accessibilityHidden(true)

                    // Round flow section
                    RulesSectionHeader(title: "EACH ROUND", subtitle: "6 phases per round")

                    let phases: [(icon: String, title: String, description: String)] = [
                        ("person.fill",            "Role Reveal",     "Each player secretly sees their role card."),
                        ("questionmark.circle",    "Question",        "A trivia question is shown to everyone."),
                        ("eye.slash.fill",         "Snake Reveal",    "Snakes secretly learn the correct answer."),
                        ("timer",                  "Discussion",      "2 minutes to discuss and debate answers."),
                        ("hand.point.up.left.fill","Voting",          "Each player votes for their chosen answer."),
                        ("trophy.fill",            "Results",         "Votes, roles, and points are revealed."),
                    ]

                    VStack(spacing: 0) {
                        ForEach(Array(phases.enumerated()), id: \.offset) { index, phase in
                            RulesPhaseRow(
                                number: index + 1,
                                icon: phase.icon,
                                title: phase.title,
                                description: phase.description,
                                isLast: index == phases.count - 1
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

                    // Divider
                    Rectangle()
                        .fill(SnakesssTheme.borderSubtle)
                        .frame(height: 1)
                        .padding(.horizontal, SnakesssSpacing.screenPadding)
                        .accessibilityHidden(true)

                    // Scoring section
                    RulesSectionHeader(title: "SCORING", subtitle: "How to earn points")

                    let scoringRules: [(points: String, label: String, description: String, color: Color)] = [
                        ("+4", "Correct Vote",   "Human or Mongoose votes the right answer.",       SnakesssTheme.truthGold),
                        ("+1", "Snake Vote",     "Snakes automatically earn 1 point per round.",    SnakesssTheme.snakeColor),
                        ("+2", "Mongoose Bonus", "Mongoose earns extra points for a correct vote.", SnakesssTheme.mongooseColor),
                        ("+0", "Wrong Vote",     "No points for incorrect answers.",                SnakesssTheme.textMuted),
                    ]

                    VStack(spacing: 0) {
                        ForEach(Array(scoringRules.enumerated()), id: \.offset) { index, rule in
                            RulesScoringRow(
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

                    // Dismiss button
                    Button {
                        SnakesssHaptic.light()
                        dismiss()
                    } label: {
                        Text("Got it!")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SnakesssPrimaryButtonStyle())
                    .padding(.horizontal, SnakesssSpacing.screenPadding)
                    .padding(.bottom, SnakesssSpacing.spacing12)
                    .accessibilityLabel("Dismiss rules sheet")
                }
                .padding(.top, SnakesssSpacing.spacing6)
            }
            .scrollIndicators(.hidden)
            .background(SnakesssTheme.bgBase.ignoresSafeArea())
            .navigationTitle("How to Play")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(SnakesssTheme.bgBase, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        SnakesssHaptic.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(SnakesssTheme.textMuted)
                    }
                    .accessibilityLabel("Close How to Play")
                }
            }
        }
        .presentationBackground(SnakesssTheme.bgBase)
    }
}

// MARK: - Rules Section Header

private struct RulesSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: SnakesssSpacing.spacing2) {
            Text(title)
                .microStyle(color: SnakesssTheme.textMuted)
            Text(subtitle)
                .font(SnakesssTypography.headline)
                .foregroundStyle(SnakesssTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
        }
        .padding(.horizontal, SnakesssSpacing.screenPadding)
    }
}

// MARK: - Rules Role Card

private struct RulesRoleCard: View {
    let role: Role

    private var description: String {
        switch role {
        case .human:    return "You don't know the answer. Listen carefully, find clues, and vote for what you believe is correct."
        case .snake:    return "You know the correct answer — but keep it secret! Mislead the group and vote snake to earn points."
        case .mongoose: return "You don't know the answer, but your identity is public. You're a trusted ally helping humans find the truth."
        }
    }

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

// MARK: - Rules Phase Row

private struct RulesPhaseRow: View {
    let number: Int
    let icon: String
    let title: String
    let description: String
    let isLast: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: SnakesssSpacing.spacing3) {
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

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(SnakesssTheme.accentPrimary)
                    .frame(width: 24)
                    .accessibilityHidden(true)

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
            .padding(.horizontal, SnakesssSpacing.cardPadding)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Phase \(number): \(title). \(description)")

            if !isLast {
                Rectangle()
                    .fill(SnakesssTheme.borderSubtle)
                    .frame(height: 1)
                    .padding(.leading, 56 + SnakesssSpacing.cardPadding)
                    .padding(.trailing, SnakesssSpacing.cardPadding)
                    .accessibilityHidden(true)
            }
        }
    }
}

// MARK: - Rules Scoring Row

private struct RulesScoringRow: View {
    let points: String
    let label: String
    let description: String
    let color: Color
    let isLast: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: SnakesssSpacing.spacing3) {
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

// MARK: - Preview

#Preview("Rules Sheet") {
    RulesSheetView()
}
