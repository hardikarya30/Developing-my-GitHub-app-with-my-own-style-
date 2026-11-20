//
//  TopicView.swift
//  GitHub 3D
//
//  A topic hub: description, follow, its repositories and people.
//

import SwiftUI

struct TopicView: View {
    @EnvironmentObject private var store: AppStore

    var topic: String
    var onBack: () -> Void = {}
    var onOpenRepository: (RepoItem) -> Void = { _ in }
    var onOpenPerson: (PersonItem) -> Void = { _ in }

    private var repositories: [RepoItem] {
        var seen = Set<String>()
        var result: [RepoItem] = []
        let all = store.exploreRepositories + store.repositories
        for repo in all where repo.topics.contains(topic) && !seen.contains(repo.name) {
            seen.insert(repo.name)
            result.append(repo)
        }
        return result
    }

    private var people: [PersonItem] {
        store.people.filter { $0.topics.contains(topic) }
    }

    private var isFollowing: Bool {
        store.isFollowingTopic(topic)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    hero
                    repositoriesSection
                    peopleSection
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

            Text("#\(topic.lowercased().replacingOccurrences(of: " ", with: "-"))")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer()

            Button {
                Haptics.tap()
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 17, weight: .semibold))
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

    // MARK: Hero

    private var hero: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Palette.accentBright.opacity(0.5), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 90
                        )
                    )
                    .frame(width: 170, height: 170)

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Palette.accentBright, Palette.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 84, height: 84)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: Palette.accentBright.opacity(0.55), radius: 20, x: 0, y: 10)

                Image(systemName: "number")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(height: 132)

            Text(topic)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)

            Text(AppStore.topicDescription(for: topic))
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)

            HStack(spacing: 0) {
                counter("\(max(repositories.count, 3))", "repositories")
                Rectangle()
                    .fill(Color.white.opacity(0.14))
                    .frame(width: 1, height: 34)
                counter(AppStore.topicFollowerCount(for: topic), "followers")
            }
            .padding(.top, 6)

            Button {
                Haptics.select()
                withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                    store.toggleTopicFollow(topic)
                }
            } label: {
                Text(isFollowing ? "Following" : "Follow topic")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
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
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .glassCard()
    }

    private func counter(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(Palette.inkFaint)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Repositories

    private var repositoriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Top repositories")
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
                        .fill(Color.white.opacity(0.10))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(repo.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(repo.blurb)
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.inkMuted)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 5) {
                    Circle()
                        .fill(Palette.accentBright)
                        .frame(width: 7, height: 7)
                    Text(repo.language)
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.inkFaint)
                }
                .padding(.top, 1)
            }

            Spacer(minLength: 4)

            HStack(spacing: 5) {
                Image(systemName: "star")
                    .font(.system(size: 13, weight: .medium))
                Text("\(repo.stars)")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(Palette.inkMuted)

            Button {
                Haptics.select()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    store.toggleStar(named: repo.name)
                }
            } label: {
                Text(isStarred ? "Starred" : "Star")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 34)
                    .background(Capsule().fill(Palette.accentBright.opacity(0.85)))
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

    @ViewBuilder
    private var peopleSection: some View {
        if !people.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("People in this topic")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("See all")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Palette.accentBright)
                }

                VStack(spacing: 0) {
                    ForEach(Array(people.enumerated()), id: \.element.id) { index, person in
                        HStack(spacing: 12) {
                            AvatarView(initials: person.initials, size: 50)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(person.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text(person.handle)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Palette.inkFaint)
                                Text(person.bio)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Palette.inkMuted)
                                    .lineLimit(1)
                            }

                            Spacer(minLength: 6)

                            Button {
                                Haptics.select()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    store.togglePersonFollow(person.id)
                                }
                            } label: {
                                Text(person.isFollowing ? "Following" : "Follow")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(person.isFollowing ? Palette.inkMuted : Color.white)
                                    .padding(.horizontal, 14)
                                    .frame(height: 34)
                                    .background(Capsule().fill(Color.white.opacity(0.12)))
                                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.18), lineWidth: 1))
                            }
                            .buttonStyle(PressableStyle(scale: 0.95))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Haptics.tap()
                            onOpenPerson(person)
                        }

                        if index < people.count - 1 {
                            Rectangle()
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 1)
                                .padding(.leading, 76)
                        }
                    }
                }
                .glassCard()
            }
        }
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        TopicView(topic: "Liquid glass")
    }
    .environmentObject(AppStore())
}
