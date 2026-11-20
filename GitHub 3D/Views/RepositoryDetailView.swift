//
//  RepositoryDetailView.swift
//  GitHub 3D
//
//  A repository overview: hero, README, files and its issues and pull requests.
//

import SwiftUI
import UIKit

struct RepositoryDetailView: View {
    @EnvironmentObject private var store: AppStore

    var repo: RepoItem
    var onBack: () -> Void = {}
    var onOpenIssue: (IssueItem) -> Void = { _ in }
    var onOpenPullRequest: (PullRequestItem) -> Void = { _ in }
    var onOpenInsights: (RepoItem) -> Void = { _ in }
    var onOpenActivity: (RepoItem) -> Void = { _ in }
    var onOpenReleases: (RepoItem) -> Void = { _ in }
    var onOpenSettings: (RepoItem) -> Void = { _ in }
    var onCompareBranches: (RepoItem, String, [String]) -> Void = { _, _, _ in }

    @State private var didCopy = false
    @State private var composer: RepositoryComposer?
    @State private var showReadmeEditor = false
    @State private var browserFolder = "Sources"
    @State private var showBrowser = false
    @State private var branch = "main"
    @State private var cloneFormat: CloneFormat = .https

    @AppStorage("home.pinnedRepositories") private var pinnedRaw =
        "swiftui-lab,liquid-glass-kit,copilot-playground"

    private let branches = ["main", "develop", "release/1.4", "feature/liquid-glass"]

    private var liveRepo: RepoItem {
        store.repositories.first(where: { $0.id == repo.id })
            ?? store.exploreRepositories.first(where: { $0.id == repo.id })
            ?? store.repositories.first(where: { $0.name == repo.name })
            ?? store.exploreRepositories.first(where: { $0.name == repo.name })
            ?? repo
    }

    private var name: String {
        liveRepo.name
    }

    private var isStarred: Bool {
        store.isStarred(name)
    }

    private var isWatching: Bool {
        store.isWatched(name)
    }

