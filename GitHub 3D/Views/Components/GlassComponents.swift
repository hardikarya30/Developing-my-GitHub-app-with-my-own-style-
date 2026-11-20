//
//  GlassComponents.swift
//  GitHub 3D
//
//  Reusable frosted pieces used across the app.
//

import SwiftUI

// MARK: - Avatar

struct AvatarView: View {
    var initials: String
    var size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Palette.accentBright, Palette.accent, Color(hex: 0x2A1E78)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.75), .white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .padding(3)

            Text(initials)
                .font(.system(size: size * 0.34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
        }
        .frame(width: size, height: size)
        .background {
            Circle()
                .fill(Palette.accentBright.opacity(0.55))
                .blur(radius: 16)
                .padding(6)
        }
        .shadow(color: Palette.accentBright.opacity(0.55), radius: 18, x: 0, y: 8)
    }
}

// MARK: - Header

struct GlassHeaderBar: View {
    var title: String
    var hasUnread: Bool = true
    var onMenu: () -> Void
    var onSearch: (() -> Void)?
    var onBell: () -> Void

    var body: some View {
        HStack {
            circleButton(symbol: "line.3.horizontal", action: onMenu)

            Spacer()

            Text(title)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            HStack(spacing: 8) {
                if let onSearch {
                    circleButton(symbol: "magnifyingglass", action: onSearch)
                }

                ZStack(alignment: .topTrailing) {
                    circleButton(symbol: "bell", action: onBell)

                    if hasUnread {
                        Circle()
                            .fill(Color(hex: 0xE879F9))
                            .frame(width: 9, height: 9)
                            .overlay(Circle().strokeBorder(Palette.canvas.opacity(0.6), lineWidth: 1))
                            .offset(x: 1, y: 2)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .glassCard(fill: Color.white.opacity(0.10), radius: 28)
    }

    private func circleButton(symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.20), .white.opacity(0.06)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .overlay(Circle().strokeBorder(.white.opacity(0.22), lineWidth: 1))
        }
        .buttonStyle(PressableStyle(scale: 0.9))
    }
}

// MARK: - Chips

struct SectionChip: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isSelected ? Color.white : Palette.inkMuted)
                .padding(.horizontal, 20)
                .frame(height: 44)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Palette.accentBright, Palette.accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(Capsule().strokeBorder(.white.opacity(0.30), lineWidth: 1))
                            .shadow(color: Palette.accentBright.opacity(0.45), radius: 14, y: 6)
                    } else {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .overlay(Capsule().strokeBorder(.white.opacity(0.14), lineWidth: 1))
                    }
                }
        }
        .buttonStyle(PressableStyle(scale: 0.95))
    }
}

// MARK: - Stats

struct StatBlock: View {
    var value: Int
    var label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(value)")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Palette.inkFaint)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Rows

struct ActivityRowView: View {
    var title: String
    var detail: String
    var systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                    )

                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white)

                Spacer(minLength: 8)

                Text(detail)
                    .font(.system(size: 15))
                    .foregroundStyle(Palette.inkMuted)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.985))
    }
}

struct RepoRowView: View {
    var repo: RepoItem
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.16), .white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(repo.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text("\(repo.language) · Updated \(repo.updated)")
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkFaint)
                        .lineLimit(1)
                }

                Spacer(minLength: 6)

                HStack(spacing: 5) {
                    Image(systemName: repo.isStarred ? "star.fill" : "star")
                        .font(.system(size: 14, weight: .medium))
                    Text("\(repo.stars)")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(repo.isStarred ? Color(hex: 0xFFD479) : Palette.inkMuted)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
            )
        }
        .buttonStyle(PressableStyle())
    }
}

struct EntryRowView: View {
    var entry: SectionEntry
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: entry.symbol)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    Text(entry.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.inkFaint)
                        .lineLimit(1)

                    if !entry.labels.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(entry.labels.prefix(3), id: \.self) { label in
                                Text(label)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(IssueLabelCatalog.color(for: label))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule().fill(IssueLabelCatalog.color(for: label).opacity(0.16))
                                    )
                                    .overlay(
                                        Capsule().strokeBorder(
                                            IssueLabelCatalog.color(for: label).opacity(0.45),
                                            lineWidth: 1
                                        )
                                    )
                            }
                        }
                        .padding(.top, 2)
                    }
                    if !entry.assignees.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(entry.assignees.prefix(4), id: \.self) { name in
                                AvatarView(initials: initials(for: name), size: 20)
                            }

                            if entry.assignees.count > 4 {
                                Text("+\(entry.assignees.count - 4)")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(Palette.inkFaint)
                            }
                        }
                        .padding(.top, 3)
                    }
                }

                Spacer(minLength: 6)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.985))
    }

    private func initials(for name: String) -> String {
        let letters = name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
        return String(letters).uppercased()
    }
}

// MARK: - Headings and buttons

struct SectionHeading: View {
    var title: String
    var subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 27, weight: .bold))
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct GradientActionButton: View {
    var title: String
    var systemImage: String?
    var action: () -> Void

    init(title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Palette.gradientStart, Palette.gradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
            )
            .shadow(color: Palette.gradientStart.opacity(0.45), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(PressableStyle())
    }
}
