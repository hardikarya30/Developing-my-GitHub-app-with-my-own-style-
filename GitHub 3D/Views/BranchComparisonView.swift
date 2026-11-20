//
//  BranchComparisonView.swift
//  GitHub 3D
//
//  Compare two repository branches and browse their changed files.
//

import SwiftUI

struct BranchComparisonRoute: Identifiable {
    var id = UUID()
    var repository: RepoItem
    var branches: [String]
    var initialBaseBranch: String
}

private struct BranchComparisonResult {
    var ahead: Int
    var behind: Int
    var files: [PRFile]
}

private enum BranchComparisonSamples {
    private static let branchOrder = ["main", "develop", "release/1.4", "feature/liquid-glass"]

    private static let pairs: [String: BranchComparisonResult] = [
        "main|develop": BranchComparisonResult(
            ahead: 4,
            behind: 2,
            files: [
                PRFile(path: "Sources/RepositoryView.swift", additions: 24, deletions: 8),
                PRFile(path: "Tests/RepositoryTests.swift", additions: 12, deletions: 2),
                PRFile(path: "README.md", additions: 4, deletions: 1)
            ]
        ),
        "main|release/1.4": BranchComparisonResult(
            ahead: 2,
            behind: 1,
            files: [
                PRFile(path: "Sources/ReleaseNotes.swift", additions: 18, deletions: 3),
                PRFile(path: "README.md", additions: 6, deletions: 1)
            ]
        ),
        "main|feature/liquid-glass": BranchComparisonResult(
            ahead: 6,
            behind: 2,
            files: [
                PRFile(path: "Sources/GlassCard.swift", additions: 32, deletions: 6),
                PRFile(path: "Sources/Theme.swift", additions: 14, deletions: 3),
                PRFile(path: "Tests/GlassCardTests.swift", additions: 18, deletions: 0)
            ]
        ),
        "develop|release/1.4": BranchComparisonResult(
            ahead: 2,
            behind: 3,
            files: [
                PRFile(path: "Sources/RepositoryView.swift", additions: 14, deletions: 8),
                PRFile(path: "Tests/RepositoryTests.swift", additions: 9, deletions: 3)
            ]
        ),
        "develop|feature/liquid-glass": BranchComparisonResult(
            ahead: 5,
            behind: 1,
            files: [
                PRFile(path: "Sources/GlassCard.swift", additions: 22, deletions: 4),
                PRFile(path: "Sources/GlassTokens.swift", additions: 11, deletions: 2),
                PRFile(path: "Tests/GlassCardTests.swift", additions: 10, deletions: 0)
            ]
        ),
        "release/1.4|feature/liquid-glass": BranchComparisonResult(
            ahead: 3,
            behind: 4,
            files: [
                PRFile(path: "Sources/ReleaseNotes.swift", additions: 8, deletions: 2),
                PRFile(path: "Sources/Theme.swift", additions: 10, deletions: 1)
            ]
        )
    ]

    static func result(base: String, compare: String) -> BranchComparisonResult {
        guard base != compare else {
            return BranchComparisonResult(ahead: 0, behind: 0, files: [])
        }

        let baseRank = branchOrder.firstIndex(of: base) ?? Int.max
        let compareRank = branchOrder.firstIndex(of: compare) ?? Int.max
        let isForward: Bool

        if baseRank == compareRank {
            isForward = base.localizedStandardCompare(compare) == .orderedAscending
        } else {
            isForward = baseRank < compareRank
        }

        let lower = isForward ? base : compare
        let higher = isForward ? compare : base
        let sample = pairs["\(lower)|\(higher)"] ?? BranchComparisonResult(
            ahead: 2,
            behind: 1,
            files: [PRFile(path: "Sources/RepositoryView.swift", additions: 8, deletions: 2)]
        )

        guard !isForward else { return sample }
        return BranchComparisonResult(
            ahead: sample.behind,
            behind: sample.ahead,
            files: sample.files.map {
                PRFile(path: $0.path, additions: $0.deletions, deletions: $0.additions)
            }
        )
    }
}

struct BranchComparisonView: View {
    @EnvironmentObject private var store: AppStore

    var repo: RepoItem
    var branches: [String]
    var initialBaseBranch: String
    var onBack: () -> Void
    var onOpenFile: (PRFile) -> Void
    var onOpenPullRequest: (PullRequestItem) -> Void

    @State private var baseBranch: String
    @State private var compareBranch: String

    init(
        repo: RepoItem,
        branches: [String],
        initialBaseBranch: String,
        onBack: @escaping () -> Void,
        onOpenFile: @escaping (PRFile) -> Void,
        onOpenPullRequest: @escaping (PullRequestItem) -> Void
    ) {
        self.repo = repo
        self.branches = branches
        self.initialBaseBranch = initialBaseBranch
        self.onBack = onBack
        self.onOpenFile = onOpenFile
        self.onOpenPullRequest = onOpenPullRequest
        _baseBranch = State(initialValue: initialBaseBranch)
        _compareBranch = State(
            initialValue: branches.first(where: { $0 != initialBaseBranch }) ?? initialBaseBranch
        )
    }

    private var comparison: BranchComparisonResult {
        BranchComparisonSamples.result(base: baseBranch, compare: compareBranch)
    }

