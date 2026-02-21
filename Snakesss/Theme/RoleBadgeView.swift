import SwiftUI

// MARK: - Role Badge View

/// Capsule-shaped role badge chip for the results screen and overlays.
/// - Shape: Capsule
/// - Fill: role-color @15%
/// - Border: 1pt role-color
/// - Text: role-color micro weight 700
/// - Contents: emoji + role name
struct RoleBadgeView: View {
    let role: Role

    var body: some View {
        HStack(spacing: SnakesssSpacing.spacing1) {
            Text(role.emoji)
                .font(.system(size: 13))

            Text(role.displayName.uppercased())
                .font(SnakesssTypography.micro)
                .tracking(1)
                .foregroundStyle(roleColor)
        }
        .padding(.horizontal, SnakesssSpacing.spacing2)
        .padding(.vertical, SnakesssSpacing.spacing1)
        .background(
            Capsule()
                .fill(roleColor.opacity(0.15))
                .overlay(
                    Capsule()
                        .strokeBorder(roleColor, lineWidth: 1)
                )
        )
    }

    // MARK: - Private

    private var roleColor: Color {
        switch role {
        case .snake:    return SnakesssTheme.snakeColor
        case .human:    return SnakesssTheme.humanColor
        case .mongoose: return SnakesssTheme.mongooseColor
        }
    }
}

// MARK: - Role Helpers

extension Role {
    var emoji: String {
        switch self {
        case .human:    return "👤"
        case .snake:    return "🐍"
        case .mongoose: return "🦦"
        }
    }

    var displayName: String {
        switch self {
        case .human:    return "Human"
        case .snake:    return "Snake"
        case .mongoose: return "Mongoose"
        }
    }

    var color: Color {
        switch self {
        case .snake:    return SnakesssTheme.snakeColor
        case .human:    return SnakesssTheme.humanColor
        case .mongoose: return SnakesssTheme.mongooseColor
        }
    }

    var glowColor: Color {
        switch self {
        case .snake:    return SnakesssTheme.accentGlow
        case .human:    return SnakesssTheme.humanColor.opacity(0.25)
        case .mongoose: return SnakesssTheme.mongooseColor.opacity(0.25)
        }
    }

    var flavorText: String {
        switch self {
        case .human:    return "You don't know the answer.\nFind the truth."
        case .snake:    return "You know the answer.\nLead them astray."
        case .mongoose: return "You don't know the answer.\nYour identity is public."
        }
    }
}

// MARK: - Preview

#Preview("Role Badges") {
    HStack(spacing: 12) {
        RoleBadgeView(role: .human)
        RoleBadgeView(role: .snake)
        RoleBadgeView(role: .mongoose)
    }
    .padding(28)
    .background(Color(hex: "#0A1A10"))
}
