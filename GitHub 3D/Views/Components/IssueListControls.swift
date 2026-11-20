//
//  IssueListControls.swift
//  GitHub 3D
//
//  Filter and sort menus shared by the issue and pull request lists.
//

import SwiftUI

enum IssueFilter: Hashable {
    case all
    case open
    case closed
    case label(String)

    var title: String {
        switch self {
        case .all: return "All"
        case .open: return "Open"
        case .closed: return "Closed"
        case .label(let label): return label
        }
    }
}

enum IssueSort: String, CaseIterable {
    case newest = "Newest"
    case oldest = "Oldest"
    case mostComments = "Most comments"
}

enum PullRequestFilter: Hashable {
    case all
    case open
    case closed

    var title: String {
        switch self {
        case .all: return "All"
        case .open: return "Open"
        case .closed: return "Closed"
        }
    }
}

enum PullRequestSort: String, CaseIterable {
    case newest = "Newest"
    case oldest = "Oldest"
}

// MARK: - Issue controls

struct IssueListControls: View {
    @Binding var filter: IssueFilter
    @Binding var sort: IssueSort
    @Binding var searchText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ListSearchField(text: $searchText, placeholder: "Search issues")

            HStack(spacing: 8) {
                Menu {
                    Button("All") { filter = .all }
                    Button("Open") { filter = .open }
                    Button("Closed") { filter = .closed }
                    Divider()
                    ForEach(IssueLabelCatalog.all, id: \.self) { label in
                        Button(label) { filter = .label(label) }
                    }
                } label: {
                    controlLabel(
                        symbol: "line.3.horizontal.decrease",
                        text: filter.title,
                        isActive: filter != .all
                    )
                }

                Menu {
                    ForEach(IssueSort.allCases, id: \.self) { option in
                        Button {
                            sort = option
                        } label: {
                            if option == sort {
                                Label(option.rawValue, systemImage: "checkmark")
                            } else {
                                Text(option.rawValue)
                            }
                        }
                    }
                } label: {
                    controlLabel(
                        symbol: "arrow.up.arrow.down",
                        text: sort.rawValue,
                        isActive: sort != .newest
                    )
                }

                Spacer(minLength: 0)
            }
        }
    }

    private func controlLabel(symbol: String, text: String, isActive: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .semibold))
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
        }
        .foregroundStyle(isActive ? Color.white : Palette.inkMuted)
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background {
            if isActive {
                Capsule().fill(
                    LinearGradient(
                        colors: [Palette.accentBright, Palette.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            } else {
                Capsule().fill(Color.white.opacity(0.08))
            }
        }
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.16), lineWidth: 1))
    }
}

// MARK: - Pull request controls

struct PullRequestListControls: View {
    @Binding var filter: PullRequestFilter
    @Binding var sort: PullRequestSort
    @Binding var searchText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ListSearchField(text: $searchText, placeholder: "Search pull requests")

            HStack(spacing: 8) {
                Menu {
                    Button("All") { filter = .all }
                    Button("Open") { filter = .open }
                    Button("Closed") { filter = .closed }
                } label: {
                    controlLabel(
                        symbol: "line.3.horizontal.decrease",
                        text: filter.title,
                        isActive: filter != .all
                    )
                }

                Menu {
                    ForEach(PullRequestSort.allCases, id: \.self) { option in
                        Button {
                            sort = option
                        } label: {
                            if option == sort {
                                Label(option.rawValue, systemImage: "checkmark")
                            } else {
                                Text(option.rawValue)
                            }
                        }
                    }
                } label: {
                    controlLabel(
                        symbol: "arrow.up.arrow.down",
                        text: sort.rawValue,
                        isActive: sort != .newest
                    )
                }

                Spacer(minLength: 0)
            }
        }
    }

    private func controlLabel(symbol: String, text: String, isActive: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .semibold))
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
        }
        .foregroundStyle(isActive ? Color.white : Palette.inkMuted)
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background {
            if isActive {
                Capsule().fill(
                    LinearGradient(
                        colors: [Palette.accentBright, Palette.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            } else {
                Capsule().fill(Color.white.opacity(0.08))
            }
        }
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.16), lineWidth: 1))
    }
}

// MARK: - Search field

struct ListSearchField: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Palette.inkMuted)

            TextField(placeholder, text: $text)
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .tint(Palette.accentBright)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !text.isEmpty {
                Button {
                    Haptics.select()
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkFaint)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(
            Capsule().fill(Color.white.opacity(0.08))
        )
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.14), lineWidth: 1))
    }
}

// MARK: - Helpers

extension IssueItem {
    func matches(_ filter: IssueFilter) -> Bool {
        switch filter {
        case .all: return true
        case .open: return isOpen
        case .closed: return !isOpen
        case .label(let label): return labels.contains(label)
        }
    }
}

extension PullRequestItem {
    func matches(_ filter: PullRequestFilter) -> Bool {
        switch filter {
        case .all: return true
        case .open: return isOpen
        case .closed: return !isOpen
        }
    }
}
