//
//  NewCodespaceView.swift
//  GitHub 3D
//
//  Pick a repository, machine and region for a new codespace.
//

import SwiftUI

struct NewCodespaceView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var onCreated: (CodespaceItem) -> Void = { _ in }

    private let machines: [(cores: String, ram: String)] = [
        ("2 cores", "4 GB RAM"),
        ("4 cores", "8 GB RAM"),
        ("8 cores", "16 GB RAM")
    ]

    private let regions = ["Frankfurt", "Mumbai", "Amsterdam"]

    @State private var repository = ""
    @State private var machineCores = "4 cores"
    @State private var machineRAM = "8 GB RAM"
    @State private var region = "Frankfurt"

    private var repositories: [RepoItem] {
        store.repositories
    }

    private var selectedRepository: RepoItem? {
        repositories.first(where: { $0.name == repository }) ?? repositories.first
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Pick a repository and a machine for your new codespace.")
                        .font(.system(size: 16))
                        .foregroundStyle(Palette.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)

                    sectionLabel("Repository")
                    repositoryPicker

                    sectionLabel("Machine")
                    machineCard

                    sectionLabel("Region")
                    regionPicker

                    createButton
                        .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(AppBackdrop())
        .preferredColorScheme(.dark)
        .onAppear {
            if repository.isEmpty {
                repository = repositories.first?.name ?? ""
            }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Button {
                Haptics.tap()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Circle().fill(Color.white.opacity(0.10)))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.20), lineWidth: 1))
            }
            .buttonStyle(PressableStyle(scale: 0.9))

            Spacer()

            Text("New codespace")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Color.clear
                .frame(width: 46, height: 46)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .glassCard(fill: Color.white.opacity(0.10), radius: 28)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(.white)
            .padding(.top, 2)
    }

    // MARK: Repository

    private var repositoryPicker: some View {
        Menu {
            ForEach(repositories) { repo in
                Button {
                    Haptics.select()
                    repository = repo.name
                } label: {
                    if repo.name == selectedRepository?.name {
                        Label(repo.name, systemImage: "checkmark")
                    } else {
                        Text(repo.name)
                    }
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 17, weight: .medium))
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
                    Text(selectedRepository?.name ?? "Choose a repository")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Text(store.profile.name)
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkMuted)
                }

                Spacer(minLength: 6)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)
            }
            .padding(14)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
        .glassCard()
    }

    // MARK: Machine

    private var machineCard: some View {
        VStack(spacing: 10) {
            ForEach(machines, id: \.cores) { option in
                machineRow(cores: option.cores, ram: option.ram)
            }
        }
    }

    private func machineRow(cores: String, ram: String) -> some View {
        let isSelected = machineCores == cores

        return Button {
            Haptics.select()
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                machineCores = cores
                machineRAM = ram
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "cpu")
                    .font(.system(size: 17, weight: .medium))
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
                    Text(cores)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(ram)
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkMuted)
                }

                Spacer(minLength: 6)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Palette.accentBright : Palette.inkFaint)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(hex: 0x32288C).opacity(0.85))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(
                        isSelected ? Palette.accentBright : Color.white.opacity(0.12),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .shadow(
                color: isSelected ? Palette.accentBright.opacity(0.35) : .clear,
                radius: 14,
                x: 0,
                y: 6
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
    }

    // MARK: Region

    private var regionPicker: some View {
        Menu {
            ForEach(regions, id: \.self) { option in
                Button {
                    Haptics.select()
                    region = option
                } label: {
                    if option == region {
                        Label(option, systemImage: "checkmark")
                    } else {
                        Text(option)
                    }
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 17, weight: .medium))
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

                Text(region)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)

                Spacer(minLength: 6)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)
            }
            .padding(14)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
        .glassCard()
    }

    // MARK: Create

    private var createButton: some View {
        Button {
            create()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .semibold))
                Text("Create codespace")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
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
        .disabled(selectedRepository == nil)
        .opacity(selectedRepository == nil ? 0.55 : 1)
    }

    private func create() {
        guard let repo = selectedRepository else { return }
        Haptics.tap()
        let codespace = store.addCodespace(
            repository: repo.name,
            branch: repo.defaultBranch,
            machine: "\(machineCores), \(machineRAM)",
            region: region
        )
        dismiss()
        onCreated(codespace)
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        NewCodespaceView()
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
