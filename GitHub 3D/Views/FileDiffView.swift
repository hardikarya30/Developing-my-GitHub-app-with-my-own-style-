//
//  FileDiffView.swift
//  GitHub 3D
//
//  A read-only unified diff for one file changed by a pull request.
//

import SwiftUI
import UIKit

struct PRDiffTarget: Identifiable, Hashable {
    var id = UUID()
    var requestID: UUID?
    var path: String
    var fileOverride: PRFile? = nil
}

struct FileDiffLine: Identifiable {
    enum Kind {
        case hunk
        case context
        case added
        case removed
    }

    var id = UUID()
    var kind: Kind
    var oldNumber: Int?
    var newNumber: Int?
    var text: String
}

struct FileDiffContent {
    var lines: [FileDiffLine]
    var hunkCount: Int
}

enum FileDiffBuilder {
    static func content(for file: PRFile) -> FileDiffContent {
        let name = file.path.split(separator: "/").last.map(String.init) ?? file.path
        let typeName = name.replacingOccurrences(of: ".swift", with: "")
            .replacingOccurrences(of: ".md", with: "")
        let lines = file.isMarkdown ? markdownLines() : swiftLines(typeName: typeName)
        return FileDiffContent(
            lines: lines,
            hunkCount: lines.filter { $0.kind == .hunk }.count
        )
    }

    private static func swiftLines(typeName: String) -> [FileDiffLine] {
        [
            .hunk("@@ -12,7 +12,8 @@ struct \(typeName)"),
            .context(old: 12, new: 12, "    let repository: RepoItem"),
            .context(old: 13, new: 13, "    let onTap: () -> Void"),
            .context(old: 14, new: 14, ""),
            .removed(old: 15, "    var showsDescription: Bool = true"),
            .removed(old: 16, "    var cornerRadius: CGFloat = 12"),
            .added(new: 15, "    var showsDescription: Bool = false"),
            .added(new: 16, "    var cornerRadius: CGFloat = 16"),
            .added(new: 17, "    var onStarTap: (() -> Void)?"),
            .context(old: 17, new: 18, ""),
            .context(old: 18, new: 19, "    var body: some View {"),
            .context(old: 19, new: 20, "        HStack(spacing: 12) {"),
            .context(old: 20, new: 21, "            RepositoryIcon(repository: repository)"),
            .context(old: 21, new: 22, "            VStack(alignment: .leading, spacing: 4) {"),

            .hunk("@@ -38,6 +39,7 @@ var body: some View {"),
            .context(old: 38, new: 39, "            .padding(16)"),
            .context(old: 39, new: 40, "            .background(.ultraThinMaterial)"),
            .removed(old: 40, "            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))"),
            .added(new: 41, "            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))"),
            .added(new: 42, "            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))"),
            .context(old: 41, new: 43, "            .shadow(color: .black.opacity(0.2), radius: 12, y: 6)"),
            .context(old: 42, new: 44, "    }"),
            .context(old: 43, new: 45, "}"),

            .hunk("@@ -52,4 +55,5 @@ extension \(typeName) {"),
            .context(old: 52, new: 55, "    static let preview = \(typeName)(repository: .preview)"),
            .removed(old: 53, "    static let compact = \(typeName)(repository: .preview)"),
            .added(new: 56, "    static let compact = \(typeName)(repository: .preview, showsDescription: false)"),
            .added(new: 57, "    static let starred = \(typeName)(repository: .preview, onStarTap: {})"),
            .context(old: 54, new: 58, "}")
        ]
    }

    private static func markdownLines() -> [FileDiffLine] {
        [
            .hunk("@@ -8,6 +8,7 @@ ## Installation"),
            .context(old: 8, new: 8, "- Open the project in Xcode 26."),
            .context(old: 9, new: 9, "- Select the `GitHub 3D` scheme."),
            .removed(old: 10, "- Run on a simulator."),
            .added(new: 10, "- Run on a simulator or a device."),
            .added(new: 11, "- Press **Run** in the toolbar."),
            .context(old: 11, new: 12, ""),
            .context(old: 12, new: 13, "## Features"),

            .hunk("@@ -24,5 +25,6 @@ ## Features"),
            .context(old: 24, new: 25, "- A profile dashboard with your repositories."),
            .context(old: 25, new: 26, "- A Copilot workspace with model choices."),
            .added(new: 27, "- A read-only diff for every changed file."),
            .context(old: 26, new: 28, ""),
            .context(old: 27, new: 29, "## License"),
            .context(old: 28, new: 30, "MIT")
        ]
    }
}

private extension FileDiffLine {
    static func hunk(_ text: String) -> FileDiffLine {
        FileDiffLine(kind: .hunk, oldNumber: nil, newNumber: nil, text: text)
    }

    static func context(old: Int, new: Int, _ text: String) -> FileDiffLine {
        FileDiffLine(kind: .context, oldNumber: old, newNumber: new, text: text)
    }

    static func added(new: Int, _ text: String) -> FileDiffLine {
        FileDiffLine(kind: .added, oldNumber: nil, newNumber: new, text: text)
    }

