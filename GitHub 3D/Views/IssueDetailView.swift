//
//  IssueDetailView.swift
//  GitHub 3D
//
//  An issue thread: description, comments, a composer and close / reopen.
//

import SwiftUI
import UIKit

struct IssueDetailView: View {
    @EnvironmentObject private var store: AppStore

    var issueID: UUID
    var onBack: () -> Void = {}

    @State private var draft = ""
    @State private var didCopy = false
    @State private var didCopyLink = false
    @State private var showLabelEditor = false
    @State private var showAssigneePicker = false

    private var issue: IssueItem? {
        store.issues.first(where: { $0.id == issueID })
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            if let issue {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        titleBlock(issue)
                        descriptionCard(issue)
                        activitySection(issue)
                        commentsSection(issue)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                }

                composer(issue)
            }
        }
        .sheet(isPresented: $showLabelEditor) {
            if let issue {
                IssueLabelsSheet(issueID: issue.id)
                    .presentationDetents([.medium])
                    .presentationCornerRadius(32)
                    .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $showAssigneePicker) {
            if let issue {
                IssueAssigneesSheet(issueID: issue.id)
                    .presentationDetents([.medium])
                    .presentationCornerRadius(32)
                    .presentationDragIndicator(.visible)
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

            Text("Issue")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                guard let issue else { return }
                copyIssueLink(issue)
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
        .padding(.horizontal, 20)
        .padding(.top, 6)
        .padding(.bottom, 8)
    }

    // MARK: Title

    private func titleBlock(_ issue: IssueItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("#\(issue.number)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Palette.accentBright)

            Text(issue.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                stateChip(isOpen: itemIsOpen)

                if let milestone = issueMilestone {
                    HStack(spacing: 5) {
                        Image(systemName: "flag")
                            .font(.system(size: 11, weight: .semibold))
                        Text(milestone)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(Palette.ink)
                    .padding(.horizontal, 12)
                    .frame(height: 30)
                    .background(Capsule().fill(Color.white.opacity(0.10)))
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.16), lineWidth: 1))
                }

                Text("\(itemAuthor) opened \(itemTime)")
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.inkMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 0)
            }

            HStack(spacing: 6) {
                ForEach(itemLabels, id: \.self) { label in
                    Text(label)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(IssueLabelCatalog.color(for: label))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(IssueLabelCatalog.color(for: label).opacity(0.16)))
                        .overlay(
                            Capsule().strokeBorder(
                                IssueLabelCatalog.color(for: label).opacity(0.45),
                                lineWidth: 1
                            )
                        )
                }

                Button {
                    Haptics.tap()
                    showLabelEditor = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "tag")
                            .font(.system(size: 11, weight: .semibold))
                        Text(itemLabels.isEmpty ? "Edit labels" : "Edit labels")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(Palette.inkMuted)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.white.opacity(0.08)))
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)
            }
            .padding(.top, 2)

            HStack(spacing: 8) {
                if !assignees.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(assignees, id: \.self) { name in
                                HStack(spacing: 6) {
                                    AvatarView(initials: initials(for: name), size: 24)
                                    Text(firstName(for: name))
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 5)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color.white.opacity(0.10)))
                                .overlay(Capsule().strokeBorder(Color.white.opacity(0.16), lineWidth: 1))
                            }
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }

                Button {
                    Haptics.tap()
                    showAssigneePicker = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 11, weight: .semibold))
                        Text(assignees.isEmpty ? "Assign" : "Add")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(Palette.inkMuted)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.white.opacity(0.08)))
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)
            }
            .padding(.top, 2)

            Button {
                Haptics.select()
                withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                    store.toggleIssueState(itemID)
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isOpen ? "checkmark.circle" : "arrow.counterclockwise")
                        .font(.system(size: 13, weight: .semibold))
                    Text(isOpen ? "Close issue" : "Reopen")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, 14)
                .frame(height: 36)
                .background(Capsule().fill(Color.white.opacity(0.08)))
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.16), lineWidth: 1))
            }
            .buttonStyle(PressableStyle(scale: 0.95))
        }
    }

    private func stateChip(isOpen: Bool) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isOpen ? Color(hex: 0x3FB950) : Palette.inkMuted)
                .frame(width: 7, height: 7)
            Text(isOpen ? "Open" : "Closed")
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundStyle(isOpen ? Color(hex: 0x3FB950) : Palette.ink)
        .padding(.horizontal, 14)
        .frame(height: 34)
        .background(
            Capsule().fill(isOpen ? Color(hex: 0x3FB950).opacity(0.18) : Color.white.opacity(0.10))
        )
        .overlay(
            Capsule().strokeBorder(
                isOpen ? Color(hex: 0x3FB950).opacity(0.4) : Color.white.opacity(0.16),
                lineWidth: 1
            )
        )
    }

    // MARK: Description

    private func descriptionCard(_ issue: IssueItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Description")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            Text(issue.body)
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            if let code = issue.code {
                ZStack(alignment: .topTrailing) {
                    CodeBlockView(code: code)

                    Button {
                        UIPasteboard.general.string = code
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
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(didCopy ? Palette.accentBright : Palette.inkMuted)
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.plain)
                    .padding(10)
                }
                .padding(.top, 2)
            }
        }
        .padding(16)
        .glassCard()
    }

    // MARK: Activity

    private func activitySection(_ issue: IssueItem) -> some View {
        let events = issue.activity.sorted { $0.timestamp < $1.timestamp }

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Activity")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(events.count)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)
            }

            if events.isEmpty {
                Text("No activity yet.")
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.inkFaint)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .glassCard()
            } else {
                VStack(spacing: 0) {
                    ForEach(events.indices, id: \.self) { index in
                        let event = events[index]

                        HStack(alignment: .top, spacing: 12) {
                            AvatarView(initials: initials(for: event.actor), size: 38)

                            VStack(alignment: .leading, spacing: 5) {
                                HStack(alignment: .firstTextBaseline, spacing: 6) {
                                    Text(event.actor)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)

                                    Spacer(minLength: 4)

                                    Text(event.timestamp.formatted(date: .abbreviated, time: .shortened))
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(Palette.inkFaint)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }

                                Text(event.action)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Palette.inkMuted)
                                    .fixedSize(horizontal: false, vertical: true)

                                if let detail = event.detail, !detail.isEmpty {
                                    Text(detail)
                                        .font(.system(size: 14))
                                        .foregroundStyle(Palette.ink)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .padding(.top, 2)
                                }
                            }
                        }
                        .padding(.vertical, 13)

                        if index < events.count - 1 {
                            Rectangle()
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 1)
                                .padding(.leading, 50)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .glassCard()
            }
        }
    }

    // MARK: Comments

    private func commentsSection(_ issue: IssueItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(issue.comments.count) comments")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            if issue.comments.isEmpty {
                Text("No comments yet. Start the conversation below.")
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.inkFaint)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 22)
                    .glassCard()
            } else {
                ForEach(issue.comments) { comment in
                    commentCard(comment)
                }
            }
        }
    }

    private func commentCard(_ comment: IssueComment) -> some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarView(initials: initials(for: comment.author), size: 54)

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .top) {
                    Text(comment.author)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)

                    Spacer(minLength: 6)

                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Palette.inkFaint)
                }

                Text(comment.time)
                    .font(.system(size: 13))
                    .foregroundStyle(Palette.inkFaint)

                Text(comment.body)
                    .font(.system(size: 15))
                    .foregroundStyle(Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)

                ReactionRow(reactions: comment.reactions) { kind in
                    store.toggleIssueReaction(kind, commentID: comment.id, issueID: itemID)
                }
                .padding(.top, 6)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(hex: 0x32288C).opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    // MARK: Composer

    private func composer(_ issue: IssueItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !mentionSuggestions.isEmpty {
                mentionSuggestionsCard
            }

            HStack(spacing: 10) {
                TextField("Leave a comment…", text: $draft, axis: .vertical)
                    .lineLimit(1...4)
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
                    .tint(Palette.accentBright)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(minHeight: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                    )

                Button {
                    Haptics.tap()
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                        store.addComment(draft, to: issue.id)
                        draft = ""
                    }
                } label: {
                    Text("Comment")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
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
                        .shadow(color: Palette.accent.opacity(0.45), radius: 14, x: 0, y: 8)
                }
                .buttonStyle(PressableStyle())
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 92)
    }

    // MARK: Helpers

    private func copyIssueLink(_ issue: IssueItem) {
        let handle = store.profile.handle.trimmingCharacters(in: CharacterSet(charactersIn: "@"))
        let repository = issue.repository.split(separator: "/").last.map(String.init) ?? issue.repository
        UIPasteboard.general.string = "https://github.com/\(handle)/\(repository)/issues/\(issue.number)"
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

    private var itemLabels: [String] {
        issue?.labels ?? []
    }

    private var issueMilestone: String? {
        issue?.milestone
    }

    private var itemID: UUID {
        issue?.id ?? issueID
    }

    private var itemIsOpen: Bool {
        issue?.isOpen ?? true
    }

    private var isOpen: Bool {
        itemIsOpen
    }

    private var itemAuthor: String {
        issue?.author ?? ""
    }

    private var itemTime: String {
        issue?.time ?? ""
    }

    private var assignees: [String] {
        issue?.assignees ?? []
    }

    private func firstName(for name: String) -> String {
        name.split(separator: " ").first.map(String.init) ?? name
    }

    // MARK: Mentions

    private var mentionQuery: String? {
        guard let atIndex = draft.lastIndex(of: "@") else { return nil }

        if atIndex != draft.startIndex {
            let before = draft[draft.index(before: atIndex)]
            guard before == " " || before == "\n" else { return nil }
        }

        let after = draft[draft.index(after: atIndex)...]
        guard !after.contains(where: { $0 == " " || $0 == "\n" }) else { return nil }

        return String(after).lowercased()
    }

    private var mentionSuggestions: [PersonItem] {
        guard let needle = mentionQuery else { return [] }

        let matches = store.people.filter { person in
            guard !needle.isEmpty else { return true }
            return person.name.lowercased().contains(needle)
                || person.handle.lowercased().contains(needle)
        }

        return Array(matches.prefix(4))
    }

    private var mentionSuggestionsCard: some View {
        VStack(spacing: 0) {
            ForEach(mentionSuggestions) { person in
                Button {
                    insertMention(person)
                } label: {
                    HStack(spacing: 10) {
                        AvatarView(initials: person.initials, size: 30)

                        Text(person.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Text(person.handle)
                            .font(.system(size: 12))
                            .foregroundStyle(Palette.inkFaint)
                            .lineLimit(1)

                        Spacer(minLength: 6)

                        Image(systemName: "at")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Palette.accentBright)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if person.id != mentionSuggestions.last?.id {
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 1)
                        .padding(.leading, 52)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(hex: 0x32288C).opacity(0.95))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
        )
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func insertMention(_ person: PersonItem) {
        guard let atIndex = draft.lastIndex(of: "@") else { return }
        let handle = person.handle.hasPrefix("@") ? person.handle : "@\(person.handle)"
        draft = String(draft[draft.startIndex..<atIndex]) + handle + " "
        Haptics.select()
    }
}

struct IssueAssigneesSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var issueID: UUID

    private var issue: IssueItem? {
        store.issues.first(where: { $0.id == issueID })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Assignees")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Choose who is working on this issue.")
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

            VStack(spacing: 0) {
                ForEach(store.people) { person in
                    let isAssigned = issue?.assignees.contains(person.name) ?? false

                    Button {
                        Haptics.select()
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                            store.toggleIssueAssignee(person.name, on: issueID)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            AvatarView(initials: person.initials, size: 40)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(person.name)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text(person.handle)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Palette.inkFaint)
                            }

                            Spacer(minLength: 6)

                            Image(systemName: isAssigned ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 19))
                                .foregroundStyle(isAssigned ? Palette.accentBright : Palette.inkFaint)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PressableStyle(scale: 0.99))

                    if person.id != store.people.last?.id {
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 1)
                            .padding(.leading, 64)
                    }
                }
            }
            .glassCard()

            Spacer(minLength: 0)

            Button {
                Haptics.tap()
                dismiss()
            } label: {
                Text("Done")
                    .font(.system(size: 16, weight: .semibold))
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
            }
            .buttonStyle(PressableStyle())
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppBackdrop())
        .preferredColorScheme(.dark)
    }
}

