import SwiftUI

// MARK: - Role Badge View

/// Capsule-shaped role badge chip for the results screen and overlays.
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
        case .human:    return String(localized: "role.human.displayName")
        case .snake:    return String(localized: "role.snake.displayName")
        case .mongoose: return String(localized: "role.mongoose.displayName")
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
        case .human:    return String(localized: "role.human.flavorText")
        case .snake:    return String(localized: "role.snake.flavorText")
        case .mongoose: return String(localized: "role.mongoose.flavorText")
        }
    }
}

// MARK: - Mongoose Announcement Chip

/// Amber chip shown persistently on screens where the Mongoose's identity is public.
struct MongooseChipView: View {
    let mongooseName: String

    var body: some View {
        HStack(spacing: SnakesssSpacing.spacing2) {
            Text("🦦")
                .font(.system(size: 14))
            Text(String(localized: "mongoose.chip.label \(mongooseName)"))
                .font(SnakesssTypography.label)
                .foregroundStyle(SnakesssTheme.mongooseColor)
        }
        .padding(.horizontal, SnakesssSpacing.spacing4)
        .padding(.vertical, SnakesssSpacing.spacing2)
        .background(
            Capsule()
                .fill(SnakesssTheme.mongooseColor.opacity(0.10))
                .overlay(
                    Capsule()
                        .strokeBorder(SnakesssTheme.mongooseColor.opacity(0.30), lineWidth: 1)
                )
        )
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
