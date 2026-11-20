//
//  ProjectBoardView.swift
//  GitHub 3D
//
//  A project kanban board with movable cards.
//

import SwiftUI

struct ProjectBoardView: View {
    @EnvironmentObject private var store: AppStore

    var projectID: UUID
    var projectName: String
    var onBack: () -> Void

    @State private var addingStatus: ProjectBoardStatus?
    @State private var selectedCardID: UUID?
    @State private var editingCardID: UUID?
    @State private var isShowingActivity = false
    @State private var isShowingCalendar = false
    @State private var searchText = ""

    private var cards: [ProjectBoardCard] {
        store.boardCards(for: projectID)
    }

    private var searchQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var filteredCards: [ProjectBoardCard] {
        guard !searchQuery.isEmpty else { return cards }
        return cards.filter { card in
            let searchableValues = [
                card.title,
                card.effectiveLabels.joined(separator: " "),
                card.issueNumber.map { "#\($0) \($0)" } ?? "",
                card.assignee ?? ""
            ]
            return searchableValues.contains {
                $0.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }

    private var title: String {
        store.projects.first(where: { $0.id == projectID })?.title ?? projectName
    }

    var body: some View {
        ZStack {
            boardContent
                .opacity(selectedCardID == nil && !isShowingActivity && !isShowingCalendar && editingCardID == nil ? 1 : 0)
                .allowsHitTesting(selectedCardID == nil && !isShowingActivity && !isShowingCalendar && editingCardID == nil)
                .accessibilityHidden(selectedCardID != nil || isShowingActivity || isShowingCalendar || editingCardID != nil)

            if isShowingCalendar {
                ProjectDeadlineCalendarView(
                    projectID: projectID,
                    projectName: title,
                    onBack: {
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                            isShowingCalendar = false
                        }
                    },
                    onOpenTask: { cardID in
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                            selectedCardID = cardID
                        }
                    }
                )
                .opacity(selectedCardID == nil ? 1 : 0)
                .allowsHitTesting(selectedCardID == nil)
                .accessibilityHidden(selectedCardID != nil)
                .zIndex(1)
            }

            if let selectedCardID {
                ProjectBoardCardDetailView(
                    cardID: selectedCardID,
                    projectID: projectID,
                    fallbackProjectName: projectName,
                    backAccessibilityLabel: isShowingCalendar ? "Back to calendar" : "Back to board",
                    onEdit: {
                        editingCardID = selectedCardID
                    }
                ) {
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                        self.selectedCardID = nil
                    }
                }
                .opacity(editingCardID == nil ? 1 : 0)
                .allowsHitTesting(editingCardID == nil)
                .transition(.move(edge: .trailing))
                .zIndex(2)
            } else if isShowingActivity {
                ProjectBoardActivityView(
                    projectID: projectID,
                    projectName: projectName
                ) {
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                        isShowingActivity = false
                    }
                }
                .transition(.move(edge: .trailing))
                .zIndex(2)
            }

