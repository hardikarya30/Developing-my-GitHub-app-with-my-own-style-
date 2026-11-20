//
//  ProfileMenuView.swift
//  GitHub 3D
//
//  The right-hand profile menu and the signed-out gate it leads to.
//

import SwiftUI

enum ProfileMenuItem: String, CaseIterable, Identifiable {
    case profile
    case repositories
    case stars
    case gists
    case organisations
    case enterprises
    case sponsors
    case settings
    case copilotSettings
    case featurePreview
    case appearance
    case accessibility

    var id: String { rawValue }

    var title: String {
        switch self {
        case .profile: return "Profile"
        case .repositories: return "Repositories"
        case .stars: return "Stars"
        case .gists: return "Gists"
        case .organisations: return "Organisations"
        case .enterprises: return "Enterprises"
        case .sponsors: return "Sponsors"
        case .settings: return "Settings"
        case .copilotSettings: return "Copilot settings"
        case .featurePreview: return "Feature preview"
        case .appearance: return "Appearance"
        case .accessibility: return "Accessibility"
        }
    }

    var symbol: String {
        switch self {
        case .profile: return "person.circle"
        case .repositories: return "book.closed"
        case .stars: return "star"
        case .gists: return "doc.text"
        case .organisations: return "building.2"
        case .enterprises: return "building.columns"
        case .sponsors: return "heart"
        case .settings: return "gearshape"
        case .copilotSettings: return "sparkles"
        case .featurePreview: return "eye"
        case .appearance: return "circle.lefthalf.filled"
        case .accessibility: return "accessibility"
        }
    }
}

// MARK: - Drawer

struct ProfileMenuDrawer: View {
    @EnvironmentObject private var store: AppStore

    var onSelect: (ProfileMenuItem) -> Void
    var onSetStatus: () -> Void
    var onCreateRepository: () -> Void
    var onEditProfile: () -> Void
    var onOpenSettings: () -> Void
    var onOpenGists: () -> Void = {}
    var onOpenProfileReadme: () -> Void = {}
    var onSignOut: () -> Void
    var onClose: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                identity
                setStatusRow
                statusLine
                divider
                createRow
                profileReadmeRow
                rows
                enterpriseRow
                signOutButton
            }
            .padding(.horizontal, 14)
            .padding(.top, 16)
            .padding(.bottom, 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                Rectangle().fill(Palette.canvasDeep.opacity(0.78))
            }
            .ignoresSafeArea()
        }
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color.white.opacity(0.14))
                .frame(width: 1)
                .ignoresSafeArea()
        }
        .shadow(color: Color(hex: 0x0B0726).opacity(0.6), radius: 30, x: -18, y: 0)
        .preferredColorScheme(.dark)
    }

    private var identity: some View {
        HStack(spacing: 12) {
            AvatarView(initials: store.profile.initials, size: 52)

            VStack(alignment: .leading, spacing: 1) {
                Text(store.profile.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Text("@\(store.profile.handle)")
                    .font(.system(size: 13))
                    .foregroundStyle(Palette.inkFaint)
            }

            Spacer(minLength: 6)

            Button {
                Haptics.tap()
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(Color.white.opacity(0.12)))
            }
            .buttonStyle(PressableStyle(scale: 0.9))
        }
        .padding(.bottom, 12)
    }

    private var setStatusRow: some View {
        Button {
            Haptics.tap()
            onSetStatus()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "circle.dashed")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Palette.inkMuted)
                Text("Set status")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Palette.ink)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)
            }
            .padding(.horizontal, 12)
            .frame(height: 42)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.98))
    }

    private var statusLine: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(store.status.isEmpty ? Palette.inkFaint : Color(hex: 0x3FB950))
                .frame(width: 7, height: 7)
            Text(store.status.isEmpty ? "No status set" : store.status)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(store.status.isEmpty ? Palette.inkFaint : Palette.inkMuted)
                .lineLimit(1)
        }
        .padding(.top, 10)
        .padding(.leading, 4)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.12))
            .frame(height: 1)
            .padding(.vertical, 12)
    }

    private var createRow: some View {
        Button {
            Haptics.tap()
            onCreateRepository()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Palette.accentBright)
                    .frame(width: 24, alignment: .leading)
                Text("Create new repository")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .frame(height: 46)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Palette.accent.opacity(0.22))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.98))
    }

    private var profileReadmeRow: some View {
        Button {
            Haptics.tap()
            onOpenProfileReadme()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "person.text.rectangle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Palette.accentBright)
                    .frame(width: 24, alignment: .leading)

                VStack(alignment: .leading, spacing: 1) {
                    Text("Profile README")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                    Text("Shown at the top of your profile")
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.inkFaint)
                }

                Spacer(minLength: 6)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.98))
        .padding(.top, 10)
    }

    private var rows: some View {
        VStack(spacing: 2) {
            ForEach(ProfileMenuItem.allCases) { item in
                menuRow(item)
            }
        }
        .padding(.top, 10)
    }

    private func menuRow(_ item: ProfileMenuItem) -> some View {
        Button {
            Haptics.select()
            if item == .profile {
                onEditProfile()
            } else if item == .settings {
                onOpenSettings()
            } else if item == .gists {
                onOpenGists()
            } else {
                onSelect(item)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: item.symbol)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Palette.inkMuted)
                    .frame(width: 24, alignment: .leading)

                Text(item.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Palette.ink)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.98))
    }

    private var enterpriseRow: some View {
        VStack(spacing: 2) {
            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(height: 1)
                .padding(.vertical, 10)

            Button {
                Haptics.tap()
                onSelect(.profile)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Palette.inkMuted)
                        .frame(width: 24, alignment: .leading)

                    Text("Try Enterprise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Palette.ink)

                    Text("New")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Palette.accentBright))

                    Spacer(minLength: 0)

                    Text("Free")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Palette.inkFaint)
                }
                .padding(.horizontal, 12)
                .frame(height: 46)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressableStyle(scale: 0.98))
        }
    }

    private var signOutButton: some View {
        Button {
            Haptics.tap()
            onSignOut()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15, weight: .semibold))
                Text("Sign out")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(Color(hex: 0xFF8A8A))
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color(hex: 0xFF5A5A).opacity(0.16))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .strokeBorder(Color(hex: 0xFF5A5A).opacity(0.35), lineWidth: 1)
            )
        }
        .buttonStyle(PressableStyle(scale: 0.98))
        .padding(.top, 18)
    }
}

#Preview {    ZStack(alignment: .trailing) {
        AppBackdrop()
        ProfileMenuDrawer(
            onSelect: { _ in },
            onSetStatus: {},
            onCreateRepository: {},
            onEditProfile: {},
            onOpenSettings: {},
            onSignOut: {},
            onClose: {}
        )
        .frame(width: 320)
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
