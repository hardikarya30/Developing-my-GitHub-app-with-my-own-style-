//
//  CollaboratorsView.swift
//  GitHub 3D
//
//  Everyone who can work on a repository, and the access they have.
//

import SwiftUI

struct CollaboratorsView: View {
    @EnvironmentObject private var store: AppStore

    var repoID: UUID
    var onBack: () -> Void = {}

    @State private var showPicker = false

    private var collaborators: [Collaborator] {
        store.collaborators(for: repoID)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("\(collaborators.count) people have access")
                        .font(.system(size: 16))
                        .foregroundStyle(Palette.inkMuted)

                    peopleCard

                    addButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
            }
        }
        .sheet(isPresented: $showPicker) {
            AddCollaboratorSheet(
                existingHandles: collaborators.map(\.handle)
            ) { person in
                store.addCollaborator(
                    to: repoID,
                    name: person.name,
                    handle: person.handle
                )
            }
            .presentationDetents([.medium])
            .presentationCornerRadius(32)
            .presentationDragIndicator(.visible)
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

            Text("Collaborators")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                Haptics.tap()
                showPicker = true
            } label: {
                Image(systemName: "plus")
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

    // MARK: People

    private var peopleCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(collaborators.enumerated()), id: \.element.id) { index, person in
                row(person)

                if index < collaborators.count - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 1)
                        .padding(.leading, 84)
                }
            }
        }
        .padding(.horizontal, 16)
        .glassCard()
    }

    private func row(_ person: Collaborator) -> some View {
        HStack(spacing: 14) {
            AvatarView(initials: person.initials, size: 54)

            VStack(alignment: .leading, spacing: 2) {
                Text(person.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(person.handle)
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.inkFaint)
                    .lineLimit(1)
            }

            Spacer(minLength: 6)

            Button {
                Haptics.select()
                withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                    store.cycleCollaboratorRole(for: repoID, collaboratorID: person.id)
                }
            } label: {
                Text(person.role.rawValue)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(roleTextColor(person.role))
                    .padding(.horizontal, 20)
                    .frame(height: 40)
                    .background {
                        if person.role == .read {
                            Capsule().fill(Color.white)
                        } else if person.role == .owner {
                            Capsule().fill(
                                LinearGradient(
                                    colors: [Palette.accentBright, Palette.accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        } else {
                            Capsule().fill(Palette.accent.opacity(0.18))
                        }
                    }
                    .overlay(
                        Capsule().strokeBorder(
                            person.role == .read
                                ? Color.clear
                                : Palette.accentBright.opacity(person.role == .owner ? 0.2 : 0.75),
                            lineWidth: 1
                        )
                    )
            }
            .buttonStyle(PressableStyle(scale: 0.95))

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Palette.inkFaint)
        }
        .padding(.vertical, 14)
    }

    private func roleTextColor(_ role: CollaboratorRole) -> Color {
        switch role {
        case .read: return Color(hex: 0x2A1E78)
        case .write: return .white
        case .owner: return .white
        }
    }

    // MARK: Add

    private var addButton: some View {
        Button {
            Haptics.tap()
            showPicker = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 17, weight: .semibold))
                Text("Add collaborator")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
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
    }
}

// MARK: - Add picker

struct AddCollaboratorSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var existingHandles: [String]
    var onAdd: (PersonItem) -> Void

    private var candidates: [PersonItem] {
        store.people.filter { person in
            !existingHandles.contains(where: {
                $0.caseInsensitiveCompare(person.handle) == .orderedSame
            })
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Add collaborator")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)

                    Text("They will get Read access to this repository.")
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.inkFaint)
                        .fixedSize(horizontal: false, vertical: true)
                }

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

            if candidates.isEmpty {
                Text("Everyone in your network already has access.")
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.inkMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 26)
                    .glassCard()
            } else {
                VStack(spacing: 0) {
                    ForEach(candidates) { person in
                        Button {
                            Haptics.tap()
                            onAdd(person)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                AvatarView(initials: person.initials, size: 40)

                                VStack(alignment: .leading, spacing: 1) {
                                    Text(person.name)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.white)
                                    Text(person.handle)
                                        .font(.system(size: 12))
                                        .foregroundStyle(Palette.inkFaint)
                                }

                                Spacer(minLength: 6)

                                Image(systemName: "plus.circle")
                                    .font(.system(size: 19))
                                    .foregroundStyle(Palette.accentBright)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PressableStyle(scale: 0.99))
                    }
                }
                .glassCard()
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppBackdrop())
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        CollaboratorsView(repoID: AppStore.sampleRepositories[0].id)
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
