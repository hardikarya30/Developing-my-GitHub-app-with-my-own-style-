//
//  RepositoryActivityView.swift
//  GitHub 3D
//
//  A filterable timeline of commits, issues, pull requests and releases.
//

import SwiftUI

private enum RepositoryActivityFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case commits = "Commits"
    case issues = "Issues"
    case pullRequests = "Pull requests"
    case releases = "Releases"

    var id: String { rawValue }

    var kind: RepositoryActivityKind? {
        switch self {
        case .all: return nil
        case .commits: return .commit
        case .issues: return .issue
        case .pullRequests: return .pullRequest
        case .releases: return .release
        }
    }
}

private enum RepositoryActivityKind {
    case commit
    case issue
    case pullRequest
    case release

    var symbol: String {
        switch self {
        case .commit: return "chevron.left.forwardslash.chevron.right"
        case .issue: return "bubble.left"
        case .pullRequest: return "arrow.triangle.branch"
        case .release: return "tag"
        }
    }

    var markerColor: Color {
        self == .release ? Palette.inkFaint : Palette.accentBright
    }
}

private struct RepositoryActivityEvent: Identifiable {
    var id: String
    var kind: RepositoryActivityKind
    var date: Date
    var title: String
    var subtitle: String
    var issue: IssueItem?
    var pullRequest: PullRequestItem?
    var filePath: String?
}

private struct RepositoryActivityGroup: Identifiable {
    var date: Date
    var events: [RepositoryActivityEvent]

    var id: Date { date }
}

struct RepositoryActivityView: View {
    @EnvironmentObject private var store: AppStore

    var repo: RepoItem
    var onBack: () -> Void = {}
    var onOpenIssue: (IssueItem) -> Void = { _ in }
    var onOpenPullRequest: (PullRequestItem) -> Void = { _ in }
    var onOpenReleases: (RepoItem) -> Void = { _ in }

    @State private var selectedFilter: RepositoryActivityFilter = .all
    @State private var showFileBrowser = false
    @State private var browserFolder = "Sources"

    private var visibleEvents: [RepositoryActivityEvent] {
        allEvents
            .filter { selectedFilter.kind == nil || $0.kind == selectedFilter.kind }
            .sorted { $0.date > $1.date }
    }

    private var allEvents: [RepositoryActivityEvent] {
        commitEvents + issueEvents + pullRequestEvents + releaseEvents
    }