            if let editingCardID,
               let card = store.projectCards.first(where: { $0.id == editingCardID }) {
                EditProjectBoardCardView(
                    card: card,
                    onCancel: {
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                            self.editingCardID = nil
                        }
                    },
                    onSave: {
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                            self.editingCardID = nil
                        }
                    }
                )
                .transition(.move(edge: .bottom))
                .zIndex(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(item: $addingStatus) { status in
            ProjectBoardCardForm(initialStatus: status) { cardTitle, cardStatus, assignee, dueDate in
                store.addProjectCard(
                    projectID: projectID,
                    title: cardTitle,
                    status: cardStatus,
                    assignee: assignee,
                    dueDate: dueDate
                )
            }
            .presentationDetents([.height(540)])
            .presentationCornerRadius(30)
            .presentationDragIndicator(.visible)
        }
    }

    private var boardContent: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Project board")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)

                        Text("Track progress and keep things moving.")
                            .font(.system(size: 14))
                            .foregroundStyle(Palette.inkMuted)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)

                    searchField
                        .padding(.horizontal, 20)

                    summary
                        .padding(.horizontal, 20)

                    if !searchQuery.isEmpty && filteredCards.isEmpty {
                        searchEmptyState
                            .padding(.horizontal, 20)
                    }

                    boardColumns
                }
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
            .accessibilityLabel("Back to projects")

            Spacer(minLength: 8)

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                Button {
                    Haptics.tap()
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                        isShowingCalendar = true
                    }
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 42)
                        .background(Circle().fill(Color.white.opacity(0.10)))
                        .overlay(Circle().strokeBorder(Color.white.opacity(0.20), lineWidth: 1))
                }
                .buttonStyle(PressableStyle(scale: 0.9))
                .accessibilityLabel("Project calendar")

                Button {
                    Haptics.tap()
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                        isShowingActivity = true
                    }
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 42)
                        .background(Circle().fill(Color.white.opacity(0.10)))
                        .overlay(Circle().strokeBorder(Color.white.opacity(0.20), lineWidth: 1))
                }
                .buttonStyle(PressableStyle(scale: 0.9))
                .accessibilityLabel("Project activity")

                Button {
                    Haptics.tap()
                    addingStatus = .todo
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(Color.white.opacity(0.10)))
                        .overlay(Circle().strokeBorder(Color.white.opacity(0.20), lineWidth: 1))
                }
                .buttonStyle(PressableStyle(scale: 0.9))
                .accessibilityLabel("Add card")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .glassCard(fill: Color.white.opacity(0.10), radius: 28)
        .padding(.horizontal, 14)
        .padding(.top, 6)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Palette.inkMuted)

            TextField("Search cards", text: $searchText)
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .tint(Palette.accentBright)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel("Search project cards")

            if !searchText.isEmpty {
                Button {
                    withAnimation(.easeOut(duration: 0.18)) {
                        searchText = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(Palette.inkMuted)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 15)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
        )
    }

    private var searchEmptyState: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Palette.accentBright)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Palette.accentBright.opacity(0.16)))

            VStack(alignment: .leading, spacing: 3) {
                Text("No cards match “\(searchQuery)”")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)

                Text("Try a title, label, issue number or assignee.")
                    .font(.system(size: 12))
                    .foregroundStyle(Palette.inkMuted)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .glassCard(fill: Color.white.opacity(0.07), radius: 18)
    }

    private var summary: some View {
        HStack(spacing: 0) {
            summaryMetric(filteredCards.count, label: "Tasks")

            Rectangle()
                .fill(Color.white.opacity(0.16))
                .frame(width: 1, height: 34)

            summaryMetric(filteredCards.filter { $0.status != .done }.count, label: "In progress")

            Rectangle()
                .fill(Color.white.opacity(0.16))
                .frame(width: 1, height: 34)

            summaryMetric(filteredCards.filter { $0.status == .done }.count, label: "Done")
        }
    }

    private func summaryMetric(_ value: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 2)
    }

    private var boardColumns: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 8) {
                ForEach(ProjectBoardStatus.allCases) { status in
                    boardColumn(status)
                        .containerRelativeFrame(.horizontal, count: 3, spacing: 8)
                }
            }
            .padding(.horizontal, 10)
        }
    }

    private func boardColumn(_ status: ProjectBoardStatus) -> some View {
        let columnCards = filteredCards.filter { $0.status == status }

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 7) {
                Circle()
                    .fill(status.color)
                    .frame(width: 10, height: 10)

                Text(status.rawValue)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Spacer(minLength: 2)

                Text("\(columnCards.count)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Palette.inkMuted)
            }
            .padding(.top, 2)

            ForEach(columnCards) { card in
                boardCard(card)
            }

            Spacer(minLength: 0)

            Button {
                Haptics.tap()
                addingStatus = status
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Add card")
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Palette.accent.opacity(0.42))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
                )
            }
            .buttonStyle(PressableStyle(scale: 0.97))
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 430, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
        )
    }

    private func boardCard(_ card: ProjectBoardCard) -> some View {
        ZStack(alignment: .topTrailing) {
            Button {
                Haptics.tap()
                withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                    selectedCardID = card.id
                }
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    Text(card.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.trailing, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(card.effectiveLabels.prefix(2), id: \.self) { label in
                        Text(label)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(labelColor(for: label).opacity(0.75)))
                            .lineLimit(1)
                    }

                    if let issueNumber = card.issueNumber {
                        Text("#\(issueNumber)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Palette.inkMuted)
                    }

                    if let assignee = card.assignee {
                        HStack(spacing: 6) {
                            AvatarView(initials: initials(for: assignee), size: 26)
                            Text(assignee)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Palette.inkMuted)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                    }

                    if let dueDate = card.dueDate {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 13, weight: .medium))
                            Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.system(size: 11, weight: .medium))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                        .foregroundStyle(Palette.inkMuted)
                    }
                }
                .padding(9)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(hex: 0x32288C).opacity(0.86))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                )
                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(PressableStyle(scale: 0.98))
            .accessibilityHint("Opens task details")

            Menu {
                Button {
                    Haptics.tap()
                    editingCardID = card.id
                } label: {
                    Label("Edit card", systemImage: "pencil")
                }

                Divider()

                ForEach(ProjectBoardStatus.allCases) { destination in
                    Button {
                        Haptics.select()
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                            store.moveProjectCard(id: card.id, to: destination)
                        }
                    } label: {
                        if destination == card.status {
                            Label(destination.rawValue, systemImage: "checkmark")
                        } else {
                            Text("Move to \(destination.rawValue)")
                        }
                    }
                    .disabled(destination == card.status)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.inkMuted)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Card actions")
            .padding(.top, 4)
            .padding(.trailing, 4)
        }
    }

    private func labelColor(for label: String) -> Color {
        switch label.lowercased() {
        case "development": return Color(hex: 0x3478D4)
        case "content": return Color(hex: 0x159C94)
        case "ui": return Color(hex: 0x6C48D9)
        default: return Palette.accentBright
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

private struct ProjectBoardCardDetailView: View {
    @EnvironmentObject private var store: AppStore

    @State private var checklistDraft = ""

    var cardID: UUID
    var projectID: UUID
    var fallbackProjectName: String
    var backAccessibilityLabel: String
    var onEdit: () -> Void
    var onBack: () -> Void

    private var card: ProjectBoardCard? {
        store.projectCards.first(where: { $0.id == cardID })
    }

    private var projectTitle: String {
        store.projects.first(where: { $0.id == projectID })?.title ?? fallbackProjectName
    }

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack(spacing: 0) {
                header

                if let card {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 24) {
                            taskSummary(card)
                            descriptionCard(card)
                            detailsCard(card)
                            checklistCard(card)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 40)
                        .padding(.bottom, 160)
                    }
                } else {
                    ContentUnavailableView(
                        "Task unavailable",
                        systemImage: "rectangle.slash",
                        description: Text("This task is no longer on the board.")
                    )
                    .foregroundStyle(.white)
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
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(Color.white.opacity(0.10)))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.15), lineWidth: 1))
            }
            .buttonStyle(PressableStyle(scale: 0.9))
            .accessibilityLabel(backAccessibilityLabel)

            Spacer()

            Text("Task")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            if let card {
                Menu {
                    Button {
                        Haptics.tap()
                        onEdit()
                    } label: {
                        Label("Edit card", systemImage: "pencil")
                    }

                    Divider()

                    ForEach(ProjectBoardStatus.allCases) { destination in
                        Button {
                            Haptics.select()
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                                store.moveProjectCard(id: card.id, to: destination)
                            }
                        } label: {
                            if destination == card.status {
                                Label(destination.rawValue, systemImage: "checkmark")
                            } else {
                                Text("Move to \(destination.rawValue)")
                            }
                        }
                        .disabled(destination == card.status)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(Color.white.opacity(0.10)))
                        .overlay(Circle().strokeBorder(Color.white.opacity(0.15), lineWidth: 1))
                }
                .accessibilityLabel("Task actions")
            } else {
                Color.clear
                    .frame(width: 48, height: 48)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .glassCard(fill: Color.white.opacity(0.10), radius: 28)
        .padding(.horizontal, 24)
        .padding(.top, 6)
    }

    private func taskSummary(_ card: ProjectBoardCard) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(card.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                ForEach(card.effectiveLabels, id: \.self) { label in
                    HStack(spacing: 6) {
                        Image(systemName: "tag")
                            .font(.system(size: 12, weight: .medium))
                        Text(label)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 11)
                    .frame(height: 34)
                    .background(Capsule().fill(labelColor(for: label)))
                }

                HStack(spacing: 8) {
                    Image(systemName: "circle")
                        .font(.system(size: 15, weight: .medium))
                    Text(card.status.rawValue)
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .frame(height: 38)
                .background(Capsule().fill(Color(hex: 0x41378E).opacity(0.92)))
            }

            Text("\(projectTitle) · \(card.issueNumber.map { "#\($0)" } ?? "Not linked")")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .padding(.top, 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func descriptionCard(_ card: ProjectBoardCard) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Description")
                .font(.system(size: 23, weight: .semibold))
                .foregroundStyle(.white)

            Text(card.description.isEmpty ? "No description provided yet." : card.description)
                .font(.system(size: 17))
                .foregroundStyle(Palette.inkMuted)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 25)
        .glassCard(fill: Color.white.opacity(0.08), radius: 24)
    }

    private func detailsCard(_ card: ProjectBoardCard) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Details")
                .font(.system(size: 23, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 2)
                .padding(.bottom, 3)

            detailRow(
                symbol: "person",
                title: "Assignee",
                value: card.assignee ?? "Unassigned",
                initials: card.assignee.map { initials(for: $0) }
            )

            Rectangle()
                .fill(Color.white.opacity(0.11))
                .frame(height: 1)
                .padding(.leading, 39)

            detailRow(
                symbol: "calendar",
                title: "Due date",
                value: card.dueDate?.formatted(date: .abbreviated, time: .omitted) ?? "No due date"
            )
        }
        .padding(.horizontal, 27)
        .padding(.top, 24)
        .padding(.bottom, 12)
        .glassCard(fill: Color.white.opacity(0.08), radius: 24)
    }

    private func checklistCard(_ card: ProjectBoardCard) -> some View {
        let completedCount = card.checklistItems.filter(\.isCompleted).count
        let totalCount = card.checklistItems.count
        let progress = totalCount == 0 ? 0 : Double(completedCount) / Double(totalCount)

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("Checklist")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(completedCount) of \(totalCount) complete")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Palette.inkMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            ProgressView(value: progress)
                .tint(Palette.accentBright)
                .scaleEffect(x: 1, y: 1.4, anchor: .center)

            if card.checklistItems.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "checklist")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Palette.accentBright)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Palette.accentBright.opacity(0.16)))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("No checklist items yet")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        Text("Add a step to break this task down.")
                            .font(.system(size: 12))
                            .foregroundStyle(Palette.inkMuted)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.vertical, 2)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(card.checklistItems.enumerated()), id: \.element.id) { index, item in
                        HStack(spacing: 12) {
                            Button {
                                Haptics.select()
                                store.toggleProjectBoardChecklistItem(cardID: cardID, itemID: item.id)
                            } label: {
                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundStyle(item.isCompleted ? Palette.accentBright : Palette.inkMuted)
                                    .frame(width: 28, height: 34)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(item.isCompleted ? "Mark \(item.title) incomplete" : "Mark \(item.title) complete")

                            Text(item.title)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(item.isCompleted ? Palette.inkFaint : .white)
                                .strikethrough(item.isCompleted, color: Palette.inkFaint)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button {
                                Haptics.tap()
                                store.deleteProjectBoardChecklistItem(cardID: cardID, itemID: item.id)
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Palette.inkFaint)
                                    .frame(width: 34, height: 34)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Delete \(item.title)")
                        }
                        .padding(.vertical, 8)

                        if index < card.checklistItems.count - 1 {
                            Rectangle()
                                .fill(Color.white.opacity(0.10))
                                .frame(height: 1)
                                .padding(.leading, 40)
                        }
                    }
                }
            }

            HStack(spacing: 10) {
                TextField("Add checklist item", text: $checklistDraft)
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
                    .tint(Palette.accentBright)
                    .submitLabel(.done)
                    .onSubmit(addChecklistItem)
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.07))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .accessibilityLabel("New checklist item")

                Button(action: addChecklistItem) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(Palette.accentBright))
                }
                .buttonStyle(PressableStyle(scale: 0.92))
                .disabled(checklistDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(checklistDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)
                .accessibilityLabel("Add checklist item")
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 22)
        .glassCard(fill: Color.white.opacity(0.08), radius: 24)
    }

    private func addChecklistItem() {
        let trimmedTitle = checklistDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty,
              store.addProjectBoardChecklistItem(cardID: cardID, title: trimmedTitle) else { return }
        checklistDraft = ""
        Haptics.tap()
    }

    private func detailRow(
        symbol: String,
        title: String,
        value: String,
        initials: String? = nil
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(.white)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Palette.inkMuted)

            Spacer(minLength: 4)

            if let initials {
                AvatarView(initials: initials, size: 38)
            }

            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .accessibilityHidden(true)
        }
        .frame(minHeight: 72)
    }

    private func labelColor(for label: String) -> Color {
        switch label.lowercased() {
        case "development": return Color(hex: 0x3478D4)
        case "content": return Color(hex: 0x159C94)
        case "ui", "design": return Color(hex: 0x7540E8)
        default: return Palette.accentBright
        }
    }

    private func initials(for name: String) -> String {
        String(name.split(separator: " ").prefix(2).compactMap { $0.first }).uppercased()
    }
}

