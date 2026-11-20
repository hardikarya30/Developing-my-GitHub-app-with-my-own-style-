//
//  ReadmeEditorView.swift
//  GitHub 3D
//
//  A markdown editor for a repository README, with a live preview.
//

import SwiftUI

// MARK: - Markdown blocks

enum MarkdownBlock: Identifiable {
    case heading(String, level: Int)
    case paragraph(String)
    case code(String)

    var id: String {
        switch self {
        case .heading(let text, let level): return "h\(level)-\(text)"
        case .paragraph(let text): return "p-\(text)"
        case .code(let code): return "c-\(code)"
        }
    }
}

enum MarkdownParser {
    static func blocks(from markdown: String) -> [MarkdownBlock] {
        var blocks: [MarkdownBlock] = []
        var paragraph = ""
        var codeLines: [String]? = nil

        func flushParagraph() {
            guard !paragraph.isEmpty else { return }
            blocks.append(.paragraph(paragraph))
            paragraph = ""
        }

        for line in markdown.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("```") {
                if let code = codeLines {
                    if !code.isEmpty {
                        blocks.append(.code(code.joined(separator: "\n")))
                    }
                    codeLines = nil
                } else {
                    flushParagraph()
                    codeLines = []
                }
                continue
            }

            if codeLines != nil {
                codeLines?.append(line)
                continue
            }

            if trimmed.isEmpty {
                flushParagraph()
                continue
            }

            if trimmed.hasPrefix("### ") {
                flushParagraph()
                blocks.append(.heading(String(trimmed.dropFirst(4)), level: 3))
            } else if trimmed.hasPrefix("## ") {
                flushParagraph()
                blocks.append(.heading(String(trimmed.dropFirst(3)), level: 2))
            } else if trimmed.hasPrefix("# ") {
                flushParagraph()
                blocks.append(.heading(String(trimmed.dropFirst(2)), level: 1))
            } else {
                paragraph = paragraph.isEmpty ? trimmed : paragraph + " " + trimmed
            }
        }

        flushParagraph()

        if let code = codeLines, !code.isEmpty {
            blocks.append(.code(code.joined(separator: "\n")))
        }

        return blocks
    }
}

// MARK: - Renderer