    private var pinnedNames: [String] {
        pinnedRaw
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private var isPinned: Bool {
        pinnedNames.contains(name)
    }

    private func togglePin() {
        var names = pinnedNames

        if let index = names.firstIndex(of: name) {
            names.remove(at: index)
        } else {
            guard names.count < 3 else { return }
            names.append(name)
        }

        pinnedRaw = names.joined(separator: ",")
    }

    private var readmeTitle: String {
        name == "swiftui-lab"
            ? "Liquid Glass Kit"
            : name.replacingOccurrences(of: "-", with: " ").capitalized
    }

    private var readmeBody: String {
        if name == "swiftui-lab" {
            return "A collection of beautiful, reusable SwiftUI components with a liquid glass aesthetic. Designed to help you polish your app faster."
        }
        return liveRepo.blurb
    }

    private var typeName: String {
        name
            .split(separator: "-")
            .prefix(2)
            .map { String($0).capitalized }
            .joined()
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 14)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    VStack(spacing: 10) {
                        heroCard
                        branchBar
                    }
                    cloneBar
                    readmeCard
                    filesCard
                    issuesCard
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
            }
        }
        .sheet(item: $composer) { kind in
            RepositoryComposerSheet(kind: kind, repository: name) { created in
                switch created {
                case .issue(let issue):
                    onOpenIssue(issue)
                case .pullRequest(let request):
                    onOpenPullRequest(request)
                }
            }
            .presentationDetents([.height(440)])
            .presentationCornerRadius(32)
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showReadmeEditor) {
            ReadmeEditorView(repositoryName: name)
        }
        .fullScreenCover(isPresented: $showBrowser) {
            FileBrowserView(repositoryName: name, folder: browserFolder, branch: branch)
        }
        .onAppear {
            store.recordRepositoryView(liveRepo)
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            circleButton(symbol: "chevron.left") {
                Haptics.tap()
                onBack()
            }

            Spacer()

            Text(name)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer()

            Menu {
                Button {
                    Haptics.select()
                    togglePin()
                } label: {
                    if isPinned {
                        Label("Unpin", systemImage: "pin.slash")
                    } else {
                        Label("Pin to Home", systemImage: "pin")
                    }
                }

                Button {
                    Haptics.tap()
                    onOpenSettings(liveRepo)
                } label: {
                    Label("Repository settings", systemImage: "gearshape")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.20), .white.opacity(0.06)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .overlay(Circle().strokeBorder(.white.opacity(0.22), lineWidth: 1))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .glassCard(fill: Color.white.opacity(0.10), radius: 28)
    }

    private func circleButton(symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.20), .white.opacity(0.06)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .overlay(Circle().strokeBorder(.white.opacity(0.22), lineWidth: 1))
        }
        .buttonStyle(PressableStyle(scale: 0.9))
    }

    // MARK: Hero

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 82, height: 82)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.18), .white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 5) {
                    Text(name)
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)

                    Text(liveRepo.blurb)
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                metaChip(symbol: "swift", text: liveRepo.language)
                metaChip(symbol: "star", text: "\(liveRepo.stars) stars")
                metaChip(symbol: "arrow.triangle.branch", text: "\(liveRepo.forks) forks")
                if liveRepo.isPrivate {
                    metaChip(symbol: "lock", text: "Private")
                }
            }

            HStack(spacing: 12) {
                Button {
                    Haptics.select()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        store.toggleStar(named: name)
                    }
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: isStarred ? "star.fill" : "star")
                            .font(.system(size: 15, weight: .semibold))
                        Text(isStarred ? "Starred" : "Star")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Palette.accentBright, Palette.accent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: Palette.accent.opacity(0.45), radius: 16, x: 0, y: 8)
                }
                .buttonStyle(PressableStyle())

                Button {
                    Haptics.select()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        store.toggleWatch(named: name)
                    }
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: isWatching ? "eye.fill" : "eye")
                            .font(.system(size: 15, weight: .semibold))
                        Text(isWatching ? "Watching" : "Watch")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.12))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.20), lineWidth: 1)
                    )
                }
                .buttonStyle(PressableStyle())
            }
        }
        .padding(16)
        .glassCard()
    }

    private func metaChip(symbol: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .frame(height: 42)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    // MARK: Branch

    private var branchBar: some View {
        Menu {
            ForEach(branches, id: \.self) { name in
                Button {
                    Haptics.select()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        branch = name
                    }
                } label: {
                    if name == branch {
                        Label(name, systemImage: "checkmark")
                    } else {
                        Text(name)
                    }
                }
            }

            Divider()

            Button {
                Haptics.tap()
                onCompareBranches(liveRepo, branch, branches)
            } label: {
                Label("Compare branches", systemImage: "arrow.left.arrow.right")
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.white.opacity(0.10)))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.14), lineWidth: 1))

                VStack(alignment: .leading, spacing: 1) {
                    Text(branch)
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(branch == "main" ? "Default branch" : "Branch")
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.inkFaint)
                }

                Spacer(minLength: 6)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.inkMuted)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
    }

    // MARK: Clone

    private enum CloneFormat: String, CaseIterable, Identifiable {
        case https = "HTTPS"
        case ssh = "SSH"
        case cli = "GitHub CLI"

        var id: String { rawValue }
    }

    /// Built from the profile handle and the repository name, so each repository
    /// shows the address it actually lives at on GitHub.
    private var repositoryPath: String {
        name.contains("/") ? name : "\(store.profile.handle)/\(name)"
    }

    private var cloneCommand: String {
        switch cloneFormat {
        case .https: return "https://github.com/\(repositoryPath).git"
        case .ssh: return "git@github.com:\(repositoryPath).git"
        case .cli: return "gh repo clone \(repositoryPath)"
        }
    }

    private var cloneBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Clone")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)

            HStack(spacing: 10) {
                Image(systemName: "link")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.white.opacity(0.10)))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.14), lineWidth: 1))

                Text(cloneCommand)
                    .font(.system(size: 13.5, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Menu {
                    ForEach(CloneFormat.allCases) { format in
                        Button {
                            Haptics.select()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                cloneFormat = format
                            }
                        } label: {
                            if format == cloneFormat {
                                Label(format.rawValue, systemImage: "checkmark")
                            } else {
                                Text(format.rawValue)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text(cloneFormat.rawValue)
                            .font(.system(size: 12.5, weight: .semibold))
                            .lineLimit(1)

                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(Palette.inkMuted)
                    .padding(.horizontal, 10)
                    .frame(height: 30)
                    .background(Capsule().fill(Color.white.opacity(0.08)))
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.14), lineWidth: 1))
                }

                Button {
                    copyCloneCommand()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 12, weight: .bold))
                        Text(didCopy ? "Copied" : "Copy")
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(didCopy ? Palette.accentBright : Color.white)
                    .padding(.horizontal, 12)
                    .frame(height: 34)
                    .background(Capsule().fill(Color.white.opacity(didCopy ? 0.16 : 0.10)))
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.20), lineWidth: 1))
                }
                .buttonStyle(PressableStyle(scale: 0.94))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
            )
        }
        .padding(16)
        .glassCard()
    }

    private func copyCloneCommand() {
        UIPasteboard.general.string = cloneCommand
        Haptics.tap()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            didCopy = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if didCopy {
                withAnimation(.easeOut(duration: 0.2)) {
                    didCopy = false
                }
            }
        }
    }

    // MARK: README

    private var readmeCard: some View {
        let markdown = store.readme(for: name)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("README")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    Haptics.tap()
                    showReadmeEditor = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Edit")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Palette.accentBright)
                }
                .buttonStyle(.plain)
            }

            MarkdownPreview(markdown: markdown)

            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(height: 1)
                .padding(.vertical, 2)

            Button {
                Haptics.tap()
            } label: {
                HStack(spacing: 6) {
                    Text("View full README")
                        .font(.system(size: 15, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(Palette.accentBright)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .glassCard()
    }

    private var readmeCode: String {
        """
        import SwiftUI

        struct \(typeName)View: View {
            var body: some View {
                Text("Hello, \(typeName)!")
            }
        }
        """
    }

    // MARK: Files

    private var filesCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Files")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.white)
                .padding(.bottom, 8)

            fileRow(symbol: "folder", title: "Sources", inset: false)
            divider
            fileRow(symbol: "folder", title: "Tests", inset: true)
            divider
            fileRow(symbol: "doc.text", title: "README.md", inset: true)
            divider
            fileRow(symbol: "chart.bar.xaxis", title: "Insights", inset: true) {
                onOpenInsights(repo)
            }
            divider
            fileRow(symbol: "clock.arrow.circlepath", title: "Activity", inset: true) {
                onOpenActivity(liveRepo)
            }
            divider
            fileRow(symbol: "shippingbox", title: "Releases", inset: true) {
                onOpenReleases(repo)
            }
        }
        .padding(16)
        .glassCard()
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(height: 1)
            .padding(.leading, 34)
    }

    private func fileRow(
        symbol: String,
        title: String,
        inset: Bool,
        action: (() -> Void)? = nil
    ) -> some View {
        Button {
            Haptics.tap()
            if let action {
                action()
            } else {
                browserFolder = title == "README.md" ? "README" : title
                showBrowser = true
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.white)
                    .frame(width: 24, alignment: .leading)

                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Palette.ink)

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
    }

    // MARK: Issues and pull requests

    private var issuesCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Issues and pull requests")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.white)
                .padding(.bottom, 8)

            countRow(
                symbol: "exclamationmark.circle",
                title: "Issues",
                count: store.issues.count
            )

            divider

            countRow(
                symbol: "arrow.triangle.pull",
                title: "Pull requests",
                count: store.pullRequests.count
            )

            HStack(spacing: 10) {
                createButton(title: "New issue", symbol: "plus") {
                    showComposer(.issue)
                }
                createButton(title: "New pull request", symbol: "plus") {
                    showComposer(.pullRequest)
                }
            }
            .padding(.top, 10)
        }
        .padding(16)
        .glassCard()
    }

    private func createButton(title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 13, weight: .bold))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(PressableStyle(scale: 0.97))
    }

    private func showComposer(_ kind: RepositoryComposer) {
        Haptics.tap()
        composer = kind
    }

    private func countRow(symbol: String, title: String, count: Int) -> some View {
        Button {
            Haptics.tap()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.white)
                    .frame(width: 24, alignment: .leading)

                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Palette.ink)

                Spacer(minLength: 6)

                Text("\(count) open")
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.inkMuted)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
    }
}