struct IssueLabelsSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var issueID: UUID

    private var issue: IssueItem? {
        store.issues.first(where: { $0.id == issueID })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text("Labels and milestone")
                    .font(.system(size: 20, weight: .bold))
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

            Text("LABELS")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.3)
                .foregroundStyle(Palette.inkFaint)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)],
                spacing: 8
            ) {
                ForEach(IssueLabelCatalog.all, id: \.self) { label in
                    let isOn = issue?.labels.contains(label) ?? false

                    Button {
                        Haptics.select()
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                            store.toggleIssueLabel(label, on: issueID)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 12, weight: .semibold))
                            Text(label)
                                .font(.system(size: 13, weight: .semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .foregroundStyle(IssueLabelCatalog.color(for: label))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Capsule().fill(IssueLabelCatalog.color(for: label).opacity(isOn ? 0.24 : 0.10)))
                        .overlay(
                            Capsule().strokeBorder(
                                IssueLabelCatalog.color(for: label).opacity(isOn ? 0.7 : 0.3),
                                lineWidth: 1
                            )
                        )
                    }
                    .buttonStyle(PressableStyle(scale: 0.97))
                }
            }

            Text("MILESTONE")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.3)
                .foregroundStyle(Palette.inkFaint)
                .padding(.top, 2)

            VStack(spacing: 0) {
                ForEach(IssueLabelCatalog.milestones, id: \.self) { milestone in
                    let isSelected = issue?.milestone == milestone

                    Button {
                        Haptics.select()
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                            store.setIssueMilestone(isSelected ? nil : milestone, for: issueID)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "flag")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Palette.inkMuted)
                            Text(milestone)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.white)
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(Palette.accentBright)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PressableStyle(scale: 0.99))

                    if milestone != IssueLabelCatalog.milestones.last {
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 1)
                            .padding(.leading, 36)
                    }
                }
            }
            .glassCard()

            Spacer(minLength: 0)

            Button {
                Haptics.tap()
                dismiss()
            } label: {
                Text("Done")
                    .font(.system(size: 16, weight: .semibold))
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
            }
            .buttonStyle(PressableStyle())
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppBackdrop())
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        IssueDetailView(issueID: AppStore.sampleIssues[0].id)
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
