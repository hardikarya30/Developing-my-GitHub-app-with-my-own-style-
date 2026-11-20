//
//  RepositoriesView.swift
//  GitHub 3D
//
//  The repositories workspace: create and import projects, pick a model
//  and jump into favourites.
//

import SwiftUI

struct RepositoryModelOption: Identifiable {
    var id: String { title }
    var title: String
    var subtitle: String
    var symbol: String
}

struct RepositoriesView: View {
    @EnvironmentObject private var store: AppStore

    var onBack: () -> Void = {}
    var onOpenRepository: (RepoItem) -> Void = { _ in }
    var onOpenWatching: () -> Void = {}

    @State private var showCreate = false
    @State private var showImport = false
    @State private var showFavorites = false
    @State private var selectedModel = 1
    @State private var searchText = ""

    private var trimmedSearch: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isFiltering: Bool {
        !trimmedSearch.isEmpty
    }

    private var visibleRepositories: [RepoItem] {
        guard isFiltering else { return store.repositories }
        return store.repositories.filter(matches)
    }

    private var visibleStarred: [RepoItem] {
        guard isFiltering else { return store.starredRepositories }
        return store.starredRepositories.filter(matches)
    }

    private var recentRepositories: [RepoItem] {
        guard isFiltering else { return store.recentlyViewedRepositories }
        return store.recentlyViewedRepositories.filter(matches)
    }

    /// Every repository the current query matches, counted once even when it
    /// sits in both the list and the favourites grid.
    private var matchCount: Int {
        guard isFiltering else { return store.repositories.count }
        let names = Set(visibleRepositories.map(\.name)).union(visibleStarred.map(\.name))
        return names.count
    }

    private func matches(_ repo: RepoItem) -> Bool {
        repo.name.localizedCaseInsensitiveContains(trimmedSearch)
            || repo.blurb.localizedCaseInsensitiveContains(trimmedSearch)
    }

    private let models: [RepositoryModelOption] = [
        RepositoryModelOption(title: "Fast and cost-efficient", subtitle: "GPT-5.4 mini", symbol: "bolt.fill"),
        RepositoryModelOption(title: "Versatile and highly intelligent", subtitle: "GPT-5.4", symbol: "sparkles"),
        RepositoryModelOption(title: "Most powerful at complex tasks", subtitle: "GPT-5.4 pro", symbol: "rocket.fill")
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 14)

            searchField
                .padding(.horizontal, 20)
                .padding(.bottom, 14)