private struct ProjectBoardCardForm: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var status: ProjectBoardStatus
    @State private var assignee: String?
    @State private var hasDueDate = false
    @State private var dueDate = Date()

    var onAdd: (String, ProjectBoardStatus, String?, Date?) -> Void

    init(
        initialStatus: ProjectBoardStatus,
        onAdd: @escaping (String, ProjectBoardStatus, String?, Date?) -> Void
    ) {
        _status = State(initialValue: initialStatus)
        _assignee = State(initialValue: nil)
        self.onAdd = onAdd
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var selectedAssignee: PersonItem? {
        store.people.first(where: { $0.name == assignee })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("New card")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.white.opacity(0.12)))
                }
                .buttonStyle(PressableStyle(scale: 0.9))
            }

            TextField("Card title", text: $title)
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .tint(Palette.accentBright)
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 8) {
                Text("COLUMN")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(Palette.inkFaint)

                Picker("Column", selection: $status) {
                    ForEach(ProjectBoardStatus.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("ASSIGNEE")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(Palette.inkFaint)

                Menu {
                    Button {
                        assignee = nil
                    } label: {
                        if assignee == nil {
                            Label("Unassigned", systemImage: "checkmark")
                        } else {
                            Text("Unassigned")
                        }
                    }

                    ForEach(store.people) { person in
                        Button {
                            assignee = person.name
                        } label: {
                            if assignee == person.name {
                                Label(person.name, systemImage: "checkmark")
                            } else {
                                Text(person.name)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 10) {
                        if let selectedAssignee {
                            AvatarView(initials: selectedAssignee.initials, size: 30)
                        } else {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 20))
                                .foregroundStyle(Palette.inkMuted)
                                .frame(width: 30, height: 30)
                        }

                        Text(assignee ?? "Unassigned")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white)

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Palette.inkMuted)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                    )
                }
                .accessibilityLabel("Assignee: \(assignee ?? "Unassigned")")
            }

            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $hasDueDate) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Due date")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                        Text(hasDueDate ? "Choose a date" : "No due date")
                            .font(.system(size: 12))
                            .foregroundStyle(Palette.inkMuted)
                    }
                }
                .tint(Palette.accentBright)

                if hasDueDate {
                    DatePicker("Due date", selection: $dueDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .tint(Palette.accentBright)
                        .padding(.leading, 2)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )

            Spacer(minLength: 0)

            Button {
                guard !trimmedTitle.isEmpty else { return }
                Haptics.tap()
                onAdd(trimmedTitle, status, assignee, hasDueDate ? dueDate : nil)
                dismiss()
            } label: {
                Text("Add card")
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
            .disabled(trimmedTitle.isEmpty)
            .opacity(trimmedTitle.isEmpty ? 0.55 : 1)
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
        ProjectBoardView(
            projectID: AppStore.sampleProjects[0].id,
            projectName: AppStore.sampleProjects[0].title,
            onBack: {}
        )
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
