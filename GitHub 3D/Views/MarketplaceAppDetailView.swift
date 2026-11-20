//
//  MarketplaceAppDetailView.swift
//  GitHub 3D
//
//  A Marketplace app's page: what it does, what is included and Install.
//

import SwiftUI

struct MarketplaceAppDetailView: View {
    @EnvironmentObject private var store: AppStore

    var appID: UUID
    var onBack: () -> Void = {}

    private var app: MarketplaceApp? {
        store.marketplaceApps.first(where: { $0.id == appID })
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            if let app {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        hero(app)
                        descriptionCard(app)

                        Text("What's included")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.top, 2)

                        includedCard(app)
                        installButton(app)
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

    // MARK: Hero

    private func hero(_ app: MarketplaceApp) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: app.symbol)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 96, height: 96)
                    .background(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Palette.accentBright, Palette.accent, Color(hex: 0x2A1E78)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .shadow(color: Palette.accentBright.opacity(0.45), radius: 18, x: 0, y: 10)

                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    Text(app.handle)
                        .font(.system(size: 17))
                        .foregroundStyle(Palette.inkMuted)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 10) {
                statTile(symbol: "arrow.down.to.line", value: app.installs, label: "Installs")
                statTile(symbol: "star", value: app.rating, label: "Rating")
                statTile(symbol: "tag", value: app.price, label: "Price")
            }
        }
        .padding(18)
        .glassCard()
    }

    private func statTile(symbol: String, value: String, label: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(label)
                    .font(.system(size: 13))
                    .foregroundStyle(Palette.inkMuted)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .frame(height: 72)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    // MARK: Description

    private func descriptionCard(_ app: MarketplaceApp) -> some View {
        Text(app.blurb)
            .font(.system(size: 16))
            .foregroundStyle(Palette.inkMuted)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .glassCard()
    }

    // MARK: Included

    private func includedCard(_ app: MarketplaceApp) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(app.bullets.enumerated()), id: \.offset) { index, bullet in
                HStack(spacing: 14) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
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

                    Text(bullet)
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 0)
                }
                .padding(.vertical, 12)

                if index < app.bullets.count - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 1)
                        .padding(.leading, 50)
                }
            }
        }
        .padding(.horizontal, 16)
        .glassCard()
    }

    // MARK: Install

    private func installButton(_ app: MarketplaceApp) -> some View {
        Button {
            Haptics.select()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                store.toggleMarketplaceInstall(app.id)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: app.isInstalled ? "checkmark" : "arrow.down.to.line")
                    .font(.system(size: 17, weight: .semibold))
                Text(app.isInstalled ? "Installed" : "Install")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: app.isInstalled
                                ? [Palette.accent, Palette.accent]
                                : [Palette.accentBright, Palette.accent],
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
}

#Preview {
    ZStack {
        AppBackdrop()
        MarketplaceAppDetailView(appID: AppStore.sampleMarketplaceApps[0].id)
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
