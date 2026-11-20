//
//  SearchView.swift
//  GitHub 3D
//
//  One search across repositories, issues, pull requests, discussions and people.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var store: AppStore

    var onBack: () -> Void = {}
    var onOpenRepository: (RepoItem) -> Void = { _ in }
    var onOpenIssue: (IssueItem) -> Void = { _ in }
    var onOpenPullRequest: (PullRequestItem) -> Void = { _ in }
    var onOpenDiscussion: (DiscussionItem) -> Void = { _ in }
    var onOpenPerson: (PersonItem) -> Void = { _ in }

    @State private var query = ""
    @State private var showSaveSheet = false

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var allRepositories: [RepoItem] {
        var seen = Set<String>()
        var result: [RepoItem] = []
        for repo in store.repositories + store.exploreRepositories where !seen.contains(repo.name) {
            seen.insert(repo.name)
            result.append(repo)
        }
        return result
    }

    private var repositoryResults: [RepoItem] {
        guard !trimmedQuery.isEmpty else { return [] }
        return allRepositories.filter {
            $0.name.localizedCaseInsensitiveContains(trimmedQuery)
                || $0.blurb.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    private var issueResults: [IssueItem] {
        guard !trimmedQuery.isEmpty else { return [] }
        return store.issues.filter {
            $0.title.localizedCaseInsensitiveContains(trimmedQuery)
                || $0.body.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    private var pullRequestResults: [PullRequestItem] {
        guard !trimmedQuery.isEmpty else { return [] }
        return store.pullRequests.filter {
            $0.title.localizedCaseInsensitiveContains(trimmedQuery)
                || $0.body.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    private var discussionResults: [DiscussionItem] {
        guard !trimmedQuery.isEmpty else { return [] }
        return store.discussions.filter {
            $0.title.localizedCaseInsensitiveContains(trimmedQuery)
                || $0.body.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    private var peopleResults: [PersonItem] {
        guard !trimmedQuery.isEmpty else { return [] }
        return store.people.filter {
            $0.name.localizedCaseInsensitiveContains(trimmedQuery)
                || $0.handle.localizedCaseInsensitiveContains(trimmedQuery)
                || $0.bio.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    private var hasResults: Bool {
        !repositoryResults.isEmpty || !issueResults.isEmpty || !pullRequestResults.isEmpty
            || !discussionResults.isEmpty || !peopleResults.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        searchField

                        if !store.savedSearches.isEmpty {
                            savedSearchChips
                        }
                    }

                    if trimmedQuery.isEmpty {
                        idleState
                    } else if !hasResults {
                        emptyState
                    } else {
                        if !repositoryResults.isEmpty {
                            repositoriesSection
                        }
                        if !issueResults.isEmpty {
                            issuesSection
                        }
                        if !pullRequestResults.isEmpty {
                            pullRequestsSection
                        }
                        if !discussionResults.isEmpty {
                            discussionsSection
                        }
                        if !peopleResults.isEmpty {
                            peopleSection
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
            }
        }
        .sheet(isPresented: $showSaveSheet) {
            SaveSearchSheet(query: trimmedQuery)
                .presentationDetents([.height(360)])
                .presentationCornerRadius(32)
                .presentationDragIndicator(.visible)
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

            Text("Search")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                Haptics.tap()
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Circle().fill(Color.white.opacity(0.10)))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.20), lineWidth: 1))
            }
            .buttonStyle(PressableStyle(scale: 0.9))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .glassCard(fill: Color.white.opacity(0.10), radius: 28)
    }

    // MARK: Field

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Palette.inkMuted)

            TextField("Search everything", text: $query)
                .font(.system(size: 17))
                .foregroundStyle(.white)
                .tint(Palette.accentBright)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !trimmedQuery.isEmpty {
                Button {
                    Haptics.select()
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(Palette.inkFaint)
                }
                .buttonStyle(.plain)

                Button {
                    openSaveSheet()
                } label: {
                    Image(systemName: "bookmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Palette.accentBright)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
        )
        .onLongPressGesture(minimumDuration: 0.45) {
            guard !trimmedQuery.isEmpty else { return }
            openSaveSheet()
        }
    }

    // MARK: Saved searches

    private var savedSearchChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(store.savedSearches) { saved in
                    Button {
                        Haptics.select()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            query = saved.query
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bookmark.fill")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Palette.accentBright)
                            Text(saved.name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 36)
                        .background(Capsule().fill(Color.white.opacity(0.10)))
                        .overlay(Capsule().strokeBorder(Color.white.opacity(0.16), lineWidth: 1))
                    }
                    .buttonStyle(PressableStyle(scale: 0.96))
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func openSaveSheet() {
        Haptics.tap()
        showSaveSheet = true
    }

    // MARK: Sections

    private var repositoriesSection: some View {
        resultSection(title: "Repositories", count: repositoryResults.count) {
            VStack(spacing: 0) {
                ForEach(Array(repositoryResults.enumerated()), id: \.element.id) { index, repo in
                    resultRow(
                        symbol: "chevron.left.forwardslash.chevron.right",
                        initials: nil,
                        title: repo.name,
                        subtitle: repo.blurb
                    ) {
                        Haptics.tap()
                        onOpenRepository(repo)
                    }
                    rowDivider(index: index, count: repositoryResults.count)
                }
            }
            .glassCard()
        }
    }

    private var issuesSection: some View {
        resultSection(title: "Issues", count: issueResults.count) {
            VStack(spacing: 0) {
                ForEach(Array(issueResults.enumerated()), id: \.element.id) { index, issue in
                    resultRow(
                        symbol: "exclamationmark.circle",
                        initials: nil,
                        title: "#\(issue.number) \(issue.title)",
                        subtitle: "Opened \(issue.time) · by \(issue.author)"
                    ) {
                        Haptics.tap()
                        onOpenIssue(issue)
                    }
                    rowDivider(index: index, count: issueResults.count)
                }
            }
            .glassCard()
        }
    }

    private var pullRequestsSection: some View {
        resultSection(title: "Pull requests", count: pullRequestResults.count) {
            VStack(spacing: 0) {
                ForEach(Array(pullRequestResults.enumerated()), id: \.element.id) { index, request in
                    resultRow(
                        symbol: "arrow.triangle.pull",
                        initials: nil,
                        title: "#\(request.number) \(request.title)",
                        subtitle: "\(request.isOpen ? "Open" : "Merged") · \(request.author)"
                    ) {
                        Haptics.tap()
                        onOpenPullRequest(request)
                    }
                    rowDivider(index: index, count: pullRequestResults.count)
                }
            }
            .glassCard()
        }
    }

    private var discussionsSection: some View {
        resultSection(title: "Discussions", count: discussionResults.count) {
            VStack(spacing: 0) {
                ForEach(Array(discussionResults.enumerated()), id: \.element.id) { index, discussion in
                    resultRow(
                        symbol: "bubble.left",
                        initials: nil,
                        title: discussion.title,
                        subtitle: "\(discussion.replies.count) replies · \(discussion.time)"
                    ) {
                        Haptics.tap()
                        onOpenDiscussion(discussion)
                    }
                    rowDivider(index: index, count: discussionResults.count)
                }
            }
            .glassCard()
        }
    }

    private var peopleSection: some View {
        resultSection(title: "People", count: peopleResults.count) {
            VStack(spacing: 0) {
                ForEach(Array(peopleResults.enumerated()), id: \.element.id) { index, person in
                    resultRow(
                        symbol: nil,
                        initials: person.initials,
                        title: person.name,
                        subtitle: person.handle
                    ) {
                        Haptics.tap()
                        onOpenPerson(person)
                    }
                    rowDivider(index: index, count: peopleResults.count)
                }
            }
            .glassCard()
        }
    }

    private func resultSection<Content: View>(
        title: String,
        count: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                Text("· \(count)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Palette.accentBright)
            }

            content()
        }
    }

    private func resultRow(
        symbol: String?,
        initials: String?,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let initials {
                    AvatarView(initials: initials, size: 46)
                } else if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 16, weight: .medium))
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
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkMuted)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 6)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
    }

    @ViewBuilder
    private func rowDivider(index: Int, count: Int) -> some View {
        if index < count - 1 {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
                .padding(.leading, 72)
        }
    }

    // MARK: States

    private var idleState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .frame(width: 72, height: 72)
                .background(Circle().fill(Color.white.opacity(0.08)))

            Text("Search everything")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(.white)

            Text("Repositories, issues, pull requests, discussions and people.")
                .font(.system(size: 14))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .frame(width: 72, height: 72)
                .background(Circle().fill(Color.white.opacity(0.08)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

            Text("No results for \"\(trimmedQuery)\"")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Try a different word, or search for a repository, issue or person.")
                .font(.system(size: 14))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .glassCard()
    }
}

struct SaveSearchSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var query: String

    @State private var name = ""

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Save search")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)

                    Text("\"\(query)\"")
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

            VStack(alignment: .leading, spacing: 6) {
                Text("NAME")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.3)
                    .foregroundStyle(Palette.inkFaint)

                TextField("Name this search", text: $name)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .tint(Palette.accentBright)
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal, 14)
                    .frame(height: 50)
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
                Haptics.tap()
                store.addSavedSearch(name: trimmedName, query: query)
                dismiss()
            } label: {
                Text("Save search")
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
            .disabled(trimmedName.isEmpty)
            .opacity(trimmedName.isEmpty ? 0.5 : 1)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppBackdrop())
        .preferredColorScheme(.dark)
        .onAppear {
            if name.isEmpty { name = query }
        }
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        SearchView()
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
