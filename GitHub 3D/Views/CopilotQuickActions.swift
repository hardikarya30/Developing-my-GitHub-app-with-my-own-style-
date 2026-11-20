//
//  CopilotQuickActions.swift
//  GitHub 3D
//
//  The quick-action bar under the composer, its menus and sheets.
//

import SwiftUI
import UIKit

// MARK: - Actions

enum CopilotPersona: String, Identifiable, CaseIterable {
    case debbie
    case agent

    var id: String { rawValue }

    var title: String {
        switch self {
        case .debbie: return "Debbie"
        case .agent: return "Agent"
        }
    }

    var symbol: String {
        switch self {
        case .debbie: return "bubble.left"
        case .agent: return "person"
        }
    }

    var blurb: String {
        switch self {
        case .debbie:
            return "Debbie reads your code and explains what broke, in plain language."
        case .agent:
            return "Agent plans a task and works through it step by step in your repo."
        }
    }
}

enum WriteCodePrompt: String, CaseIterable, Identifiable {
    case profileReadme
    case calculator
    case pong
    case mermaid

    var id: String { rawValue }

    var title: String {
        switch self {
        case .profileReadme: return "Create a profile README"
        case .calculator: return "Generate a simple calculator"
        case .pong: return "Make a Pong game"
        case .mermaid: return "Design a Mermaid architecture overview"
        }
    }

    var prompt: String {
        switch self {
        case .profileReadme:
            return "Create a profile README that introduces me and the projects I am building."
        case .calculator:
            return "Generate a simple calculator in SwiftUI that adds, subtracts, multiplies and divides."
        case .pong:
            return "Make a Pong game in SwiftUI with two paddles, a bouncing ball and a score."
        case .mermaid:
            return "Design a Mermaid architecture overview for my SwiftUI app."
        }
    }
}

struct GitCommand: Identifiable, Hashable {
    var command: String
    var detail: String

    var id: String { command }
}

enum GitReference: String, CaseIterable, Identifiable {
    case basic
    case branching
    case advanced

    var id: String { rawValue }

    var title: String {
        switch self {
        case .basic: return "Basic Git commands"
        case .branching: return "Git branching"
        case .advanced: return "Advanced Git commands"
        }
    }

    var subtitle: String {
        switch self {
        case .basic: return "The everyday commands, from first commit to push."
        case .branching: return "Work in parallel and bring the pieces back together."
        case .advanced: return "Recover, rewrite and move work between branches."
        }
    }

    var commands: [GitCommand] {
        switch self {
        case .basic:
            return [
                GitCommand(command: "git init", detail: "Start a repository here."),
                GitCommand(command: "git clone <url>", detail: "Copy a remote repository."),
                GitCommand(command: "git status", detail: "See what has changed."),
                GitCommand(command: "git add .", detail: "Stage every change."),
                GitCommand(command: "git commit -m \"Message\"", detail: "Save staged work."),
                GitCommand(command: "git pull", detail: "Bring down new commits."),
                GitCommand(command: "git push", detail: "Publish your commits.")
            ]
        case .branching:
            return [
                GitCommand(command: "git branch", detail: "List your branches."),
                GitCommand(command: "git switch -c feature", detail: "Create and switch to a branch."),
                GitCommand(command: "git switch main", detail: "Go back to main."),
                GitCommand(command: "git merge feature", detail: "Merge a branch into this one."),
                GitCommand(command: "git branch -d feature", detail: "Delete a finished branch."),
                GitCommand(command: "git log --oneline --graph", detail: "Read the branch history."),
                GitCommand(command: "git rebase main", detail: "Replay your work on top of main.")
            ]
        case .advanced:
            return [
                GitCommand(command: "git stash", detail: "Shelve work in progress."),
                GitCommand(command: "git stash pop", detail: "Restore the shelved work."),
                GitCommand(command: "git reset --hard HEAD~1", detail: "Drop the last commit."),
                GitCommand(command: "git cherry-pick <sha>", detail: "Copy one commit onto this branch."),
                GitCommand(command: "git reflog", detail: "Find commits you thought were lost."),
                GitCommand(command: "git rebase -i HEAD~3", detail: "Squash or edit recent commits."),
                GitCommand(command: "git remote -v", detail: "Show where this repo points.")
            ]
        }
    }
}

// MARK: - Bar

struct CopilotQuickActionsBar: View {
    var onPersona: (CopilotPersona) -> Void
    var onCreateIssue: () -> Void
    var onWriteCode: (WriteCodePrompt) -> Void
    var onGit: (GitReference) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                pillButton(title: "Debbie", symbol: "bubble.left") {
                    Haptics.tap()
                    onPersona(.debbie)
                }

                pillButton(title: "Agent", symbol: "person") {
                    Haptics.tap()
                    onPersona(.agent)
                }

                pillButton(title: "Create issue", symbol: "plus.circle") {
                    Haptics.tap()
                    onCreateIssue()
                }

                Menu {
                    ForEach(WriteCodePrompt.allCases) { prompt in
                        Button(prompt.title) {
                            Haptics.select()
                            onWriteCode(prompt)
                        }
                    }
                } label: {
                    pillLabel(
                        title: "Write code",
                        symbol: "chevron.left.forwardslash.chevron.right",
                        showsChevron: true
                    )
                }

                Menu {
                    ForEach(GitReference.allCases) { reference in
                        Button(reference.title) {
                            Haptics.tap()
                            onGit(reference)
                        }
                    }
                } label: {
                    pillLabel(title: "Git", symbol: "arrow.triangle.branch", showsChevron: true)
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, -20)
    }

    private func pillButton(title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            pillLabel(title: title, symbol: symbol, showsChevron: false)
        }
        .buttonStyle(PressableStyle(scale: 0.96))
    }

    private func pillLabel(title: String, symbol: String, showsChevron: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(CopilotPalette.violet)

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(CopilotPalette.ink)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(CopilotPalette.inkMuted)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
        .lightGlass(fill: Color.white.opacity(0.86), radius: 25)
    }
}

