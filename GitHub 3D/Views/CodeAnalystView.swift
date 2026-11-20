//
//  CodeAnalystView.swift
//  GitHub 3D
//
//  The code analysis dashboard: progress ring, AI generator and the
//  Swift / SwiftUI snippet generator.
//

import SwiftUI
import UIKit

enum CodeLanguage: String, CaseIterable, Identifiable {
    case swift = "Swift"
    case swiftUI = "SwiftUI"

    var id: String { rawValue }

    var sample: String {
        switch self {
        case .swift:
            return """
            import Foundation

            struct Calculator {
                func add(_ a: Int, _ b: Int) -> Int {
                    return a + b
                }
            }
            """
        case .swiftUI:
            return """
            import SwiftUI

            struct ContentView: View {
                var body: some View {
                    Text("Hello, world!")
                }
            }
            """
        }
    }
}

struct CodeAnalystView: View {
    var onBack: () -> Void = {}

    @State private var language: CodeLanguage = .swift
    @State private var generatedCode: String?
    @State private var prompt = ""
    @State private var gptPrompt = ""
    @State private var copied = false

    private var snippet: String { language.sample }

    private var snippetLines: [String] {
        snippet.components(separatedBy: "\n")
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 14)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    progressCard
                    generatorCard
                    gptCard
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

            Text("Code Analyst")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            circleButton(symbol: "line.3.horizontal.decrease") {
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

    // MARK: Progress

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Code progress")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

                Text("Overall code health and quality across your repositories.")
                    .font(.system(size: 15))
                    .foregroundStyle(Palette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ZStack {
                CodeProgressRing(progress: 0.76)

                VStack(spacing: 2) {
                    Text("76%")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Code quality score")
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkMuted)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)

            HStack(spacing: 0) {
                statBlock(value: "12.4k", label: "Lines")
                statDivider
                statBlock(value: "98%", label: "Coverage")
                statDivider
                statBlock(value: "4", label: "Open issues")
            }
        }
        .padding(18)
        .glassCard()
    }

    private func statBlock(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(Palette.inkFaint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.14))
            .frame(width: 1, height: 34)
    }

    // MARK: Code generator

    private var generatorCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("Code Generator")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

                Text("AI")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Palette.accent))
            }

            Text("Generate code from a prompt.")
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)

            TextField("Describe what you want to build…", text: $prompt, axis: .vertical)
                .lineLimit(1...4)
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .tint(Palette.accentBright)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.07))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )

            Button {
                Haptics.tap()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    generatedCode = generatedSnippet(for: prompt)
                }
            } label: {
                Text("Generate")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Palette.accentBright, Palette.accent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: Palette.accent.opacity(0.45), radius: 16, x: 0, y: 8)
            }
            .buttonStyle(PressableStyle())

            if let generatedCode {
                CodeBlockView(code: generatedCode)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(18)
        .glassCard()
    }

    private func generatedSnippet(for prompt: String) -> String {
        let subject = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = subject.isEmpty ? "Feature" : subject.capitalized
        return """
        import SwiftUI

        struct \(title.replacingOccurrences(of: " ", with: ""))View: View {
            @State private var isReady = false

            var body: some View {
                VStack(spacing: 16) {
                    Text("\(subject.isEmpty ? "Generated with Copilot" : subject)")
                        .font(.headline)
                    Button("Continue") {
                        isReady.toggle()
                    }
                }
                .padding()
            }
        }
        """
    }

    // MARK: ChatGPT generator

    private var gptCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Google ChatGPT generator")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(.white)

                Text("For Swift and SwiftUI code.")
                    .font(.system(size: 15))
                    .foregroundStyle(Palette.inkMuted)
            }

            HStack(spacing: 10) {
                ForEach(CodeLanguage.allCases) { item in
                    Button {
                        Haptics.select()
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                            language = item
                            copied = false
                        }
                    } label: {
                        Text(item.rawValue)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(language == item ? Color.white : Palette.inkMuted)
                            .padding(.horizontal, 22)
                            .frame(height: 40)
                            .background {
                                if language == item {
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [Palette.accentBright, Palette.accent],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .overlay(Capsule().strokeBorder(.white.opacity(0.25), lineWidth: 1))
                                } else {
                                    Capsule()
                                        .fill(Color.white.opacity(0.08))
                                        .overlay(Capsule().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))
                                }
                            }
                    }
                    .buttonStyle(PressableStyle(scale: 0.96))
                }
            }

            TextField(
                language == .swift ? "Enter a detailed prompt for Swift code…" : "Enter a detailed prompt for SwiftUI code…",
                text: $gptPrompt,
                axis: .vertical
            )
            .lineLimit(1...4)
            .font(.system(size: 15))
            .foregroundStyle(.white)
            .tint(Palette.accentBright)
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.07))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )

            CodeBlockView(code: snippet, showsLineNumbers: true)

            Button {
                UIPasteboard.general.string = snippet
                Haptics.tap()
                withAnimation(.easeOut(duration: 0.2)) {
                    copied = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        copied = false
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 15, weight: .semibold))
                    Text(copied ? "Copied" : "Copy code")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Palette.accent.opacity(copied ? 0.5 : 0.28))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Palette.accentBright.opacity(0.35), lineWidth: 1)
                )
            }
            .buttonStyle(PressableStyle())
        }
        .padding(18)
        .glassCard()
    }
}

