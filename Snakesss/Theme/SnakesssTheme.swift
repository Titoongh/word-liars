import SwiftUI

// MARK: - Color Hex Initializer

extension Color {
    /// Initialize a Color from a hex string like "#3DBA6B" or "3DBA6B"
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Tier 1: Primitive Color Tokens

enum ColorPrimitive {
    // Greens — dark to light
    static let green900 = Color(hex: "#0A1A10") // Near-black forest green (base background)
    static let green800 = Color(hex: "#132218") // Dark forest green (surface)
    static let green700 = Color(hex: "#1A2E20") // Forest green (elevated surfaces)
    static let green600 = Color(hex: "#1F3527") // Medium forest green (card backgrounds)
    static let green500 = Color(hex: "#2A8C4F") // Deep snake green
    static let green400 = Color(hex: "#3DBA6B") // Vibrant snake green (primary accent)
    static let green300 = Color(hex: "#5DD68A") // Light snake green (hover/active states)
    static let green200 = Color(hex: "#90E8B2") // Pale snake green (subtle highlights)

    // Golds
    static let gold500  = Color(hex: "#F4C430") // Truth gold (correct answers, winners)
    static let gold400  = Color(hex: "#F7D568") // Light gold

    // Amber
    static let amber500 = Color(hex: "#F4A429") // Mongoose amber

    // Blues
    static let blue500  = Color(hex: "#5E9BDE") // Human blue
    static let blue400  = Color(hex: "#7EB5EE") // Light human blue

    // Reds
    static let red500   = Color(hex: "#E05252") // Danger/wrong red
    static let red400   = Color(hex: "#E87878") // Light danger red

    // Neutrals
    static let ivory100 = Color(hex: "#EAE8E0") // Warm white (primary text)
    static let sage400  = Color(hex: "#7A9E80") // Muted sage (secondary text)
    static let sage600  = Color(hex: "#4D6B52") // Dark sage (tertiary/muted text)
}

// MARK: - Tier 2: Semantic Tokens

enum SnakesssTheme {
    // Backgrounds
    static let bgBase     = ColorPrimitive.green900 // App background
    static let bgSurface  = ColorPrimitive.green800 // Sheet backgrounds, navigation bars
    static let bgElevated = ColorPrimitive.green700 // Cards, input backgrounds
    static let bgCard     = ColorPrimitive.green600 // Reveal cards, modals

    // Accents
    static let accentPrimary = ColorPrimitive.green400 // Primary CTAs, active states, brand accent
    static let accentDeep    = ColorPrimitive.green500 // Gradient bottoms, pressed states
    static let accentGlow    = ColorPrimitive.green400.opacity(0.25) // Box shadows, glowing borders

    // Truth / Gold
    static let truthGold    = ColorPrimitive.gold500
    static let truthGoldDim = ColorPrimitive.gold500.opacity(0.15) // Correct answer card background

    // Danger
    static let danger     = ColorPrimitive.red500 // Wrong answers, error states
    static let dangerGlow = ColorPrimitive.red500.opacity(0.20) // Wrong answer glow

    // Text
    static let textPrimary   = ColorPrimitive.ivory100 // Headings, primary body
    static let textSecondary = ColorPrimitive.sage400   // Captions, labels, instructions
    static let textMuted     = ColorPrimitive.sage600   // Disabled, placeholder, tertiary

    // Role colors
    static let snakeColor    = ColorPrimitive.green400 // Snake role badge, Snake vote display
    static let humanColor    = ColorPrimitive.blue500  // Human role badge
    static let mongooseColor = ColorPrimitive.amber500 // Mongoose role badge

    // Borders
    static let borderSubtle = ColorPrimitive.green400.opacity(0.15) // Card borders, row separators
    static let borderActive = ColorPrimitive.green400.opacity(0.40) // Selected/focused borders