    private var matchingPullRequest: PullRequestItem? {
        store.pullRequests.first {
            $0.repository == repo.name
                && $0.baseBranch == baseBranch
                && $0.headBranch == compareBranch
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 14)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    branchSelectionCard

                    if comparison.files.isEmpty {
                        emptyState
                    } else {
                        summaryCard
                        changedFilesCard
                    }

                    viewPullRequestButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 140)
            }
        }
    }

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
            .accessibilityLabel("Back")

            Spacer()

            Text("Compare branches")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Color.clear
                .frame(width: 46, height: 46)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .glassCard(fill: Color.white.opacity(0.10), radius: 28)
    }

    private var branchSelectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            branchSelector(title: "base", selection: $baseBranch)

            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color.white.opacity(0.14))
                    .frame(height: 1)

                Button {
                    Haptics.select()
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        let previousBase = baseBranch
                        baseBranch = compareBranch
                        compareBranch = previousBase
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 58, height: 58)
                        .background(
                            Circle().fill(
                                LinearGradient(
                                    colors: [Palette.accentBright.opacity(0.82), Palette.accent.opacity(0.70)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        )
                        .overlay(Circle().strokeBorder(Color.white.opacity(0.18), lineWidth: 1))
                        .shadow(color: Palette.accentBright.opacity(0.34), radius: 16, y: 6)
                }
                .buttonStyle(PressableStyle(scale: 0.92))
                .accessibilityLabel("Swap branches")

                Rectangle()
                    .fill(Color.white.opacity(0.14))
                    .frame(height: 1)
            }
            .padding(.vertical, 1)

            branchSelector(title: "compare", selection: $compareBranch)
        }
        .padding(16)
        .glassCard(fill: Color.white.opacity(0.10), radius: 26)
    }

    private func branchSelector(title: String, selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .padding(.leading, 2)

            Menu {
                ForEach(branches, id: \.self) { branch in
                    Button {
                        Haptics.select()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            selection.wrappedValue = branch
                        }
                    } label: {
                        if branch == selection.wrappedValue {
                            Label(branch, systemImage: "checkmark")
                        } else {
                            Text(branch)
                        }
                    }
                }
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 54, height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(Color.white.opacity(0.13))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                        )

                    Text(selection.wrappedValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Palette.inkMuted)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 68)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.07))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(PressableStyle(scale: 0.99))
        }
    }

    private var summaryCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(Palette.accentBright)
                .frame(width: 70, height: 70)
                .background(Circle().fill(Color.white.opacity(0.09)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

            VStack(alignment: .leading, spacing: 8) {
                summaryMessage
                    .font(.system(size: 18, weight: .semibold))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)

                Text("Last updated 12 minutes ago")
                    .font(.system(size: 13.5))
                    .foregroundStyle(Palette.inkMuted)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    private var summaryMessage: Text {
        Text("\(compareBranch) is ")
            + Text("\(comparison.ahead) commits ahead").foregroundColor(Color(hex: 0x55D98A))
            + Text(" and ")
            + Text("\(comparison.behind) commits behind").foregroundColor(Palette.accentBright)
            + Text(" \(baseBranch)")
    }

    private var changedFilesCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(comparison.files.count) changed files")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .padding(.bottom, 4)

            ForEach(Array(comparison.files.enumerated()), id: \.element.path) { index, file in
                changedFileRow(file)

                if index < comparison.files.count - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(0.10))
                        .frame(height: 1)
                        .padding(.leading, 56)
                }
            }
        }
        .padding(14)
        .glassCard()
    }

    private func changedFileRow(_ file: PRFile) -> some View {
        Button {
            Haptics.tap()
            onOpenFile(file)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: fileSymbol(for: file))
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .fill(Color.white.opacity(0.13))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(file.path)
                        .font(.system(size: 14.5, weight: .medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Text(folderName(for: file.path))
                        .font(.system(size: 12.5))
                        .foregroundStyle(Palette.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 10) {
                    Text("+\(file.additions)")
                        .foregroundStyle(Color(hex: 0x55D98A))
                    Text("−\(file.deletions)")
                        .foregroundStyle(Color(hex: 0xFF6685))
                }
                .font(.system(size: 14, weight: .semibold))
                .fixedSize()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Palette.inkMuted)
            }
            .padding(.vertical, 7)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(Palette.accentBright)
                .frame(width: 62, height: 62)
                .background(Circle().fill(Color.white.opacity(0.09)))

            Text("No differences found")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)

            Text("Choose a different branch pair to see changed files.")
                .font(.system(size: 14))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 18)
        .glassCard()
    }

    private var viewPullRequestButton: some View {
        Button {
            guard let matchingPullRequest else { return }
            Haptics.tap()
            onOpenPullRequest(matchingPullRequest)
        } label: {
            Text("View pull request")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Palette.gradientStart, Color(hex: 0x4338F5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: Palette.gradientStart.opacity(0.38), radius: 15, y: 7)
        }
        .buttonStyle(PressableStyle())
        .disabled(matchingPullRequest == nil)
        .opacity(matchingPullRequest == nil ? 0.78 : 1)
    }

    private func fileSymbol(for file: PRFile) -> String {
        file.path.lowercased().hasSuffix(".swift") && !file.path.lowercased().contains("test")
            ? "chevron.left.forwardslash.chevron.right"
            : "doc.text"
    }

    private func folderName(for path: String) -> String {
        let folder = path.split(separator: "/").dropLast().joined(separator: "/")
        return folder.isEmpty ? "Root" : folder
    }
}
