//
//  PinnedRepositoriesSheet.swift
//  GitHub 3D
//
//  Choose up to three repositories to pin on Home.
//

import SwiftUI

struct PinnedRepositoriesSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var pinnedNames: [String]
    var onSave: ([String]) -> Void

    @State private var selection: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Pin repositories")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Choose up to three to show on Home.")
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkMuted)
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

            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(store.repositories) { repo in
                        row(repo)
                    }
                }
                .padding(.bottom, 8)
            }

            Button {
                Haptics.tap()
                onSave(selection)
                dismiss()
            } label: {
                Text("Done")
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
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppBackdrop())
        .preferredColorScheme(.dark)
        .onAppear {
            selection = pinnedNames
        }
    }

    private func row(_ repo: RepoItem) -> some View {
        let isSelected = selection.contains(repo.name)

        return Button {
            Haptics.select()
            if isSelected {
                selection.removeAll { $0 == repo.name }
            } else if selection.count < 3 {
                selection.append(repo.name)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "book.closed")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(repo.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Text("\(repo.language) · \(repo.stars) stars")
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.inkFaint)
                }

                Spacer(minLength: 6)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Palette.accentBright : Palette.inkFaint)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Palette.accent.opacity(0.22) : Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        isSelected ? Palette.accentBright.opacity(0.5) : Color.white.opacity(0.10),
                        lineWidth: 1
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
    }
}

#Preview {
    PinnedRepositoriesSheet(pinnedNames: [], onSave: { _ in })
        .environmentObject(AppStore())
}
