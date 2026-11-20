//
//  SettingsView.swift
//  GitHub 3D
//
//  Appearance, notification, Copilot and account settings.
//

import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable {
    case light
    case dark
    case system

    var id: String { rawValue }

    var title: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }

    var symbol: String {
        switch self {
        case .light: return "sun.max"
        case .dark: return "moon"
        case .system: return "display"
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore

    var onBack: () -> Void = {}
    var onEditProfile: () -> Void = {}
    var onSignOut: () -> Void = {}

    @AppStorage("settings.appearance") private var appearanceRaw = AppAppearance.dark.rawValue
    @AppStorage("settings.markAllReadOnOpen") private var markAllReadOnOpen = true
    @AppStorage("settings.reviewRequests") private var reviewRequestAlerts = true
    @AppStorage("settings.mentions") private var mentionAlerts = false
    @AppStorage("copilot.model.name") private var modelName = "GPT-5.4 mini"
    @AppStorage("copilot.auto") private var autoMode = true

    private var selectedModel: CopilotModel {
        CopilotModel.all.first(where: { $0.name == modelName }) ?? CopilotModel.all[0]
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    appearanceSection
                    notificationsSection
                    copilotSection
                    accountSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
            }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Button {
                Haptics.tap()
                onBack()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Circle().fill(Color.white.opacity(0.10)))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.20), lineWidth: 1))
            }
            .buttonStyle(PressableStyle(scale: 0.9))

            Spacer()

            Text("Settings")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Color.clear.frame(width: 46, height: 46)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .glassCard(fill: Color.white.opacity(0.10), radius: 28)
    }

    // MARK: Appearance

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Appearance")

            VStack(spacing: 0) {
                ForEach(AppAppearance.allCases) { option in
                    appearanceRow(option)

                    if option != AppAppearance.allCases.last {
                        divider
                    }
                }
            }
            .padding(.vertical, 4)
            .glassCard()
        }
    }

    private func appearanceRow(_ option: AppAppearance) -> some View {
        let isSelected = appearanceRaw == option.rawValue

        return Button {
            Haptics.select()
            withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                appearanceRaw = option.rawValue
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: option.symbol)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.10))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )

                Text(option.title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white)

                Spacer(minLength: 0)

                if isSelected {
                    ZStack {
                        Circle()
                            .fill(Palette.accentBright.opacity(0.25))
                            .frame(width: 28, height: 28)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Palette.accentBright)
                    }
                } else {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 1.5)
                        .frame(width: 26, height: 26)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? Palette.accent.opacity(0.18) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(
                        isSelected ? Palette.accentBright.opacity(0.55) : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
    }

    // MARK: Notifications

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Notifications")

            VStack(spacing: 0) {
                toggleRow(
                    symbol: "bell",
                    title: "Mark all read on open",
                    isOn: $markAllReadOnOpen
                )
                divider
                toggleRow(
                    symbol: "envelope",
                    title: "Review requests",
                    isOn: $reviewRequestAlerts
                )
                divider
                toggleRow(
                    symbol: "at",
                    title: "Mentions",
                    isOn: $mentionAlerts
                )
            }
            .padding(.vertical, 4)
            .glassCard()
        }
    }

    // MARK: Copilot

    private var copilotSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Copilot")

            VStack(spacing: 0) {
                Menu {
                    ForEach(CopilotModel.all) { model in
                        Button {
                            Haptics.select()
                            modelName = model.name
                        } label: {
                            if model.name == modelName {
                                Label(model.name, systemImage: "checkmark")
                            } else {
                                Text(model.name)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "cpu")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 46, height: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white.opacity(0.10))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Default model")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(.white)
                            Text(selectedModel.name)
                                .font(.system(size: 14))
                                .foregroundStyle(Palette.inkMuted)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Palette.inkFaint)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }

                divider

                toggleRow(
                    symbol: "gearshape",
                    title: "Auto",
                    isOn: $autoMode
                )
            }
            .padding(.vertical, 4)
            .glassCard()
        }
    }

    // MARK: Account

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Account")

            VStack(spacing: 0) {
                Button {
                    Haptics.tap()
                    onEditProfile()
                } label: {
                    HStack(spacing: 14) {
                        AvatarView(initials: store.profile.initials, size: 46)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(store.profile.name)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("@\(store.profile.handle)")
                                .font(.system(size: 14))
                                .foregroundStyle(Palette.inkMuted)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Palette.inkFaint)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressableStyle(scale: 0.99))

                divider

                Button {
                    Haptics.tap()
                    onSignOut()
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(Color(hex: 0xFF8A8A))
                            .frame(width: 46, height: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color(hex: 0xFF5A5A).opacity(0.16))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(Color(hex: 0xFF5A5A).opacity(0.3), lineWidth: 1)
                            )

                        Text("Sign out")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color(hex: 0xFF8A8A))

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressableStyle(scale: 0.99))
            }
            .padding(.vertical, 4)
            .glassCard()
        }
    }

    // MARK: Pieces

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(.white)
    }

    private func toggleRow(symbol: String, title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )

            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.white)

            Spacer(minLength: 8)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Palette.accentBright)
                .scaleEffect(0.85)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(height: 1)
            .padding(.leading, 72)
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        SettingsView()
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
