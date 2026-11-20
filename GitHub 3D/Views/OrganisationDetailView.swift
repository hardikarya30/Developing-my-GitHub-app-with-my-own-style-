//
//  OrganisationDetailView.swift
//  GitHub 3D
//
//  An organisation: identity, members, repositories and membership.
//

import SwiftUI

struct OrganisationDetailView: View {
    @EnvironmentObject private var store: AppStore

    var organisationID: UUID
    var onBack: () -> Void = {}

    private var organisation: OrganisationItem? {
        store.organisations.first(where: { $0.id == organisationID })
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            if let organisation {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        heroCard(organisation)
                        repositoriesSection
                        membershipButton(organisation)
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

            Text(organisation?.name ?? "Organisation")
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

    private func heroCard(_ organisation: OrganisationItem) -> some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Palette.accentBright, Palette.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: Palette.accentBright.opacity(0.55), radius: 22, x: 0, y: 12)

                Text(organisation.initials)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(.top, 6)

            Text(organisation.name)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)

            Text(organisation.handle)
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)

            Text(organisation.about)
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)

            HStack(spacing: 10) {
                metaChip(symbol: "chevron.left.forwardslash.chevron.right", text: "6 repositories")
                metaChip(symbol: "person.2", text: "\(organisation.memberCount) members")
            }
            .padding(.top, 4)

            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(height: 1)
                .padding(.vertical, 4)

            memberRow(organisation)

            Text("\(organisation.memberCount) members · A global community")
                .font(.system(size: 13))
                .foregroundStyle(Palette.inkFaint)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .glassCard()
    }

    private func metaChip(symbol: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private func memberRow(_ organisation: OrganisationItem) -> some View {
        let members = Array(store.people.prefix(5))

        return HStack(spacing: -12) {
            ForEach(members) { person in
                AvatarView(initials: person.initials, size: 46)
                    .overlay(
                        Circle().strokeBorder(Color(hex: 0x2A2079), lineWidth: 2)
                    )
            }

            Text("+\(max(organisation.memberCount - members.count, 0))")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(Circle().fill(Palette.accent.opacity(0.6)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.18), lineWidth: 1))

            Spacer(minLength: 0)
        }
        .padding(.leading, 2)
    }

    // MARK: Repositories

    private var repositoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Repositories")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Text("See all")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Palette.accentBright)
            }

            VStack(spacing: 0) {
                ForEach(Array(repositoryList.enumerated()), id: \.element.id) { index, repo in
                    repositoryRow(repo)

                    if index < repositoryList.count - 1 {
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

    private var repositoryList: [RepoItem] {
        Array(store.repositories.prefix(3))
    }

    private func repositoryRow(_ repo: RepoItem) -> some View {
        Button {
            Haptics.tap()
        } label: {
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

                VStack(alignment: .leading, spacing: 3) {
                    Text(repo.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text("\(repo.language) · Updated \(repo.updated)")
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
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
    }

    // MARK: Membership

    private func membershipButton(_ organisation: OrganisationItem) -> some View {
        Button {
            Haptics.select()
            withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                store.toggleOrganisationMembership(organisation.id)
            }
        } label: {
            Text(organisation.isMember ? "Leave organisation" : "Join organisation")
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
}

#Preview {
    ZStack {
        AppBackdrop()
        OrganisationDetailView(organisationID: AppStore.sampleOrganisations[0].id)
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