            if !recentRepositories.isEmpty {
                recentlyViewedRow
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    heroCard
                    topRepositoriesSection
                    modelSection
                    favoritesCard

                    if showFavorites && !visibleStarred.isEmpty {
                        favoritesGrid
                    } else if showFavorites && isFiltering
                        && !store.starredRepositories.isEmpty
                        && matchCount > 0 {
                        noMatchesCard(
                            title: "No favourites match \"\(trimmedSearch)\"",
                            subtitle: "Try a different name or description."
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
            }
        }
        .sheet(isPresented: $showCreate) {
            CreateRepositorySheet()
                .presentationDetents([.height(440)])
                .presentationCornerRadius(32)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showImport) {
            ImportRepositorySheet()
                .presentationDetents([.height(380)])
                .presentationCornerRadius(32)
                .presentationDragIndicator(.visible)
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

            HStack(spacing: 8) {
                Text("Repositories")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.white)

                Text("\(matchCount)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .frame(height: 22)
                    .background(Capsule().fill(Color.white.opacity(0.16)))
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.22), lineWidth: 1))
                    .contentTransition(.numericText())
            }

            Spacer()

            HStack(spacing: 8) {
                circleButton(symbol: "eye") {
                    Haptics.tap()
                    onOpenWatching()
                }

                circleButton(symbol: "plus") {
                    Haptics.tap()
                    showCreate = true
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

    // MARK: Hero

    private var heroCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Palette.accentBright.opacity(0.45), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 90
                        )
                    )
                    .frame(width: 190, height: 190)

                Image(systemName: "folder.fill")
                    .font(.system(size: 78))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white.opacity(0.95), Palette.accentBright.opacity(0.75)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Palette.accentBright.opacity(0.6), radius: 24, x: 0, y: 10)

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Palette.accentBright, Palette.accent],
                                center: .center,
                                startRadius: 1,
                                endRadius: 30
                            )
                        )
                        .frame(width: 48, height: 48)
                        .overlay(Circle().strokeBorder(.white.opacity(0.35), lineWidth: 1))

                    Image(systemName: "plus")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(.white)
                }
                .offset(x: 26, y: 28)
            }
            .frame(height: 152)

            Text("Create your first project")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            Text("Ready to start building? Create a repository for a new idea or bring over an existing repository to keep contributing to it.")
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                Button {
                    Haptics.tap()
                    showCreate = true
                } label: {
                    Text("Create repository")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
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

                Button {
                    Haptics.tap()
                    showImport = true
                } label: {
                    Text("Import repository")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white.opacity(0.12))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                        )
                }
                .buttonStyle(PressableStyle())
            }
            .padding(.top, 4)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .glassCard()
    }

    // MARK: Top repositories

    private var topRepositoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Repositories")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            if isFiltering && visibleRepositories.isEmpty {
                noMatchesCard(
                    title: "No repositories match \"\(trimmedSearch)\"",
                    subtitle: "Try another name or a word from the description."
                )
            } else {
                VStack(spacing: 10) {
                    ForEach(visibleRepositories) { repo in
                        RepoRowView(repo: repo) {
                            Haptics.tap()
                            onOpenRepository(repo)
                        }
                    }
                }
                .padding(14)
                .glassCard()
            }
        }
    }

    // MARK: Search field

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Palette.inkMuted)

            TextField("Search repositories", text: $searchText)
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
    }

    // MARK: Recently viewed

    private var recentlyViewedRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recently viewed")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)

                Spacer(minLength: 8)

                Button {
                    Haptics.select()
                    store.clearRecentlyViewedRepositories()
                } label: {
                    Text("Clear")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Palette.accentBright)
                }
                .buttonStyle(.plain)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(recentRepositories) { repo in
                        Button {
                            Haptics.tap()
                            onOpenRepository(repo)
                        } label: {
                            HStack(spacing: 7) {
                                Image(systemName: "folder.fill")
                                    .font(.system(size: 12.5, weight: .semibold))
                                    .foregroundStyle(Palette.accentBright)

                                Text(repo.name)
                                    .font(.system(size: 13.5, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 13)
                            .frame(height: 40)
                            .background(Capsule().fill(Color.white.opacity(0.08)))
                            .overlay(Capsule().strokeBorder(Color.white.opacity(0.14), lineWidth: 1))
                        }
                        .buttonStyle(PressableStyle(scale: 0.95))
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func noMatchesCard(title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .frame(width: 56, height: 56)
                .background(Circle().fill(Color.white.opacity(0.08)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.system(size: 13))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .glassCard()
    }

    // MARK: Models

    private var modelSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Model")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            VStack(spacing: 10) {
                ForEach(Array(models.enumerated()), id: \.element.id) { index, model in
                    modelCard(model, isSelected: selectedModel == index)
                }
            }
        }
    }

    private func modelCard(_ model: RepositoryModelOption, isSelected: Bool) -> some View {
        Button {
            Haptics.select()
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                selectedModel = models.firstIndex(where: { $0.id == model.id }) ?? selectedModel
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: model.symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(isSelected ? Palette.accentBright.opacity(0.20) : Color.white.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(model.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(model.subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkFaint)
                }

                Spacer(minLength: 6)

                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? Palette.accentBright : Color.white.opacity(0.25),
                            lineWidth: 1.5
                        )
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Palette.accentBright)
                            .frame(width: 24, height: 24)
                        Circle()
                            .fill(.white)
                            .frame(width: 9, height: 9)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(isSelected ? Palette.accent.opacity(0.16) : Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(
                        isSelected ? Palette.accentBright.opacity(0.75) : Color.white.opacity(0.10),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .shadow(color: isSelected ? Palette.accentBright.opacity(0.35) : .clear, radius: 18, x: 0, y: 8)
        }
        .buttonStyle(PressableStyle(scale: 0.985))
    }

    // MARK: Favorites

    private var favoritesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Favorites")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                    )

                Text("Favourite repositories here to have quick access at any time without having to search.")
                    .font(.system(size: 15))
                    .foregroundStyle(Palette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            GradientActionButton(title: "Favorites") {
                Haptics.select()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    showFavorites.toggle()
                }
            }
            .padding(.top, 4)
        }
        .padding(16)
        .glassCard()
    }

    private var favoritesGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
            spacing: 10
        ) {
            ForEach(visibleStarred) { repo in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Palette.accentBright)

                        Spacer()

                        Button {
                            Haptics.select()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                store.toggleStar(named: repo.name)
                            }
                        } label: {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color(hex: 0xFFD479))
                                .frame(width: 26, height: 26)
                                .background(Circle().fill(Color.white.opacity(0.10)))
                        }
                        .buttonStyle(PressableStyle(scale: 0.9))
                    }

                    Text(repo.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Image(systemName: "star")
                            .font(.system(size: 10, weight: .medium))
                        Text("\(repo.stars) · \(repo.language)")
                            .font(.system(size: 12))
                            .lineLimit(1)
                    }
                    .foregroundStyle(Palette.inkFaint)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.07))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Create repository sheet

