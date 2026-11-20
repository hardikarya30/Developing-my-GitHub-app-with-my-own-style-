//
//  RepositorySettingsView.swift
//  GitHub 3D
//
//  Rename, describe and configure a repository.
//

import SwiftUI

struct RepositorySettingsView: View {
    @EnvironmentObject private var store: AppStore

    var repo: RepoItem
    var onCancel: () -> Void = {}
    var onSaved: () -> Void = {}
    var onOpenCollaborators: () -> Void = {}

    @State private var name: String
    @State private var blurb: String
    @State private var isPrivate: Bool
    @State private var defaultBranch: String
    @State private var hasIssues: Bool
    @State private var hasDiscussions: Bool
    @State private var hasWiki: Bool

    private let branches = ["main", "develop", "release/1.4"]

    init(
        repo: RepoItem,
        onCancel: @escaping () -> Void = {},
        onSaved: @escaping () -> Void = {},
        onOpenCollaborators: @escaping () -> Void = {}
    ) {
        self.repo = repo
        self.onCancel = onCancel
        self.onSaved = onSaved
        self.onOpenCollaborators = onOpenCollaborators
        _name = State(initialValue: repo.name)
        _blurb = State(initialValue: repo.blurb)
        _isPrivate = State(initialValue: repo.isPrivate)
        _defaultBranch = State(initialValue: repo.defaultBranch)
        _hasIssues = State(initialValue: repo.hasIssues)
        _hasDiscussions = State(initialValue: repo.hasDiscussions)
        _hasWiki = State(initialValue: repo.hasWiki)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    sectionLabel("GENERAL")
                    generalCard

                    sectionLabel("DEFAULTS")
                    defaultsCard

                    sectionLabel("FEATURES")
                    featuresCard

                    sectionLabel("ACCESS")
                    collaboratorsRow

                    saveButton
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
                onCancel()
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

            Color.clear
                .frame(width: 46, height: 46)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .glassCard(fill: Color.white.opacity(0.10), radius: 28)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .tracking(1.2)
            .foregroundStyle(Palette.inkMuted)
            .padding(.leading, 4)
    }

    // MARK: General

    private var generalCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("Repository name")
                TextField("Repository name", text: $name)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .tint(Palette.accentBright)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal, 14)
                    .frame(height: 50)
                    .background(fieldBackground)
            }

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("Description")
                TextField("Describe your repository", text: $blurb, axis: .vertical)
                    .lineLimit(2...4)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .tint(Palette.accentBright)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(minHeight: 82, alignment: .topLeading)
                    .background(fieldBackground)
            }

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Visibility")
                visibilityPicker
                Text(
                    isPrivate
                        ? "Only you can see this repository."
                        : "Anyone can see this repository."
                )
                .font(.system(size: 14))
                .foregroundStyle(Palette.inkMuted)
                .padding(.leading, 2)
            }
        }
        .padding(16)
        .glassCard()
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15))
            .foregroundStyle(Palette.inkMuted)
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.white.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
            )
    }

    private var visibilityPicker: some View {
        HStack(spacing: 0) {
            visibilityOption("Public", isSelected: !isPrivate) {
                isPrivate = false
            }
            visibilityOption("Private", isSelected: isPrivate) {
                isPrivate = true
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
    }

    private func visibilityOption(
        _ title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            Haptics.select()
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                action()
            }
        } label: {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isSelected ? Color.white : Palette.inkMuted)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Palette.accentBright, Palette.accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: Defaults

    private var defaultsCard: some View {
        Menu {
            ForEach(branches, id: \.self) { branch in
                Button {
                    Haptics.select()
                    defaultBranch = branch
                } label: {
                    if branch == defaultBranch {
                        Label(branch, systemImage: "checkmark")
                    } else {
                        Text(branch)
                    }
                }
            }
        } label: {
            HStack(spacing: 12) {
                iconTile("arrow.triangle.branch")

                VStack(alignment: .leading, spacing: 2) {
                    Text("Default branch")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(defaultBranch)
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkMuted)
                }

                Spacer(minLength: 6)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)
            }
            .padding(14)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
        .glassCard()
    }

    // MARK: Features

    private var featuresCard: some View {
        VStack(spacing: 0) {
            featureRow(
                symbol: "exclamationmark.circle",
                title: "Issues",
                subtitle: "Track and manage issues",
                isOn: $hasIssues,
                showsDivider: true
            )
            featureRow(
                symbol: "bubble.left",
                title: "Discussions",
                subtitle: "Have conversations with your community",
                isOn: $hasDiscussions,
                showsDivider: true
            )
            featureRow(
                symbol: "book",
                title: "Wiki",
                subtitle: "Document your project",
                isOn: $hasWiki,
                showsDivider: false
            )
        }
        .padding(.horizontal, 14)
        .glassCard()
    }

    private func featureRow(
        symbol: String,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>,
        showsDivider: Bool
    ) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                iconTile(symbol)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkMuted)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 6)

                Toggle("", isOn: isOn)
                    .labelsHidden()
                    .tint(Palette.accentBright)
            }
            .padding(.vertical, 12)

            if showsDivider {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.leading, 52)
            }
        }
    }

    private func iconTile(_ symbol: String) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
    }

    // MARK: Collaborators

    private var collaboratorsRow: some View {
        Button {
            Haptics.tap()
            onOpenCollaborators()
        } label: {
            HStack(spacing: 12) {
                iconTile("person.2")

                VStack(alignment: .leading, spacing: 2) {
                    Text("Collaborators")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("\(store.collaborators(for: repo.id).count) people have access")
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkMuted)
                }

                Spacer(minLength: 6)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)
            }
            .padding(14)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
        .glassCard()
    }

    // MARK: Save

    private var saveButton: some View {
        Button {
            Haptics.tap()
            store.updateRepository(
                originalName: repo.name,
                name: name,
                blurb: blurb,
                isPrivate: isPrivate,
                defaultBranch: defaultBranch,
                hasIssues: hasIssues,
                hasDiscussions: hasDiscussions,
                hasWiki: hasWiki
            )
            onSaved()
        } label: {
            Text("Save changes")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Palette.accentBright, Palette.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: Palette.accent.opacity(0.45), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(PressableStyle())
        .padding(.top, 4)
        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        RepositorySettingsView(repo: AppStore.sampleRepositories[2])
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
