//
//  CopilotHistoryView.swift
//  GitHub 3D
//
//  Every Copilot conversation from this session, newest first.
//

import SwiftUI

struct CopilotHistoryView: View {
    @EnvironmentObject private var store: AppStore

    var onBack: () -> Void = {}

    private var conversations: [CopilotConversation] {
        store.copilotConversations
    }

    var body: some View {
        ZStack {
            CopilotBackdrop()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 12)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(subtitle)
                            .font(.system(size: 15))
                            .foregroundStyle(CopilotPalette.inkMuted)
                            .padding(.top, 4)

                        if conversations.isEmpty {
                            emptyState
                        } else {
                            ForEach(conversations) { conversation in
                                card(conversation)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 130)
                }
            }
        }
        .preferredColorScheme(.light)
    }

    private var subtitle: String {
        let count = conversations.count
        if count == 1 { return "1 conversation this session" }
        return "\(count) conversations this session"
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
                    .foregroundStyle(CopilotPalette.ink)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white.opacity(0.78)))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.9), lineWidth: 1))
            }
            .buttonStyle(PressableStyle(scale: 0.92))

            Spacer()

            Text("History")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(CopilotPalette.ink)

            Spacer()

            Button {
                Haptics.tap()
                store.startNewCopilotConversation()
                onBack()
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(CopilotPalette.violet)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white.opacity(0.78)))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.9), lineWidth: 1))
            }
            .buttonStyle(PressableStyle(scale: 0.92))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .lightGlass(fill: Color.white.opacity(0.55), radius: 28)
    }

    // MARK: Card

    private func card(_ conversation: CopilotConversation) -> some View {
        Button {
            Haptics.tap()
            store.openCopilotConversation(conversation.id)
            onBack()
        } label: {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(CopilotPalette.violet)
                    .frame(width: 56, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(CopilotPalette.violet.opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text(conversation.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(CopilotPalette.ink)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)

                    Text(conversation.preview)
                        .font(.system(size: 14.5))
                        .foregroundStyle(CopilotPalette.inkMuted)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)

                    HStack(spacing: 10) {
                        Text(conversation.model)
                            .font(.system(size: 12.5, weight: .semibold))
                            .foregroundStyle(CopilotPalette.violet)
                            .padding(.horizontal, 10)
                            .frame(height: 26)
                            .background(
                                Capsule().fill(CopilotPalette.violet.opacity(0.12))
                            )

                        Rectangle()
                            .fill(CopilotPalette.line)
                            .frame(width: 1, height: 14)

                        Text(conversation.countLabel)
                            .font(.system(size: 13))
                            .foregroundStyle(CopilotPalette.inkMuted)

                        Rectangle()
                            .fill(CopilotPalette.line)
                            .frame(width: 1, height: 14)

                        Text(conversation.timeLabel)
                            .font(.system(size: 13))
                            .foregroundStyle(CopilotPalette.inkMuted)
                    }
                    .padding(.top, 2)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(CopilotPalette.inkMuted)
                    .padding(.top, 20)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white)
            )
            .shadow(color: Color(hex: 0x1B2A55).opacity(0.10), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(PressableStyle(scale: 0.99))
    }

    // MARK: Empty

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "bubble.left.and.text.bubble.right")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(CopilotPalette.violet)
                .frame(width: 60, height: 60)
                .background(Circle().fill(CopilotPalette.violet.opacity(0.12)))

            Text("No conversations yet")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(CopilotPalette.ink)

            Text("Send your first prompt to Copilot and it will show up here.")
                .font(.system(size: 14))
                .foregroundStyle(CopilotPalette.inkMuted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
        .shadow(color: Color(hex: 0x1B2A55).opacity(0.10), radius: 16, x: 0, y: 8)
    }
}

#Preview {
    CopilotHistoryView()
        .environmentObject(AppStore())
}
