//
//  ProjectDeadlineAgendaView.swift
//  GitHub 3D
//
//  A week-by-week agenda of dated tasks in a project.
//

import SwiftUI

struct ProjectDeadlineAgendaView: View {
    @EnvironmentObject private var store: AppStore

    var projectID: UUID
    var projectName: String
    var activeStatusIDs: Set<String>
    var initialDate: Date
    var onBackToCalendar: () -> Void
    var onShowCalendar: () -> Void
    var onOpenTask: (UUID) -> Void

    @State private var weekStart: Date

    private var calendar: Calendar {
        Calendar.current
    }

    private var currentWeekStart: Date {
        startOfWeek(containing: Date())
    }

    private var isCurrentWeek: Bool {
        calendar.isDate(weekStart, inSameDayAs: currentWeekStart)
    }

    private var weekDates: [Date] {
        (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    private var weekTasks: [ProjectBoardCard] {
        guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else { return [] }

        return store.boardCards(for: projectID)
            .filter { card in
                guard activeStatusIDs.contains(card.status.id),
                      let dueDate = card.dueDate else { return false }
                let dueDay = calendar.startOfDay(for: dueDate)
                return dueDay >= weekStart && dueDay < weekEnd
            }
            .sorted { lhs, rhs in
                let lhsDate = lhs.dueDate.map(calendar.startOfDay(for:)) ?? .distantFuture
                let rhsDate = rhs.dueDate.map(calendar.startOfDay(for:)) ?? .distantFuture
                if lhsDate != rhsDate { return lhsDate < rhsDate }
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
    }

    private var datesWithTasks: [Date] {
        weekDates.filter { !tasks(dueOn: $0).isEmpty }
    }

    private var weekTitle: String {
        if isCurrentWeek { return "This week" }
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
        return "\(weekStart.formatted(date: .abbreviated, time: .omitted)) – \(weekEnd.formatted(date: .abbreviated, time: .omitted))"
    }

    private var taskCountTitle: String {
        if isCurrentWeek {
            return "\(weekTasks.count) \(weekTasks.count == 1 ? "task" : "tasks") due this week"
        }
        return "\(weekTasks.count) \(weekTasks.count == 1 ? "task" : "tasks") in this range"
    }

    init(
        projectID: UUID,
        projectName: String,
        activeStatusIDs: Set<String>,
        initialDate: Date,
        onBackToCalendar: @escaping () -> Void,
        onShowCalendar: @escaping () -> Void,
        onOpenTask: @escaping (UUID) -> Void
    ) {
        self.projectID = projectID
        self.projectName = projectName
        self.activeStatusIDs = activeStatusIDs
        self.initialDate = initialDate
        self.onBackToCalendar = onBackToCalendar
        self.onShowCalendar = onShowCalendar
        self.onOpenTask = onOpenTask

        let calendar = Calendar.current
        let initialDay = calendar.startOfDay(for: initialDate)
        let leadingDays = (calendar.component(.weekday, from: initialDay) - calendar.firstWeekday + 7) % 7
        _weekStart = State(
            initialValue: calendar.date(byAdding: .day, value: -leadingDays, to: initialDay) ?? initialDay
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    titleSection
                    weekNavigator

                    if datesWithTasks.isEmpty {
                        emptyState
                    } else {
                        VStack(alignment: .leading, spacing: 18) {
                            ForEach(datesWithTasks, id: \.self) { date in
                                daySection(date)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 26)
                .padding(.bottom, 150)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Button {
                Haptics.tap()
                onBackToCalendar()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Back to calendar")
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 13)
                .frame(height: 42)
                .background(Capsule().fill(Color.white.opacity(0.10)))
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.14), lineWidth: 1))
            }
            .buttonStyle(PressableStyle(scale: 0.96))
            .accessibilityLabel("Back to calendar")

            Spacer(minLength: 0)

            Text("Agenda")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer(minLength: 0)

            Button {
                Haptics.tap()
                onShowCalendar()
            } label: {
                Image(systemName: "calendar")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(Color.white.opacity(0.10)))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.16), lineWidth: 1))
            }
            .buttonStyle(PressableStyle(scale: 0.9))
            .accessibilityLabel("Show monthly calendar")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .glassCard(fill: Color.white.opacity(0.10), radius: 28)
        .padding(.horizontal, 14)
        .padding(.top, 6)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Upcoming deadlines")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Palette.inkMuted)

            Text(projectName)
                .font(.system(size: 27, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text(taskCountTitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
        }
    }

    private var weekNavigator: some View {
        HStack(spacing: 8) {
            weekNavigationButton(symbol: "chevron.left", label: "Previous week", offset: -1)

            Spacer(minLength: 8)

            Text(weekTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 8)

            weekNavigationButton(symbol: "chevron.right", label: "Next week", offset: 1)
        }
        .padding(6)
        .frame(height: 54)
        .glassCard(fill: Color.white.opacity(0.10), radius: 25)
    }

    private func weekNavigationButton(symbol: String, label: String, offset: Int) -> some View {
        Button {
            Haptics.select()
            guard let newStart = calendar.date(byAdding: .day, value: offset * 7, to: weekStart) else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                weekStart = newStart
            }
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(Circle().fill(Color.white.opacity(0.08)))
        }
        .buttonStyle(PressableStyle(scale: 0.9))
        .accessibilityLabel(label)
    }

    private func daySection(_ date: Date) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            dayHeading(date)

            VStack(spacing: 10) {
                ForEach(tasks(dueOn: date)) { card in
                    taskRow(card)
                }
            }
        }
    }

    private func taskRow(_ card: ProjectBoardCard) -> some View {
        HStack(spacing: 8) {
            Button {
                Haptics.tap()
                onOpenTask(card.id)
            } label: {
                HStack(spacing: 12) {
                    statusIndicator(for: card.status)
                        .frame(width: 34, height: 34)

                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 1, height: 48)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(card.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if let issueNumber = card.issueNumber {
                            Text("#\(issueNumber)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Palette.inkMuted)
                        }

                        HStack(spacing: 8) {
                            statusBadge(for: card.status)

                            if let assignee = card.assignee {
                                HStack(spacing: 6) {
                                    AvatarView(initials: initials(for: assignee), size: 28)
                                    Text(assignee)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(Palette.inkMuted)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.75)
                                }
                            }
                        }
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Palette.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens task details")

            ProjectDeadlineRescheduleButton(card: card)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .glassCard(fill: Color.white.opacity(0.09), radius: 21)
    }

    private func statusIndicator(for status: ProjectBoardStatus) -> some View {
        ZStack {
            Circle()
                .stroke(status.color.opacity(status == .done ? 1 : 0.48), lineWidth: 2.5)

            if status == .inProgress {
                Circle()
                    .trim(from: 0.02, to: 0.72)
                    .stroke(status.color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            } else if status == .done {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(status.color)
            }
        }
        .padding(5)
        .accessibilityHidden(true)
    }

    private func statusBadge(for status: ProjectBoardStatus) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(status.color)
                .frame(width: 6, height: 6)
            Text(status.rawValue)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(status.color)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Capsule().fill(status.color.opacity(0.16)))
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 78, height: 78)
                .background(Circle().fill(Palette.accentBright.opacity(0.48)))
                .shadow(color: Palette.accentBright.opacity(0.42), radius: 18, y: 6)

            VStack(spacing: 5) {
                Text("No deadlines in this range")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                Text("Try another week or switch back to the month view.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Palette.inkMuted)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 34)
        .glassCard(fill: Color.white.opacity(0.08), radius: 24)
    }

    private func tasks(dueOn date: Date) -> [ProjectBoardCard] {
        weekTasks.filter { card in
            guard let dueDate = card.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: date)
        }
    }

    @ViewBuilder
    private func dayHeading(_ date: Date) -> some View {
        if calendar.isDateInToday(date) || isTomorrow(date) {
            HStack(alignment: .firstTextBaseline, spacing: 7) {
                Text(dayLead(for: date))
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("·")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Palette.inkMuted)
                Text(dayDetail(for: date))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Palette.inkMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        } else {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(dayLead(for: date))
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(", \(dayDetail(for: date))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Palette.inkMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }

    private func dayLead(for date: Date) -> String {
        if calendar.isDateInToday(date) { return "Today" }
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())),
           calendar.isDate(date, inSameDayAs: tomorrow) {
            return "Tomorrow"
        }
        return date.formatted(.dateTime.weekday(.wide))
    }

    private func dayDetail(for date: Date) -> String {
        if calendar.isDateInToday(date) || isTomorrow(date) {
            return date.formatted(.dateTime.weekday(.wide).month(.wide).day())
        }
        return date.formatted(.dateTime.month(.wide).day())
    }

    private func isTomorrow(_ date: Date) -> Bool {
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) else {
            return false
        }
        return calendar.isDate(date, inSameDayAs: tomorrow)
    }

    private func startOfWeek(containing date: Date) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: startOfDay)
        let offset = (weekday - calendar.firstWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: -offset, to: startOfDay) ?? startOfDay
    }

    private func initials(for name: String) -> String {
        String(name.split(separator: " ").prefix(2).compactMap { $0.first }).uppercased()
    }
}

#Preview {
    ProjectDeadlineAgendaView(
        projectID: AppStore.sampleProjects[0].id,
        projectName: AppStore.sampleProjects[0].title,
        activeStatusIDs: Set(ProjectBoardStatus.allCases.map(\.id)),
        initialDate: Date(),
        onBackToCalendar: {},
        onShowCalendar: {},
        onOpenTask: { _ in }
    )
    .environmentObject(AppStore())
}
