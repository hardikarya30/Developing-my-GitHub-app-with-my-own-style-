//
//  FollowingFeedView.swift
//  GitHub 3D
//
//  Activity from the repositories you starred and the people you follow.
//

import SwiftUI

struct FollowingEntry: Identifiable {
    enum Kind {
        case repository(RepoItem)
        case person(PersonItem)
    }

    var id = UUID()
    var name: String
    var initials: String
    var summary: String
    var time: String
    var isLatest: Bool
    var kind: Kind
}

struct FollowingFeedView: View {
    @EnvironmentObject private var store: AppStore

    var onOpenRepository: (RepoItem) -> Void = { _ in }
    var onOpenPerson: (PersonItem) -> Void = { _ in }

    private var entries: [FollowingEntry] {
        var result: [FollowingEntry] = []

        let people = store.people.filter { $0.isFollowing }
        for (index, person) in people.enumerated() {
            let repo = store.repositories[index % max(store.repositories.count, 1)]
            result.append(
                FollowingEntry(
                    name: person.name,
                    initials: person.initials,
                    summary: "starred \(repo.name) — \(repo.blurb)",
                    time: ["2h ago", "5h ago", "8h ago"][index % 3],
                    isLatest: true,
                    kind: .person(person)
                )
            )
        }

        let starred = store.starredRepositories
        for (index, repo) in starred.enumerated() {
            result.append(
                FollowingEntry(
                    name: "You",
                    initials: "HA",
                    summary: "starred \(repo.name) — \(repo.blurb)",
                    time: index == 0 ? "1d ago" : "2d ago",
                    isLatest: false,
                    kind: .repository(repo)
                )
            )
        }

        return result
    }

    private var latest: [FollowingEntry] {
        entries.filter(\.isLatest)
    }

    private var earlier: [FollowingEntry] {
        entries.filter { !$0.isLatest }
    }

    var body: some View {
        if entries.isEmpty {
            emptyState
        } else {
            VStack(alignment: .leading, spacing: 18) {
                if !latest.isEmpty {
                    section(title: "Latest", items: latest)
                }
                if !earlier.isEmpty {
                    section(title: "Earlier", items: earlier)
                }
            }
        }
    }

    private func section(title: String, items: [FollowingEntry]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)

            VStack(spacing: 10) {
                ForEach(items) { entry in
                    card(entry)
                }
            }
        }
    }

    private func card(_ entry: FollowingEntry) -> some View {
        Button {
            Haptics.tap()
            switch entry.kind {
            case .repository(let repo):
                onOpenRepository(repo)
            case .person(let person):
                onOpenPerson(person)
            }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                AvatarView(initials: entry.initials, size: 58)

                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)

                    Text(entry.summary)
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 6)

                VStack(alignment: .trailing, spacing: 6) {
                    Text(entry.time)
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.inkFaint)
                        .lineLimit(1)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Palette.inkFaint)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(hex: 0x32288C).opacity(0.85))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "rss")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .frame(width: 76, height: 76)
                .background(Circle().fill(Color.white.opacity(0.08)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

            Text("Nothing here yet")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            Text("Star a repository or follow a person and their activity will show up here.")
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .glassCard()
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        FollowingFeedView()
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
