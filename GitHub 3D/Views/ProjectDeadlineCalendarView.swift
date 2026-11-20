//
//  ProjectDeadlineCalendarView.swift
//  GitHub 3D
//
//  A monthly view of project deadlines and the tasks scheduled for a selected day.
//

import SwiftUI

struct ProjectDeadlineCalendarView: View {
    @EnvironmentObject private var store: AppStore

    var projectID: UUID
    var projectName: String
    var onBack: () -> Void
    var onOpenTask: (UUID) -> Void

    @State private var displayedMonth = Calendar.current.startOfDay(for: Date())
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())
    @State private var didSetInitialDate = false
    @State private var activeStatusIDs = Set(ProjectBoardStatus.allCases.map(\.id))
    @State private var isShowingAgenda = false

    private var calendar: Calendar {
        Calendar.current
    }

    private var projectCards: [ProjectBoardCard] {
        store.boardCards(for: projectID)
    }

    private var allStatusIDs: Set<String> {
        Set(ProjectBoardStatus.allCases.map(\.id))
    }

    private var hasAllStatusesSelected: Bool {
        activeStatusIDs == allStatusIDs
    }

    private var hasSelectedDayDeadlines: Bool {
        projectCards.contains { card in
            guard let dueDate = card.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: selectedDate)
        }
    }

    private var monthCells: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let dayRange = calendar.range(of: .day, in: .month, for: displayedMonth) else {
            return []
        }

        let leadingDays = (calendar.component(.weekday, from: monthInterval.start) - calendar.firstWeekday + 7) % 7
        let cellCount = ((leadingDays + dayRange.count + 6) / 7) * 7

        return (0..<cellCount).map { index in
            let day = index - leadingDays + 1
            guard dayRange.contains(day) else { return nil }
            return calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start)
                .map(calendar.startOfDay(for:))
        }
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let firstIndex = calendar.firstWeekday - 1
        return Array(symbols[firstIndex...]) + Array(symbols[..<firstIndex])
    }

    private var monthTitle: String {
        displayedMonth.formatted(.dateTime.month(.wide).year())
    }

    private var selectedDayTitle: String {
        selectedDate.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    private var selectedDayCards: [ProjectBoardCard] {
        projectCards
            .filter { card in
                guard activeStatusIDs.contains(card.status.id),
                      let dueDate = card.dueDate else { return false }
                return calendar.isDate(dueDate, inSameDayAs: selectedDate)
            }
            .sorted { lhs, rhs in
                if lhs.status != rhs.status {
                    let lhsOrder = ProjectBoardStatus.allCases.firstIndex(of: lhs.status) ?? 0
                    let rhsOrder = ProjectBoardStatus.allCases.firstIndex(of: rhs.status) ?? 0
                    return lhsOrder < rhsOrder
                }
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
    }

    var body: some View {
        ZStack {
            AppBackdrop()

            calendarContent
                .opacity(isShowingAgenda ? 0 : 1)
                .allowsHitTesting(!isShowingAgenda)
                .accessibilityHidden(isShowingAgenda)

            if isShowingAgenda {
                ProjectDeadlineAgendaView(
                    projectID: projectID,
                    projectName: projectName,
                    activeStatusIDs: activeStatusIDs,
                    initialDate: selectedDate,
                    onBackToCalendar: {
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                            isShowingAgenda = false
                        }
                    },
                    onShowCalendar: {
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                            isShowingAgenda = false
                        }
                    },
                    onOpenTask: onOpenTask
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(.dark)
        .onAppear(perform: setInitialDateIfNeeded)
    }

    private var calendarContent: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Project calendar")
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text(projectName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Palette.inkMuted)
                    }
                    .padding(.top, 20)

                    monthCard
                    selectedDaySection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 150)
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
            .accessibilityLabel("Back to project board")

            Spacer()

            Text("Calendar")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                Haptics.tap()
                withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                    isShowingAgenda = true
                }
            } label: {
                Image(systemName: "list.bullet")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Circle().fill(Color.white.opacity(0.10)))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.15), lineWidth: 1))
            }
            .buttonStyle(PressableStyle(scale: 0.9))
            .accessibilityLabel("Show deadline agenda")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .glassCard(fill: Color.white.opacity(0.10), radius: 28)
        .padding(.horizontal, 14)
        .padding(.top, 6)
    }

    private var monthCard: some View {
        VStack(spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(monthTitle)
                        .font(.system(size: 21, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Project deadlines")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Palette.inkMuted)
                }

                Spacer()

                monthNavigationButton(symbol: "chevron.left", accessibilityLabel: "Previous month", offset: -1)
                monthNavigationButton(symbol: "chevron.right", accessibilityLabel: "Next month", offset: 1)
            }

            statusFilters

            HStack(spacing: 0) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Palette.inkFaint)
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 8) {
                ForEach(monthCells.indices, id: \.self) { index in
                    if let date = monthCells[index] {
                        dayButton(date)
                    } else {
                        Color.clear
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .accessibilityHidden(true)
                    }
                }
            }
        }
        .padding(18)
        .glassCard(fill: Color.white.opacity(0.08), radius: 24)
    }

    private var statusFilters: some View {
        HStack(spacing: 6) {
            Button(action: restoreAllStatuses) {
                Text("All")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(hasAllStatusesSelected ? .white : Palette.inkMuted)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(hasAllStatusesSelected ? Palette.accentBright.opacity(0.72) : Color.white.opacity(0.06))
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                hasAllStatusesSelected ? Color.white.opacity(0.24) : Color.white.opacity(0.10),
                                lineWidth: 1
                            )
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Show all task statuses")
            .accessibilityValue(hasAllStatusesSelected ? "Selected" : "Not selected")
            .accessibilityAddTraits(hasAllStatusesSelected ? .isSelected : [])

            ForEach(ProjectBoardStatus.allCases) { status in
                statusFilterButton(status)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statusFilterButton(_ status: ProjectBoardStatus) -> some View {
        let isActive = activeStatusIDs.contains(status.id)

        return Button {
            Haptics.select()
            withAnimation(.easeOut(duration: 0.18)) {
                if isActive {
                    activeStatusIDs.remove(status.id)
                } else {
                    activeStatusIDs.insert(status.id)
                }
            }
        } label: {
            HStack(spacing: 5) {
                Circle()
                    .fill(isActive ? status.color : Palette.inkFaint)
                    .frame(width: 6, height: 6)
                Text(status.rawValue)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(isActive ? .white : Palette.inkMuted)
                    .lineLimit(1)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(isActive ? status.color.opacity(0.18) : Color.white.opacity(0.06))
            )
            .overlay(
                Capsule()
                    .strokeBorder(isActive ? status.color.opacity(0.48) : Color.white.opacity(0.10), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Filter by \(status.rawValue)")
        .accessibilityValue(isActive ? "Selected" : "Not selected")
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    private func restoreAllStatuses() {
        guard !hasAllStatusesSelected else { return }
        Haptics.select()
        withAnimation(.easeOut(duration: 0.18)) {
            activeStatusIDs = allStatusIDs
        }
    }

    private func monthNavigationButton(
        symbol: String,
        accessibilityLabel: String,
        offset: Int
    ) -> some View {
        Button {
            Haptics.select()
            moveMonth(by: offset)
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.white.opacity(0.10)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(PressableStyle(scale: 0.9))
        .accessibilityLabel(accessibilityLabel)
    }

    private func dayButton(_ date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let dayCards = cards(dueOn: date)

        return Button {
            Haptics.select()
            withAnimation(.easeOut(duration: 0.18)) {
                selectedDate = date
            }
        } label: {
            VStack(spacing: 4) {
                Text(calendar.component(.day, from: date).formatted())
                    .font(.system(size: 14, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundStyle(isSelected ? .white : (isToday ? Palette.accentBright : .white.opacity(0.92)))

                HStack(spacing: 3) {
                    ForEach(Array(dayCards.prefix(3).enumerated()), id: \.offset) { _, card in
                        Circle()
                            .fill(card.status.color)
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(height: 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background {
                if isSelected {
                    Circle()
                        .fill(Palette.accentBright)
                        .frame(width: 42, height: 42)
                        .shadow(color: Palette.accentBright.opacity(0.32), radius: 10, y: 4)
                }
            }
            .overlay {
                if isToday && !isSelected {
                    Circle()
                        .strokeBorder(Palette.accentBright.opacity(0.72), lineWidth: 1)
                        .frame(width: 42, height: 42)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.92))
        .accessibilityLabel(accessibilityLabel(for: date, deadlineCount: dayCards.count))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var selectedDaySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Selected day")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.1)
                        .foregroundStyle(Palette.inkFaint)
                    Text(selectedDayTitle)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer(minLength: 8)

                Text("\(selectedDayCards.count) \(selectedDayCards.count == 1 ? "task" : "tasks")")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Palette.inkMuted)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.white.opacity(0.09)))
            }

            if selectedDayCards.isEmpty {
                emptyDayState
            } else {
                VStack(spacing: 10) {
                    ForEach(selectedDayCards) { card in
                        taskRow(card)
                    }
                }
            }
        }
    }

    private var emptyDayState: some View {
        HStack(spacing: 13) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(Palette.accentBright)
                .frame(width: 42, height: 42)
                .background(Circle().fill(Palette.accentBright.opacity(0.16)))

            VStack(alignment: .leading, spacing: 4) {
                Text(hasSelectedDayDeadlines ? "No tasks match these filters" : "No deadlines on this day")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                Text(hasSelectedDayDeadlines
                    ? "Turn on a status or choose All to show deadlines."
                    : "Choose a marked date to see its tasks.")
                    .font(.system(size: 12))
                    .foregroundStyle(Palette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .glassCard(fill: Color.white.opacity(0.07), radius: 18)
    }

    private func taskRow(_ card: ProjectBoardCard) -> some View {
        HStack(spacing: 8) {
            Button {
                Haptics.tap()
                onOpenTask(card.id)
            } label: {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(card.status.color)
                        .frame(width: 4, height: 46)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(card.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 8) {
                            Text(card.status.rawValue)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(card.status.color)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(card.status.color.opacity(0.13)))

                            if let assignee = card.assignee {
                                HStack(spacing: 5) {
                                    AvatarView(initials: initials(for: assignee), size: 22)
                                    Text(assignee)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(Palette.inkMuted)
                                        .lineLimit(1)
                                }
                            }

                            if let issueNumber = card.issueNumber {
                                Text("#\(issueNumber)")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(Palette.inkFaint)
                            }
                        }
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Palette.inkFaint)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens task details")

            ProjectDeadlineRescheduleButton(card: card)
        }
        .padding(12)
        .glassCard(fill: Color.white.opacity(0.08), radius: 18)
    }

    private func cards(dueOn date: Date) -> [ProjectBoardCard] {
        projectCards.filter { card in
            guard activeStatusIDs.contains(card.status.id),
                  let dueDate = card.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: date)
        }
    }

    private func initials(for name: String) -> String {
        String(name.split(separator: " ").prefix(2).compactMap { $0.first }).uppercased()
    }

    private func accessibilityLabel(for date: Date, deadlineCount: Int) -> String {
        let dateText = date.formatted(date: .complete, time: .omitted)
        guard deadlineCount > 0 else { return dateText }
        return "\(dateText), \(deadlineCount) \(deadlineCount == 1 ? "deadline" : "deadlines")"
    }

    private func moveMonth(by amount: Int) {
        guard let nextMonth = calendar.date(byAdding: .month, value: amount, to: displayedMonth),
              let dayRange = calendar.range(of: .day, in: .month, for: nextMonth) else { return }

        let selectedDay = calendar.component(.day, from: selectedDate)
        let clampedDay = min(selectedDay, dayRange.count)
        let nextSelectedDate = calendar.date(byAdding: .day, value: clampedDay - 1, to: nextMonth)
            .map(calendar.startOfDay(for:)) ?? nextMonth

        withAnimation(.easeInOut(duration: 0.2)) {
            displayedMonth = nextMonth
            selectedDate = nextSelectedDate
        }
    }

    private func setInitialDateIfNeeded() {
        guard !didSetInitialDate else { return }
        didSetInitialDate = true

        let today = calendar.startOfDay(for: Date())
        let dueDates = projectCards
            .compactMap(\.dueDate)
            .map(calendar.startOfDay(for:))
            .sorted()
        let initialDate = dueDates.first(where: { $0 >= today }) ?? dueDates.last ?? today

        displayedMonth = calendar.dateInterval(of: .month, for: initialDate)?.start ?? initialDate
        selectedDate = initialDate
    }
}

#Preview {
    ProjectDeadlineCalendarView(
        projectID: AppStore.sampleProjects[0].id,
        projectName: AppStore.sampleProjects[0].title,
        onBack: {},
        onOpenTask: { _ in }
    )
    .environmentObject(AppStore())
}