enum RepositoryComposer: String, Identifiable {
    case issue
    case pullRequest

    var id: String { rawValue }

    var title: String {
        switch self {
        case .issue: return "New issue"
        case .pullRequest: return "New pull request"
        }
    }

    var cta: String {
        switch self {
        case .issue: return "Create issue"
        case .pullRequest: return "Create pull request"
        }
    }
}

enum ComposedRepositoryItem {
    case issue(IssueItem)
    case pullRequest(PullRequestItem)
}

enum IssueTemplate: String, CaseIterable, Identifiable {
    case bug = "Bug report"
    case feature = "Feature request"
    case blank = "Blank"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .bug: return "ladybug"
        case .feature: return "sparkles"
        case .blank: return "doc"
        }
    }

    var titlePrefix: String {
        switch self {
        case .bug: return "Bug: "
        case .feature: return "Feature: "
        case .blank: return ""
        }
    }

    var body: String {
        switch self {
        case .bug:
            return """
            ## What happened

            ## What you expected

            ## Steps to reproduce
            1.
            2.
            """
        case .feature:
            return """
            ## What happened

            ## What you expected

            ## Steps to reproduce
            1.
            2.
            """
        case .blank:
            return ""
        }
    }
}

struct RepositoryComposerSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var kind: RepositoryComposer
    var repository: String
    var onCreated: (ComposedRepositoryItem) -> Void

    @State private var title = ""
    @State private var detail = ""
    @State private var template: IssueTemplate?

    private var canCreate: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(kind.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                    Text(repository)
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.inkFaint)
                        .lineLimit(1)
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Color.white.opacity(0.12)))
                }
                .buttonStyle(PressableStyle(scale: 0.9))
            }

            if kind == .issue {
                HStack(spacing: 8) {
                    ForEach(IssueTemplate.allCases) { option in
                        templateChip(option)
                    }
                    Spacer(minLength: 0)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("TITLE")
                TextField("Add a title", text: $title, axis: .vertical)
                    .lineLimit(1...3)
                    .authField()
            }

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("DESCRIPTION")
                TextField("Describe it…", text: $detail, axis: .vertical)
                    .lineLimit(4...8)
                    .padding(14)
                    .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
                    .tint(Palette.accentBright)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                    )
            }

            Spacer(minLength: 0)

            Button {
                create()
            } label: {
                Text(kind.cta)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
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
            .disabled(!canCreate)
            .opacity(canCreate ? 1 : 0.45)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppBackdrop())
        .preferredColorScheme(.dark)
    }

    private func templateChip(_ option: IssueTemplate) -> some View {
        let isSelected = template == option

        return Button {
            Haptics.select()
            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                template = option
                title = option.titlePrefix
                detail = option.body
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: option.symbol)
                    .font(.system(size: 11, weight: .semibold))
                Text(option.rawValue)
                    .font(.system(size: 12.5, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(isSelected ? Color.white : Palette.inkMuted)
            .padding(.horizontal, 11)
            .frame(height: 34)
            .background {
                if isSelected {
                    Capsule().fill(
                        LinearGradient(
                            colors: [Palette.accentBright, Palette.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                } else {
                    Capsule().fill(Color.white.opacity(0.08))
                }
            }
            .overlay(Capsule().strokeBorder(Color.white.opacity(0.16), lineWidth: 1))
        }
        .buttonStyle(PressableStyle(scale: 0.95))
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .tracking(1.3)
            .foregroundStyle(Palette.inkFaint)
    }

    private func create() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDetail = detail.trimmingCharacters(in: .whitespacesAndNewlines)
        let created: ComposedRepositoryItem

        switch kind {
        case .issue:
            let issue = store.addIssue(
                title: trimmedTitle,
                detail: trimmedDetail,
                repository: repository
            )
            created = .issue(issue)
        case .pullRequest:
            let request = store.addPullRequest(
                title: trimmedTitle,
                detail: trimmedDetail,
                repository: repository
            )
            created = .pullRequest(request)
        }

        Haptics.tap()
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            onCreated(created)
        }
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        RepositoryDetailView(repo: AppStore.sampleRepositories[0])
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
