import SwiftUI

// MARK: - SettingsView

/// Game settings screen with Serpentine Dark styling.
/// Presented as a sheet from HomeView via gear icon.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    private var settings = SettingsManager.shared

    var body: some View {
        ZStack {
            SnakesssTheme.bgBase.ignoresSafeArea()
                .scaleTexture()
            SnakesssTheme.greenRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

            ScrollView {
                VStack(spacing: SnakesssSpacing.spacing6) {
                    // Header
                    header

                    // Rounds section
                    settingsSection(title: String(localized: "settings.rounds.section")) {
                        roundCountPicker
                    }

                    // Timer section
                    settingsSection(title: String(localized: "settings.timer.section")) {
                        timerDurationPicker
                    }

                    // Audio & Haptics section
                    settingsSection(title: String(localized: "settings.feedback.section")) {
                        feedbackToggles
                    }

                    // Language section
                    settingsSection(title: String(localized: "settings.language.section")) {
                        languageSection
                    }

                    // Difficulty section
                    settingsSection(title: String(localized: "Difficulty")) {
                        difficultySection
                    }

                    // Categories section
                    settingsSection(title: String(localized: "settings.categories.section")) {
                        categoriesSection
                    }

                    // Reset button
                    resetButton
                        .padding(.top, SnakesssSpacing.spacing2)
                        .padding(.bottom, SnakesssSpacing.spacing12)
                }
                .padding(.horizontal, SnakesssSpacing.screenPadding)
                .padding(.top, SnakesssSpacing.spacing6)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: SnakesssSpacing.spacing1) {
                Text("settings.title")
                    .font(SnakesssTypography.headline)
                    .foregroundStyle(SnakesssTheme.textPrimary)
                Text("settings.subtitle")
                    .font(SnakesssTypography.caption)
                    .foregroundStyle(SnakesssTheme.textSecondary)
            }
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(SnakesssTheme.textMuted)
            }
            .accessibilityLabel(String(localized: "settings.close.accessibility"))
        }
    }

    // MARK: - Section Container

    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: SnakesssSpacing.spacing3) {
            Text(title)
                .microStyle(color: SnakesssTheme.textSecondary)

            content()
        }
    }

    // MARK: - Round Count Picker

    private var roundCountPicker: some View {
        HStack(spacing: SnakesssSpacing.spacing2) {
            ForEach(SettingsManager.roundCountOptions, id: \.self) { count in
                let isActive = settings.roundCount == count
                Button {
                    SnakesssHaptic.light()
                    withAnimation(SnakesssAnimation.bouncy) {
                        settings.roundCount = count
                    }
                } label: {
                    Text("\(count)")
                        .font(SnakesssTypography.bodyLarge)
                        .fontWeight(isActive ? .heavy : .semibold)
                        .foregroundStyle(isActive ? SnakesssTheme.accentPrimary : SnakesssTheme.textMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            Capsule()
                                .fill(SnakesssTheme.bgElevated)
                                .overlay(
                                    Capsule()
                                        .strokeBorder(
                                            isActive ? SnakesssTheme.accentPrimary : SnakesssTheme.borderSubtle,
                                            lineWidth: 2
                                        )
                                )
                        )
                        .shadow(color: isActive ? SnakesssTheme.accentGlow : .clear, radius: 12)
                }
                .scaleEffect(isActive ? 1.05 : 1.0)
                .animation(SnakesssAnimation.bouncy, value: settings.roundCount)
                .accessibilityLabel(String(localized: "settings.rounds.accessibility \(count)"))
                .accessibilityAddTraits(isActive ? .isSelected : [])
            }
        }
    }

    // MARK: - Timer Duration Picker

    private var timerDurationPicker: some View {
        HStack(spacing: SnakesssSpacing.spacing2) {
            ForEach(SettingsManager.timerDurationOptions, id: \.self) { duration in
                let isActive = settings.timerDuration == duration
                Button {
                    SnakesssHaptic.light()
                    withAnimation(SnakesssAnimation.bouncy) {
                        settings.timerDuration = duration
                    }
                } label: {
                    Text(SettingsManager.timerLabel(for: duration))
                        .font(SnakesssTypography.label)
                        .fontWeight(isActive ? .heavy : .semibold)
                        .foregroundStyle(isActive ? SnakesssTheme.accentPrimary : SnakesssTheme.textMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            Capsule()
                                .fill(SnakesssTheme.bgElevated)
                                .overlay(
                                    Capsule()
                                        .strokeBorder(
                                            isActive ? SnakesssTheme.accentPrimary : SnakesssTheme.borderSubtle,
                                            lineWidth: 2
                                        )
                                )
                        )
                        .shadow(color: isActive ? SnakesssTheme.accentGlow : .clear, radius: 12)
                }
                .scaleEffect(isActive ? 1.05 : 1.0)
                .animation(SnakesssAnimation.bouncy, value: settings.timerDuration)
                .accessibilityLabel(SettingsManager.timerLabel(for: duration))
                .accessibilityAddTraits(isActive ? .isSelected : [])
            }
        }
    }

    // MARK: - Feedback Toggles

    private var feedbackToggles: some View {
        VStack(spacing: SnakesssSpacing.spacing2) {
            settingsToggleRow(
                label: String(localized: "settings.soundEffects.label"),
                icon: "speaker.wave.2.fill",
                isOn: Binding(
                    get: { settings.soundEnabled },
                    set: { settings.soundEnabled = $0 }
                )
            )
            Divider()
                .overlay(SnakesssTheme.borderSubtle)
            settingsToggleRow(
                label: String(localized: "settings.haptics.label"),
                icon: "hand.tap.fill",
                isOn: Binding(
                    get: { settings.hapticsEnabled },
                    set: { settings.hapticsEnabled = $0 }
                )
            )
        }
        .padding(SnakesssSpacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: SnakesssRadius.radiusLg)
                .fill(SnakesssTheme.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusLg)
                        .strokeBorder(SnakesssTheme.borderSubtle, lineWidth: 1)
                )
        )
    }

    private func settingsToggleRow(label: String, icon: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: SnakesssSpacing.spacing3) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(SnakesssTheme.accentPrimary)
                .frame(width: 28)

            Text(label)
                .font(SnakesssTypography.body)
                .foregroundStyle(SnakesssTheme.textPrimary)

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(SnakesssTheme.accentPrimary)
                .onChange(of: isOn.wrappedValue) { _, _ in
                    SnakesssHaptic.light()
                }
        }
    }

    // MARK: - Language Section

    private var languageSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(SettingsManager.languageOptions.enumerated()), id: \.element) { index, option in
                VStack(spacing: 0) {
                    languageRow(option: option)
                    if index < SettingsManager.languageOptions.count - 1 {
                        Divider()
                            .overlay(SnakesssTheme.borderSubtle)
                            .padding(.leading, 52)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: SnakesssRadius.radiusLg)
                .fill(SnakesssTheme.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusLg)
                        .strokeBorder(SnakesssTheme.borderSubtle, lineWidth: 1)
                )
        )
    }

    private func languageRow(option: String) -> some View {
        let isSelected = settings.language == option
        return Button {
            SnakesssHaptic.light()
            withAnimation(SnakesssAnimation.bouncy) {
                settings.language = option
            }
        } label: {
            HStack(spacing: SnakesssSpacing.spacing3) {
                ZStack {
                    Circle()
                        .fill(isSelected ? SnakesssTheme.accentPrimary.opacity(0.15) : SnakesssTheme.bgCard)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isSelected ? SnakesssTheme.accentPrimary : SnakesssTheme.borderSubtle,
                                    lineWidth: 1.5
                                )
                        )
                        .frame(width: 28, height: 28)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(SnakesssTheme.accentPrimary)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(SettingsManager.languageLabel(for: option))
                        .font(SnakesssTypography.body)
                        .foregroundStyle(isSelected ? SnakesssTheme.textPrimary : SnakesssTheme.textMuted)
                    Text(SettingsManager.languageDescription(for: option))
                        .font(SnakesssTypography.caption)
                        .foregroundStyle(SnakesssTheme.textMuted)
                }

                Spacer()
            }
            .padding(.horizontal, SnakesssSpacing.cardPadding)
            .padding(.vertical, SnakesssSpacing.spacing3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(SettingsManager.languageLabel(for: option))
        .accessibilityValue(isSelected ? "selected" : "")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Difficulty Section

    private var difficultySection: some View {
        VStack(spacing: 0) {
            ForEach(Array(SettingsManager.difficultyOptions.enumerated()), id: \.element) { index, option in
                VStack(spacing: 0) {
                    difficultyRow(option: option)
                    if index < SettingsManager.difficultyOptions.count - 1 {
                        Divider()
                            .overlay(SnakesssTheme.borderSubtle)
                            .padding(.leading, 52)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: SnakesssRadius.radiusLg)
                .fill(SnakesssTheme.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusLg)
                        .strokeBorder(SnakesssTheme.borderSubtle, lineWidth: 1)
                )
        )
    }

    private func difficultyRow(option: String) -> some View {
        let isSelected = settings.difficulty == option
        return Button {
            SnakesssHaptic.light()
            withAnimation(SnakesssAnimation.bouncy) {
                settings.difficulty = option
            }
        } label: {
            HStack(spacing: SnakesssSpacing.spacing3) {
                ZStack {
                    Circle()
                        .fill(isSelected ? SnakesssTheme.accentPrimary.opacity(0.15) : SnakesssTheme.bgCard)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isSelected ? SnakesssTheme.accentPrimary : SnakesssTheme.borderSubtle,
                                    lineWidth: 1.5
                                )
                        )
                        .frame(width: 28, height: 28)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(SnakesssTheme.accentPrimary)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(SettingsManager.difficultyLabel(for: option))
                        .font(SnakesssTypography.body)
                        .foregroundStyle(isSelected ? SnakesssTheme.textPrimary : SnakesssTheme.textMuted)
                    Text(SettingsManager.difficultyDescription(for: option))
                        .font(SnakesssTypography.caption)
                        .foregroundStyle(SnakesssTheme.textMuted)
                }

                Spacer()
            }
            .padding(.horizontal, SnakesssSpacing.cardPadding)
            .padding(.vertical, SnakesssSpacing.spacing3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(SettingsManager.difficultyLabel(for: option))
        .accessibilityValue(isSelected ? "selected" : "")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Categories Section

    private var categoriesSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(SettingsManager.allCategories.enumerated()), id: \.element) { index, category in
                VStack(spacing: 0) {
                    categoryRow(category: category)
                    if index < SettingsManager.allCategories.count - 1 {
                        Divider()
                            .overlay(SnakesssTheme.borderSubtle)
                            .padding(.leading, 52)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: SnakesssRadius.radiusLg)
                .fill(SnakesssTheme.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusLg)
                        .strokeBorder(SnakesssTheme.borderSubtle, lineWidth: 1)
                )
        )
    }

    private func categoryRow(category: String) -> some View {
        let isEnabled = settings.enabledCategories.contains(category)
        return Button {
            SnakesssHaptic.light()
            withAnimation(SnakesssAnimation.bouncy) {
                if isEnabled {
                    // Prevent disabling all categories
                    if settings.enabledCategories.count > 1 {
                        settings.enabledCategories.remove(category)
                    }
                } else {
                    settings.enabledCategories.insert(category)
                }
            }
        } label: {
            HStack(spacing: SnakesssSpacing.spacing3) {
                ZStack {
                    Circle()
                        .fill(isEnabled ? SnakesssTheme.accentPrimary.opacity(0.15) : SnakesssTheme.bgCard)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isEnabled ? SnakesssTheme.accentPrimary : SnakesssTheme.borderSubtle,
                                    lineWidth: 1.5
                                )
                        )
                        .frame(width: 28, height: 28)
                    if isEnabled {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(SnakesssTheme.accentPrimary)
                    }
                }

                Text(category)
                    .font(SnakesssTypography.body)
                    .foregroundStyle(isEnabled ? SnakesssTheme.textPrimary : SnakesssTheme.textMuted)

                Spacer()
            }
            .padding(.horizontal, SnakesssSpacing.cardPadding)
            .padding(.vertical, SnakesssSpacing.spacing3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(category)
        .accessibilityValue(String(localized: isEnabled ? "settings.category.enabled" : "settings.category.disabled"))
        .accessibilityAddTraits(isEnabled ? .isSelected : [])
    }

    // MARK: - Reset Button

    private var resetButton: some View {
        Button {
            SnakesssHaptic.medium()
            withAnimation(SnakesssAnimation.standard) {
                settings.resetToDefaults()
            }
        } label: {
            Text("settings.reset.button")
                .font(SnakesssTypography.label)
                .fontWeight(.bold)
                .foregroundStyle(SnakesssTheme.accentPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    Capsule()
                        .strokeBorder(SnakesssTheme.borderActive, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
}
