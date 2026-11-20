//
//  GistsView.swift
//  GitHub 3D
//
//  Your reusable snippets and a composer for new ones.
//

import SwiftUI

struct GistsView: View {
    @EnvironmentObject private var store: AppStore

    var onBack: () -> Void = {}
    var onOpenGist: (GistItem) -> Void = { _ in }

    @State private var showComposer = false

    private var myGists: [GistItem] {
        store.gists.filter(\.isMine)
    }

    private var starredGists: [GistItem] {
        store.gists.filter { !$0.isMine }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            if let message = store.gistDeletionMessage {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .semibold))

                    Text(message)
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(1)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(Capsule().fill(Color.white.opacity(0.12)))
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.18), lineWidth: 1))
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    if !myGists.isEmpty {
                        HStack(spacing: 6) {
                            Text("Your gists")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                            Text("· \(myGists.count)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Palette.accentBright)
                        }

                        VStack(spacing: 10) {
                            ForEach(myGists) { gist in
                                gistCard(gist)
                            }
                        }
                    }

                    if !starredGists.isEmpty {
                        Text("Starred gists")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.top, 4)

                        VStack(spacing: 10) {
                            ForEach(starredGists) { gist in
                                gistCard(gist)
                            }
                        }
                    }

                    GradientActionButton(title: "New gist") {
                        Haptics.tap()
                        showComposer = true
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
            }
        }
        .sheet(isPresented: $showComposer) {
            NewGistSheet()
                .presentationDetents([.large])
                .presentationCornerRadius(32)
                .presentationDragIndicator(.visible)
        }
        .task(id: store.gistDeletionMessage) {
            guard store.gistDeletionMessage != nil else { return }
            try? await Task.sleep(for: .seconds(2.6))
            withAnimation(.easeOut(duration: 0.25)) {
                store.clearGistDeletionMessage()
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

            Text("Gists")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                Haptics.tap()
                showComposer = true
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

    // MARK: Rows

    private func gistCard(_ gist: GistItem) -> some View {
        Button {
            Haptics.tap()
            onOpenGist(gist)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "doc.text")
                    .font(.system(size: 18, weight: .medium))
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

                VStack(alignment: .leading, spacing: 4) {
                    Text(gist.filename)
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    HStack(spacing: 4) {
                        Text(gist.language)
                        Text("·")
                        if gist.isPrivate {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        Text(gist.visibilityLabel)
                        Text("·")
                        Text("Updated \(gist.updated)")
                    }
                    .font(.system(size: 13.5))
                    .foregroundStyle(Palette.inkFaint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                    Text(gist.about)
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 2)
                }

                Spacer(minLength: 4)

                VStack(spacing: 10) {
                    HStack(spacing: 5) {
                        Image(systemName: "star")
                            .font(.system(size: 13, weight: .medium))
                        Text("\(gist.stars)")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(Palette.inkMuted)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Palette.inkFaint)
                }
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
}

// MARK: - Composer

struct NewGistSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var filename = ""
    @State private var about = ""
    @State private var code = ""
    @State private var language = "Swift"
    @State private var isPrivate = false

    private let languages = ["Swift", "SwiftUI", "TypeScript", "Markdown"]

    private var canCreate: Bool {
        !filename.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text("New gist")
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

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("FILENAME")
                TextField("snippet.swift", text: $filename)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .authField()
            }

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("DESCRIPTION")
                TextField("What does this snippet do?", text: $about)
                    .authField()
            }

            HStack(spacing: 10) {
                Menu {
                    ForEach(languages, id: \.self) { item in
                        Button {
                            language = item
                        } label: {
                            if item == language {
                                Label(item, systemImage: "checkmark")
                            } else {
                                Text(item)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(language)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Palette.inkMuted)
                    }
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                    )
                }

                Button {
                    Haptics.select()
                    isPrivate.toggle()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isPrivate ? "lock.fill" : "globe")
                            .font(.system(size: 13, weight: .semibold))
                        Text(isPrivate ? "Private" : "Public")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                    )
                }
                .buttonStyle(PressableStyle(scale: 0.97))
            }

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("CODE")
                TextField("Paste your code here…", text: $code, axis: .vertical)
                    .lineLimit(6...12)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(.white)
                    .tint(Palette.accentBright)
                    .padding(14)
                    .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(hex: 0x121831))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                    )
            }

            Spacer(minLength: 0)

            Button {
                store.addGist(
                    filename: filename,
                    language: language,
                    about: about,
                    code: code,
                    isPrivate: isPrivate
                )
                Haptics.tap()
                dismiss()
            } label: {
                Text("Create")
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

#Preview {
    ZStack {
        AppBackdrop()
        GistsView()
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
