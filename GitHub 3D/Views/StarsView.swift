//
//  StarsView.swift
//  GitHub 3D
//
//  Every repository you have starred, newest first.
//

import SwiftUI

struct StarsView: View {
    @EnvironmentObject private var store: AppStore

    var onBack: () -> Void = {}
    var onOpenRepository: (RepoItem) -> Void = { _ in }
    var onExplore: () -> Void = {}

    @State private var isSearching = false
    @State private var searchText = ""

    private var starred: [RepoItem] {
        store.starredRepositories
    }

    private var trimmedSearch: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var visibleRepos: [RepoItem] {
        guard isSearching, !trimmedSearch.isEmpty else { return starred }
        return starred.filter { repo in
            repo.name.localizedCaseInsensitiveContains(trimmedSearch)
                || repo.blurb.localizedCaseInsensitiveContains(trimmedSearch)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            if isSearching {
                searchField
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("\(visibleRepos.count) repositories you starred.")
                        .font(.system(size: 15))
                        .foregroundStyle(Palette.inkMuted)

                    if starred.isEmpty {
                        emptyState
                    } else if visibleRepos.isEmpty {
                        noMatchesState
                    } else {
                        ForEach(visibleRepos) { repo in
                            card(repo)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
            }
        }
    }

    // MARK: Search

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Palette.inkMuted)

            TextField("Search starred repositories", text: $searchText)
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .tint(Palette.accentBright)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !searchText.isEmpty {
                Button {
                    Haptics.select()
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Palette.inkFaint)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(
            RoundedRectangle(cornerRadius: 23, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 23, style: .continuous)
                .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
        )
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var noMatchesState: some View {
        VStack(spacing: 8) {
            Image(systemName: "star")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .frame(width: 60, height: 60)
                .background(Circle().fill(Color.white.opacity(0.08)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

            Text("No starred repositories match \"\(trimmedSearch)\"")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Try a different name.")
                .font(.system(size: 14))
                .foregroundStyle(Palette.inkMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .glassCard()
    }

    // MARK: Header

    private var header: some View {
        HStack {
            circleButton(symbol: "chevron.left") {
                Haptics.tap()
                onBack()
            }

            Spacer()

            Text("Stars")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            circleButton(symbol: isSearching ? "xmark" : "magnifyingglass") {
                Haptics.tap()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    isSearching.toggle()
                    if !isSearching {
                        searchText = ""
                    }
                }
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

    // MARK: Card

    private func card(_ repo: RepoItem) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.16), .white.opacity(0.06)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(repo.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(repo.blurb)
                    .font(.system(size: 15))
                    .foregroundStyle(Palette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 5) {
                    Text(repo.language)
                    Text("·")
                    Image(systemName: "star")
                        .font(.system(size: 11, weight: .medium))
                    Text("\(repo.stars)")
                    Text("·")
                    Text("Updated \(repo.updated)")
                }
                .font(.system(size: 14))
                .foregroundStyle(Palette.inkFaint)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.top, 2)
            }

            Spacer(minLength: 4)

            Button {
                Haptics.select()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    store.toggleStar(named: repo.name)
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Starred")
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(1)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(
                    Capsule().fill(
                        LinearGradient(
                            colors: [Palette.accentBright, Palette.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                )
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.18), lineWidth: 1))
                .shadow(color: Palette.accent.opacity(0.35), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(PressableStyle(scale: 0.95))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(hex: 0x32288C).opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            Haptics.tap()
            onOpenRepository(repo)
        }
    }

    // MARK: Empty

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "star")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .frame(width: 72, height: 72)
                .background(Circle().fill(Color.white.opacity(0.08)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

            Text("No starred repositories")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(.white)

            Text("Star a repository in Explore and it will show up here.")
                .font(.system(size: 14))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

            Button {
                Haptics.tap()
                onExplore()
            } label: {
                Text("Explore repositories")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .frame(height: 48)
                    .background(
                        Capsule().fill(
                            LinearGradient(
                                colors: [Palette.accentBright, Palette.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    )
                    .shadow(color: Palette.accent.opacity(0.4), radius: 14, x: 0, y: 8)
            }
            .buttonStyle(PressableStyle())
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .glassCard()
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        StarsView()
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
