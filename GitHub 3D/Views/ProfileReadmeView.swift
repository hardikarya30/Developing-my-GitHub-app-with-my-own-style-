//
//  ProfileReadmeView.swift
//  GitHub 3D
//
//  The README shown at the top of your profile.
//

import SwiftUI

struct ProfileReadmeView: View {
    @EnvironmentObject private var store: AppStore

    var onBack: () -> Void = {}

    @State private var draft = ""
    @State private var didSave = false

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("This shows at the top of your profile.")
                        .font(.system(size: 16))
                        .foregroundStyle(Palette.inkMuted)

                    editorCard

                    Text("Preview")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.top, 4)

                    MarkdownPreview(markdown: draft)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .glassCard()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
            }
        }
        .onAppear {
            if draft.isEmpty {
                draft = store.profileReadme
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

            Text("Profile README")
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

    // MARK: Editor

    private var editorCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("MARKDOWN")
                .font(.system(size: 12, weight: .bold))
                .tracking(1.3)
                .foregroundStyle(Palette.inkMuted)

            TextEditor(text: $draft)
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(.white)
                .tint(Palette.accentBright)
                .scrollContentBackground(.hidden)
                .padding(10)
                .frame(minHeight: 260)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                )

            Button {
                save()
            } label: {
                Text(didSave ? "Saved" : "Save README")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
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
        .padding(16)
        .glassCard()
    }

    private func save() {
        Haptics.tap()
        store.updateProfileReadme(draft)
        withAnimation(.easeOut(duration: 0.2)) {
            didSave = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeOut(duration: 0.25)) {
                didSave = false
            }
        }
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        ProfileReadmeView()
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
