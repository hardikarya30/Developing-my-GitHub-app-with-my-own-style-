//
//  ReactionRow.swift
//  GitHub 3D
//
//  The four reactions shown under a comment.
//

import SwiftUI

struct ReactionRow: View {
    var reactions: CommentReactions
    var onToggle: (ReactionKind) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(ReactionKind.allCases) { kind in
                chip(kind)
            }
        }
    }

    private func chip(_ kind: ReactionKind) -> some View {
        let isOn = reactions.isMine(kind)

        return Button {
            Haptics.select()
            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                onToggle(kind)
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: kind.symbol)
                    .font(.system(size: 13, weight: .medium))
                Text("\(reactions.count(for: kind))")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(isOn ? Color.white : Palette.inkMuted)
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(
                Capsule().fill(
                    isOn ? Palette.accent.opacity(0.30) : Color.white.opacity(0.08)
                )
            )
            .overlay(
                Capsule().strokeBorder(
                    isOn ? Palette.accentBright.opacity(0.75) : Color.white.opacity(0.12),
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(PressableStyle(scale: 0.95))
        .accessibilityLabel("\(kind.title), \(reactions.count(for: kind))")
    }
}
