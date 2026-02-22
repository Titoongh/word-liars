import SwiftUI

// MARK: - OnboardingView

/// Full-screen onboarding walkthrough shown on first app launch.
/// 4 swipeable pages using TabView with page style.
/// Stores `snakesss.hasSeenOnboarding` in UserDefaults on completion or skip.
struct OnboardingView: View {
    /// Bound to the app-level flag — set to true to dismiss onboarding.
    var onComplete: () -> Void

    @State private var currentPage = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let totalPages = 4

    var body: some View {
        ZStack {
            // Background
            SnakesssTheme.bgBase.ignoresSafeArea()
                .scaleTexture()
            SnakesssTheme.greenRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: 0) {
                // Top bar: Skip (pages 1–3) or invisible spacer (page 4)
                HStack {
                    Spacer()
                    if currentPage < totalPages - 1 {
                        Button("Skip") {
                            SnakesssHaptic.light()
                            completeOnboarding()
                        }
                        .font(SnakesssTypography.label)
                        .foregroundStyle(SnakesssTheme.textMuted)
                        .accessibilityLabel("Skip onboarding introduction")
                    } else {
                        // Invisible spacer to keep layout stable
                        Text("Skip")
                            .font(SnakesssTypography.label)
                            .hidden()
                            .accessibilityHidden(true)
                    }
                }
                .padding(.horizontal, SnakesssSpacing.screenPadding)
                .padding(.top, SnakesssSpacing.spacing6)
                .frame(height: 44)

                // Paged content
                TabView(selection: $currentPage) {
                    OnboardingPage1View()
                        .tag(0)
                    OnboardingPage2View()
                        .tag(1)
                    OnboardingPage3View()
                        .tag(2)
                    OnboardingPage4View(onComplete: completeOnboarding)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(
                    reduceMotion ? .default : SnakesssAnimation.standard,
                    value: currentPage
                )

                // Footer: page dots + Next button (pages 1–3)
                VStack(spacing: SnakesssSpacing.spacing6) {
                    // Custom dot indicators
                    HStack(spacing: SnakesssSpacing.spacing2) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Capsule()
                                .fill(
                                    index == currentPage
                                        ? SnakesssTheme.accentPrimary
                                        : SnakesssTheme.borderSubtle
                                )
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(
                                    reduceMotion ? .default : SnakesssAnimation.bouncy,
                                    value: currentPage
                                )
                        }
                    }
                    .accessibilityLabel("Page \(currentPage + 1) of \(totalPages)")

                    // Next button — hidden on last page (page 4 has its own CTA)
                    if currentPage < totalPages - 1 {
                        Button {
                            SnakesssHaptic.light()
                            withAnimation(reduceMotion ? .default : SnakesssAnimation.standard) {
                                currentPage += 1
                            }
                        } label: {
                            Text("Next")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SnakesssPrimaryButtonStyle())
                        .padding(.horizontal, SnakesssSpacing.screenPadding)
                        .accessibilityLabel("Next page, page \(currentPage + 2) of \(totalPages)")
                    } else {
                        // Spacer matching button height for consistent layout
                        Spacer()
                            .frame(height: 56)
                    }
                }
                .padding(.bottom, SnakesssSpacing.spacing12)
            }
        }
        .accessibilityAddTraits(.isModal)
    }

    // MARK: - Private

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "snakesss.hasSeenOnboarding")
        withAnimation(reduceMotion ? .default : SnakesssAnimation.standard) {
            onComplete()
        }
    }
}

// MARK: - Preview

#Preview("Onboarding Flow") {
    OnboardingView(onComplete: {})
}