    static func removed(old: Int, _ text: String) -> FileDiffLine {
        FileDiffLine(kind: .removed, oldNumber: old, newNumber: nil, text: text)
    }
}

struct FileDiffView: View {
    @EnvironmentObject private var store: AppStore

    var pullRequestID: UUID?
    var filePath: String
    var fileOverride: PRFile? = nil
    var onBack: () -> Void = {}

    @State private var didCopy = false

    private let addedGreen = Color(hex: 0x3FB950)
    private let removedRed = Color(hex: 0xFF6B6B)

    private var request: PullRequestItem? {
        guard let pullRequestID else { return nil }
        return store.pullRequests.first(where: { $0.id == pullRequestID })
    }

    private var file: PRFile? {
        if let fileOverride {
            return fileOverride
        }
        guard let files = request?.files else { return nil }
        return files.first(where: { $0.path == filePath }) ?? files.first
    }

    private var fileName: String {
        guard let path = file?.path else { return "Diff" }
        return path.split(separator: "/").last.map(String.init) ?? path
    }

    private var language: String {
        guard let file else { return "Swift" }
        return file.isMarkdown ? "Markdown" : "Swift"
    }

    private var diff: FileDiffContent {
        guard let file else { return FileDiffContent(lines: [], hunkCount: 0) }
        return FileDiffBuilder.content(for: file)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 14)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    pathCard
                    diffCard

                    Text(hunkCaption)
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
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

            Spacer(minLength: 8)

            Text(fileName)
                .font(.system(size: 19, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Spacer(minLength: 8)

            circleButton(symbol: didCopy ? "checkmark" : "doc.on.doc") {
                copyPath()
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

    private func copyPath() {
        UIPasteboard.general.string = file?.path ?? filePath
        Haptics.tap()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            didCopy = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if didCopy {
                withAnimation(.easeOut(duration: 0.2)) {
                    didCopy = false
                }
            }
        }
    }

    // MARK: Path and stats

    private var pathCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(file?.path ?? filePath)
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .foregroundStyle(Palette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                chip(language, tint: Palette.accentBright, text: .white)

                if let file {
                    chip(
                        "+\(file.additions)",
                        tint: addedGreen,
                        text: Color(hex: 0x8FE9A9)
                    )
                    chip(
                        "−\(file.deletions)",
                        tint: removedRed,
                        text: Color(hex: 0xFFA3B0)
                    )
                }

                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassCard()
    }

    private func chip(_ text: String, tint: Color, text textColor: Color) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(textColor)
            .padding(.horizontal, 14)
            .frame(height: 34)
            .background(Capsule().fill(tint.opacity(0.28)))
            .overlay(Capsule().strokeBorder(tint.opacity(0.45), lineWidth: 1))
    }

    // MARK: Diff

    private var diffCard: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(diff.lines) { line in
                    row(line)
                }
            }
            .padding(.vertical, 8)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(hex: 0x2A2179).opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func row(_ line: FileDiffLine) -> some View {
        if line.kind == .hunk {
            Text(line.text)
                .font(.system(size: 13.5, weight: .medium, design: .monospaced))
                .foregroundStyle(Palette.inkMuted)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            HStack(spacing: 0) {
                Text(line.oldNumber.map(String.init) ?? "")
                    .foregroundStyle(Palette.inkFaint)
                    .frame(width: 34, alignment: .trailing)

                Text(line.newNumber.map(String.init) ?? "")
                    .foregroundStyle(Palette.inkFaint)
                    .frame(width: 34, alignment: .trailing)

                Text(marker(for: line.kind))
                    .foregroundStyle(markerColor(for: line.kind))
                    .frame(width: 24, alignment: .center)

                Text(line.text)
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.system(size: 13, design: .monospaced))
            .foregroundStyle(textColor(for: line.kind))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(background(for: line.kind))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func marker(for kind: FileDiffLine.Kind) -> String {
        switch kind {
        case .added: return "+"
        case .removed: return "−"
        default: return " "
        }
    }

    private func markerColor(for kind: FileDiffLine.Kind) -> Color {
        switch kind {
        case .added: return Color(hex: 0x8FE9A9)
        case .removed: return Color(hex: 0xFFA3B0)
        default: return Palette.inkFaint
        }
    }

    private func textColor(for kind: FileDiffLine.Kind) -> Color {
        switch kind {
        case .added: return Color(hex: 0x8FE9A9)
        case .removed: return Color(hex: 0xFFA3B0)
        default: return .white
        }
    }

    private func background(for kind: FileDiffLine.Kind) -> Color {
        switch kind {
        case .added: return addedGreen.opacity(0.18)
        case .removed: return removedRed.opacity(0.20)
        default: return .clear
        }
    }

    private var hunkCaption: String {
        let count = diff.hunkCount
        return count == 1 ? "Showing 1 hunk" : "Showing \(count) hunks"
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        FileDiffView(
            pullRequestID: AppStore.samplePullRequests[0].id,
            filePath: AppStore.samplePullRequests[0].files[0].path
        )
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
