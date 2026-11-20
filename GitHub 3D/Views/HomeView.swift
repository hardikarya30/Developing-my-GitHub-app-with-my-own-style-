//
//  HomeView.swift
//  GitHub 3D
//
//  The profile dashboard: hero, section chips and the section cards.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppStore

    @State private var section: HomeSection = .home
    @State private var showShortcuts = false
    @State private var showCopilotApp = false
    @State private var showPinPicker = false
    @State private var selectedDay: Int?
    @State private var selectedHeatCell: HeatCell?
    @State private var issueFilter: IssueFilter = .all
    @State private var issueSort: IssueSort = .newest
    @State private var issueSearch = ""
    @State private var prFilter: PullRequestFilter = .all
    @State private var prSort: PullRequestSort = .newest
    @State private var prSearch = ""
    @AppStorage("home.pinnedRepositories") private var pinnedRaw =
        "swiftui-lab,liquid-glass-kit,copilot-playground"

    private let changelogItems: [(time: String, title: String)] = [
        ("4 hours ago", "Enterprise Live Migrations from Azure DevOps generally available"),
        ("4 hours ago", "Red Hat Enterprise Linux runner images now generally available"),
        ("15 hours ago", "S3 audit log streaming with OpenID Connect expands to GHE.com"),
        ("yesterday", "Wait for pull request events with GitHub CLI")
    ]

    var onOpenInbox: () -> Void = {}
    var onOpenRepositories: () -> Void = {}
    var onOpenMenu: () -> Void = {}
    var onOpenSearch: () -> Void = {}
    var onOpenProfileMenu: () -> Void = {}
    var onOpenRepository: (RepoItem) -> Void = { _ in }
    var onOpenIssue: (IssueItem) -> Void = { _ in }
    var onOpenPullRequest: (PullRequestItem) -> Void = { _ in }
    var onOpenDiscussion: (DiscussionItem) -> Void = { _ in }
    var onOpenOrganisation: (OrganisationItem) -> Void = { _ in }
    var onOpenProject: (SectionEntry) -> Void = { _ in }

    var body: some View {
        VStack(spacing: 0) {
            GlassHeaderBar(
                title: "Home",
                onMenu: {
                    Haptics.tap()
                    onOpenMenu()
                },
                onSearch: {
                    Haptics.tap()
                    onOpenSearch()
                },
                onBell: {
                    Haptics.tap()
                    onOpenInbox()
                }
            )
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 14)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    profileHeader
                        .padding(.horizontal, 20)

                    brandCard
                        .padding(.horizontal, 20)

                    designSystemCard
                        .padding(.horizontal, 20)

                    profileReadmeCard
                        .padding(.horizontal, 20)

                    chipRow

                    sectionBody
                        .padding(.horizontal, 20)
                }
                .padding(.top, 4)
                .padding(.bottom, 132)
            }
        }
        .sheet(isPresented: $showShortcuts) {
            ShortcutsSheet { chosen in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    section = chosen
                }
            }
            .presentationDetents([.medium])
            .presentationCornerRadius(32)
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showCopilotApp) {
            CopilotAppSheet()
                .presentationDetents([.height(430)])
                .presentationCornerRadius(32)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showPinPicker) {
            PinnedRepositoriesSheet(pinnedNames: pinnedRepositories.map(\.name)) { names in
                pinnedRaw = names.joined(separator: ",")
            }
            .presentationDetents([.large])
            .presentationCornerRadius(32)
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: Pinned

    private var pinnedNames: [String] {
        pinnedRaw
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private var pinnedRepositories: [RepoItem] {
        let names = pinnedNames
        let all = store.repositories + store.exploreRepositories
        return names.compactMap { name in
            all.first(where: { $0.name == name })
        }
    }

    private var pinnedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Pinned")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    Haptics.tap()
                    showPinPicker = true
                } label: {
                    Text("Edit")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Palette.accentBright)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                ForEach(pinnedRepositories.prefix(3)) { repo in
                    pinnedCard(repo)
                }
            }
        }
    }

    private func pinnedCard(_ repo: RepoItem) -> some View {
        Button {
            Haptics.tap()
            onOpenRepository(repo)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "pin.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.accentBright)

                Text(repo.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .truncationMode(.middle)

                Spacer(minLength: 0)

                Text("\(repo.language) · ★ \(repo.stars)")
                    .font(.system(size: 12))
                    .foregroundStyle(Palette.inkFaint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 108, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(hex: 0x32288C).opacity(0.85))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.98))
    }

    // MARK: - Hero

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                Button {
                    Haptics.tap()
                    onOpenProfileMenu()
                } label: {
                    AvatarView(initials: store.profile.initials, size: 92)
                }
                .buttonStyle(PressableStyle(scale: 0.95))
                .accessibilityLabel("Open profile menu")

                VStack(alignment: .leading, spacing: 5) {
                    Text(store.profile.name)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Text("@\(store.profile.handle)")
                        .font(.system(size: 16))
                        .foregroundStyle(Palette.inkMuted)

                    Text(store.profile.bio)
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkFaint)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 2)

                    if let websiteURL = URL(string: store.profile.website) {
                        Link(destination: websiteURL) {
                            HStack(spacing: 6) {
                                Image(systemName: "link")
                                    .font(.system(size: 12, weight: .semibold))
                                Text(store.profile.website.replacingOccurrences(of: "https://", with: ""))
                                    .font(.system(size: 12, weight: .semibold))
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            .foregroundStyle(Palette.accentBright)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 0) {
                StatBlock(value: store.profile.repositories, label: "Repositories")
                statDivider
                StatBlock(value: store.profile.following, label: "Following")
                statDivider
                StatBlock(value: store.profile.followers, label: "Followers")
            }
        }
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.16))
            .frame(width: 1, height: 32)
            .padding(.horizontal, 12)
    }

    // MARK: - Brand

    private var brandCard: some View {
        HStack(spacing: 16) {
            HAFreelanceMark(size: 66)

            Text("Ha Freelance as Designer system")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(hex: 0x3B35AF))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: Color(hex: 0x140D4D).opacity(0.55), radius: 22, x: 0, y: 14)
    }

    private var designSystemCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "paintpalette")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Palette.iconBackground)
                Text("Design system")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                Spacer(minLength: 0)
            }

            designColorRow("Background", hex: "#3B35AF", color: Palette.canvas)
            designColorRow("Webpage background", hex: "#32288C", color: Palette.webpageBackground)
            designColorRow("Icons background", hex: "#9DACFB", color: Palette.iconBackground, symbol: "square.grid.2x2.fill")
        }
        .padding(16)
        .glassCard()
    }

    private func designColorRow(
        _ title: String,
        hex: String,
        color: Color,
        symbol: String? = nil
    ) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(color)
                .overlay {
                    if let symbol {
                        Image(systemName: symbol)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Palette.canvas)
                    }
                }
                .frame(width: 44, height: 44)

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Palette.ink)

            Spacer(minLength: 8)

            Text(hex)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(Palette.inkMuted)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.white.opacity(0.06)))
    }

    private var profileReadmeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "doc.text")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Palette.accentBright)
                Text("README.md")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                Spacer(minLength: 0)
            }

            MarkdownPreview(markdown: store.profileReadme)
        }
        .padding(14)
        .glassCard()
    }

    // MARK: - Chips

    private var chipRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(HomeSection.allCases) { item in
                    SectionChip(title: item.rawValue, isSelected: section == item) {
                        Haptics.select()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            section = item
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 2)
        }
    }

    // MARK: - Section bodies

    @ViewBuilder
    private var sectionBody: some View {
        switch section {
        case .home:
            VStack(spacing: 22) {
                if !pinnedRepositories.isEmpty {
                    pinnedSection
                }

                SectionHeading(title: "Home", subtitle: HomeSection.home.subtitle)
                activityCard
                changelogCard
                topRepositoriesCard
                copilotAppCard
                weeklyActivityCard
                contributionHeatmapCard
                shortcutsCard
            }
        case .repositories:
            sectionList(title: "Repositories", subtitle: HomeSection.repositories.subtitle) {
                repoStack(store.repositories)
            }
        case .starred:
            sectionList(title: "Starred", subtitle: HomeSection.starred.subtitle) {
                if store.starredRepositories.isEmpty {
                    emptyState(
                        symbol: "star",
                        message: "Star a repository to find it here in one tap."
                    )
                } else {
                    repoStack(store.starredRepositories)
                }
            }
        case .organisations:
            sectionList(title: "Organisations", subtitle: HomeSection.organisations.subtitle) {
                organisationStack
            }
        case .issues:
            sectionList(title: "Issues", subtitle: HomeSection.issues.subtitle) {
                IssueListControls(filter: $issueFilter, sort: $issueSort, searchText: $issueSearch)

                if filteredIssues.isEmpty {
                    listEmptyState(issuesEmptyMessage)
                } else {
                    issueStack
                }
            }
        case .pullRequests:
            sectionList(title: "Pull requests", subtitle: HomeSection.pullRequests.subtitle) {
                PullRequestListControls(filter: $prFilter, sort: $prSort, searchText: $prSearch)

                if filteredPullRequests.isEmpty {
                    listEmptyState(pullRequestsEmptyMessage)
                } else {
                    pullRequestStack
                }
            }
        case .discussions:
            sectionList(title: "Discussions", subtitle: HomeSection.discussions.subtitle) {
                discussionStack
            }
        case .projects:
            sectionList(title: "Projects", subtitle: HomeSection.projects.subtitle) {
                projectStack
            }
        }
    }

    private var activityCard: some View {
        let items = store.highlights

        return VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                ActivityRowView(
                    title: item.section.rawValue,
                    detail: item.detail,
                    systemImage: item.section.symbol
                ) {
                    Haptics.select()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        section = item.section
                    }
                }

                if index < items.count - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 1)
                        .padding(.leading, 74)
                }
            }
        }
        .padding(.vertical, 6)
        .glassCard()
    }

    private var changelogCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Palette.accentBright)

                Text("Latest from our changelog")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 0) {
                ForEach(Array(changelogItems.enumerated()), id: \.offset) { index, item in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.title)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(item.time)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Palette.inkFaint)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 11)

                    if index < changelogItems.count - 1 {
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 1)
                    }
                }
            }

            if let changelogURL = URL(string: "https://github.blog/changelog/") {
                Link(destination: changelogURL) {
                    HStack(spacing: 7) {
                        Text("View changelog")
                            .font(.system(size: 15, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(Palette.accentBright)
                }
                .buttonStyle(PressableStyle(scale: 0.98))
                .padding(.top, 2)
            }
        }
        .padding(16)
        .glassCard()
    }

    private var topRepositoriesCard: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Top Repositories")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    Haptics.select()
                    onOpenRepositories()
                } label: {
                    Text("See all")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Palette.accentBright)
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: 10) {
                ForEach(store.topRepositories) { repo in
                    RepoRowView(repo: repo) {
                        Haptics.tap()
                        onOpenRepository(repo)
                    }
                }
            }
        }
        .padding(16)
        .glassCard()
    }

    private var copilotAppCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Palette.accentBright, Palette.accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )

                Text("The GitHub Copilot app")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }

            Text("Ask, review and ship from your phone. Copilot keeps your repos in reach wherever you are.")
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                Haptics.tap()
                showCopilotApp = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Send me download link")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                )
            }
            .buttonStyle(PressableStyle())
            .padding(.top, 4)
        }
        .padding(16)
        .glassCard()
    }

    private var weeklyActivityCard: some View {
        let activity = store.weeklyActivity
        let labels = store.weekdayLabels
        let total = activity.reduce(0, +)
        let best = activity.max() ?? 0

        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("This week")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(total) contributions")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Palette.inkMuted)
            }

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(activity.enumerated()), id: \.offset) { index, count in
                    let isBest = count == best
                    let isSelected = selectedDay == index

                    Button {
                        Haptics.select()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            selectedDay = isSelected ? nil : index
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Capsule()
                                .fill(
                                    isBest
                                        ? LinearGradient(
                                            colors: [Palette.accentBright, Palette.accent],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        : LinearGradient(
                                            colors: [Color.white.opacity(0.35), Color.white.opacity(0.16)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                )
                                .frame(height: max(8, 56 * Double(count) / Double(max(best, 1))))
                                .frame(maxWidth: .infinity)

                            Text(labels[index])
                                .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                                .foregroundStyle(isSelected || isBest ? Color.white : Palette.inkFaint)
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: 84, alignment: .bottom)

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)

            HStack(spacing: 8) {
                Circle()
                    .fill(Palette.accentBright)
                    .frame(width: 8, height: 8)
                Text("Best day")
                    .font(.system(size: 12))
                    .foregroundStyle(Palette.inkFaint)

                Spacer()

                Text(selectedDay.map { "\(labels[$0]) · \(activity[$0]) contributions" } ?? "Tap a bar for that day")
                    .font(.system(size: 12))
                    .foregroundStyle(Palette.inkMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(16)
        .glassCard()
    }

    private var contributionHeatmapCard: some View {
        let counts = store.contributionHeatmap
        let total = counts.reduce(0, +)
        let longest = longestStreak(counts)

        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Contributions")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Text("Last 12 weeks")
                    .font(.system(size: 13))
                    .foregroundStyle(Palette.inkFaint)
            }

            HStack(alignment: .top, spacing: 4) {
                ForEach(0..<12, id: \.self) { week in
                    VStack(spacing: 4) {
                        ForEach(0..<7, id: \.self) { day in
                            let index = week * 7 + day
                            let count = counts[index]
                            let isSelected = selectedHeatCell?.week == week
                                && selectedHeatCell?.day == day

                            Button {
                                Haptics.select()
                                withAnimation(.easeOut(duration: 0.15)) {
                                    selectedHeatCell = isSelected
                                        ? nil
                                        : HeatCell(week: week, day: day, count: count, date: date(at: index))
                                }
                            } label: {
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .fill(tint(for: count))
                                    .frame(height: 14)
                                    .frame(maxWidth: .infinity)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                                            .strokeBorder(
                                                isSelected ? Color.white.opacity(0.9) : Color.clear,
                                                lineWidth: 1
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            HStack(spacing: 6) {
                Text("Less")
                    .font(.system(size: 11))
                    .foregroundStyle(Palette.inkFaint)

                ForEach(0...5, id: \.self) { level in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(tint(for: level))
                        .frame(width: 10, height: 10)
                }

                Text("More")
                    .font(.system(size: 11))
                    .foregroundStyle(Palette.inkFaint)

                Spacer()

                Text(
                    selectedHeatCell.map { "\($0.date) · \($0.count) contributions" }
                        ?? "\(total) contributions · \(longest)-day streak"
                )
                .font(.system(size: 11))
                .foregroundStyle(Palette.inkMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }
        }
        .padding(16)
        .glassCard()
    }

    private func tint(for count: Int) -> Color {
        switch count {
        case 0: return Color.white.opacity(0.06)
        case 1: return Palette.accent.opacity(0.25)
        case 2: return Palette.accent.opacity(0.45)
        case 3: return Palette.accent.opacity(0.65)
        case 4: return Palette.accentBright.opacity(0.85)
        default: return Palette.accentBright
        }
    }

    private func longestStreak(_ counts: [Int]) -> Int {
        var best = 0
        var current = 0
        for count in counts {
            if count > 0 {
                current += 1
                best = max(best, current)
            } else {
                current = 0
            }
        }
        return best
    }

    private func date(at index: Int) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let daysBack = (store.contributionHeatmap.count - 1) - index
        let date = calendar.date(byAdding: .day, value: -daysBack, to: today) ?? today
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private var shortcutsCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Shortcuts")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            Text("The things you need, one tap away. Fast access to your lists of Issues, Pull Requests, or Discussions.")
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            GradientActionButton(title: "Get started") {
                Haptics.tap()
                showShortcuts = true
            }
            .padding(.top, 10)
        }
        .padding(16)
        .glassCard()
    }

    // MARK: - Helpers

    private func sectionList<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 16) {
            SectionHeading(title: title, subtitle: subtitle)

            VStack(spacing: 10) {
                content()
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard()
        }
    }

    @ViewBuilder
    private func repoStack(_ repos: [RepoItem]) -> some View {
        ForEach(repos) { repo in
            RepoRowView(repo: repo) {
                Haptics.tap()
                onOpenRepository(repo)
            }
        }
    }

    @ViewBuilder
    private var organisationStack: some View {
        ForEach(Array(store.organisations.enumerated()), id: \.element.id) { index, organisation in
            EntryRowView(entry: organisation.listEntry) {
                Haptics.tap()
                onOpenOrganisation(organisation)
            }

            if index < store.organisations.count - 1 {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.leading, 60)
            }
        }
    }

    private var trimmedIssueSearch: String {
        issueSearch.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedPullRequestSearch: String {
        prSearch.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var issuesEmptyMessage: String {
        let query = trimmedIssueSearch
        if trimmedIssueSearch.isEmpty {
            return "No issues match this filter."
        }
        return "No issues match \"\(query)\" with the \(issueFilter.title) filter."
    }

    private var pullRequestsEmptyMessage: String {
        let query = trimmedPullRequestSearch
        if trimmedPullRequestSearch.isEmpty {
            return "No pull requests match this filter."
        }
        return "No pull requests match \"\(query)\" with the \(prFilter.title) filter."
    }

    private var filteredIssues: [IssueItem] {
        let query = trimmedIssueSearch
        let matching = store.issues.filter { issue in
            guard issue.matches(issueFilter) else { return false }
            guard !query.isEmpty else { return true }
            return issue.title.localizedCaseInsensitiveContains(query)
                || issue.author.localizedCaseInsensitiveContains(query)
                || issue.body.localizedCaseInsensitiveContains(query)
        }
        switch issueSort {
        case .newest:
            return matching.sorted { $0.number > $1.number }
        case .oldest:
            return matching.sorted { $0.number < $1.number }
        case .mostComments:
            return matching.sorted { $0.comments.count > $1.comments.count }
        }
    }

    private var filteredPullRequests: [PullRequestItem] {
        let query = trimmedPullRequestSearch
        let matching = store.pullRequests.filter { request in
            guard request.matches(prFilter) else { return false }
            guard !query.isEmpty else { return true }
            return request.title.localizedCaseInsensitiveContains(query)
                || request.author.localizedCaseInsensitiveContains(query)
                || request.body.localizedCaseInsensitiveContains(query)
        }
        switch prSort {
        case .newest:
            return matching.sorted { $0.number > $1.number }
        case .oldest:
            return matching.sorted { $0.number < $1.number }
        }
    }

    private func listEmptyState(_ message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(Palette.inkFaint)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
    }

    @ViewBuilder
    private var issueStack: some View {
        ForEach(Array(filteredIssues.enumerated()), id: \.element.id) { index, issue in
            EntryRowView(entry: issue.listEntry) {
                Haptics.tap()
                onOpenIssue(issue)
            }

            if index < filteredIssues.count - 1 {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.leading, 60)
            }
        }
    }

    @ViewBuilder
    private var discussionStack: some View {
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

    @ViewBuilder
    private var pullRequestStack: some View {
        ForEach(Array(filteredPullRequests.enumerated()), id: \.element.id) { index, request in
            EntryRowView(entry: request.listEntry) {
                Haptics.tap()
                onOpenPullRequest(request)
            }

            if index < filteredPullRequests.count - 1 {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.leading, 60)
            }
        }
    }

    @ViewBuilder
    private var projectStack: some View {
        ForEach(Array(store.projects.enumerated()), id: \.element.id) { index, project in
            EntryRowView(entry: project) {
                Haptics.tap()
                onOpenProject(project)
            }

            if index < store.projects.count - 1 {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.leading, 60)
            }
        }
    }

    private func emptyState(symbol: String, message: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(Palette.inkFaint)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }
}

// MARK: - Shortcuts sheet

struct ShortcutsSheet: View {
    var onSelect: (HomeSection) -> Void

    @Environment(\.dismiss) private var dismiss

    private let items: [HomeSection] = [.issues, .pullRequests, .discussions, .projects, .repositories, .starred]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Shortcuts")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.white.opacity(0.12)))
                }
                .buttonStyle(PressableStyle(scale: 0.9))
            }

            Text("The things you need, one tap away.")
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(items) { item in
                        Button {
                            Haptics.select()
                            onSelect(item)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: item.symbol)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(.white)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color.white.opacity(0.08))
                                    )

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.rawValue)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.white)
                                    Text(item.subtitle)
                                        .font(.system(size: 13))
                                        .foregroundStyle(Palette.inkFaint)
                                        .lineLimit(1)
                                }

                                Spacer(minLength: 6)

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Palette.inkFaint)
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.white.opacity(0.07))
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PressableStyle(scale: 0.98))
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppBackdrop())
        .preferredColorScheme(.dark)
    }
}

struct HeatCell: Equatable {
    var week: Int
    var day: Int
    var count: Int
    var date: String
}

#Preview {
    HomeView()
        .environmentObject(AppStore())
        .preferredColorScheme(.dark)
}
