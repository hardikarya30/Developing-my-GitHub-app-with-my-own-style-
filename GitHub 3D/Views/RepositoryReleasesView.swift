//
//  RepositoryReleasesView.swift
//  GitHub 3D
//
//  The version history of a repository, newest first.
//

import SwiftUI

struct RepositoryReleasesView: View {
    @EnvironmentObject private var store: AppStore

    var repo: RepoItem
    var onBack: () -> Void = {}

    @State private var expanded: Set<UUID> = []

    private var releases: [RepositoryRelease] {
        store.releases[repo.name] ?? []
    }

    private var latest: RepositoryRelease? {
        releases.first
    }

    private var older: [RepositoryRelease] {
        Array(releases.dropFirst())
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    if let latest {
                        latestCard(latest)
                    }

                    if !older.isEmpty {
                        Text("All releases")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.top, 6)

                        VStack(spacing: 12) {
                            ForEach(older) { release in
                                releaseCard(release)
                            }
                        }
                    }

                    if releases.isEmpty {
                        emptyState
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
            circleButton(symbol: "chevron.left") {
                Haptics.tap()
                onBack()
            }

            Spacer()

            Text("Releases")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            circleButton(symbol: "plus") {
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

    // MARK: Latest

    private func latestCard(_ release: RepositoryRelease) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Palette.accentBright, Palette.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 76, height: 76)
                    .overlay(
                        Image(systemName: "tag")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .shadow(color: Palette.accentBright.opacity(0.40), radius: 16, x: 0, y: 8)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        Text(release.tag)
                            .font(.system(size: 17, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white)

                        Text("Latest")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .frame(height: 26)
                            .background(Capsule().fill(Palette.accent))
                    }

                    Text(release.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)

                    Text("Published \(release.published)")
                        .font(.system(size: 15))
                        .foregroundStyle(Palette.inkFaint)
                }

                Spacer(minLength: 0)
            }

            Text(release.notes)
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .padding(.leading, 90)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    // MARK: Older releases

    private func releaseCard(_ release: RepositoryRelease) -> some View {
        let isExpanded = expanded.contains(release.id)

        return Button {
            Haptics.tap()
            withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                if isExpanded {
                    expanded.remove(release.id)
                } else {
                    expanded.insert(release.id)
                }
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(release.tag)
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white)

                        Text(release.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)

                        Text(release.published)
                            .font(.system(size: 15))
                            .foregroundStyle(Palette.inkFaint)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Palette.inkFaint)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }

                if isExpanded {
                    Text(release.notes)
                        .font(.system(size: 15))
                        .foregroundStyle(Palette.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(hex: 0x32288C).opacity(0.90))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "shippingbox")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .frame(width: 72, height: 72)
                .background(Circle().fill(Color.white.opacity(0.08)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

            Text("No releases yet")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(.white)

            Text("Tag a version of this repository and it will show up here.")
                .font(.system(size: 14))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .glassCard()
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        RepositoryReleasesView(repo: AppStore.sampleRepositories[0])
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
