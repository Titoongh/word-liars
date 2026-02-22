import SwiftUI

// MARK: - PlayerSetupView

/// Player count selection + name entry before starting the game.
struct PlayerSetupView: View {
    @State private var setupVM = GameSetupViewModel()
    @State private var navigateToGame = false
    @FocusState private var focusedField: Int?
    @Environment(GameNavigationCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            SnakesssTheme.bgBase.ignoresSafeArea()
                .scaleTexture() // M1
            SnakesssTheme.greenRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: 0) {
                // Header
                Text("setup.title")
                    .font(SnakesssTypography.headline)
                    .foregroundStyle(SnakesssTheme.textPrimary)
                    .padding(.top, SnakesssSpacing.spacing8)

                // Player count picker
                playerCountPicker
                    .padding(.top, SnakesssSpacing.spacing6)

                // Name fields
                ScrollView {
                    VStack(spacing: SnakesssSpacing.spacing3) {
                        ForEach(0..<setupVM.playerCount, id: \.self) { index in
                            nameField(index: index)
                        }
                    }
                    .padding(.horizontal, SnakesssSpacing.screenPadding)
                    .padding(.top, SnakesssSpacing.spacing4)
                }

                Spacer()

                // Start button
                NavigationLink(
                    destination: GameView(
                        viewModel: GameViewModel(players: setupVM.createPlayers())
                    )
                ) {
                    Text("setup.startGame.button")
                        .font(SnakesssTypography.bodyLarge)
                        .foregroundStyle(SnakesssTheme.bgBase)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 56)
                        .background(
                            Capsule()
                                .fill(SnakesssTheme.buttonPrimaryGradient)
                        )
                        .shadow(
                            color: SnakesssTheme.accentGlow,
                            radius: 16, x: 0, y: 4
                        )
                }
                .disabled(!setupVM.isValid)
                .opacity(setupVM.isValid ? 1.0 : 0.4)
                .padding(.horizontal, SnakesssSpacing.screenPadding)
                .padding(.bottom, SnakesssSpacing.spacing12)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: coordinator.shouldReturnHome) { _, newValue in
            if newValue { dismiss() }
        }
    }

    // MARK: - Player Count Picker (M5)

    private var playerCountPicker: some View {
        VStack(spacing: SnakesssSpacing.spacing2) {
            Text("setup.playerCount.label")
                .font(SnakesssTypography.label)
                .foregroundStyle(SnakesssTheme.textSecondary)

            HStack(spacing: SnakesssSpacing.spacing2) {
                ForEach(4...8, id: \.self) { count in
                    let isActive = setupVM.playerCount == count
                    Button("\(count)") {
                        SnakesssHaptic.light()
                        withAnimation(SnakesssAnimation.bouncy) {
                            setupVM.playerCount = count
                        }
                    }
                    .font(SnakesssTypography.bodyLarge)
                    .fontWeight(isActive ? .heavy : .semibold)
                    .foregroundStyle(
                        isActive
                            ? SnakesssTheme.accentPrimary
                            : SnakesssTheme.textMuted
                    )
                    .frame(width: 44, height: 44)
                    .background(
                        Capsule()
                            .fill(SnakesssTheme.bgElevated)
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        isActive
                                            ? SnakesssTheme.accentPrimary
                                            : SnakesssTheme.borderSubtle,
                                        lineWidth: 2
                                    )
                            )
                    )
                    .shadow(
                        color: isActive ? SnakesssTheme.accentGlow : .clear,
                        radius: 12, x: 0, y: 0
                    )
                    .contentShape(Capsule())
                    .scaleEffect(isActive ? 1.1 : 1.0)
                    .animation(SnakesssAnimation.bouncy, value: setupVM.playerCount)
                    .accessibilityLabel(String(localized: "setup.players.accessibility \(count)"))
                    .accessibilityAddTraits(isActive ? .isSelected : [])
                }
            }
        }
        .padding(.horizontal, SnakesssSpacing.screenPadding)
    }

    // MARK: - Name Field

    private func nameField(index: Int) -> some View {
        HStack(spacing: SnakesssSpacing.spacing3) {
            // Player number badge
            ZStack {
                Circle()
                    .fill(SnakesssTheme.accentPrimary.opacity(0.12))
                    .overlay(Circle().strokeBorder(SnakesssTheme.borderActive, lineWidth: 1))
                    .frame(width: 36, height: 36)
                Text("\(index + 1)")
                    .font(SnakesssTypography.micro)
                    .foregroundStyle(SnakesssTheme.accentPrimary)
            }

            TextField(String(localized: "setup.playerName.placeholder \(index + 1)"),
                      text: Binding(
                get: {
                    index < setupVM.playerNames.count ? setupVM.playerNames[index] : ""
                },
                set: { newValue in
                    if index < setupVM.playerNames.count {
                        setupVM.playerNames[index] = newValue
                    }
                }
            ))
            .font(SnakesssTypography.body)
            .foregroundStyle(SnakesssTheme.textPrimary)
            .autocorrectionDisabled()
            .focused($focusedField, equals: index)
            .submitLabel(index == setupVM.playerCount - 1 ? .done : .next)
            .onSubmit {
                if index < setupVM.playerCount - 1 {
                    focusedField = index + 1
                } else {
                    focusedField = nil
                }
            }
        }
        .padding(.horizontal, SnakesssSpacing.spacing4)
        .padding(.vertical, SnakesssSpacing.spacing3)
        .background(
            RoundedRectangle(cornerRadius: SnakesssRadius.radiusLg)
                .fill(SnakesssTheme.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusLg)
                        .strokeBorder(
                            focusedField == index
                                ? SnakesssTheme.accentPrimary
                                : SnakesssTheme.borderSubtle,
                            lineWidth: 1.5
                        )
                )
        )
        .animation(SnakesssAnimation.standard, value: focusedField)
    }
}

#Preview {
    NavigationStack {
        PlayerSetupView()
            .environment(GameNavigationCoordinator())
    }
}