    // Overlays
    static let overlayScrim = ColorPrimitive.green900.opacity(0.80) // Pass-phone interstitial overlay
}

// MARK: - Tier 2: Semantic Gradient Helpers

extension SnakesssTheme {
    /// Primary button gradient: accentPrimary → accentDeep, 135°
    static var buttonPrimaryGradient: LinearGradient {
        LinearGradient(
            colors: [accentPrimary, accentDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Green radial overlay for home/role reveal screens
    static var greenRadialOverlay: RadialGradient {
        RadialGradient(
            colors: [ColorPrimitive.green400.opacity(0.12), .clear],
            center: .top,
            startRadius: 0,
            endRadius: 300
        )
    }

    /// Gold radial overlay for results/game end screens
    static var goldRadialOverlay: RadialGradient {
        RadialGradient(
            colors: [ColorPrimitive.gold500.opacity(0.10), .clear],
            center: UnitPoint(x: 0.5, y: 0.3),
            startRadius: 0,
            endRadius: 300
        )
    }
}

// MARK: - Tier 3: Component Tokens

enum SnakesssComponentToken {
    // Button — Primary
    static let buttonPrimaryFg   = SnakesssTheme.bgBase
    static let buttonPrimaryGlow = SnakesssTheme.accentGlow

    // Button — Secondary
    static let buttonSecondaryBorder = SnakesssTheme.borderActive
    static let buttonSecondaryFg     = SnakesssTheme.accentPrimary

    // Answer Button
    static let answerButtonBg             = SnakesssTheme.bgElevated
    static let answerButtonBorder         = SnakesssTheme.borderSubtle
    static let answerButtonSelectedBorder = SnakesssTheme.accentPrimary
    static let answerLabelBg             = SnakesssTheme.accentPrimary.opacity(0.10)

    // Timer Ring
    static let timerActiveStroke  = SnakesssTheme.accentPrimary
    static let timerWarningStroke = SnakesssTheme.truthGold
    static let timerDangerStroke  = SnakesssTheme.danger
}

// MARK: - Spacing System (4pt base grid)

enum SnakesssSpacing {
    static let spacing1:  CGFloat = 4   // Micro gaps (icon-to-label)
    static let spacing2:  CGFloat = 8   // Tight element groups
    static let spacing3:  CGFloat = 12  // Related content groups
    static let spacing4:  CGFloat = 16  // Standard padding
    static let spacing5:  CGFloat = 20  // List row padding
    static let spacing6:  CGFloat = 24  // Section spacing
    static let spacing8:  CGFloat = 32  // Large section gaps
    static let spacing10: CGFloat = 40  // Generous padding
    static let spacing12: CGFloat = 48  // Safe area padding
    static let spacing16: CGFloat = 64  // Hero section spacing
    static let screenPadding: CGFloat = 28 // Horizontal screen padding (adaptive)
    static let cardPadding:   CGFloat = 20 // Card internal padding
}

// MARK: - Border Radius

enum SnakesssRadius {
    static let radiusSm:        CGFloat = 8
    static let radiusMd:        CGFloat = 12
    static let radiusLg:        CGFloat = 16
    static let radiusXl:        CGFloat = 20
    static let radiusCard:      CGFloat = 24
    static let radiusLargeCard: CGFloat = 32
    static let radiusFull:      CGFloat = 9999
}

// MARK: - Shadow & Glow Definitions

struct SnakesssGlow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

enum SnakesssShadow {
    /// Resting cards: 0 2 8 rgba(0,0,0,0.3)
    static let shadowSubtle = SnakesssGlow(
        color: Color.black.opacity(0.30),
        radius: 8,
        x: 0,
        y: 2
    )

    /// Elevated cards: 0 4 16 rgba(0,0,0,0.4)
    static let shadowCard = SnakesssGlow(
        color: Color.black.opacity(0.40),
        radius: 16,
        x: 0,
        y: 4
    )

    /// Primary CTA / active role card glow: green
    static let glowAccent = SnakesssGlow(
        color: ColorPrimitive.green400.opacity(0.25),
        radius: 20,
        x: 0,
        y: 0
    )

    /// Correct answer / winner glow: gold
    static let glowGold = SnakesssGlow(
        color: ColorPrimitive.gold500.opacity(0.30),
        radius: 20,
        x: 0,
        y: 0
    )

    /// Wrong answer glow: red
    static let glowDanger = SnakesssGlow(
        color: ColorPrimitive.red500.opacity(0.20),
        radius: 20,
        x: 0,
        y: 0
    )
}

// MARK: - View Modifier Helpers

extension View {
    /// Apply a shadow/glow from SnakesssShadow
    func snakesssGlow(_ glow: SnakesssGlow) -> some View {
        self.shadow(color: glow.color, radius: glow.radius, x: glow.x, y: glow.y)
    }

    /// Apply the primary accent glow (two-layer for depth)
    func accentGlow() -> some View {
        self
            .shadow(color: ColorPrimitive.green400.opacity(0.25), radius: 20, x: 0, y: 0)
            .shadow(color: ColorPrimitive.green400.opacity(0.10), radius: 40, x: 0, y: 0)
    }

    /// Apply the gold glow
    func goldGlow() -> some View {
        self
            .shadow(color: ColorPrimitive.gold500.opacity(0.30), radius: 20, x: 0, y: 0)
            .shadow(color: ColorPrimitive.gold500.opacity(0.10), radius: 40, x: 0, y: 0)
    }

    /// Apply the danger glow
    func dangerGlow() -> some View {
        self.shadow(color: ColorPrimitive.red500.opacity(0.20), radius: 20, x: 0, y: 0)
    }
}

// MARK: - Preview

#Preview("Design Tokens") {
    ScrollView {
        VStack(alignment: .leading, spacing: SnakesssSpacing.spacing4) {

            // Primitive Colors
            Group {
                Text("Primitive Colors").font(.headline).foregroundStyle(.white)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                    ForEach([
                        ("green900", ColorPrimitive.green900),
                        ("green800", ColorPrimitive.green800),
                        ("green700", ColorPrimitive.green700),
                        ("green600", ColorPrimitive.green600),
                        ("green500", ColorPrimitive.green500),
                        ("green400", ColorPrimitive.green400),
                        ("green300", ColorPrimitive.green300),
                        ("green200", ColorPrimitive.green200),
                        ("gold500",  ColorPrimitive.gold500),
                        ("gold400",  ColorPrimitive.gold400),
                        ("amber500", ColorPrimitive.amber500),
                        ("blue500",  ColorPrimitive.blue500),
                        ("blue400",  ColorPrimitive.blue400),
                        ("red500",   ColorPrimitive.red500),
                        ("red400",   ColorPrimitive.red400),
                        ("ivory100", ColorPrimitive.ivory100),
                        ("sage400",  ColorPrimitive.sage400),
                        ("sage600",  ColorPrimitive.sage600),
                    ], id: \.0) { name, color in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(color)
                                .frame(height: 40)
                            Text(name)
                                .font(.system(size: 9))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }
            }

            Divider().overlay(.white.opacity(0.2))

            // Spacing
            Group {
                Text("Spacing").font(.headline).foregroundStyle(.white)
                ForEach([
                    ("spacing1 (4)", SnakesssSpacing.spacing1),
                    ("spacing2 (8)", SnakesssSpacing.spacing2),
                    ("spacing4 (16)", SnakesssSpacing.spacing4),
                    ("spacing6 (24)", SnakesssSpacing.spacing6),
                    ("spacing8 (32)", SnakesssSpacing.spacing8),
                    ("cardPadding (20)", SnakesssSpacing.cardPadding),
                    ("screenPadding (28)", SnakesssSpacing.screenPadding),
                ], id: \.0) { name, value in
                    HStack {
                        Text(name).font(.caption).foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        Rectangle()
                            .fill(SnakesssTheme.accentPrimary)
                            .frame(width: value, height: 8)
                    }
                }
            }

            Divider().overlay(.white.opacity(0.2))

            // Border Radius
            Group {
                Text("Border Radius").font(.headline).foregroundStyle(.white)
                HStack(spacing: SnakesssSpacing.spacing3) {
                    ForEach([
                        ("Sm", SnakesssRadius.radiusSm),
                        ("Md", SnakesssRadius.radiusMd),
                        ("Lg", SnakesssRadius.radiusLg),
                        ("Xl", SnakesssRadius.radiusXl),
                    ], id: \.0) { name, radius in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: radius)
                                .fill(SnakesssTheme.bgElevated)
                                .overlay(
                                    RoundedRectangle(cornerRadius: radius)
                                        .stroke(SnakesssTheme.borderActive, lineWidth: 1)
                                )
                                .frame(width: 60, height: 40)
                            Text(name).font(.caption2).foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }
            }

            Divider().overlay(.white.opacity(0.2))

            // Glows
            Group {
                Text("Glows").font(.headline).foregroundStyle(.white)
                HStack(spacing: SnakesssSpacing.spacing4) {
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusMd)
                        .fill(SnakesssTheme.bgElevated)
                        .frame(width: 80, height: 40)
                        .accentGlow()
                        .overlay(Text("Accent").font(.caption2).foregroundStyle(.white))

                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusMd)
                        .fill(SnakesssTheme.bgElevated)
                        .frame(width: 80, height: 40)
                        .goldGlow()
                        .overlay(Text("Gold").font(.caption2).foregroundStyle(.white))

                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusMd)
                        .fill(SnakesssTheme.bgElevated)
                        .frame(width: 80, height: 40)
                        .dangerGlow()
                        .overlay(Text("Danger").font(.caption2).foregroundStyle(.white))
                }
            }
        }
        .padding(SnakesssSpacing.screenPadding)
    }
    .background(SnakesssTheme.bgBase)
}
