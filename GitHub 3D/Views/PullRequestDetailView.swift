//
//  PullRequestDetailView.swift
//  GitHub 3D
//
//  A pull request: branches, description, changed files and review actions.
//

import SwiftUI
import UIKit

struct PullRequestDetailView: View {
    @EnvironmentObject private var store: AppStore

    var pullRequestID: UUID
    var onOpenFile: (String) -> Void = { _ in }
    var onBack: () -> Void = {}

    @State private var didCopyLink = false
    @State private var reviewPath: String?
    @State private var reviewLine = "1"
    @State private var reviewDraft = ""
    @State private var formalReviewDecision: PRReviewDecision = .comment
    @State private var formalReviewDraft = ""

    private var request: PullRequestItem? {
        store.pullRequests.first(where: { $0.id == pullRequestID })
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 10)

            if let request {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        titleBlock(request)
                        branchPill(request)
                        descriptionCard(request)
                        filesSection(request)
                        commitsSection(request)
                        reviewsSection(request)
                        formalReviewSection(request)
                        actions(request)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 120)
                }
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

            Text("Pull request")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                guard let request else { return }
                copyPullRequestLink(request)
            } label: {
                Image(systemName: didCopyLink ? "checkmark" : "link")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(didCopyLink ? Palette.accentBright : .white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.white.opacity(0.10)))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.20), lineWidth: 1))
            }
            .accessibilityLabel(didCopyLink ? "Link copied" : "Copy link")
            .buttonStyle(PressableStyle(scale: 0.9))
        }
    }

    // MARK: Title

    private func titleBlock(_ request: PullRequestItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("#\(request.number)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Palette.accentBright)

            Text(request.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.pull")
                        .font(.system(size: 12, weight: .semibold))
                    Text(stateWord(request))
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Color(hex: 0x3FB950))
                .padding(.horizontal, 14)
                .frame(height: 34)
                .background(Capsule().fill(Color(hex: 0x3FB950).opacity(0.18)))
                .overlay(Capsule().strokeBorder(Color(hex: 0x3FB950).opacity(0.4), lineWidth: 1))

                Rectangle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 1, height: 22)

                AvatarView(initials: initials(for: request.author), size: 26)

                Text("\(Text(request.author).bold()) wants to merge")
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.inkMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 0)
            }

            Text("opened \(request.time)")
                .font(.system(size: 13))
                .foregroundStyle(Palette.inkFaint)
        }
    }

    // MARK: Branch

    private func branchPill(_ request: PullRequestItem) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Palette.inkMuted)

            Text("\(request.baseBranch) ← \(request.headBranch)")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 6)

            Button {
                Haptics.tap()
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Palette.inkMuted)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    // MARK: Description

    private func descriptionCard(_ request: PullRequestItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(request.body.components(separatedBy: "\n\n").enumerated()), id: \.offset) { _, paragraph in
                Text(paragraph)
                    .font(.system(size: 15))
                    .foregroundStyle(Palette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassCard()
    }

    // MARK: Files

    private func filesSection(_ request: PullRequestItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Files changed · \(request.files.count)")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            VStack(spacing: 8) {
                ForEach(request.files) { file in
                    fileRow(file)
                }
            }
        }
    }

    private func fileRow(_ file: PRFile) -> some View {
        Button {
            Haptics.tap()
            onOpenFile(file.path)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: file.isMarkdown ? "doc.text" : "swift")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )

                Text(file.path)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 4)

                Text("+\(file.additions)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x3FB950))

                Text("-\(file.deletions)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: 0xFF6B6B))

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(hex: 0x32288C).opacity(0.85))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
    }

    // MARK: Commits

    private func commitsSection(_ request: PullRequestItem) -> some View {
        let commits = request.commits

        return VStack(alignment: .leading, spacing: 12) {
            Text("Commits · \(commits.count)")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            VStack(spacing: 10) {
                ForEach(commits) { commit in
                    commitCard(commit)
                }
            }
        }
    }

    private func commitCard(_ commit: PRCommit) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                AvatarView(initials: initials(for: commit.author), size: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(commit.author)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("committed \(commit.relativeTime)")
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.inkFaint)
                }

                Spacer(minLength: 6)
            }

            Text(commit.message)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Palette.ink)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Text(commit.shortSHA)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Palette.inkMuted)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.white.opacity(0.08)))
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

                Image(systemName: "doc.text")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Palette.inkFaint)

                Text("\(commit.changedFileCount) \(commit.changedFileCount == 1 ? "file" : "files") changed")
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundStyle(Palette.inkMuted)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(radius: 22)
    }

    // MARK: Reviews

    private func reviewsSection(_ request: PullRequestItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Inline comments · \(request.reviewComments.count)")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            if request.reviewComments.isEmpty {
                Text("No inline review comments yet. Leave the first one below.")
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.inkFaint)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 22)
                    .glassCard()
            } else {
                ForEach(request.reviewComments) { comment in
                    reviewCard(comment, request: request)
                }
            }

            reviewComposer(request)
        }
    }

    private func reviewCard(_ comment: PRReviewComment, request: PullRequestItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 7) {
                Image(systemName: "doc.text")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Palette.accentBright)

                Text("\(comment.path) · line \(comment.line)")
                    .font(.system(size: 12.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.accentBright)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            HStack(spacing: 10) {
                AvatarView(initials: initials(for: comment.reviewer), size: 36)

                VStack(alignment: .leading, spacing: 1) {
                    Text(comment.reviewer)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(comment.time)
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.inkFaint)
                }

                Spacer(minLength: 6)
            }

            Text(comment.body)
                .font(.system(size: 15))
                .foregroundStyle(Palette.ink)
                .fixedSize(horizontal: false, vertical: true)

            ReactionRow(reactions: comment.reactions) { kind in
                store.toggleReviewReaction(kind, commentID: comment.id, requestID: request.id)
            }
            .padding(.top, 2)
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
    }

    private func reviewComposer(_ request: PullRequestItem) -> some View {
        let path = currentReviewPath(request)
        let canPost = !reviewDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !path.isEmpty

        return VStack(alignment: .leading, spacing: 10) {
            Text("Add a review comment")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)

            Menu {
                ForEach(request.files) { file in
                    Button {
                        Haptics.select()
                        reviewPath = file.path
                    } label: {
                        if file.path == path {
                            Label(file.path, systemImage: "checkmark")
                        } else {
                            Text(file.path)
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Palette.inkMuted)

                    Text(path.isEmpty ? "No files changed" : path)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer(minLength: 6)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Palette.inkFaint)
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(request.files.isEmpty)

            HStack(spacing: 8) {
                Text("Line")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Palette.inkFaint)

                TextField("1", text: $reviewLine)
                    .keyboardType(.numberPad)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white)
                    .tint(Palette.accentBright)
                    .multilineTextAlignment(.center)
                    .frame(width: 62, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )

                Spacer(minLength: 0)
            }

            TextField("Leave a review comment…", text: $reviewDraft, axis: .vertical)
                .lineLimit(2...5)
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .tint(Palette.accentBright)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(minHeight: 64, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                )

            Button {
                postReview(on: request)
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Post comment")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
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
                .shadow(color: Palette.accent.opacity(0.40), radius: 14, x: 0, y: 8)
            }
            .buttonStyle(PressableStyle())
            .disabled(!canPost)
            .opacity(canPost ? 1 : 0.55)
        }
        .padding(14)
        .glassCard()
    }

    private func currentReviewPath(_ request: PullRequestItem) -> String {
        if let reviewPath, request.files.contains(where: { $0.path == reviewPath }) {
            return reviewPath
        }
        return request.files.first?.path ?? ""
    }

    private func postReview(on request: PullRequestItem) {
        let line = Int(reviewLine.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 1
        Haptics.tap()
        withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
            store.addReviewComment(
                reviewDraft,
                path: currentReviewPath(request),
                line: line,
                to: request.id
            )
            reviewDraft = ""
            reviewLine = "1"
        }
    }

    // MARK: Formal review

    private func formalReviewSection(_ request: PullRequestItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Formal review")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Latest review status")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Palette.inkMuted)

                    Spacer()

                    if let latestReview = request.latestReviewEvent {
                        reviewDecisionBadge(latestReview.decision)
                    } else {
                        Text("No review yet")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Palette.inkFaint)
                    }
                }

                if let latestReview = request.latestReviewEvent {
                    Text("Submitted by \(latestReview.reviewer) · \(latestReview.time)")
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.inkFaint)
                } else {
                    Text("Choose a review outcome and add a summary below.")
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.inkFaint)
                }
            }
            .padding(14)
            .glassCard(radius: 20)

            if !request.reviewEvents.isEmpty {
                Text("Review history · \(request.reviewEvents.count)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 2)

                ForEach(Array(request.reviewEvents.reversed())) { event in
                    formalReviewCard(event)
                }
            }

            formalReviewComposer(request)
        }
    }

    private func formalReviewCard(_ event: PRReviewEvent) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                AvatarView(initials: initials(for: event.reviewer), size: 34)

                VStack(alignment: .leading, spacing: 2) {
                    Text(event.reviewer)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(event.time)
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.inkFaint)
                }

                Spacer(minLength: 6)

                reviewDecisionBadge(event.decision)
            }

            Text(event.summary)
                .font(.system(size: 15))
                .foregroundStyle(Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(radius: 22)
    }

    private func reviewDecisionBadge(_ decision: PRReviewDecision) -> some View {
        HStack(spacing: 5) {
            Image(systemName: decision.symbol)
                .font(.system(size: 11, weight: .semibold))
            Text(decision.statusTitle)
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(1)
        }
        .foregroundStyle(reviewTint(for: decision))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(reviewTint(for: decision).opacity(0.16)))
        .overlay(Capsule().strokeBorder(reviewTint(for: decision).opacity(0.4), lineWidth: 1))
    }

    private func reviewTint(for decision: PRReviewDecision) -> Color {
        switch decision {
        case .comment: return Palette.accentBright
        case .approve: return Color(hex: 0x3FB950)
        case .requestChanges: return Color(hex: 0xFF9B54)
        }
    }

    private func formalReviewComposer(_ request: PullRequestItem) -> some View {
        let canSubmit = request.isOpen
            && !formalReviewDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        return VStack(alignment: .leading, spacing: 12) {
            Text("Submit a review")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)

            Menu {
                ForEach(PRReviewDecision.allCases) { decision in
                    Button {
                        Haptics.select()
                        formalReviewDecision = decision
                    } label: {
                        Label(decision.rawValue, systemImage: decision.symbol)
                    }
                }
            } label: {
                HStack(spacing: 9) {
                    Image(systemName: formalReviewDecision.symbol)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(reviewTint(for: formalReviewDecision))

                    Text(formalReviewDecision.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Palette.inkFaint)
                }
                .padding(.horizontal, 13)
                .frame(height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!request.isOpen)

            TextField("Write a review summary…", text: $formalReviewDraft, axis: .vertical)
                .lineLimit(3...6)
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .tint(Palette.accentBright)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .frame(minHeight: 82, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                )
                .disabled(!request.isOpen)

            Button {
                submitFormalReview(on: request)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Submit review")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(
                            colors: [Palette.accentBright, Palette.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                )
            }
            .buttonStyle(PressableStyle())
            .disabled(!canSubmit)
            .opacity(canSubmit ? 1 : 0.55)
        }
        .padding(14)
        .glassCard()
    }

    private func submitFormalReview(on request: PullRequestItem) {
        Haptics.tap()
        withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
            store.submitPullRequestReview(
                formalReviewDraft,
                decision: formalReviewDecision,
                to: request.id
            )
            formalReviewDraft = ""
        }
    }

    // MARK: Actions

    private func actions(_ request: PullRequestItem) -> some View {
        let isMerged = !request.isOpen

        return VStack(spacing: 10) {
            HStack(spacing: 12) {
                Button {
                    Haptics.select()
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                        store.approvePullRequest(request.id)
                    }
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: request.isApproved ? "checkmark" : "checkmark.circle")
                            .font(.system(size: 15, weight: .semibold))
                        Text(request.isApproved ? "Approved" : "Approve")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
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
                .disabled(request.isApproved || isMerged)
                .opacity(request.isApproved || isMerged ? 0.55 : 1)

                Button {
                    Haptics.select()
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                        store.mergePullRequest(request.id)
                    }
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "arrow.triangle.merge")
                            .font(.system(size: 15, weight: .semibold))
                        Text(isMerged ? "Merged" : "Merge")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(hex: 0x3FB950).opacity(isMerged ? 0.30 : 0.22))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color(hex: 0x3FB950).opacity(0.50), lineWidth: 1)
                    )
                }
                .buttonStyle(PressableStyle())
                .disabled(isMerged)
                .opacity(isMerged ? 0.65 : 1)
            }

            Button {
                Haptics.tap()
            } label: {
                Text("Request changes")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.12))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    )
            }
            .buttonStyle(PressableStyle())
            .disabled(isMerged)
            .opacity(isMerged ? 0.55 : 1)
        }
        .padding(.top, 4)
    }

    private func stateWord(_ request: PullRequestItem) -> String {
        if !request.isOpen { return "Merged" }
        return request.isApproved ? "Approved" : "Open"
    }

    private func copyPullRequestLink(_ request: PullRequestItem) {
        let handle = store.profile.handle.trimmingCharacters(in: CharacterSet(charactersIn: "@"))
        let repository = request.repository.split(separator: "/").last.map(String.init) ?? request.repository
        UIPasteboard.general.string = "https://github.com/\(handle)/\(repository)/pull/\(request.number)"
        Haptics.tap()

        withAnimation(.easeOut(duration: 0.2)) {
            didCopyLink = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeOut(duration: 0.25)) {
                didCopyLink = false
            }
        }
    }

    private func initials(for name: String) -> String {
        let letters = name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
        return String(letters).uppercased()
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        PullRequestDetailView(pullRequestID: AppStore.samplePullRequests[0].id)
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
