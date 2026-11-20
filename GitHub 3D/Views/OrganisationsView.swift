//
//  OrganisationsView.swift
//  GitHub 3D
//
//  The organisations you belong to, and ones you could join.
//

import SwiftUI

struct OrganisationsView: View {
    @EnvironmentObject private var store: AppStore

    var onBack: () -> Void = {}
    var onOpenOrganisation: (OrganisationItem) -> Void = { _ in }

    private var joined: [OrganisationItem] {
        store.organisations.filter(\.isMember)
    }

    private var discover: [OrganisationItem] {
        store.organisations.filter { !$0.isMember }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    if store.organisations.isEmpty {
                        emptyState
                    } else {
                        if !joined.isEmpty {
                            sectionLabel("Your organisations")

                            ForEach(joined) { organisation in
                                card(organisation)
                            }
                        }

                        if !discover.isEmpty {
                            sectionLabel("Discover")
                                .padding(.top, 6)

                            ForEach(discover) { organisation in
                                card(organisation)
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

            Text("Organisations")
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

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(Palette.inkMuted)
    }

    // MARK: Card

    private func card(_ organisation: OrganisationItem) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(organisation.initials)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
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
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(organisation.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(organisation.handle)
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.inkFaint)
                    .lineLimit(1)

                Text(organisation.about)
                    .font(.system(size: 15))
                    .foregroundStyle(Palette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 2)

                HStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.2")
                            .font(.system(size: 14, weight: .medium))
                        Text("\(organisation.memberCount) members")
                            .font(.system(size: 15))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(Palette.inkMuted)

                    Spacer(minLength: 6)

                    membershipButton(organisation)
                }
                .padding(.top, 6)
            }
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
            onOpenOrganisation(organisation)
        }
    }

    private func membershipButton(_ organisation: OrganisationItem) -> some View {
        Button {
            Haptics.select()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                store.toggleOrganisationMembership(organisation.id)
            }
        } label: {
            Text(organisation.isMember ? "Joined" : "Join")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(organisation.isMember ? Color.white : Palette.accentBright)
                .padding(.horizontal, 18)
                .frame(height: 44)
                .background {
                    if organisation.isMember {
                        Capsule().fill(
                            LinearGradient(
                                colors: [Palette.accentBright, Palette.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    } else {
                        Capsule().fill(Palette.accent.opacity(0.14))
                    }
                }
                .overlay(
                    Capsule().strokeBorder(
                        organisation.isMember
                            ? Color.white.opacity(0.18)
                            : Palette.accentBright.opacity(0.75),
                        lineWidth: 1
                    )
                )
                .shadow(
                    color: organisation.isMember ? Palette.accent.opacity(0.35) : .clear,
                    radius: 12,
                    x: 0,
                    y: 6
                )
        }
        .buttonStyle(PressableStyle(scale: 0.95))
    }

    // MARK: Empty

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "building.2")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .frame(width: 72, height: 72)
                .background(Circle().fill(Color.white.opacity(0.08)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

            Text("No organisations yet")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(.white)

            Text("Organisations you belong to will show up here.")
                .font(.system(size: 14))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .glassCard()
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        OrganisationsView()
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