    private var groups: [RepositoryActivityGroup] {
        let grouped = Dictionary(grouping: visibleEvents) {
            Calendar.current.startOfDay(for: $0.date)
        }

        return grouped
            .map { RepositoryActivityGroup(date: $0.key, events: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 10)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    titleBlock
                    filterPicker
                        .padding(.top, 18)

                    if groups.isEmpty {
                        emptyState
                            .padding(.top, 28)
                    } else {
                        LazyVStack(alignment: .leading, spacing: 24) {
                            ForEach(groups) { group in
                                dateGroup(group)
                            }
                        }
                        .padding(.top, 22)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 130)
            }
        }
        .fullScreenCover(isPresented: $showFileBrowser) {
            FileBrowserView(repositoryName: repo.name, folder: browserFolder, branch: repo.defaultBranch)
        }
    }

    private var navigationBar: some View {
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
            .accessibilityLabel("Back to repository")

            Spacer()

            Text(repo.name)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer()

            Color.clear
                .frame(width: 46, height: 46)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .glassCard(fill: Color.white.opacity(0.10), radius: 28)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Activity")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)

            Text("What's happening in this repository")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
    }

    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(RepositoryActivityFilter.allCases) { filter in
                    let isSelected = selectedFilter == filter

                    Button {
                        Haptics.select()
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                            selectedFilter = filter
                        }
                    } label: {
                        Text(filter.rawValue)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(isSelected ? Color.white : Palette.inkMuted)
                            .padding(.horizontal, 12)
                            .frame(height: 39)
                            .background {
                                Capsule()
                                    .fill(isSelected ? Palette.accentBright : Color.white.opacity(0.08))
                            }
                            .overlay {
                                Capsule()
                                    .strokeBorder(Color.white.opacity(isSelected ? 0.25 : 0.12), lineWidth: 1)
                            }
                    }
                    .buttonStyle(PressableStyle(scale: 0.96))
                }
            }
            .padding(.vertical, 2)
        }
        .contentMargins(.trailing, 2)
    }

    private func dateGroup(_ group: RepositoryActivityGroup) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(dateTitle(for: group.date))
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)

            VStack(spacing: 11) {
                ForEach(group.events) { event in
                    eventRow(event)
                }
            }
            .background(alignment: .leading) {
                GeometryReader { proxy in
                    Rectangle()
                        .fill(Palette.accentBright.opacity(0.35))
                        .frame(width: 1, height: max(0, proxy.size.height - 40))
                        .position(x: 9, y: proxy.size.height / 2)
                }
                .frame(width: 18)
            }
        }
    }

    private func eventRow(_ event: RepositoryActivityEvent) -> some View {
        Button {
            open(event)
        } label: {
            HStack(spacing: 9) {
                Circle()
                    .fill(event.kind.markerColor)
                    .frame(width: 10, height: 10)
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.62), lineWidth: 1))
                    .shadow(color: event.kind.markerColor.opacity(0.65), radius: 5)
                    .frame(width: 18)

                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 42, height: 42)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                        }
                        .overlay {
                            Image(systemName: event.kind.symbol)
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(.white)
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        Text(event.subtitle)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Palette.inkMuted)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Palette.inkFaint)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.075))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.13), lineWidth: 1)
                )
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens this activity")
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .frame(width: 72, height: 72)
                .background(Circle().fill(Color.white.opacity(0.08)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

            Text("No activity yet")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(.white)

            Text("There are no \(selectedFilter.rawValue.lowercased()) to show for this repository.")
                .font(.system(size: 14))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .glassCard()
    }

    private var commitEvents: [RepositoryActivityEvent] {
        let title = repo.name == "swiftui-lab" ? "liquid glass polish" : "\(repo.name) polish"
        let event = RepositoryActivityEvent(
            id: "\(repo.name)-recent-commits",
            kind: .commit,
            date: date(from: "2 hours ago"),
            title: title,
            subtitle: "\(store.profile.name) pushed 3 commits · 2 hours ago",
            filePath: "Sources/GlassCard.swift"
        )
        return [event]
    }

    private var issueEvents: [RepositoryActivityEvent] {
        store.issues
            .filter { $0.repository == repo.name }
            .map { issue in
                RepositoryActivityEvent(
                    id: "issue-\(issue.id)",
                    kind: .issue,
                    date: date(from: issue.time),
                    title: issue.title,
                    subtitle: "Issue #\(issue.number) \(issue.isOpen ? "opened" : "closed") by \(issue.author) · \(issue.time)",
                    issue: issue
                )
            }
            .sorted { $0.date > $1.date }
            .prefix(1)
            .map { $0 }
    }

    private var pullRequestEvents: [RepositoryActivityEvent] {
        store.pullRequests
            .filter { $0.repository == repo.name }
            .map { request in
                RepositoryActivityEvent(
                    id: "pull-request-\(request.id)",
                    kind: .pullRequest,
                    date: date(from: request.time),
                    title: request.title,
                    subtitle: "Pull request #\(request.number) \(request.isOpen ? "opened" : "merged") by \(request.author) · \(request.time)",
                    pullRequest: request
                )
            }
            .sorted { $0.date > $1.date }
            .prefix(1)
            .map { $0 }
    }

    private var releaseEvents: [RepositoryActivityEvent] {
        (store.releases[repo.name] ?? [])
            .map { release in
                RepositoryActivityEvent(
                    id: "release-\(release.id)",
                    kind: .release,
                    date: date(from: release.published),
                    title: release.tag,
                    subtitle: "Release published · \(release.published)"
                )
            }
            .sorted { $0.date > $1.date }
            .prefix(1)
            .map { $0 }
    }

    private func open(_ event: RepositoryActivityEvent) {
        Haptics.tap()

        if let issue = event.issue {
            onOpenIssue(issue)
        } else if let request = event.pullRequest {
            onOpenPullRequest(request)
        } else if event.kind == .release {
            onOpenReleases(repo)
        } else {
            let path = event.filePath ?? "Sources/"
            browserFolder = path.split(separator: "/").first.map(String.init) ?? "Sources"
            showFileBrowser = true
        }
    }

    private func dateTitle(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }

    private func date(from relativeTime: String) -> Date {
        let normalized = relativeTime.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let now = Date()

        if normalized.contains("just now") { return now.addingTimeInterval(-30) }
        if normalized.contains("yesterday") {
            return Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now
        }

        let amountText = normalized.prefix { $0.isNumber }
        let amount = max(1, Int(amountText) ?? 1)
        let unit = String(normalized.dropFirst(amountText.count)).trimmingCharacters(in: .whitespaces)
        let component: Calendar.Component

        if unit.contains("month") || unit.hasPrefix("mo") {
            component = .month
        } else if unit.contains("week") || unit.hasPrefix("w") {
            component = .weekOfYear
        } else if unit.contains("day") || unit.hasPrefix("d") {
            component = .day
        } else if unit.contains("hour") || unit.hasPrefix("h") {
            component = .hour
        } else {
            component = .minute
        }

        return Calendar.current.date(byAdding: component, value: -amount, to: now) ?? now
    }
}
