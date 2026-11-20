//
//  SidebarView.swift
//  GitHub 3D
//
//  The left navigation drawer and the list screens it opens.
//

import SwiftUI

enum SidebarSelection: String, CaseIterable, Identifiable {
    case home
    case feed
    case issues
    case pullRequests
    case repositories
    case projects
    case discussions
    case codespaces
    case copilot
    case explore
    case marketplace
    case mcpRegistry
    case codeAnalyst
    case iconLibrary

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .feed: return "Feed"
        case .issues: return "All issues"
        case .pullRequests: return "All pull requests"
        case .repositories: return "All repositories"
        case .projects: return "Projects"
        case .discussions: return "Discussions"
        case .codespaces: return "Codespaces"
        case .copilot: return "Copilot"
        case .explore: return "Explore"
        case .marketplace: return "Marketplace"
        case .mcpRegistry: return "MCP registry"
        case .codeAnalyst: return "Code Analyst"
        case .iconLibrary: return "Icon library"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "house"
        case .feed: return "rss"
        case .issues: return "exclamationmark.circle"
        case .pullRequests: return "arrow.triangle.pull"
        case .repositories: return "book.closed"
        case .projects: return "square.stack.3d.up"
        case .discussions: return "bubble.left.and.bubble.right"
        case .codespaces: return "terminal"
        case .copilot: return "sparkles"
        case .explore: return "safari"
        case .marketplace: return "bag"
        case .mcpRegistry: return "shippingbox"
        case .codeAnalyst: return "chart.line.uptrend.xyaxis"
        case .iconLibrary: return "square.grid.2x2"
        }
    }
}

// MARK: - Drawer

struct SidebarDrawer: View {
    @EnvironmentObject private var store: AppStore

    var active: SidebarSelection?
    var onSelect: (SidebarSelection) -> Void
    var onOpenRepository: (RepoItem) -> Void = { _ in }
    var onSetStatus: () -> Void
    var onCreateRepository: () -> Void
    var onOpenProfile: () -> Void = {}
    var onOpenRepositories: () -> Void = {}
    var onOpenStars: () -> Void = {}
    var onOpenOrganisations: () -> Void = {}
    var onOpenGists: () -> Void = {}
    var onOpenSettings: () -> Void = {}
    var onSignOut: () -> Void = {}
    var onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 14)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 2) {
                    createRow
                    accountLinks

                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)

                    ForEach(SidebarSelection.allCases) { item in
                        row(item)
                    }

                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)

                    Text("Top repositories")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Palette.inkFaint)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 4)

                    ForEach(store.topSidebarRepositories) { repo in
                        repositoryRow(repo)
                    }

                    signOutButton
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                Rectangle().fill(Palette.canvasDeep.opacity(0.72))
            }
            .ignoresSafeArea()
        }
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Color.white.opacity(0.14))
                .frame(width: 1)
                .ignoresSafeArea()
        }
        .shadow(color: Color(hex: 0x0B0726).opacity(0.6), radius: 30, x: 18, y: 0)
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarView(initials: store.profile.initials, size: 46)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("@\(store.profile.handle)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Palette.inkFaint)
                        .lineLimit(1)

                    Button {
                        Haptics.tap()
                        onCreateRepository()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 17, height: 17)
                            .background(Circle().fill(Palette.accentBright))
                    }
                    .buttonStyle(PressableStyle(scale: 0.9))
                }

                Text(store.profile.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                HStack(spacing: 5) {
                    Image(systemName: "house")
                        .font(.system(size: 10, weight: .medium))
                    Text(store.status.isEmpty ? "No status set" : store.status)
                        .font(.system(size: 12))
                }
                .foregroundStyle(Palette.inkMuted)
            }

            Spacer(minLength: 4)

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
    }

    private func row(_ item: SidebarSelection) -> some View {
        let isActive = active == item

        return Button {
            Haptics.select()
            onSelect(item)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: item.symbol)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isActive ? Palette.accentBright : Palette.inkMuted)
                    .frame(width: 24, alignment: .leading)

                Text(item.title)
                    .font(.system(size: 16, weight: isActive ? .semibold : .medium))
                    .foregroundStyle(isActive ? Color.white : Palette.ink)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .frame(height: 46)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isActive ? Palette.accent.opacity(0.30) : Color.clear)
            )
            .overlay(alignment: .leading) {
                if active == item {
                    Capsule()
                        .fill(Palette.accentBright)
                        .frame(width: 3, height: 20)
                        .padding(.leading, 3)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.98))
    }

    private func repositoryRow(_ repo: RepoItem) -> some View {
        Button {
            Haptics.tap()
            onOpenRepository(repo)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "book.closed")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Palette.inkMuted)
                    .frame(width: 24, alignment: .leading)

                Text(repo.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .frame(height: 40)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.98))
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

    private var accountLinks: some View {
        VStack(spacing: 2) {
            ForEach(ProfileMenuItem.allCases) { item in
                accountRow(item)
            }

            tryEnterpriseRow
        }
        .padding(.top, 10)
    }

    private func accountRow(_ item: ProfileMenuItem) -> some View {
        Button {
            Haptics.select()
            switch item {
            case .profile:
                onOpenProfile()
            case .repositories:
                onOpenRepositories()
            case .stars:
                onOpenStars()
            case .organisations:
                onOpenOrganisations()
            case .gists:
                onOpenGists()
            case .settings, .copilotSettings, .appearance, .accessibility:
                onOpenSettings()
            case .enterprises, .sponsors, .featurePreview:
                onClose()
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

                if item == .featurePreview {
                    Spacer(minLength: 6)
                    Text("New")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Palette.accentBright))
                } else {
                    Spacer(minLength: 0)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.98))
    }

    private var tryEnterpriseRow: some View {
        Button {
            Haptics.tap()
            onClose()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "building.columns")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Palette.inkMuted)
                    .frame(width: 24, alignment: .leading)

                Text("Try Enterprise")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Palette.ink)

                Spacer(minLength: 6)

                Text("New")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Palette.accentBright))

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

