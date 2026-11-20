//
//  PersonProfileView.swift
//  GitHub 3D
//
//  Another developer's profile: identity, follow, repositories and activity.
//

import SwiftUI

struct PersonProfileView: View {
    @EnvironmentObject private var store: AppStore

    var personID: UUID
    var onBack: () -> Void = {}

    private var person: PersonItem? {
        store.people.first(where: { $0.id == personID })
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            if let person {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        hero(person)
                        repositoriesSection(person)
                        activitySection(person)
                        contributionGraphCard(person)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 130)
                }
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

            Text(person?.handle ?? "Profile")
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

    private func hero(_ person: PersonItem) -> some View {
        VStack(spacing: 8) {
            AvatarView(initials: person.initials, size: 108)
                .padding(.top, 6)

            Text(person.name)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)

            Text(person.handle)
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)

            Text(person.bio)
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 0) {
                counter(person.repositories, "Repositories")
                divider
                counter(person.followers, "Followers")
                divider
                counter(person.following, "Following")
            }
            .padding(.top, 8)

            Button {
                Haptics.select()
                withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                    store.togglePersonFollow(person.id)
                }
            } label: {
                Text(person.isFollowing ? "Following" : "Follow")
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
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
    }

    private func counter(_ value: Int, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(Palette.inkFaint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.14))
            .frame(width: 1, height: 34)
    }

    // MARK: Repositories

    private func repositoriesSection(_ person: PersonItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("Repositories")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                Text("· \(person.repos.count)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Palette.accentBright)
                Spacer()
                Text("See all")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Palette.accentBright)
            }

            VStack(spacing: 0) {
                ForEach(Array(person.repos.enumerated()), id: \.element.id) { index, repo in
                    HStack(spacing: 12) {
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

                        VStack(alignment: .leading, spacing: 2) {
                            Text(repo.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Text(repo.blurb)
                                .font(.system(size: 14))
                                .foregroundStyle(Palette.inkMuted)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 6)

                        HStack(spacing: 5) {
                            Image(systemName: "star")
                                .font(.system(size: 13, weight: .medium))
                            Text("\(repo.stars)")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundStyle(Palette.inkMuted)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Palette.inkFaint)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)

                    if index < person.repos.count - 1 {
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 1)
                            .padding(.leading, 72)
                    }
                }
            }
            .glassCard()
        }
    }

    // MARK: Activity

    private func activitySection(_ person: PersonItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent activity")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)

            VStack(spacing: 0) {
                ForEach(Array(person.activity.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 12) {
                        Image(systemName: item.symbol)
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

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Text(item.subtitle)
                                .font(.system(size: 14))
                                .foregroundStyle(Palette.inkMuted)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 6)

                        Text(item.time)
                            .font(.system(size: 13))
                            .foregroundStyle(Palette.inkFaint)
                            .lineLimit(1)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Palette.inkFaint)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)

                    if index < person.activity.count - 1 {
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 1)
                            .padding(.leading, 72)
                    }
                }
            }
            .glassCard()
        }
    }

    // MARK: Contributions

    private func contributionGraphCard(_ person: PersonItem) -> some View {
        let counts = contributions(for: person)
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
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(tint(for: counts[index]))
                                .frame(height: 14)
                                .frame(maxWidth: .infinity)
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

                Text("\(total) contributions · \(longest)-day streak")
                    .font(.system(size: 11))
                    .foregroundStyle(Palette.inkMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(16)
        .glassCard()
    }

    private func contributions(for person: PersonItem) -> [Int] {
        let seedText = person.name.unicodeScalars.reduce(0) { $0 &+ Int($1.value) } + person.followers
        var state = UInt64(seedText % 9973 + 1)
        var values: [Int] = []

        for index in 0..<84 {
            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            let roll = Int((state >> 33) % 100)
            let isWeekend = (index % 7) >= 5

            let count: Int
            if roll < (isWeekend ? 55 : 22) {
                count = 0
            } else if roll < (isWeekend ? 82 : 52) {
                count = 1
            } else if roll < 94 {
                count = 2 + roll % 3
            } else {
                count = 5 + roll % 3
            }

            values.append(count)
        }

        return values
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
}

#Preview {
    ZStack {
        AppBackdrop()
        PersonProfileView(personID: AppStore.samplePeople[2].id)
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
