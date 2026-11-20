//
//  DiscussionThreadView.swift
//  GitHub 3D
//
//  A discussion: the opening post, its replies and a reply composer.
//

import SwiftUI

struct DiscussionThreadView: View {
    @EnvironmentObject private var store: AppStore

    var discussionID: UUID
    var onBack: () -> Void = {}

    @State private var draft = ""

    private var discussion: DiscussionItem? {
        store.discussions.first(where: { $0.id == discussionID })
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 10)

            if let discussion {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        titleBlock(discussion)
                        postCard(discussion)
                        repliesSection(discussion)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }

                composer(discussion)
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

            Text("Discussion")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                Haptics.tap()
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Circle().fill(Color.white.opacity(0.10)))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.20), lineWidth: 1))
            }
            .buttonStyle(PressableStyle(scale: 0.9))
        }
    }

    // MARK: Title

    private func titleBlock(_ discussion: DiscussionItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(discussion.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Text(discussion.category)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .frame(height: 34)
                    .background(Capsule().fill(Palette.accentBright.opacity(0.75)))
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.2), lineWidth: 1))

                Text("\(discussion.author) started \(discussion.time)")
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.inkMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 0)
            }
        }
    }

    // MARK: Opening post

    private func postCard(_ discussion: DiscussionItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                AvatarView(initials: initials(for: discussion.author), size: 54)

                VStack(alignment: .leading, spacing: 2) {
                    Text(discussion.author)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                    Text(discussion.time)
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.inkFaint)
                }

                Spacer(minLength: 0)

                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)
            }

            ForEach(Array(discussion.body.components(separatedBy: "\n\n").enumerated()), id: \.offset) { _, paragraph in
                Text(paragraph)
                    .font(.system(size: 15))
                    .foregroundStyle(Palette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .glassCard()
    }

    // MARK: Replies

    private func repliesSection(_ discussion: DiscussionItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(discussion.replies.count) replies")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            if discussion.replies.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Palette.inkMuted)
                    Text("No replies yet — be the first to answer.")
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkFaint)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 26)
                .glassCard()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(discussion.replies.enumerated()), id: \.element.id) { index, reply in
                        replyRow(reply)

                        if index < discussion.replies.count - 1 {
                            Rectangle()
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 1)
                                .padding(.leading, 66)
                        }
                    }
                }
                .glassCard()
            }
        }
    }

    private func replyRow(_ reply: DiscussionReply) -> some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarView(initials: initials(for: reply.author), size: 50)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(reply.author)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)

                    Text(reply.time)
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.inkFaint)
                        .padding(.leading, 2)

                    Spacer(minLength: 6)

                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Palette.inkFaint)
                }

                Text(reply.body)
                    .font(.system(size: 15))
                    .foregroundStyle(Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
    }

    // MARK: Composer

    private func composer(_ discussion: DiscussionItem) -> some View {
        HStack(spacing: 10) {
            TextField("Write a reply…", text: $draft)
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .tint(Palette.accentBright)
                .padding(.horizontal, 16)
                .frame(height: 50)
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
                    store.addDiscussionReply(draft, to: discussion.id)
                    draft = ""
                }
            } label: {
                Text("Reply")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
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
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 92)
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
        DiscussionThreadView(discussionID: AppStore.sampleDiscussions[0].id)
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