// MARK: - Destination screen

struct SidebarDestinationView: View {
    @EnvironmentObject private var store: AppStore

    var selection: SidebarSelection
    var onBack: () -> Void
    var onOpenIssue: (IssueItem) -> Void = { _ in }
    var onOpenPullRequest: (PullRequestItem) -> Void = { _ in }
    var onOpenDiscussion: (DiscussionItem) -> Void = { _ in }
    var onOpenOrganisation: (OrganisationItem) -> Void = { _ in }
    var onOpenProject: (SectionEntry) -> Void = { _ in }

    var body: some View {
        if selection == .iconLibrary {
            IconLibraryView(onBack: onBack)
        } else {
            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 14)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeading(title: selection.title, subtitle: subtitle)

                        if selection == .issues && !store.issues.isEmpty {
                            issueCard
                        } else if selection == .pullRequests && !store.pullRequests.isEmpty {
                            pullRequestCard
                        } else if selection == .discussions && !store.discussions.isEmpty {
                            discussionCard
                        } else if entries.isEmpty {
                            emptyCard
                        } else {
                            entryCard
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 130)
                }
            }
        }
    }

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

            Text(selection.title)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Image(systemName: selection.symbol)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .frame(width: 46, height: 46)
                .background(Circle().fill(Color.white.opacity(0.08)))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .glassCard(fill: Color.white.opacity(0.10), radius: 28)
    }

    private var issueCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(store.issues.enumerated()), id: \.element.id) { index, issue in
                EntryRowView(entry: issue.listEntry) {
                    Haptics.tap()
                    onOpenIssue(issue)
                }

                if index < store.issues.count - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 1)
                        .padding(.leading, 60)
                }
            }
        }
        .padding(.vertical, 6)
        .glassCard()
    }

    private var pullRequestCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(store.pullRequests.enumerated()), id: \.element.id) { index, request in
                EntryRowView(entry: request.listEntry) {
                    Haptics.tap()
                    onOpenPullRequest(request)
                }

                if index < store.pullRequests.count - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 1)
                        .padding(.leading, 60)
                }
            }
        }
        .padding(.vertical, 6)
        .glassCard()
    }

    private var discussionCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(store.discussions.enumerated()), id: \.element.id) { index, discussion in
                EntryRowView(entry: discussion.listEntry) {
                    Haptics.tap()
                    onOpenDiscussion(discussion)
                }

                if index < store.discussions.count - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 1)
                        .padding(.leading, 60)
                }
            }
        }
        .padding(.vertical, 6)
        .glassCard()
    }

    private var entryCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                EntryRowView(entry: entry) {
                    Haptics.tap()
                    if selection == .projects {
                        onOpenProject(entry)
                    }
                }

                if index < entries.count - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 1)
                        .padding(.leading, 60)
                }
            }
        }
        .padding(.vertical, 6)
        .glassCard()
    }

    private var emptyCard: some View {
        VStack(spacing: 10) {
            Image(systemName: selection.symbol)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
            Text("Nothing here yet.")
                .font(.system(size: 14))
                .foregroundStyle(Palette.inkFaint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .glassCard()
    }

    private var subtitle: String {
        switch selection {
        case .home: return "Your activity, all in one place"
        case .feed: return "What's new in your network"
        case .issues: return "\(store.issues.count) open"
        case .pullRequests: return "\(store.pullRequests.filter(\.isOpen).count) open"
        case .repositories: return "\(store.repositories.count) repositories"
        case .discussions: return "\(store.discussions.count) new"
        case .projects: return "\(store.projects.count) active"
        case .codespaces: return "Your cloud dev environments"
        case .explore: return "Trending right now"
        case .marketplace: return "Tools for your workflow"
        case .mcpRegistry: return "Model Context Protocol servers"
        case .copilot: return "Your AI pair programmer"
        case .codeAnalyst: return "Health and quality across your code"
        case .iconLibrary: return "Browse and copy Heroicons"
        }
    }

    private var entries: [SectionEntry] {
        switch selection {
        case .home:
            return []
        case .feed:
            return [
                SectionEntry(title: "Debbie opened an issue in swiftui-lab", subtitle: "12 minutes ago", symbol: "exclamationmark.circle"),
                SectionEntry(title: "You starred liquid-glass-kit", subtitle: "2 hours ago", symbol: "star"),
                SectionEntry(title: "mermaid-forge released v1.4", subtitle: "yesterday", symbol: "tag"),
                SectionEntry(title: "Arya Labs invited you to Copilot 3D", subtitle: "2d ago", symbol: "building.2")
            ]
        case .issues:
            return store.issues.map(\.listEntry)
        case .pullRequests:
            return store.pullRequests.map(\.listEntry)
        case .repositories:
            return store.repositories.map { repo in
                SectionEntry(
                    title: repo.name,
                    subtitle: "\(repo.language) · Updated \(repo.updated)",
                    symbol: "book.closed"
                )
            }
        case .discussions:
            return store.discussions.map(\.listEntry)
        case .codespaces:
            return [
                SectionEntry(title: "swiftui-lab — main", subtitle: "Active 2h ago · 4 cores", symbol: "terminal"),
                SectionEntry(title: "copilot-playground — main", subtitle: "Stopped · last used yesterday", symbol: "terminal")
            ]
        case .explore:
            return [
                SectionEntry(title: "Trending repositories this week", subtitle: "SwiftUI · Liquid glass", symbol: "flame"),
                SectionEntry(title: "Topics to follow", subtitle: "Swift · iOS · Design systems", symbol: "number"),
                SectionEntry(title: "People to follow", subtitle: "12 suggestions", symbol: "person.2")
            ]
        case .marketplace:
            return [
                SectionEntry(title: "Copilot", subtitle: "AI pair programmer", symbol: "sparkles"),
                SectionEntry(title: "Code review", subtitle: "Automated pull request review", symbol: "checkmark.seal"),
                SectionEntry(title: "Actions", subtitle: "CI and CD workflows", symbol: "gearshape.2")
            ]
        case .projects:
            return store.projects
        case .mcpRegistry:
            return [
                SectionEntry(title: "Filesystem", subtitle: "Read and write local files", symbol: "shippingbox"),
                SectionEntry(title: "Fetch", subtitle: "Retrieve and convert web pages", symbol: "shippingbox"),
                SectionEntry(title: "Memory", subtitle: "Persist notes between sessions", symbol: "shippingbox")
            ]
        case .copilot:
            return []
        case .codeAnalyst:
            return []
        case .iconLibrary:
            return []
        }
    }
}

#Preview {
    ZStack(alignment: .leading) {
        AppBackdrop()
        SidebarDrawer(
            active: .issues,
            onSelect: { _ in },
            onOpenRepository: { _ in },
            onSetStatus: {},
            onCreateRepository: {},
            onClose: {}
        )
        .frame(width: 320)
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
