//
//  RepositoryInsightsView.swift
//  GitHub 3D
//
//  Commit, contributor and language insights for a repository.
//

import SwiftUI

struct InsightContributor: Identifiable {
    var id = UUID()
    var name: String
    var handle: String
    var initials: String
    var commits: Int
}

struct InsightLanguage: Identifiable {
    var name: String
    var share: Double
    var color: Color

    var id: String { name }
}

struct RepositoryInsightsView: View {
    @EnvironmentObject private var store: AppStore

    var repo: RepoItem
    var onBack: () -> Void = {}

    private let weeklyCommits: [(letter: String, value: Double)] = [
        ("S", 0.38), ("M", 0.42), ("T", 0.92), ("W", 0.35),
        ("T", 0.55), ("F", 0.33), ("S", 0.68),
        ("S", 0.48), ("M", 0.85), ("T", 0.42), ("W", 0.50), ("T", 0.80)
    ]

    private var liveRepo: RepoItem {
        store.repositories.first(where: { $0.name == repo.name })
            ?? store.exploreRepositories.first(where: { $0.name == repo.name })
            ?? repo
    }

    private var totalCommits: Int {
        max(1, liveRepo.stars * 7)
    }

    private var contributorCount: Int {
        max(4, store.people.count + 8)
    }

    private var contributors: [InsightContributor] {
        let base = Double(liveRepo.stars)
        var result: [InsightContributor] = [
            InsightContributor(
                name: store.profile.name,
                handle: "@\(store.profile.handle)",
                initials: store.profile.initials,
                commits: Int((base * 2.2).rounded())
            )
        ]

        let factors: [Double] = [1.55, 0.89, 0.53]
        for (index, person) in store.people.prefix(3).enumerated() {
            let factor = index < factors.count ? factors[index] : 0.4
            result.append(
                InsightContributor(
                    name: person.name,
                    handle: person.handle,
                    initials: person.initials,
                    commits: max(12, Int((base * factor).rounded()))
                )
            )
        }

        return result
    }

    private var topCommits: Int {
        contributors.map(\.commits).max() ?? 1
    }

    private var languages: [InsightLanguage] {
        [
            InsightLanguage(name: liveRepo.language, share: 0.82, color: Palette.accentBright),
            InsightLanguage(name: "TypeScript", share: 0.12, color: Color(hex: 0x3E9BFF)),
            InsightLanguage(name: "Other", share: 0.06, color: Color(hex: 0x2EE6C5))
        ]
    }

    private var monthLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: Date())
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    heroCard
                    commitsCard
                    contributorsCard
                    languagesCard
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
            }
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

            Text("Insights")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            circleButton(symbol: "funnel") {
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

    // MARK: Totals

    private var heroCard: some View {
        HStack(spacing: 10) {
            statBlock(
                symbol: "chevron.left.forwardslash.chevron.right",
                value: totalCommits.formatted(),
                label: "Commits"
            )

            heroDivider

            statBlock(
                symbol: "person.3.fill",
                value: "\(contributorCount)",
                label: "Contributors"
            )

            heroDivider

            statBlock(
                symbol: "star.fill",
                value: "\(liveRepo.stars)",
                label: "Stars"
            )
        }
        .padding(16)
        .glassCard()
    }

    private func statBlock(symbol: String, value: String, label: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.24), .white.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                )

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(Palette.inkMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

    private var heroDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.10))
            .frame(width: 1, height: 76)
    }

    // MARK: Commits

    private var commitsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Commits this month")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 6)

                HStack(spacing: 6) {
                    Text(monthLabel)
                        .font(.system(size: 15, weight: .medium))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(Palette.inkMuted)
            }

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(Array(weeklyCommits.enumerated()), id: \.offset) { _, item in
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Palette.accentBright, Palette.accent],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: max(10, 112 * item.value))
                            .frame(maxWidth: .infinity)

                        Text(item.letter)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Palette.inkMuted)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 138, alignment: .bottom)
        }
        .padding(16)
        .glassCard()
    }

    // MARK: Contributors

    private var contributorsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Contributors")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Text("See all")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Palette.accentBright)
            }

            VStack(spacing: 0) {
                ForEach(Array(contributors.enumerated()), id: \.element.id) { index, person in
                    contributorRow(person)

                    if index < contributors.count - 1 {
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 1)
                            .padding(.vertical, 10)
                    }
                }
            }
        }
        .padding(16)
        .glassCard()
    }

    private func contributorRow(_ person: InsightContributor) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                AvatarView(initials: person.initials, size: 46)

                VStack(alignment: .leading, spacing: 1) {
                    Text(person.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(person.handle)
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.inkFaint)
                        .lineLimit(1)
                }

                Spacer(minLength: 6)

                Text("\(person.commits) commits")
                    .font(.system(size: 13))
                    .foregroundStyle(Palette.inkMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)
            }

            bar(
                share: Double(person.commits) / Double(max(topCommits, 1)),
                height: 5,
                colors: [Palette.accentBright, Palette.accent]
            )
        }
    }

    // MARK: Languages

    private var languagesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Languages")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.white)

            ForEach(languages) { language in
                HStack(spacing: 12) {
                    Text(language.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .frame(width: 92, alignment: .leading)

                    bar(
                        share: language.share,
                        height: 8,
                        colors: [language.color, language.color.opacity(0.85)]
                    )

                    Text("\(Int((language.share * 100).rounded()))%")
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkMuted)
                        .frame(width: 42, alignment: .trailing)
                }
            }
        }
        .padding(16)
        .glassCard()
    }

    // MARK: Bar

    private func bar(share: Double, height: CGFloat, colors: [Color]) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.10))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(8, proxy.size.width * share))
            }
        }
        .frame(height: height)
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        RepositoryInsightsView(repo: AppStore.sampleRepositories[0])
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