struct MarkdownPreview: View {
    var markdown: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(MarkdownParser.blocks(from: markdown)) { block in
                switch block {
                case .heading(let text, let level):
                    Text(text)
                        .font(.system(size: level == 1 ? 26 : (level == 2 ? 22 : 18), weight: .bold))
                        .foregroundStyle(CopilotPalette.ink)
                case .paragraph(let text):
                    Text(text)
                        .font(.system(size: 16))
                        .foregroundStyle(CopilotPalette.ink.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                case .code(let code):
                    Text(code)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundStyle(CopilotPalette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(CopilotPalette.violet.opacity(0.08))
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
        )
    }
}

enum ReadmeTemplate: String, CaseIterable {
    case app
    case library
    case cli
    case portfolio

    var title: String {
        switch self {
        case .app: return "App"
        case .library: return "Library"
        case .cli: return "CLI"
        case .portfolio: return "Portfolio"
        }
    }

    var symbol: String {
        switch self {
        case .app: return "app.badge"
        case .library: return "books.vertical"
        case .cli: return "terminal"
        case .portfolio: return "person.crop.square"
        }
    }

    var markdown: String {
        switch self {
        case .app:
            return """
            # App Name

            A short sentence on what the app does and who it is for.

            ## Features

            - Feature one
            - Feature two
            - Works offline

            ## Install

            ```swift
            import SwiftUI
            ```

            ## Usage

            Open the app and tap the first card to get started.

            ## License

            MIT
            """
        case .library:
            return """
            # Library

            A small, focused Swift package that does one thing well.

            ## Installation

            Add the package to your project with Swift Package Manager.

            ```swift
            import Library
            ```

            ## Usage

            ```swift
            let result = Library.run()
            ```

            ## Requirements

            - iOS 17 or later
            - Swift 5.9

            ## License

            MIT
            """
        case .cli:
            return """
            # cli-tool

            A command line tool for everyday tasks.

            ## Install

            ```bash
            brew install cli-tool
            ```

            ## Usage

            ```bash
            cli-tool --help
            ```

            ## Options

            - `--verbose` prints each step
            - `--output` writes to a file

            ## License

            MIT
            """
        case .portfolio:
            return """
            # Hi, I'm someone 👋

            I build small, thoughtful apps for Apple platforms.

            ## What I'm working on

            - A liquid glass component kit
            - A Pong game in pure SwiftUI

            ## Tools I use

            `Swift` · `SwiftUI` · `Xcode`

            ## Get in touch

            Open an issue on any repository or say hello in Discussions.
            """
        }
    }
}

// MARK: - Editor

struct ReadmeEditorView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var repositoryName: String

    @State private var markdown = ""
    @State private var mode: Mode = .markdown
    @State private var originalMarkdown = ""
    @State private var pendingTemplate: ReadmeTemplate?
    @State private var showReplaceAlert = false

    private enum Mode: String, CaseIterable {
        case markdown = "Markdown"
        case preview = "Preview"
    }

    private var lines: [String] {
        markdown.components(separatedBy: "\n")
    }

    var body: some View {
        VStack(spacing: 14) {
            header

            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(Mode.allCases, id: \.self) { item in
                        Button {
                            Haptics.select()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                mode = item
                            }
                        } label: {
                            Text(item.rawValue)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(mode == item ? Color.white : Palette.inkMuted)
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                                .background {
                                    if mode == item {
                                        Capsule().fill(
                                            LinearGradient(
                                                colors: [Palette.accentBright, Palette.accent],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
                .background(Capsule().fill(Color.white.opacity(0.08)))

                Menu {
                    ForEach(ReadmeTemplate.allCases, id: \.self) { template in
                        Button {
                            Haptics.select()
                            requestTemplate(template)
                        } label: {
                            Label(template.title, systemImage: template.symbol)
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Templates")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(Palette.accentBright)
                    .padding(.horizontal, 12)
                    .frame(height: 46)
                    .background(Capsule().fill(Color.white.opacity(0.08)))
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.16), lineWidth: 1))
                }
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    if mode == .markdown {
                        editor
                    } else {
                        MarkdownPreview(markdown: markdown)
                    }
                }
                .padding(.bottom, 20)
            }

            if mode == .markdown {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preview")
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkFaint)
                    MarkdownPreview(markdown: markdown)
                }
            }

            GradientActionButton(title: "Save README") {
                Haptics.tap()
                store.setReadme(markdown, for: repositoryName)
                dismiss()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 6)
        .background(AppBackdrop())
        .preferredColorScheme(.dark)
        .onAppear {
            markdown = store.readme(for: repositoryName)
            originalMarkdown = markdown
        }
        .alert("Replace your README?", isPresented: $showReplaceAlert) {
            Button("Cancel", role: .cancel) {
                pendingTemplate = nil
            }
            Button("Replace", role: .destructive) {
                if let template = pendingTemplate {
                    markdown = template.markdown
                    pendingTemplate = nil
                }
            }
        } message: {
            Text("Choosing a template will replace the text you have written since opening the editor.")
        }
    }

    private func requestTemplate(_ template: ReadmeTemplate) {
        if markdown != originalMarkdown {
            pendingTemplate = template
            showReplaceAlert = true
        } else {
            withAnimation(.easeOut(duration: 0.2)) {
                markdown = template.markdown
            }
        }
    }

    private var header: some View {
        HStack {
            Button {
                Haptics.tap()
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Edit README")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                Haptics.tap()
                store.setReadme(markdown, for: repositoryName)
                dismiss()
            } label: {
                Text("Save")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Palette.accentBright)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
        .glassCard(fill: Color.white.opacity(0.10), radius: 24)
    }

    private var editor: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .trailing, spacing: 4) {
                ForEach(Array(lines.enumerated()), id: \.offset) { index, _ in
                    Text("\(index + 1)")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(Palette.inkFaint.opacity(0.7))
                }
            }
            .frame(width: 22, alignment: .trailing)

            TextEditor(text: $markdown)
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(.white)
                .tint(Palette.accentBright)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 280)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(hex: 0x1B1550).opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

#Preview {
    ReadmeEditorView(repositoryName: "swiftui-lab")
        .environmentObject(AppStore())
}
