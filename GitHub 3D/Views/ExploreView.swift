//
//  ExploreView.swift
//  GitHub 3D
//
//  Discovery: search, topics, trending repositories and people to follow.
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var store: AppStore

    var onOpenMenu: () -> Void = {}
    var onOpenRepository: (RepoItem) -> Void = { _ in }
    var onOpenPerson: (PersonItem) -> Void = { _ in }
    var onOpenTopic: (String) -> Void = { _ in }

    @State private var query = ""
    @State private var topic: String? = "Liquid glass"
    @State private var language: String?
    @State private var showFollowing = false

    private let topics = ["Swift", "SwiftUI", "Liquid glass", "Design systems", "AI"]
    private let languages = ["All", "Swift", "TypeScript", "JavaScript", "Shell"]

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var repositories: [RepoItem] {
        store.exploreRepositories.filter { repo in
            let matchesTopic = topic.map { repo.topics.contains($0) } ?? true
            guard matchesTopic else { return false }

            let matchesLanguage = language.map { repo.language == $0 } ?? true
            guard matchesLanguage else { return false }

            guard !trimmedQuery.isEmpty else { return true }
            return repo.name.localizedCaseInsensitiveContains(trimmedQuery)
                || repo.blurb.localizedCaseInsensitiveContains(trimmedQuery)
                || repo.topics.contains(where: { $0.localizedCaseInsensitiveContains(trimmedQuery) })
        }
    }

    private var people: [PersonItem] {
        store.people.filter { person in
            let matchesTopic = topic.map { person.topics.contains($0) } ?? true
            guard matchesTopic else { return false }
            guard !trimmedQuery.isEmpty else { return true }
            return person.name.localizedCaseInsensitiveContains(trimmedQuery)
                || person.handle.localizedCaseInsensitiveContains(trimmedQuery)
                || person.bio.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    private var hasNoResults: Bool {
        repositories.isEmpty && people.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    if !showFollowing {
                        searchField
                    }
                    topicRow

                    if !showFollowing {
                        languageRow
                    }

                    if showFollowing {
                        FollowingFeedView(
                            onOpenRepository: onOpenRepository,
                            onOpenPerson: onOpenPerson
                        )
                    } else if hasNoResults {
                        emptyState
                    } else {
                        if !repositories.isEmpty {
                            trendingSection
                        }
                        if !people.isEmpty {
                            peopleSection
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
            }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            circleButton(symbol: "line.3.horizontal") {
                Haptics.tap()
                onOpenMenu()
            }

            Spacer()

            Text("Explore")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            circleButton(symbol: "line.3.horizontal.decrease") {
                Haptics.tap()
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

    // MARK: Search

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Palette.inkMuted)

            TextField("Search repositories, topics and people", text: $query)
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .tint(Palette.accentBright)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !query.isEmpty {
                Button {
                    Haptics.select()
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Palette.inkFaint)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 27, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 27, style: .continuous)
                .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
        )
    }

    private var topicRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                SectionChip(title: "Following", isSelected: showFollowing) {
                    Haptics.select()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        showFollowing.toggle()
                    }
                }

                ForEach(topics, id: \.self) { item in
                    SectionChip(title: item, isSelected: !showFollowing && topic == item) {
                        Haptics.select()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            showFollowing = false
                            topic = topic == item ? nil : item
                        }
                        onOpenTopic(item)
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: Languages

    private var languageRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(languages, id: \.self) { item in
                    languageChip(item, isSelected: language == (item == "All" ? nil : item))
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func languageChip(_ title: String, isSelected: Bool) -> some View {
        Button {
            Haptics.select()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                language = title == "All" ? nil : title
            }
        } label: {
            Text(title)
                .font(.system(size: 13.5, weight: .semibold))
                .foregroundStyle(isSelected ? Color.white : Palette.inkMuted)
                .padding(.horizontal, 14)
                .frame(height: 36)
                .background {
                    if isSelected {
                        Capsule().fill(Palette.accentBright.opacity(0.85))
                    } else {
                        Capsule().fill(Color.white.opacity(0.08))
                    }
                }
                .overlay(
                    Capsule().strokeBorder(
                        isSelected ? Palette.accentBright : Color.white.opacity(0.14),
                        lineWidth: 1
                    )
                )
        }
        .buttonStyle(PressableStyle(scale: 0.95))
    }

    // MARK: Trending

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Trending repositories")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Text("See all")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Palette.accentBright)
            }

            VStack(spacing: 10) {
                ForEach(repositories) { repo in
                    repositoryCard(repo)
                }
            }
        }
    }

    private func repositoryCard(_ repo: RepoItem) -> some View {
        let isStarred = store.isStarred(repo.name)

        return HStack(spacing: 12) {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.16), .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(repo.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(repo.blurb)
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.inkMuted)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 4) {
                    Text(repo.language)
                    Text("·")
                    Image(systemName: "star")
                        .font(.system(size: 10, weight: .medium))
                    Text("\(repo.stars)")
                    Text("·")
                    Text("Updated \(repo.updated)")
                }
                .font(.system(size: 12.5))
                .foregroundStyle(Palette.inkFaint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 4)

            Button {
                Haptics.select()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    store.toggleStar(named: repo.name)
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: isStarred ? "star.fill" : "star")
                        .font(.system(size: 13, weight: .semibold))
                    Text(isStarred ? "Starred" : "Star")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .frame(height: 38)
                .background {
                    if isStarred {
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
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.18), lineWidth: 1))
            }
            .buttonStyle(PressableStyle(scale: 0.95))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(hex: 0x32288C).opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            Haptics.tap()
            onOpenRepository(repo)
        }
    }

    // MARK: People

    private var peopleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("People to follow")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Text("See all")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Palette.accentBright)
            }

            VStack(spacing: 10) {
                ForEach(people) { person in
                    personCard(person)
                }
            }
        }
    }

    private func personCard(_ person: PersonItem) -> some View {
        HStack(spacing: 14) {
            AvatarView(initials: person.initials, size: 58)

            VStack(alignment: .leading, spacing: 2) {
                Text(person.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                Text(person.handle)
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.inkFaint)
                Text(person.bio)
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }

            Spacer(minLength: 6)

            Button {
                Haptics.select()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    store.togglePersonFollow(person.id)
                }
            } label: {
                Text(person.isFollowing ? "Following" : "Follow")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(person.isFollowing ? Palette.inkMuted : Color.white)
                    .padding(.horizontal, 16)
                    .frame(height: 38)
                    .background {
                        if person.isFollowing {
                            Capsule().fill(Color.white.opacity(0.10))
                        } else {
                            Capsule().fill(Color.white.opacity(0.14))
                        }
                    }
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.20), lineWidth: 1))
            }
            .buttonStyle(PressableStyle(scale: 0.95))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(hex: 0x32288C).opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            Haptics.tap()
            onOpenPerson(person)
        }
    }

    // MARK: Empty

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .frame(width: 72, height: 72)
                .background(Circle().fill(Color.white.opacity(0.08)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

            Text(emptyTitle)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(emptySubtitle)
                .font(.system(size: 14))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .glassCard()
    }

    private var emptyTitle: String {
        if let language {
            return trimmedQuery.isEmpty
                ? "No \(language) repositories here"
                : "No \(language) repositories for \"\(trimmedQuery)\""
        }

        return "No results for \"\(trimmedQuery.isEmpty ? (topic ?? "") : trimmedQuery)\""
    }

    private var emptySubtitle: String {
        if language != nil {
            return "Try another language, search or topic."
        }
        return "Try a different search or pick another topic."
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        ExploreView()
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
