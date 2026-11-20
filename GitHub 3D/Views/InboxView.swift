//
//  InboxView.swift
//  GitHub 3D
//
//  Notifications grouped by day, with filters and swipe actions.
//

import SwiftUI

enum InboxFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case unread = "Unread"
    case reviewRequests = "Review requests"
    case mentions = "Mentions"
    case stars = "Stars"

    var id: String { rawValue }
}

struct InboxView: View {
    @EnvironmentObject private var store: AppStore

    var onOpenMenu: () -> Void = {}

    @AppStorage("settings.markAllReadOnOpen") private var markAllReadOnOpen = true

    @State private var filter: InboxFilter = .all

    private var filtered: [NotificationItem] {
        switch filter {
        case .all:
            return store.notifications
        case .unread:
            return store.notifications.filter { !$0.isRead }
        case .reviewRequests:
            return store.notifications.filter { $0.kind == .review }
        case .mentions:
            return store.notifications.filter { $0.kind == .mention }
        case .stars:
            return store.notifications.filter { $0.kind == .star }
        }
    }

    private var todayItems: [NotificationItem] {
        filtered.filter { $0.isToday }
    }

    private var earlierItems: [NotificationItem] {
        filtered.filter { !$0.isToday }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            chipRow

            if filtered.isEmpty {
                emptyState
            } else {
                feed
            }
        }
        .onAppear {
            if markAllReadOnOpen {
                store.markAllNotificationsRead()
            }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Button {
                Haptics.tap()
                onOpenMenu()
            } label: {
                Image(systemName: "line.3.horizontal")
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

            Spacer()

            HStack(spacing: 7) {
                Text("Inbox")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.white)

                if store.unreadNotificationCount > 0 {
                    Text("\(store.unreadNotificationCount)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7)
                        .frame(minHeight: 22)
                        .background(Capsule().fill(Palette.accentBright))
                        .accessibilityLabel("\(store.unreadNotificationCount) unread notifications")
                }
            }

            Spacer()

            Button {
                Haptics.tap()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    store.markAllNotificationsRead()
                }
            } label: {
                Text("Mark all as read")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 38)
                    .background(Capsule().fill(Color.white.opacity(0.12)))
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.18), lineWidth: 1))
            }
            .buttonStyle(PressableStyle(scale: 0.94))
            .disabled(store.unreadNotificationCount == 0)
            .opacity(store.unreadNotificationCount == 0 ? 0.55 : 1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .glassCard(fill: Color.white.opacity(0.10), radius: 28)
    }

    // MARK: Filters

    private var chipRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(InboxFilter.allCases) { item in
                    SectionChip(title: item.rawValue, isSelected: filter == item) {
                        Haptics.select()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            filter = item
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
        .padding(.bottom, 6)
    }

    // MARK: Feed

    private var feed: some View {
        List {
            if !todayItems.isEmpty {
                notificationSection(title: "Today", items: todayItems)
            }
            if !earlierItems.isEmpty {
                notificationSection(title: "Earlier", items: earlierItems)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear.frame(height: 110)
        }
    }

    private func notificationSection(title: String, items: [NotificationItem]) -> some View {
        Section {
            ForEach(items) { item in
                NotificationRow(item: item)
                    .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Haptics.tap()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                store.deleteNotification(item.id)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        Button {
                            Haptics.select()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                store.toggleNotificationRead(item.id)
                            }
                        } label: {
                            Label(item.isRead ? "Mark unread" : "Mark read", systemImage: "envelope")
                        }
                        .tint(Palette.accent)
                    }
            }
        } header: {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Palette.inkFaint)
                .textCase(nil)
                .listRowInsets(EdgeInsets(top: 14, leading: 20, bottom: 6, trailing: 20))
        }
    }

    // MARK: Empty

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()

            Image(systemName: "bell.slash")
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .frame(width: 76, height: 76)
                .background(Circle().fill(Color.white.opacity(0.08)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

            Text(emptyTitle)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            Text(emptyMessage)
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
        .padding(.bottom, 100)
    }

    private var emptyTitle: String {
        switch filter {
        case .all: return "You're all caught up"
        case .unread: return "No unread notifications"
        case .reviewRequests: return "No review requests"
        case .mentions: return "No mentions yet"
        case .stars: return "No new stars"
        }
    }

    private var emptyMessage: String {
        switch filter {
        case .all: return "New notifications will land here as your repositories move."
        case .unread: return "You're all caught up. New unread notifications will appear here."
        case .reviewRequests: return "When someone asks for your review, it shows up here."
        case .mentions: return "Mentions of your handle in issues and discussions appear here."
        case .stars: return "Stars on your repositories will show up here."
        }
    }
}

// MARK: - Row

struct NotificationRow: View {
    var item: NotificationItem

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            avatar

            VStack(alignment: .leading, spacing: 3) {
                (Text(item.actor).bold() + Text(" " + item.action))
                    .font(.system(size: 15))
                    .foregroundStyle(Palette.ink.opacity(item.isRead ? 0.82 : 1))
                    .fixedSize(horizontal: false, vertical: true)

                if let body = item.body {
                    Text(body)
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 1)
                }

                Text(item.time)
                    .font(.system(size: 13))
                    .foregroundStyle(Palette.inkFaint)
                    .padding(.top, 2)
            }

            Spacer(minLength: 4)

            if !item.isRead {
                Circle()
                    .fill(Palette.accentBright)
                    .frame(width: 9, height: 9)
                    .padding(.top, 6)
                    .shadow(color: Palette.accentBright.opacity(0.7), radius: 6)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(hex: 0x32288C).opacity(item.isRead ? 0.55 : 0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(item.isRead ? 0.08 : 0.14), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var avatar: some View {
        switch item.kind {
        case .review, .mention:
            AvatarView(initials: initials, size: 54)
        case .star:
            iconCircle(symbol: "star.fill", colors: [Palette.accentBright, Palette.accent])
        case .release:
            iconCircle(symbol: "chevron.left.forwardslash.chevron.right", colors: [Color(hex: 0x4B3FB0), Color(hex: 0x32288C)])
        case .organisation:
            iconCircle(symbol: "person.2.fill", colors: [Color(hex: 0x4B3FB0), Color(hex: 0x32288C)])
        }
    }

    private var initials: String {
        let letters = item.actor
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
        return String(letters).uppercased()
    }

    private func iconCircle(symbol: String, colors: [Color]) -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            Image(systemName: symbol)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 54, height: 54)
        .overlay(Circle().strokeBorder(Color.white.opacity(0.18), lineWidth: 1))
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        InboxView()
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
