//
//  EditProjectBoardCardView.swift
//  GitHub 3D
//
//  Edit a project card's content and board details.
//

import SwiftUI

struct EditProjectBoardCardView: View {
    @EnvironmentObject private var store: AppStore

    var card: ProjectBoardCard
    var onCancel: () -> Void
    var onSave: () -> Void

    @State private var title: String
    @State private var description: String
    @State private var labels: [String]
    @State private var assignee: String?
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var status: ProjectBoardStatus

    private let availableLabels = [
        "feature", "ios", "good first issue", "bug", "enhancement", "design"
    ]

    init(card: ProjectBoardCard, onCancel: @escaping () -> Void, onSave: @escaping () -> Void) {
        self.card = card
        self.onCancel = onCancel
        self.onSave = onSave
        _title = State(initialValue: card.title)
        _description = State(initialValue: card.description)
        _labels = State(initialValue: card.effectiveLabels)
        _assignee = State(initialValue: card.assignee)
        _hasDueDate = State(initialValue: card.dueDate != nil)
        _dueDate = State(initialValue: card.dueDate ?? Date())
        _status = State(initialValue: card.status)
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var assigneeOptions: [String] {
        var names = store.people.map(\.name) + AppStore.defaultCollaborators.map(\.name)
        if let assignee {
            names.append(assignee)
        }
        return Array(Set(names)).sorted()
    }

    private var labelOptions: [String] {
        Array(Set(availableLabels + labels + card.effectiveLabels)).sorted()
    }

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        textFieldSection(title: "Title") {
                            TextField("Card title", text: $title)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white)
                                .tint(Palette.accentBright)
                                .padding(.horizontal, 14)
                                .frame(height: 58)
                                .cardEditSurface(cornerRadius: 18)
                                .accessibilityLabel("Title")

                            if trimmedTitle.isEmpty {
                                Text("A title is required.")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color(hex: 0xFF9AAB))
                                    .padding(.leading, 2)
                            }
                        }

                        textFieldSection(title: "Description") {
                            ZStack(alignment: .topLeading) {
                                if description.isEmpty {
                                    Text("Add a description")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Palette.inkFaint)
                                        .padding(.horizontal, 16)
                                        .padding(.top, 14)
                                }

                                TextEditor(text: $description)
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white)
                                    .scrollContentBackground(.hidden)
                                    .tint(Palette.accentBright)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                            }
                            .frame(minHeight: 132)
                            .cardEditSurface(cornerRadius: 18)
                            .accessibilityLabel("Description")
                        }

                        textFieldSection(title: "Labels") {
                            Menu {
                                ForEach(labelOptions, id: \.self) { label in
                                    Button {
                                        toggleLabel(label)
                                    } label: {
                                        if labels.contains(label) {
                                            Label(label, systemImage: "checkmark")
                                        } else {
                                            Text(label)
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 11) {
                                    Image(systemName: "tag")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundStyle(.white)
                                        .frame(width: 32)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 7) {
                                            if labels.isEmpty {
                                                Text("Add labels")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundStyle(Palette.inkMuted)
                                            } else {
                                                ForEach(labels, id: \.self) { label in
                                                    Text(label)
                                                        .font(.system(size: 12, weight: .medium))
                                                        .foregroundStyle(.white)
                                                        .padding(.horizontal, 11)
                                                        .padding(.vertical, 7)
                                                        .background(Capsule().fill(labelColor(for: label)))
                                                }
                                            }
                                        }
                                    }

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Palette.inkMuted)
                                }
                                .padding(.horizontal, 15)
                                .frame(minHeight: 64)
                                .cardEditSurface(cornerRadius: 18)
                            }
                            .accessibilityLabel("Labels: \(labels.isEmpty ? "None" : labels.joined(separator: ", "))")
                        }

                        textFieldSection(title: "Assignee") {
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

                                ForEach(assigneeOptions, id: \.self) { name in
                                    Button {
                                        assignee = name
                                    } label: {
                                        if assignee == name {
                                            Label(name, systemImage: "checkmark")
                                        } else {
                                            Text(name)
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    if let assignee {
                                        AvatarView(initials: initials(for: assignee), size: 40)
                                    } else {
                                        Image(systemName: "person.crop.circle")
                                            .font(.system(size: 27))
                                            .foregroundStyle(Palette.inkMuted)
                                            .frame(width: 40, height: 40)
                                    }

                                    Text(assignee ?? "Unassigned")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(.white)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Palette.inkMuted)
                                }
                                .padding(.horizontal, 14)
                                .frame(height: 72)
                                .cardEditSurface(cornerRadius: 18)
                            }
                            .accessibilityLabel("Assignee: \(assignee ?? "Unassigned")")
                        }

                        textFieldSection(title: "Due date") {
                            VStack(spacing: 0) {
                                HStack(spacing: 12) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundStyle(.white)
                                        .frame(width: 34)

                                    Text("Due date")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(.white)

                                    Spacer()

                                    Toggle("Due date", isOn: $hasDueDate)
                                        .labelsHidden()
                                        .tint(Palette.accentBright)
                                        .accessibilityLabel("Enable due date")
                                }
                                .frame(height: 66)
                                .padding(.horizontal, 14)

                                if hasDueDate {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.12))
                                        .frame(height: 1)
                                        .padding(.horizontal, 14)

                                    DatePicker("", selection: $dueDate, displayedComponents: .date)
                                        .labelsHidden()
                                        .datePickerStyle(.compact)
                                        .tint(.white)
                                        .padding(.horizontal, 14)
                                        .frame(maxWidth: .infinity, minHeight: 61, alignment: .leading)
                                }
                            }
                            .cardEditSurface(cornerRadius: 18)
                        }

                        textFieldSection(title: "Status") {
                            statusPicker
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 18)
                }
                .scrollDismissesKeyboard(.interactively)

                footer
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(spacing: 12) {
            Capsule()
                .fill(Color.white.opacity(0.72))
                .frame(width: 72, height: 6)
                .padding(.top, 12)

            ZStack {
                Text("Edit card")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)

                HStack {
                    Spacer()
                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(Circle().fill(Color.white.opacity(0.10)))
                            .overlay(Circle().strokeBorder(Color.white.opacity(0.14), lineWidth: 1))
                    }
                    .buttonStyle(PressableStyle(scale: 0.92))
                    .accessibilityLabel("Cancel editing")
                }
            }
            .frame(height: 52)
            .padding(.horizontal, 18)
        }
        .padding(.bottom, 5)
    }

    private var statusPicker: some View {
        HStack(spacing: 4) {
            ForEach(ProjectBoardStatus.allCases) { option in
                Button {
                    Haptics.select()
                    status = option
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: statusSymbol(for: option))
                            .font(.system(size: 15, weight: .medium))
                        Text(option.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(status == option ? .white : Palette.inkMuted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background {
                        if status == option {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Palette.accentBright)
                                .shadow(color: Palette.accentBright.opacity(0.35), radius: 10, y: 4)
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(status == option ? 0.18 : 0.08), lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(status == option ? .isSelected : [])
            }
        }
        .padding(5)
        .cardEditSurface(cornerRadius: 20)
    }

    private var footer: some View {
        VStack(spacing: 10) {
            Button {
                let saved = store.updateProjectCard(
                    id: card.id,
                    title: title,
                    description: description,
                    labels: labels,
                    assignee: assignee,
                    dueDate: hasDueDate ? dueDate : nil,
                    status: status
                )
                guard saved else { return }
                Haptics.tap()
                onSave()
            } label: {
                Text("Save changes")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 17, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Palette.accentBright, Color(hex: 0x3448F5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
            .buttonStyle(PressableStyle())
            .disabled(trimmedTitle.isEmpty)
            .opacity(trimmedTitle.isEmpty ? 0.58 : 1)

            Button(action: onCancel) {
                Text("Cancel")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Palette.inkMuted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 17, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 17, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                    )
            }
            .buttonStyle(PressableStyle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(Color(hex: 0x211A75).opacity(0.76))
    }

    private func textFieldSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .padding(.leading, 1)
            content()
        }
    }

    private func toggleLabel(_ label: String) {
        if labels.contains(label) {
            labels.removeAll { $0 == label }
        } else {
            labels.append(label)
        }
    }

    private func labelColor(for label: String) -> Color {
        switch label.lowercased() {
        case "feature", "enhancement": return Palette.accentBright
        case "ios", "ui": return Color(hex: 0x3478D4)
        case "good first issue": return Color(hex: 0x526AAB)
        case "development": return Color(hex: 0x3478D4)
        case "content": return Color(hex: 0x159C94)
        case "design": return Color(hex: 0x7540E8)
        case "bug": return Color(hex: 0xD94B66)
        default: return Palette.accent
        }
    }

    private func statusSymbol(for status: ProjectBoardStatus) -> String {
        switch status {
        case .todo: return "circle"
        case .inProgress: return "circle"
        case .done: return "checkmark.circle"
        }
    }

    private func initials(for name: String) -> String {
        String(name.split(separator: " ").prefix(2).compactMap { $0.first }).uppercased()
    }
}

private extension View {
    func cardEditSurface(cornerRadius: CGFloat) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color(hex: 0x32288C).opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}
