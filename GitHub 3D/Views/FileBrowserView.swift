//
//  FileBrowserView.swift
//  GitHub 3D
//
//  Browse a folder of a repository and read a file's code.
//

import SwiftUI
import UIKit

struct FileBrowserView: View {
    @Environment(\.dismiss) private var dismiss

    var repositoryName: String
    var folder: String
    var branch: String = "main"

    @State private var path: [String] = []
    @State private var openFile: RepoFile?
    @State private var isSearching = false
    @State private var searchText = ""

    private var breadcrumb: String {
        ([repositoryName, branch, folder] + path).joined(separator: " / ")
    }

    private var files: [RepoFile] {
        FileBrowserView.files(for: folder, path: path)
    }

    private var trimmedSearch: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var visibleFiles: [RepoFile] {
        guard isSearching, !trimmedSearch.isEmpty else { return files }
        return files.filter { $0.name.localizedCaseInsensitiveContains(trimmedSearch) }
    }

    private var showsNoMatches: Bool {
        isSearching && !trimmedSearch.isEmpty && visibleFiles.isEmpty
    }

    private var currentFolder: String {
        path.last ?? folder
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 10)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    Button {
                        if !path.isEmpty {
                            Haptics.select()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                path.removeLast()
                            }
                        }
                    } label: {
                        Text(breadcrumb)
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundStyle(Palette.inkFaint)
                            .lineLimit(1)
                            .truncationMode(.head)
                    }
                    .buttonStyle(.plain)
                    .disabled(path.isEmpty)

                    if isSearching {
                        searchField
                    }

                    if showsNoMatches {
                        noMatches
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(visibleFiles.enumerated()), id: \.element.id) { index, file in
                                fileRow(file)

                                if index < visibleFiles.count - 1 {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.08))
                                        .frame(height: 1)
                                        .padding(.leading, 72)
                                }
                            }
                        }
                        .glassCard()
                    }

                    Text("\(visibleFiles.filter { !$0.isFolder }.count) files · \(lineCount) lines")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundStyle(Palette.inkFaint)

                    Button {
                        Haptics.tap()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.down.to.line")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Download folder")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.10))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PressableStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(AppBackdrop())
        .preferredColorScheme(.dark)
        .sheet(item: $openFile) { file in
            FileCodeView(file: file)
                .presentationDetents([.large])
                .presentationCornerRadius(32)
                .presentationDragIndicator(.visible)
        }
    }

    private var lineCount: Int {
        visibleFiles.reduce(0) { total, file in
            file.isFolder ? total : total + file.code.components(separatedBy: "\n").count
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Palette.inkMuted)

            TextField("Search this folder", text: $searchText)
                .font(.system(size: 15, design: .monospaced))
                .foregroundStyle(.white)
                .tint(Palette.accentBright)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    Haptics.select()
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Palette.inkFaint)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
        )
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var noMatches: some View {
        VStack(spacing: 8) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .frame(width: 64, height: 64)
                .background(Circle().fill(Color.white.opacity(0.08)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

            Text("No files here match \"\(trimmedSearch)\"")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Try a different name.")
                .font(.system(size: 14))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .glassCard()
    }

    private var header: some View {
        HStack {
            Button {
                Haptics.tap()
                dismiss()
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

            Text(currentFolder)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer()

            Button {
                Haptics.tap()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    isSearching.toggle()
                    if !isSearching {
                        searchText = ""
                    }
                }
            } label: {
                Image(systemName: isSearching ? "xmark" : "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
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

    private func fileRow(_ file: RepoFile) -> some View {
        Button {
            Haptics.tap()
            if file.isFolder {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    path.append(file.name)
                }
            } else {
                openFile = file
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: file.isFolder ? "folder" : "chevron.left.forwardslash.chevron.right")
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

                Text(file.name)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 6)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(file.isFolder ? "—" : file.size)
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.inkFaint)
                    Text("Changed \(file.changed)")
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.inkFaint)
                }

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

    // MARK: Sample contents

    static func files(for folder: String, path: [String]) -> [RepoFile] {
        if let current = path.last {
            if current == "Models" {
                return [
                    RepoFile(
                        name: "Repo.swift",
                        size: "1.8KB",
                        changed: "2h ago",
                        isFolder: false,
                        code: """
                        import Foundation

                        struct Repo: Identifiable {
                            var id = UUID()
                            var name: String
                            var stars: Int
                        }
                        """
                    ),
                    RepoFile(
                        name: "User.swift",
                        size: "1.2KB",
                        changed: "3h ago",
                        isFolder: false,
                        code: """
                        import Foundation

                        struct User: Identifiable {
                            var id = UUID()
                            var name: String
                            var handle: String
                        }
                        """
                    )
                ]
            }
            return []
        }

        switch folder {
        case "Sources":
            return [
                RepoFile(
                    name: "GlassCard.swift",
                    size: "4.2KB",
                    changed: "2h ago",
                    isFolder: false,
                    code: """
                    import SwiftUI

                    struct GlassCard<Content: View>: View {
                        @ViewBuilder var content: Content

                        var body: some View {
                            content
                                .padding(16)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                        }
                    }
                    """
                ),
                RepoFile(
                    name: "PressButton.swift",
                    size: "3.1KB",
                    changed: "2h ago",
                    isFolder: false,
                    code: """
                    import SwiftUI

                    struct PressButton: View {
                        var body: some View {
                            Button("Press") {}
                                .buttonStyle(PressableStyle())
                        }
                    }
                    """
                ),
                RepoFile(name: "Models", size: "—", changed: "2h ago", isFolder: true),
                RepoFile(
                    name: "Theme.swift",
                    size: "5.6KB",
                    changed: "2h ago",
                    isFolder: false,
                    code: """
                    import SwiftUI

                    enum Palette {
                        static let canvas = Color(hex: 0x3B35AF)
                        static let surface = Color(hex: 0x32288C)
                    }
                    """
                )
            ]
        case "Tests":
            return [
                RepoFile(
                    name: "GlassCardTests.swift",
                    size: "2.4KB",
                    changed: "1d ago",
                    isFolder: false,
                    code: """
                    import XCTest

                    final class GlassCardTests: XCTestCase {
                        func testRenders() {
                            XCTAssertTrue(true)
                        }
                    }
                    """
                ),
                RepoFile(
                    name: "ThemeTests.swift",
                    size: "1.1KB",
                    changed: "1d ago",
                    isFolder: false,
                    code: """
                    import XCTest

                    final class ThemeTests: XCTestCase {
                        func testPalette() {
                            XCTAssertEqual(1, 1)
                        }
                    }
                    """
                )
            ]
        default:
            return [
                RepoFile(
                    name: "README.md",
                    size: "1.4KB",
                    changed: "2d ago",
                    isFolder: false,
                    language: "Markdown",
                    code: """
                    # Liquid Glass Kit

                    A collection of beautiful, reusable SwiftUI components.

                    ## Quick start

                    ```swift
                    import SwiftUI
                    ```
                    """
                )
            ]
        }
    }
}

// MARK: - File code view

struct FileCodeView: View {
    @Environment(\.dismiss) private var dismiss

    var file: RepoFile

    @State private var didCopy = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(file.name)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                    Text("\(file.language) · \(file.size) · Changed \(file.changed)")
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.inkFaint)
                }

                Spacer()

                Button {
                    UIPasteboard.general.string = file.code
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
                    HStack(spacing: 6) {
                        Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 13, weight: .semibold))
                        Text(didCopy ? "Copied" : "Copy")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Palette.accentBright)
                    .padding(.horizontal, 12)
                    .frame(height: 34)
                    .background(Capsule().fill(Color.white.opacity(0.10)))
                }
                .buttonStyle(.plain)

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
                CodeBlockView(code: file.code, showsLineNumbers: true)
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
    FileBrowserView(repositoryName: "swiftui-lab", folder: "Sources")
}