// MARK: - Toast

struct CopilotToast: View {
    var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 15, weight: .semibold))

            Text(text)
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .frame(height: 46)
        .background(Capsule().fill(CopilotPalette.ink.opacity(0.94)))
        .shadow(color: CopilotPalette.ink.opacity(0.22), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Persona sheet

struct CopilotPersonaSheet: View {
    var persona: CopilotPersona
    var onStart: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(CopilotPalette.ink)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.white.opacity(0.9)))
                }
                .buttonStyle(PressableStyle(scale: 0.9))
            }

            Image(systemName: persona.symbol)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(CopilotPalette.violet)
                .frame(width: 64, height: 64)
                .background(Circle().fill(CopilotPalette.violet.opacity(0.14)))

            Text(persona.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(CopilotPalette.ink)

            Text(persona.blurb)
                .font(.system(size: 15))
                .foregroundStyle(CopilotPalette.inkMuted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)

            Spacer(minLength: 0)

            Button {
                Haptics.tap()
                onStart()
                dismiss()
            } label: {
                Text("Start")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(CopilotPalette.violet)
                    )
                    .shadow(color: CopilotPalette.violet.opacity(0.35), radius: 16, x: 0, y: 8)
            }
            .buttonStyle(PressableStyle())
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CopilotPalette.canvas)
        .preferredColorScheme(.light)
    }
}

// MARK: - Create issue sheet

struct CopilotCreateIssueSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var onCreate: (String) -> Void

    @State private var title = ""
    @State private var detail = ""
    @State private var repositoryName = ""

    private var canCreate: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !repositoryName.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Create issue")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(CopilotPalette.ink)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(CopilotPalette.ink)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.white.opacity(0.9)))
                }
                .buttonStyle(PressableStyle(scale: 0.9))
            }

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("Title")
                TextField("Add a title", text: $title, axis: .vertical)
                    .lineLimit(1...2)
                    .issueField()
            }

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("Repository")

                Menu {
                    ForEach(store.repositories) { repo in
                        Button {
                            repositoryName = repo.name
                        } label: {
                            if repo.name == repositoryName {
                                Label(repo.name, systemImage: "checkmark")
                            } else {
                                Text(repo.name)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(repositoryName.isEmpty ? "Choose a repository" : repositoryName)
                            .foregroundStyle(repositoryName.isEmpty ? CopilotPalette.inkMuted : CopilotPalette.ink)

                        Spacer()

                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(CopilotPalette.inkMuted)
                    }
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 14)
                    .frame(height: 52)
                    .lightGlass(fill: Color.white.opacity(0.9), radius: 16)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("Description")

                TextField("Describe the issue", text: $detail, axis: .vertical)
                    .lineLimit(4...8)
                    .issueField(minHeight: 110, alignment: .topLeading)
            }

            Spacer(minLength: 0)

            Button {
                let name = repositoryName
                store.addIssue(
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    detail: detail.trimmingCharacters(in: .whitespacesAndNewlines),
                    repository: name
                )
                Haptics.tap()
                onCreate("Issue created in \(name)")
                dismiss()
            } label: {
                Text("Create issue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(CopilotPalette.violet)
                    )
                    .shadow(color: CopilotPalette.violet.opacity(0.35), radius: 16, x: 0, y: 8)
            }
            .buttonStyle(PressableStyle())
            .disabled(!canCreate)
            .opacity(canCreate ? 1 : 0.45)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(CopilotPalette.canvas)
        .preferredColorScheme(.light)
        .onAppear {
            if repositoryName.isEmpty {
                repositoryName = store.repositories.first?.name ?? ""
            }
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(CopilotPalette.inkMuted)
    }
}

private extension View {
    func issueField(minHeight: CGFloat = 52, alignment: Alignment = .leading) -> some View {
        self
            .font(.system(size: 16))
            .foregroundStyle(CopilotPalette.ink)
            .tint(CopilotPalette.violet)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: alignment)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.9), lineWidth: 1)
            )
    }
}

// MARK: - Git reference sheet

struct CopilotGitReferenceSheet: View {
    var reference: GitReference

    @Environment(\.dismiss) private var dismiss
    @State private var copiedCommand: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(reference.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(CopilotPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(CopilotPalette.ink)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.white.opacity(0.9)))
                }
                .buttonStyle(PressableStyle(scale: 0.9))
            }

            Text(reference.subtitle)
                .font(.system(size: 15))
                .foregroundStyle(CopilotPalette.inkMuted)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(reference.commands) { command in
                        commandRow(command)
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 8)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(CopilotPalette.canvas)
        .preferredColorScheme(.light)
    }

    private func commandRow(_ command: GitCommand) -> some View {
        Button {
            UIPasteboard.general.string = command.command
            Haptics.tap()
            withAnimation(.easeOut(duration: 0.2)) {
                copiedCommand = command.command
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                if copiedCommand == command.command {
                    withAnimation(.easeOut(duration: 0.2)) {
                        copiedCommand = nil
                    }
                }
            }
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(command.command)
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundStyle(CopilotPalette.ink)
                        .multilineTextAlignment(.leading)
                    Text(command.detail)
                        .font(.system(size: 13))
                        .foregroundStyle(CopilotPalette.inkMuted)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 6)

                Image(systemName: copiedCommand == command.command ? "checkmark.circle.fill" : "doc.on.doc")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(copiedCommand == command.command ? CopilotPalette.violet : CopilotPalette.inkMuted)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.88))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.985))
    }
}