struct CreateRepositorySheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var detail = ""

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text("Create repository")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

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

            Text("A repository holds your code, your issues and the history of the project.")
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("REPOSITORY NAME")
                TextField("my-new-project", text: $name)
                    .repositoryField()
            }

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("DESCRIPTION")
                TextField("What are you building?", text: $detail, axis: .vertical)
                    .lineLimit(2...4)
                    .repositoryField(minHeight: 84, alignment: .topLeading)
            }

            Spacer(minLength: 0)

            Button {
                let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedDetail = detail.trimmingCharacters(in: .whitespacesAndNewlines)
                store.addRepository(
                    name: trimmedName,
                    blurb: trimmedDetail.isEmpty ? "A new project, just created." : trimmedDetail
                )
                Haptics.tap()
                dismiss()
            } label: {
                Text("Create repository")
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
            .disabled(!canCreate)
            .opacity(canCreate ? 1 : 0.45)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppBackdrop())
        .preferredColorScheme(.dark)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .tracking(1.3)
            .foregroundStyle(Palette.inkFaint)
    }
}

// MARK: - Import repository sheet

struct ImportRepositorySheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var url = ""
    @State private var errorMessage: String?

    private var canImport: Bool {
        !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text("Import repository")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

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

            Text("Paste the link to a repository you already own and keep contributing to it.")
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("REPOSITORY URL")
                TextField("https://github.com/you/project", text: $url)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .repositoryField()

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: 0xFF8A8A))
                }
            }

            Spacer(minLength: 0)

            Button {
                importRepository()
            } label: {
                Text("Import repository")
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
            .disabled(!canImport)
            .opacity(canImport ? 1 : 0.45)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppBackdrop())
        .preferredColorScheme(.dark)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .tracking(1.3)
            .foregroundStyle(Palette.inkFaint)
    }

    private func importRepository() {
        let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.contains("/"), trimmed.count > 3 else {
            Haptics.tap()
            withAnimation(.easeOut(duration: 0.2)) {
                errorMessage = "Enter a repository link, for example github.com/you/project."
            }
            return
        }

        let slug = trimmed
            .split(separator: "/")
            .last
            .map(String.init)?
            .replacingOccurrences(of: ".git", with: "")
            .trimmingCharacters(in: .whitespaces)

        let name = (slug?.isEmpty == false ? slug! : "imported-project")
        store.addRepository(name: name, blurb: "Imported from \(trimmed)")
        Haptics.tap()
        dismiss()
    }
}

// MARK: - Field style

private extension View {
    func repositoryField(minHeight: CGFloat = 52, alignment: Alignment = .leading) -> some View {
        self
            .font(.system(size: 16))
            .foregroundStyle(.white)
            .tint(Palette.accentBright)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: alignment)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
            )
    }
}

#Preview {
    RepositoriesView()
        .environmentObject(AppStore())
        .background(AppBackdrop())
        .preferredColorScheme(.dark)
}
