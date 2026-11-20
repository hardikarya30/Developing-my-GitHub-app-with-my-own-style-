//
//  ProjectDeadlineRescheduleButton.swift
//  GitHub 3D
//
//  A focused date editor for tasks shown in the project calendar.
//

import SwiftUI

struct ProjectDeadlineRescheduleButton: View {
    @EnvironmentObject private var store: AppStore

    var card: ProjectBoardCard

    @State private var isShowingReschedule = false
    @State private var draftDueDate = Date()

    var body: some View {
        Button {
            Haptics.tap()
            draftDueDate = card.dueDate ?? Date()
            isShowingReschedule = true
        } label: {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Palette.accentBright)
                .frame(width: 38, height: 38)
                .background(Circle().fill(Palette.accentBright.opacity(0.15)))
                .overlay(Circle().strokeBorder(Palette.accentBright.opacity(0.28), lineWidth: 1))
                .contentShape(Circle())
        }
        .buttonStyle(PressableStyle(scale: 0.9))
        .accessibilityLabel("Reschedule \(card.title)")
        .sheet(isPresented: $isShowingReschedule) {
            ProjectDeadlineRescheduleSheet(
                card: card,
                dueDate: $draftDueDate,
                onCancel: {
                    isShowingReschedule = false
                },
                onSave: { date in
                    guard store.rescheduleProjectCard(id: card.id, dueDate: date) else { return }
                    Haptics.tap()
                    isShowingReschedule = false
                }
            )
            .presentationDetents([.height(340)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
    }
}

private struct ProjectDeadlineRescheduleSheet: View {
    var card: ProjectBoardCard
    @Binding var dueDate: Date
    var onCancel: () -> Void
    var onSave: (Date) -> Void

    private var currentDeadline: String {
        card.dueDate?.formatted(date: .abbreviated, time: .omitted) ?? "No deadline"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 17) {
            Text("Reschedule task")
                .font(.system(size: 21, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 5) {
                Text(card.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Current deadline · \(currentDeadline)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Palette.inkMuted)
            }

            DatePicker("New deadline", selection: $dueDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .tint(Palette.accentBright)
                .padding(.horizontal, 13)
                .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )

            Spacer(minLength: 0)

            HStack(spacing: 10) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Palette.inkMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(Color.white.opacity(0.08))
                        )
                }
                .buttonStyle(PressableStyle())

                Button {
                    onSave(dueDate)
                } label: {
                    Text("Save date")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(Palette.accentBright)
                        )
                }
                .buttonStyle(PressableStyle())
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppBackdrop())
        .preferredColorScheme(.dark)
    }
}
