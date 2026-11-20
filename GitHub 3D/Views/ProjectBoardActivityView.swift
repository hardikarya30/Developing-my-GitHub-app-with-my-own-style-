//
//  ProjectBoardActivityView.swift
//  GitHub 3D
//
//  A chronological feed of changes made to a project board.
//

import SwiftUI

struct ProjectBoardActivityView: View {
    @EnvironmentObject private var store: AppStore

    var projectID: UUID
    var projectName: String
    var onBack: () -> Void

    private var projectTitle: String {
        store.projects.first(where: { $0.id == projectID })?.title ?? projectName
    }

    private var events: [ProjectBoardActivityEvent] {
        store.projectBoardActivity(for: projectID)
    }

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(projectTitle)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .fixedSize(horizontal: false, vertical: true)

                            Text("Recent project updates")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Palette.inkMuted)
                        }

                        if events.isEmpty {
                            emptyState
                        } else {
                            VStack(spacing: 12) {
                                ForEach(events) { event in
                                    ProjectBoardActivityRow(event: event)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .padding(.bottom, 140)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(.dark)
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
            .accessibilityLabel("Back to project board")

            Spacer()

            Text("Activity")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Palette.accentBright)
                .frame(width: 46, height: 46)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .glassCard(fill: Color.white.opacity(0.10), radius: 28)
        .padding(.horizontal, 14)
        .padding(.top, 6)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(Palette.accentBright)
                .frame(width: 62, height: 62)
                .background(Circle().fill(Palette.accentBright.opacity(0.16)))

            VStack(spacing: 5) {
                Text("No activity yet")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                Text("Add a card or move a task to see project updates here.")
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.inkMuted)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 38)
        .glassCard(fill: Color.white.opacity(0.08), radius: 24)
    }
}

private struct ProjectBoardActivityRow: View {
    var event: ProjectBoardActivityEvent

    private var initials: String {
        String(event.actor.split(separator: " ").prefix(2).compactMap { $0.first }).uppercased()
    }

    private var action: String {
        switch event.kind {
        case .added:
            return "added a card"
        case .moved:
            return "moved a card"
        }
    }

    private var statusText: String? {
        guard let status = event.status else { return nil }
        if event.kind == .moved, let previousStatus = event.previousStatus {
            return "\(previousStatus.rawValue) → \(status.rawValue)"
        }
        return status.rawValue
    }

    private var timeLabel: String {
        let calendar = Calendar.current
        let time = event.timestamp.formatted(date: .omitted, time: .shortened)
        if calendar.isDateInToday(event.timestamp) {
            return "Today · \(time)"
        }
        if calendar.isDateInYesterday(event.timestamp) {
            return "Yesterday · \(time)"
        }
        return event.timestamp.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            AvatarView(initials: initials, size: 44)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(event.actor)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    Text(timeLabel)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Palette.inkFaint)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Text(action)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Palette.inkMuted)

                HStack(spacing: 9) {
                    Image(systemName: event.kind == .added ? "plus" : "arrow.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(event.status?.color ?? Palette.accentBright)
                        .frame(width: 25, height: 25)
                        .background(Circle().fill((event.status?.color ?? Palette.accentBright).opacity(0.16)))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.cardTitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)

                        if let statusText {
                            Text(statusText)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(event.status?.color ?? Palette.inkMuted)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(11)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.07))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                )
            }
        }
        .padding(15)
        .glassCard(fill: Color.white.opacity(0.08), radius: 22)
        .accessibilityElement(children: .combine)
    }
}
