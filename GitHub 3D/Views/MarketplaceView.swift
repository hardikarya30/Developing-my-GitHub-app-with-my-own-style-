//
//  MarketplaceView.swift
//  GitHub 3D
//
//  Apps and tools that extend your workflow, plus their detail pages.
//

import SwiftUI

struct MarketplaceView: View {
    @EnvironmentObject private var store: AppStore

    var onBack: () -> Void = {}
    var onOpenApp: (MarketplaceApp) -> Void = { _ in }

    @State private var query = ""
    @State private var selectedCategory = "All"

    private let categories = ["All", "CI/CD", "Code review", "AI", "Deployment"]

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var apps: [MarketplaceApp] {
        store.marketplaceApps.filter { app in
            let matchesCategory = selectedCategory == "All" || app.category == selectedCategory
            guard matchesCategory else { return false }
            guard !trimmedQuery.isEmpty else { return true }
            return app.name.localizedCaseInsensitiveContains(trimmedQuery)
                || app.blurb.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    private var emptyTitle: String {
        if trimmedQuery.isEmpty {
            return "No apps in \(selectedCategory == "All" ? "the Marketplace" : selectedCategory) yet"
        }
        if selectedCategory == "All" {
            return "No apps match \"\(trimmedQuery)\""
        }
        return "No \(selectedCategory) apps match \"\(trimmedQuery)\""
    }

    private var installedApps: [MarketplaceApp] {
        store.marketplaceApps.filter(\.isInstalled)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Enhance your workflow with extensions")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Tools from the community and partners to simplify tasks and automate processes")
                            .font(.system(size: 14))
                            .foregroundStyle(Palette.inkMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    searchField
                    categoryRow

                    if !installedApps.isEmpty {
                        installedSection
                    }

                    if apps.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: 10) {
                            ForEach(apps) { app in
                                appRow(app)
                            }
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
            circleButton(symbol: "chevron.left") {
                Haptics.tap()
                onBack()
            }

            Spacer()

            Text("Marketplace")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            circleButton(symbol: "magnifyingglass") {
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

            TextField("Search in GitHub Marketplace", text: $query)
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .tint(Palette.accentBright)
                .multilineTextAlignment(.center)
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
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
        )
    }

    // MARK: Categories

    private var categoryRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    SectionChip(title: category, isSelected: selectedCategory == category) {
                        Haptics.select()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: Installed

    private var installedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Installed")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(installedApps) { app in
                        Button {
                            Haptics.tap()
                            onOpenApp(app)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: app.symbol)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 34, height: 34)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Palette.accentBright, Palette.accent],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    )

                                VStack(alignment: .leading, spacing: 1) {
                                    Text(app.name)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)

                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundStyle(Palette.accentBright)
                                        Text("Installed")
                                            .font(.system(size: 12))
                                            .foregroundStyle(Palette.inkMuted)
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(hex: 0x32288C).opacity(0.85))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PressableStyle(scale: 0.97))
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: App row

    private func appRow(_ app: MarketplaceApp) -> some View {
        Button {
            Haptics.tap()
            onOpenApp(app)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: app.symbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(app.name)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        if app.isInstalled {
                            Text("Installed")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Palette.accentBright))
                        }
                    }

                    Text(app.blurb)
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                }

                Spacer(minLength: 6)

                Text("App")
                    .font(.system(size: 13))
                    .foregroundStyle(Palette.inkFaint)
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

    // MARK: Empty

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "bag")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .frame(width: 64, height: 64)
                .background(Circle().fill(Color.white.opacity(0.08)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

            Text(emptyTitle)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Try a different name.")
                .font(.system(size: 14))
                .foregroundStyle(Palette.inkMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .glassCard()
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        MarketplaceView()
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