// MARK: - Progress ring

struct CodeProgressRing: View {
    var progress: Double

    @State private var animated: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 16)

            Circle()
                .trim(from: 0, to: animated)
                .stroke(
                    AngularGradient(
                        colors: [
                            Palette.accentBright,
                            Color(hex: 0xB98CFF),
                            Color(hex: 0x7C5CFF),
                            Palette.accentBright
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: Palette.accentBright.opacity(0.55), radius: 14)
                .animation(.easeOut(duration: 1.2), value: animated)
        }
        .frame(width: 196, height: 196)
        .onAppear {
            animated = progress
        }
    }
}

// MARK: - Code block

struct CodeBlockView: View {
    var code: String
    var showsLineNumbers: Bool = false

    private let keywords: Set<String> = [
        "import", "struct", "class", "var", "let", "func", "return",
        "enum", "extension", "if", "else", "for", "in", "some", "init",
        "private", "public", "static", "true", "false"
    ]

    private var lines: [String] {
        code.components(separatedBy: "\n")
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if showsLineNumbers {
                VStack(alignment: .trailing, spacing: 4) {
                    ForEach(lines.indices, id: \.self) { index in
                        Text("\(index + 1)")
                            .font(.system(size: 13, weight: .regular, design: .monospaced))
                            .foregroundStyle(Palette.inkFaint.opacity(0.7))
                    }
                }
                .frame(width: 22, alignment: .trailing)
            }

            VStack(alignment: .leading, spacing: 4) {
                ForEach(lines.indices, id: \.self) { index in
                    highlighted(lines[index])
                        .font(.system(size: 13.5, weight: .regular, design: .monospaced))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(hex: 0x121831))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func highlighted(_ line: String) -> Text {
        let tokens = line.components(separatedBy: " ")
        var result = Text("")

        for (index, token) in tokens.enumerated() {
            if index > 0 {
                result = result + Text(" ")
            }

            if keywords.contains(token) {
                result = result + Text(token).foregroundColor(Color(hex: 0xB48CFF))
            } else if token.hasPrefix("\"") {
                result = result + Text(token).foregroundColor(Color(hex: 0x7BD88F))
            } else {
                result = result + Text(token)
            }
        }

        return result
            .foregroundColor(Color(hex: 0xE6E1FF))
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        CodeAnalystView()
    }
    .preferredColorScheme(.dark)
}
