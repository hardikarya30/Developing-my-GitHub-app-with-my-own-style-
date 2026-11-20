//
//  GistDetailView.swift
//  GitHub 3D
//
//  One gist: its details, its code and when it changed.
//

import SwiftUI
import UIKit

struct GistDetailView: View {
    @EnvironmentObject private var store: AppStore

    var gistID: UUID
    var onBack: () -> Void = {}

    @State private var didCopy = false
    @State private var editingGist: GistItem?
    @State private var showDeleteAlert = false

    private var gist: GistItem? {
        store.gists.first(where: { $0.id == gistID })
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            if let gist {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        hero(gist)
                        codeCard(gist)
                        timesCard(gist)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 130)
                }
            }
        }
        .sheet(item: $editingGist) { gist in
            GistEditorSheet(gist: gist)
                .presentationDetents([.large])
                .presentationCornerRadius(28)
                .presentationDragIndicator(.visible)
        }
        .alert("Delete gist?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteGist()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("\"\(gist?.filename ?? "This gist")\" will be removed from your gists and cannot be restored.")
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

            Text("Gist")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Menu {
                Button {
                    Haptics.tap()
                    if let gist {
                        editingGist = gist
                    }
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Button(role: .destructive) {
                    Haptics.tap()
                    showDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Circle().fill(Color.white.opacity(0.10)))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.20), lineWidth: 1))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .glassCard(fill: Color.white.opacity(0.10), radius: 28)
    }

    private func deleteGist() {
        guard let gist else { return }
        Haptics.tap()
        store.deleteGist(gist.id)
        onBack()
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

    private func hero(_ gist: GistItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Text(gist.filename)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)

                Spacer(minLength: 6)

                HStack(spacing: 5) {
                    Image(systemName: "swift")
                        .font(.system(size: 12, weight: .semibold))
                    Text(gist.language)
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(
                    Capsule().fill(
                        LinearGradient(
                            colors: [Palette.accentBright, Palette.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                )

                Text(gist.visibilityLabel)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .frame(height: 34)
                    .background(Capsule().fill(Color.white.opacity(0.14)))
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.18), lineWidth: 1))
            }

            Text(gist.about)
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                Image(systemName: "star")
                    .font(.system(size: 14, weight: .medium))
                Text("\(gist.stars) stars")
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundStyle(Palette.inkMuted)
            .padding(.top, 2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    // MARK: Code

    private func codeCard(_ gist: GistItem) -> some View {
        ZStack(alignment: .topTrailing) {
            CodeBlockView(code: gist.code, showsLineNumbers: true)

            Button {
                UIPasteboard.general.string = gist.code
                Haptics.tap()
                withAnimation(.easeOut(duration: 0.2)) {
                    didCopy = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        didCopy = false
                    }
                }
            } label: {
                Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(didCopy ? Palette.accentBright : Palette.inkMuted)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.white.opacity(0.10)))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.14), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .padding(14)
        }
    }

    // MARK: Times

    private func timesCard(_ gist: GistItem) -> some View {
        VStack(spacing: 0) {
            timeRow(label: "Created", value: gist.created, showsDivider: true)
            timeRow(label: "Last updated", value: gist.updated, showsDivider: false)
        }
        .padding(.horizontal, 18)
        .glassCard()
    }

    private func timeRow(label: String, value: String, showsDivider: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(label)
                    .font(.system(size: 16))
                    .foregroundStyle(Palette.inkMuted)

                Spacer(minLength: 8)

                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
            .frame(height: 56)

            if showsDivider {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
            }
        }
    }
}

// MARK: - Editor sheet

struct GistEditorSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var gist: GistItem

    @State private var filename: String
    @State private var about: String
    @State private var code: String
    @State private var errorMessage: String?

    init(gist: GistItem) {
        self.gist = gist
        _filename = State(initialValue: gist.filename)
        _about = State(initialValue: gist.about)
        _code = State(initialValue: gist.code)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Edit gist")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                    Text(gist.visibilityLabel.lowercased() + " gist")
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.inkFaint)
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

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("FILENAME")
                TextField("snippet.swift", text: $filename)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .authField(isError: errorMessage != nil)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: 0xFF8A8A))
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("DESCRIPTION")
                TextField("What does this snippet do?", text: $about)
                    .authField()
            }

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("CODE")
                TextField("Paste your code here…", text: $code, axis: .vertical)
                    .lineLimit(6...14)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(.white)
                    .tint(Palette.accentBright)
                    .padding(14)
                    .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
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

            HStack(spacing: 12) {
                Button {
                    Haptics.tap()
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
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

                Button {
                    save()
                } label: {
                    Text("Save")
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

    private func save() {
        let trimmedName = filename.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            Haptics.tap()
            withAnimation(.easeOut(duration: 0.2)) {
                errorMessage = "Add a filename before saving, for example snippet.swift."
            }
            return
        }

        store.updateGist(id: gist.id, filename: trimmedName, about: about, code: code)
        Haptics.tap()
        dismiss()
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        GistDetailView(gistID: AppStore.sampleGists[0].id)
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
