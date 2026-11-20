//
//  AppStore.swift
//  GitHub 3D
//
//  The app's in-memory data: profile, repositories and section lists.
//

import SwiftUI

struct GitHubProfile {
    var name: String
    var handle: String
    var bio: String
    var website: String
    var initials: String
    var repositories: Int
    var following: Int
    var followers: Int

    static let hardik = GitHubProfile(
        name: "Hardik",
        handle: "hardikarya30",
        bio: "Freelance as Designer system",
        website: "https://design-system-studio-rbvn.bolt.host",
        initials: "HA",
        repositories: 12,
        following: 0,
        followers: 2
    )
}

struct RepoItem: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var language: String
    var updated: String
    var stars: Int
    var blurb: String
    var isStarred: Bool
    var isWatched: Bool = false
    var topics: [String] = []
    var isPrivate: Bool = false
    var defaultBranch: String = "main"
    var hasIssues: Bool = true
    var hasDiscussions: Bool = true
    var hasWiki: Bool = false
    var collaborators: [Collaborator] = []

    var forks: Int {
        Int((Double(stars) / 15.0).rounded())
    }
}

enum CollaboratorRole: String, CaseIterable {
    case read = "Read"
    case write = "Write"
    case owner = "Owner"

    var next: CollaboratorRole {
        switch self {
        case .read: return .write
        case .write: return .owner
        case .owner: return .read
        }
    }
}

struct Collaborator: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var handle: String
    var role: CollaboratorRole

    var initials: String {
        String(
            name
                .split(separator: " ")
                .prefix(2)
                .compactMap { $0.first }
        ).uppercased()
    }
}

struct PersonRepo: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var blurb: String
    var stars: Int
}

struct PersonActivity: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var subtitle: String
    var time: String
    var symbol: String
}

struct PersonItem: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var handle: String
    var bio: String
    var topics: [String] = []
    var repositories: Int = 0
    var followers: Int = 0
    var following: Int = 0
    var isFollowing: Bool = false
    var repos: [PersonRepo] = []
    var activity: [PersonActivity] = []

    var initials: String {
        let letters = name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
        return String(letters).uppercased()
    }
}

struct SectionEntry: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var subtitle: String
    var symbol: String
    var detail: String = ""
    var labels: [String] = []
    var assignees: [String] = []
}

enum ProjectBoardStatus: String, CaseIterable, Identifiable {
    case todo = "To do"
    case inProgress = "In progress"
    case done = "Done"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .todo: return Color(hex: 0xB6B8D8)
        case .inProgress: return Color(hex: 0x38BDF8)
        case .done: return Color(hex: 0x34D399)
        }
    }
}

struct ProjectBoardCard: Identifiable, Hashable {
    var id = UUID()
    var projectID: UUID
    var title: String
    var description: String = "No description provided yet."
    var label: String? = nil
    var labels: [String] = []
    var issueNumber: Int? = nil
    var assignee: String? = nil
    var dueDate: Date? = nil
    var status: ProjectBoardStatus
    var checklistItems: [ProjectBoardChecklistItem] = []

    var effectiveLabels: [String] {
        labels.isEmpty ? label.map { [$0] } ?? [] : labels
    }
}

struct ProjectBoardChecklistItem: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
}

enum ProjectBoardActivityKind: Hashable {
    case added
    case moved
}

struct ProjectBoardActivityEvent: Identifiable, Hashable {
    var id = UUID()
    var projectID: UUID
    var actor: String
    var cardTitle: String
    var kind: ProjectBoardActivityKind
    var previousStatus: ProjectBoardStatus? = nil
    var status: ProjectBoardStatus? = nil
    var timestamp: Date = Date()
}

struct SavedSearch: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var query: String
}

struct RepositoryRelease: Identifiable, Hashable {
    var id = UUID()
    var tag: String
    var name: String
    var published: String
    var notes: String
}

struct MarketplaceApp: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var handle: String
    var blurb: String
    var installs: String
    var rating: String
    var price: String
    var symbol: String
    var bullets: [String] = []
    var isInstalled: Bool = false
    var category: String = "AI"
}

struct CodespaceItem: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var repository: String
    var machine: String
    var region: String
    var lastUsed: String
    var isRunning: Bool
}

struct PRFile: Identifiable, Hashable {
    var id = UUID()
    var path: String
    var additions: Int
    var deletions: Int

    var isMarkdown: Bool { path.lowercased().hasSuffix(".md") }
}

struct PRCommit: Identifiable, Hashable {
    var shortSHA: String
    var message: String
    var author: String
    var relativeTime: String
    var changedFileCount: Int

    var id: String { shortSHA }
}

struct PRReviewComment: Identifiable, Hashable {
    var id = UUID()
    var reviewer: String
    var path: String
    var line: Int
    var time: String
    var body: String
    var reactions: CommentReactions = CommentReactions()
}

enum PRReviewDecision: String, CaseIterable, Identifiable {
    case comment = "Comment"
    case approve = "Approve"
    case requestChanges = "Request changes"

    var id: String { rawValue }

    var statusTitle: String {
        switch self {
        case .comment: return "Commented"
        case .approve: return "Approved"
        case .requestChanges: return "Changes requested"
        }
    }

    var symbol: String {
        switch self {
        case .comment: return "text.bubble"
        case .approve: return "checkmark.circle.fill"
        case .requestChanges: return "exclamationmark.bubble.fill"
        }
    }
}

struct PRReviewEvent: Identifiable, Hashable {
    var id = UUID()
    var reviewer: String
    var time: String
    var decision: PRReviewDecision
    var summary: String
}

struct PullRequestItem: Identifiable, Hashable {
    var id = UUID()
    var number: Int
    var title: String
    var body: String
    var repository: String
    var author: String
    var time: String
    var baseBranch: String
    var headBranch: String
    var isOpen: Bool
    var isApproved: Bool
    var files: [PRFile]
    var reviewComments: [PRReviewComment] = []
    var reviewEvents: [PRReviewEvent] = []

    var latestReviewEvent: PRReviewEvent? { reviewEvents.last }

    var commits: [PRCommit] {
        PRCommitHistory.make(for: self)
    }

    var listEntry: SectionEntry {
        SectionEntry(
            title: title,
            subtitle: "#\(number) · \(isOpen ? "open" : "merged") · \(time)",
            symbol: "arrow.triangle.pull",
            detail: body
        )
    }
}

enum PRCommitHistory {
    static func make(for request: PullRequestItem) -> [PRCommit] {
        let commitCount = min(3, max(1, request.files.count))
        return (0..<commitCount).map { index in
            let startIndex = request.files.count * index / commitCount
            let endIndex = request.files.count * (index + 1) / commitCount
            let files = Array(request.files[startIndex..<endIndex])
            let message: String

            if request.files.isEmpty {
                message = "Prepare \(request.title)"
            } else if index == commitCount - 1 {
                message = request.title
            } else {
                let filename = files.first?.path.split(separator: "/").last.map(String.init) ?? "changes"
                message = "Update \(filename)"
            }

            let seed = [
                request.repository,
                String(request.number),
                request.title,
                files.map(\.path).joined(separator: ","),
                String(index)
            ].joined(separator: "|")

            return PRCommit(
                shortSHA: shortSHA(for: seed),
                message: message,
                author: request.author,
                relativeTime: relativeTime(
                    for: request.time,
                    index: index,
                    count: commitCount
                ),
                changedFileCount: files.count
            )
        }
    }

    private static func shortSHA(for seed: String) -> String {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in seed.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }

        return String(String(hash, radix: 16).suffix(7))
            .padding(toLength: 7, withPad: "0", startingAt: 0)
    }

    private static func relativeTime(for latest: String, index: Int, count: Int) -> String {
        let steps = count - index - 1
        guard steps > 0 else { return latest }

        if latest == "just now" {
            let minutes = steps * 15
            return "\(minutes) minutes ago"
        }

        let parts = latest.split(separator: " ")
        let amount = parts.first.flatMap { Int($0) } ?? 0

        if latest.contains("hour"), amount > 0 {
            let hours = amount + steps
            return "\(hours) \(hours == 1 ? "hour" : "hours") ago"
        }

        if latest == "yesterday" {
            return dayLabel(1 + steps)
        }

        if latest.contains("day"), amount > 0 {
            return dayLabel(amount + steps)
        }

        return latest
    }

    private static func dayLabel(_ days: Int) -> String {
        days == 1 ? "yesterday" : "\(days) days ago"
    }
}

struct DiscussionReply: Identifiable, Hashable {
    var id = UUID()
    var author: String
    var time: String
    var body: String
}

struct DiscussionItem: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var category: String
    var author: String
    var time: String
    var body: String
    var replies: [DiscussionReply]

    var listEntry: SectionEntry {
        SectionEntry(
            title: title,
            subtitle: "\(replies.count) replies · \(time)",
            symbol: "bubble.left"
        )
    }
}

struct OrganisationItem: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var handle: String
    var about: String
    var memberCount: Int
    var isMember: Bool

    var initials: String {
        let letters = name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
        return String(letters).uppercased()
    }

    var listEntry: SectionEntry {
        SectionEntry(
            title: name,
            subtitle: "\(memberCount) members",
            symbol: "building.2"
        )
    }
}

struct GistItem: Identifiable, Hashable {
    var id = UUID()
    var filename: String
    var language: String
    var about: String
    var code: String
    var isPrivate: Bool
    var updated: String
    var stars: Int
    var isMine: Bool
    var created: String = "3 weeks ago"

    var visibilityLabel: String { isPrivate ? "Private" : "Public" }
}

struct RepoFile: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var size: String
    var changed: String
    var isFolder: Bool
    var language: String = "Swift"
    var code: String = ""
}

enum IssueLabelCatalog {    static let all = ["bug", "enhancement", "design", "good first issue"]
    static let milestones = ["v1.4", "v1.5", "Backlog"]

    static func color(for label: String) -> Color {
        switch label {
        case "bug": return Color(hex: 0xFF6B6B)
        case "enhancement": return Palette.accentBright
        case "design": return Color(hex: 0x5AC8FA)
        case "good first issue": return Color(hex: 0x3FB950)
        default: return Palette.inkMuted
        }
    }
}

struct IssueComment: Identifiable, Hashable {
    var id = UUID()
    var author: String
    var time: String
    var body: String
    var reactions: CommentReactions = CommentReactions()
}

struct IssueActivityEvent: Identifiable, Hashable {
    var id = UUID()
    var actor: String
    var action: String
    var detail: String? = nil
    var timestamp: Date = Date()
}

enum ReactionKind: String, CaseIterable, Identifiable {
    case thumbsUp = "thumbsup"
    case heart
    case rocket
    case party

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .thumbsUp: return "hand.thumbsup"
        case .heart: return "heart"
        case .rocket: return "rocket"
        case .party: return "party.popper"
        }
    }

    var title: String {
        switch self {
        case .thumbsUp: return "Thumbs up"
        case .heart: return "Heart"
        case .rocket: return "Rocket"
        case .party: return "Party popper"
        }
    }
}

struct CommentReactions: Hashable {
    var counts: [String: Int] = [:]
    var mine: Set<String> = []

    func count(for kind: ReactionKind) -> Int {
        counts[kind.rawValue] ?? 0
    }

    func isMine(_ kind: ReactionKind) -> Bool {
        mine.contains(kind.rawValue)
    }

    mutating func toggle(_ kind: ReactionKind) {
        let key = kind.rawValue
        if mine.contains(key) {
            mine.remove(key)
            counts[key] = max(0, (counts[key] ?? 0) - 1)
        } else {
            mine.insert(key)
            counts[key] = (counts[key] ?? 0) + 1
        }
    }
}

struct IssueItem: Identifiable, Hashable {
    var id = UUID()
    var number: Int
    var title: String
    var body: String
    var code: String?
    var author: String
    var time: String
    var repository: String
    var isOpen: Bool
    var comments: [IssueComment]
    var labels: [String] = []
    var milestone: String? = nil
    var assignees: [String] = []
    var activity: [IssueActivityEvent] = []

    var stateWord: String { isOpen ? "Open" : "Closed" }

    var initials: String {
        let letters = author
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
        return String(letters).uppercased()
    }

    var listEntry: SectionEntry {
        SectionEntry(
            title: title,
            subtitle: "#\(number) · \(isOpen ? "opened" : "closed") \(time)",
            symbol: isOpen ? "exclamationmark.circle" : "checkmark.circle",
            detail: body,
            labels: labels,
            assignees: assignees
        )
    }
}

enum HomeSection: String, CaseIterable, Identifiable {
    case home = "Home"
    case repositories = "Repositories"
    case starred = "Starred"
    case organisations = "Organisations"
    case issues = "Issues"
    case pullRequests = "Pull requests"
    case discussions = "Discussions"
    case projects = "Projects"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .home: return "house"
        case .repositories: return "book.closed"
        case .starred: return "star"
        case .organisations: return "building.2"
        case .issues: return "exclamationmark.circle"
        case .pullRequests: return "arrow.triangle.pull"
        case .discussions: return "bubble.left.and.bubble.right"
        case .projects: return "square.stack.3d.up"
        }
    }

    var subtitle: String {
        switch self {
        case .home: return "Your activity, all in one place"
        case .repositories: return "Everything you are building"
        case .starred: return "Saved work, one tap away"
        case .organisations: return "Teams you belong to"
        case .issues: return "Work that needs attention"
        case .pullRequests: return "Changes waiting on review"
        case .discussions: return "Conversations in your communities"
        case .projects: return "Plans in motion"
        }
    }
}

struct ActivityHighlight: Identifiable {
    var id: String { section.rawValue }
    var section: HomeSection
    var detail: String
}

enum NotificationKind: String, Hashable {
    case review
    case mention
    case star
    case release
    case organisation
}

enum CopilotRole: String, Hashable {
    case user
    case copilot
}

struct CopilotMessage: Identifiable, Hashable {
    var id = UUID()
    var role: CopilotRole
    var text: String
    var model: String?
    var time: String
}

struct CopilotConversation: Identifiable, Hashable {
    var id = UUID()
    var messages: [CopilotMessage]
    var model: String
    var createdAt: Date = Date()

    /// The first thing the user asked, used as the conversation's title.
    var title: String {
        messages.first(where: { $0.role == .user })?.text ?? "New conversation"
    }

    /// The latest Copilot reply, shown as the card's one-line preview.
    var preview: String {
        messages.last(where: { $0.role == .copilot })?.text ?? "No reply yet."
    }

    var countLabel: String {
        messages.count == 1 ? "1 message" : "\(messages.count) messages"
    }

    var timeLabel: String {
        let seconds = max(0, Date().timeIntervalSince(createdAt))
        if seconds < 60 { return "just now" }
        if seconds < 3600 { return "\(Int(seconds / 60))m ago" }
        if seconds < 86_400 { return "\(Int(seconds / 3600))h ago" }
        return "\(Int(seconds / 86_400))d ago"
    }
}

struct NotificationItem: Identifiable, Hashable {
    var id = UUID()
    var actor: String
    var action: String
    var body: String?
    var time: String
    var kind: NotificationKind
    var isRead: Bool
    var isToday: Bool
}

final class AppStore: ObservableObject {
    @Published var profile: GitHubProfile
    @Published var status: String = "Working from home"
    @Published var statusIsBusy: Bool = false
    @Published var statusExpiration: String = "Never"
    @Published var statusVisibility: String = "Everyone"
    @Published var profileReadme: String = AppStore.starterProfileReadme
    @Published var repositories: [RepoItem]
    @Published var issues: [IssueItem]
    @Published var pullRequests: [PullRequestItem]
    @Published var discussions: [DiscussionItem]
    @Published var projects: [SectionEntry]
    @Published var projectCards: [ProjectBoardCard]
    @Published var projectBoardActivityEvents: [ProjectBoardActivityEvent]
    @Published var organisations: [OrganisationItem]

    @Published var notifications: [NotificationItem]

    var unreadNotificationCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    @Published var gists: [GistItem] = AppStore.sampleGists

    /// Set when a gist is deleted so the list can confirm it briefly.
    @Published var gistDeletionMessage: String?

    @Published var readmes: [String: String] = [:]

    @Published var followedTopics: Set<String> = []

    /// Repositories opened this session, newest first.
    @Published var recentlyViewedRepositories: [RepoItem] = []

    func isFollowingTopic(_ topic: String) -> Bool {
        followedTopics.contains(topic)
    }

    func toggleTopicFollow(_ topic: String) {
        if followedTopics.contains(topic) {
            followedTopics.remove(topic)
        } else {
            followedTopics.insert(topic)
        }
    }

    static func topicDescription(for topic: String) -> String {
        switch topic {
        case "Swift":
            return "The language behind every app in this workspace — safe, fast and expressive."
        case "SwiftUI":
            return "Declarative interfaces for every Apple platform, from one codebase."
        case "Liquid glass":
            return "Frosted surfaces, depth and motion for modern app interfaces."
        case "Design systems":
            return "Tokens, components and patterns that keep products consistent."
        case "AI":
            return "On-device models, prompts and tooling for building with AI."
        default:
            return "A community topic on GitHub 3D."
        }
    }

    static func topicFollowerCount(for topic: String) -> String {
        switch topic {
        case "Swift": return "12.4k"
        case "SwiftUI": return "8.6k"
        case "Liquid glass": return "1.2k"
        case "Design systems": return "4.1k"
        case "AI": return "9.8k"
        default: return "320"
        }
    }

    let weeklyActivity = [12, 18, 9, 24, 15, 6, 11]
    let weekdayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    /// Twelve weeks of daily contribution counts, oldest first.
    let contributionHeatmap: [Int] = (0..<84).map { index in
        let value = (index * 13 + index / 3 + 5) % 7
        return max(0, value - 1)
    }

    func readme(for name: String) -> String {        if let saved = readmes[name] {
            return saved
        }
        return AppStore.defaultReadme(for: name)
    }

    func setReadme(_ markdown: String, for name: String) {
        readmes[name] = markdown
    }

    static func defaultReadme(for name: String) -> String {
        if name == "swiftui-lab" {
            return """
            # Liquid Glass Kit

            A collection of beautiful, reusable SwiftUI components.

            ## Quick start

            ```swift
            import SwiftUI
            ```
            """
        }

        let title = name
            .replacingOccurrences(of: "-", with: " ")
            .capitalized

        return """
        # \(title)

        A focused SwiftUI package, built to be dropped straight into your app.

        ## Quick start

        ```swift
        import SwiftUI
        ```
        """
    }

    @Published var copilotMessages: [CopilotMessage] = []

    /// Every Copilot conversation from this session, newest first.
    @Published var copilotConversations: [CopilotConversation] = []

    @Published var activeCopilotConversationID: UUID?

    @Published var exploreRepositories: [RepoItem]
    @Published var people: [PersonItem]
    @Published var savedSearches: [SavedSearch]
    @Published var releases: [String: [RepositoryRelease]]
    @Published var marketplaceApps: [MarketplaceApp]
    @Published var codespaces: [CodespaceItem]

    var nextIssueNumber: Int = 129
    var nextPullRequestNumber: Int = 43

    init(
        profile: GitHubProfile = .hardik,
        repositories: [RepoItem] = AppStore.sampleRepositories,
        issues: [IssueItem] = AppStore.sampleIssues,
        pullRequests: [PullRequestItem] = AppStore.samplePullRequests,
        discussions: [DiscussionItem] = AppStore.sampleDiscussions,
        projects: [SectionEntry] = AppStore.sampleProjects,
        projectCards: [ProjectBoardCard]? = nil,
        projectBoardActivityEvents: [ProjectBoardActivityEvent]? = nil,
        organisations: [OrganisationItem] = AppStore.sampleOrganisations,
        notifications: [NotificationItem] = AppStore.sampleNotifications,
        exploreRepositories: [RepoItem] = AppStore.sampleExploreRepositories,
        people: [PersonItem] = AppStore.samplePeople,
        savedSearches: [SavedSearch] = [],
        releases: [String: [RepositoryRelease]]? = nil,
        marketplaceApps: [MarketplaceApp] = AppStore.sampleMarketplaceApps,
        codespaces: [CodespaceItem] = AppStore.sampleCodespaces
    ) {
        self.profile = profile
        self.repositories = repositories
        self.issues = issues
        self.pullRequests = pullRequests
        self.discussions = discussions
        self.projects = projects
        let initialProjectCards = projectCards ?? Self.sampleProjectCards(for: projects)
        self.projectCards = initialProjectCards
        self.projectBoardActivityEvents = projectBoardActivityEvents
            ?? Self.sampleProjectBoardActivity(for: initialProjectCards, profileName: profile.name)
        self.organisations = organisations
        self.notifications = notifications
        self.exploreRepositories = exploreRepositories
        self.people = people
        self.savedSearches = savedSearches

        if let releases {
            self.releases = releases
        } else {
            var initial: [String: [RepositoryRelease]] = [:]
            for repo in repositories + exploreRepositories where initial[repo.name] == nil {
                initial[repo.name] = AppStore.sampleReleases
            }
            self.releases = initial
        }

        self.marketplaceApps = marketplaceApps
        self.codespaces = codespaces

        if let savedReadme = UserDefaults.standard.string(forKey: "profile.readme") {
            self.profileReadme = savedReadme
        }

        for index in self.repositories.indices where self.repositories[index].collaborators.isEmpty {
            self.repositories[index].collaborators = AppStore.defaultCollaborators
        }
        for index in self.exploreRepositories.indices
        where self.exploreRepositories[index].collaborators.isEmpty {
            self.exploreRepositories[index].collaborators = AppStore.defaultCollaborators
        }
    }

    func boardCards(for projectID: UUID) -> [ProjectBoardCard] {
        projectCards.filter { $0.projectID == projectID }
    }

    func projectBoardActivity(for projectID: UUID) -> [ProjectBoardActivityEvent] {
        projectBoardActivityEvents
            .filter { $0.projectID == projectID }
            .sorted { $0.timestamp > $1.timestamp }
    }

    func addProjectCard(
        projectID: UUID,
        title: String,
        status: ProjectBoardStatus,
        assignee: String? = nil,
        dueDate: Date? = nil
    ) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        projectCards.append(
            ProjectBoardCard(
                projectID: projectID,
                title: trimmedTitle,
                assignee: assignee,
                dueDate: dueDate,
                status: status
            )
        )
        projectBoardActivityEvents.append(
            ProjectBoardActivityEvent(
                projectID: projectID,
                actor: profile.name,
                cardTitle: trimmedTitle,
                kind: .added,
                status: status
            )
        )
    }

    func moveProjectCard(id: UUID, to status: ProjectBoardStatus) {
        guard let index = projectCards.firstIndex(where: { $0.id == id }) else { return }
        let previousStatus = projectCards[index].status
        guard previousStatus != status else { return }

        projectCards[index].status = status
        projectBoardActivityEvents.append(
            ProjectBoardActivityEvent(
                projectID: projectCards[index].projectID,
                actor: profile.name,
                cardTitle: projectCards[index].title,
                kind: .moved,
                previousStatus: previousStatus,
                status: status
            )
        )
    }

    @discardableResult
    func rescheduleProjectCard(id: UUID, dueDate: Date) -> Bool {
        guard let index = projectCards.firstIndex(where: { $0.id == id }) else { return false }
        projectCards[index].dueDate = Calendar.current.startOfDay(for: dueDate)
        return true
    }

    @discardableResult
    func updateProjectCard(
        id: UUID,
        title: String,
        description: String,
        labels: [String],
        assignee: String?,
        dueDate: Date?,
        status: ProjectBoardStatus
    ) -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty,
              let index = projectCards.firstIndex(where: { $0.id == id }) else { return false }

        let previousStatus = projectCards[index].status
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let uniqueLabels = labels.reduce(into: [String]()) { result, label in
            let trimmedLabel = label.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedLabel.isEmpty && !result.contains(trimmedLabel) {
                result.append(trimmedLabel)
            }
        }

        projectCards[index].title = trimmedTitle
        projectCards[index].description = trimmedDescription.isEmpty
            ? "No description provided yet."
            : trimmedDescription
        projectCards[index].labels = uniqueLabels
        projectCards[index].label = uniqueLabels.first
        projectCards[index].assignee = assignee
        projectCards[index].dueDate = dueDate
        projectCards[index].status = status

        if previousStatus != status {
            projectBoardActivityEvents.append(
                ProjectBoardActivityEvent(
                    projectID: projectCards[index].projectID,
                    actor: profile.name,
                    cardTitle: projectCards[index].title,
                    kind: .moved,
                    previousStatus: previousStatus,
                    status: status
                )
            )
        }

        return true
    }

    @discardableResult
    func addProjectBoardChecklistItem(cardID: UUID, title: String) -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty,
              let cardIndex = projectCards.firstIndex(where: { $0.id == cardID }) else { return false }
        projectCards[cardIndex].checklistItems.append(ProjectBoardChecklistItem(title: trimmedTitle))
        return true
    }

    func toggleProjectBoardChecklistItem(cardID: UUID, itemID: UUID) {
        guard let cardIndex = projectCards.firstIndex(where: { $0.id == cardID }),
              let itemIndex = projectCards[cardIndex].checklistItems.firstIndex(where: { $0.id == itemID }) else {
            return
        }
        projectCards[cardIndex].checklistItems[itemIndex].isCompleted.toggle()
    }

    func deleteProjectBoardChecklistItem(cardID: UUID, itemID: UUID) {
        guard let cardIndex = projectCards.firstIndex(where: { $0.id == cardID }) else { return }
        projectCards[cardIndex].checklistItems.removeAll { $0.id == itemID }
    }

    static let defaultCollaborators: [Collaborator] = [
        Collaborator(name: "Hardik Arya", handle: "@hardikarya30", role: .owner),
        Collaborator(name: "Priya Desai", handle: "@priyadesai", role: .write),
        Collaborator(name: "Sam Okafor", handle: "@samokafor", role: .write),
        Collaborator(name: "Mei Lin", handle: "@meilin", role: .read)
    ]

    var topRepositories: [RepoItem] {
        Array(repositories.prefix(2))
    }

    var topSidebarRepositories: [RepoItem] {
        Array(repositories.filter { $0.name.contains("/") }.prefix(3))
    }

    var starredRepositories: [RepoItem] {
        var seen = Set<String>()
        var result: [RepoItem] = []

        for repo in repositories + exploreRepositories where repo.isStarred {
            guard !seen.contains(repo.name) else { continue }
            seen.insert(repo.name)
            result.append(repo)
        }

        return result
    }

    func isStarred(_ name: String) -> Bool {
        if let repo = repositories.first(where: { $0.name == name }) {
            return repo.isStarred
        }
        if let repo = exploreRepositories.first(where: { $0.name == name }) {
            return repo.isStarred
        }
        return false
    }

    func toggleStar(named name: String) {
        let target = !isStarred(name)
        let delta = target ? 1 : -1

        for index in repositories.indices where repositories[index].name == name {
            repositories[index].isStarred = target
            repositories[index].stars = max(0, repositories[index].stars + delta)
        }

        for index in exploreRepositories.indices where exploreRepositories[index].name == name {
            exploreRepositories[index].isStarred = target
            exploreRepositories[index].stars = max(0, exploreRepositories[index].stars + delta)
        }
    }

    var watchedRepositories: [RepoItem] {
        var seen = Set<String>()
        var result: [RepoItem] = []

        for repo in repositories + exploreRepositories where repo.isWatched {
            guard !seen.contains(repo.name) else { continue }
            seen.insert(repo.name)
            result.append(repo)
        }

        return result
    }

    func isWatched(_ name: String) -> Bool {
        if let repo = repositories.first(where: { $0.name == name }) {
            return repo.isWatched
        }
        if let repo = exploreRepositories.first(where: { $0.name == name }) {
            return repo.isWatched
        }
        return false
    }

    func toggleWatch(named name: String) {
        let target = !isWatched(name)

        for index in repositories.indices where repositories[index].name == name {
            repositories[index].isWatched = target
        }

        for index in exploreRepositories.indices where exploreRepositories[index].name == name {
            exploreRepositories[index].isWatched = target
        }
    }

    private static let recentlyViewedLimit = 4

    func recordRepositoryView(_ repo: RepoItem) {
        var updated = recentlyViewedRepositories.filter { $0.name != repo.name }
        updated.insert(repo, at: 0)
        recentlyViewedRepositories = Array(updated.prefix(AppStore.recentlyViewedLimit))
    }

    func clearRecentlyViewedRepositories() {
        recentlyViewedRepositories.removeAll()
    }

    var highlights: [ActivityHighlight] {
        [
            ActivityHighlight(section: .issues, detail: "\(issues.filter(\.isOpen).count) open"),
            ActivityHighlight(section: .pullRequests, detail: "\(pullRequests.filter(\.isOpen).count) open"),
            ActivityHighlight(section: .discussions, detail: "\(discussions.count) new")
        ]
    }

    @discardableResult
    func addIssue(title: String, detail: String, repository: String) -> IssueItem {
        let issue = IssueItem(
            number: nextIssueNumber,
            title: title,
            body: detail.isEmpty ? "No description provided yet." : detail,
            code: nil,
            author: profile.name,
            time: "just now",
            repository: repository,
            isOpen: true,
            comments: [],
            activity: [
                IssueActivityEvent(actor: profile.name, action: "opened this issue")
            ]
        )
        nextIssueNumber += 1
        issues.insert(issue, at: 0)
        return issue
    }

    @discardableResult
    func addPullRequest(title: String, detail: String, repository: String) -> PullRequestItem {
        let request = PullRequestItem(
            number: nextPullRequestNumber,
            title: title,
            body: detail.isEmpty ? "No description provided yet." : detail,
            repository: repository,
            author: profile.name,
            time: "just now",
            baseBranch: "main",
            headBranch: "feature/\(title.lowercased().replacingOccurrences(of: " ", with: "-"))",
            isOpen: true,
            isApproved: false,
            files: []
        )
        nextPullRequestNumber += 1
        pullRequests.insert(request, at: 0)
        return request
    }

    func toggleIssueState(_ id: UUID) {
        guard let index = issues.firstIndex(where: { $0.id == id }) else { return }
        issues[index].isOpen.toggle()
        issues[index].activity.append(
            IssueActivityEvent(
                actor: profile.name,
                action: issues[index].isOpen ? "reopened this issue" : "closed this issue"
            )
        )
    }

    func toggleIssueLabel(_ label: String, on id: UUID) {
        guard let index = issues.firstIndex(where: { $0.id == id }) else { return }
        let isRemoving = issues[index].labels.contains(label)
        if isRemoving {
            issues[index].labels.removeAll { $0 == label }
        } else {
            issues[index].labels.append(label)
        }
        issues[index].activity.append(
            IssueActivityEvent(
                actor: profile.name,
                action: "\(isRemoving ? "removed" : "added") the \(label) label"
            )
        )
    }

    func setIssueMilestone(_ milestone: String?, for id: UUID) {
        guard let index = issues.firstIndex(where: { $0.id == id }) else { return }
        issues[index].milestone = milestone
    }

    func toggleIssueAssignee(_ name: String, on id: UUID) {
        guard let index = issues.firstIndex(where: { $0.id == id }) else { return }
        let isRemoving = issues[index].assignees.contains(name)
        if isRemoving {
            issues[index].assignees.removeAll { $0 == name }
        } else {
            issues[index].assignees.append(name)
        }
        issues[index].activity.append(
            IssueActivityEvent(
                actor: profile.name,
                action: "\(isRemoving ? "unassigned" : "assigned") \(name)"
            )
        )
    }

    func approvePullRequest(_ id: UUID) {
        guard let index = pullRequests.firstIndex(where: { $0.id == id }) else { return }
        pullRequests[index].isApproved = true
    }

    func submitPullRequestReview(_ summary: String, decision: PRReviewDecision, to id: UUID) {
        let trimmedSummary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSummary.isEmpty,
              let index = pullRequests.firstIndex(where: { $0.id == id }),
              pullRequests[index].isOpen else { return }

        pullRequests[index].reviewEvents.append(
            PRReviewEvent(
                reviewer: profile.name,
                time: "just now",
                decision: decision,
                summary: trimmedSummary
            )
        )

        switch decision {
        case .comment:
            break
        case .approve:
            pullRequests[index].isApproved = true
        case .requestChanges:
            pullRequests[index].isApproved = false
        }
    }

    func mergePullRequest(_ id: UUID) {
        guard let index = pullRequests.firstIndex(where: { $0.id == id }) else { return }
        guard pullRequests[index].isOpen else { return }
        pullRequests[index].isOpen = false
    }

    func collaborators(for repoID: UUID) -> [Collaborator] {
        if let repo = repositories.first(where: { $0.id == repoID }) {
            return repo.collaborators
        }
        if let repo = exploreRepositories.first(where: { $0.id == repoID }) {
            return repo.collaborators
        }
        return []
    }

    func cycleCollaboratorRole(for repoID: UUID, collaboratorID: UUID) {
        if let index = repositories.firstIndex(where: { $0.id == repoID }),
           let personIndex = repositories[index].collaborators.firstIndex(where: {
               $0.id == collaboratorID
           }) {
            let current = repositories[index].collaborators[personIndex].role
            repositories[index].collaborators[personIndex].role = current.next
            return
        }

        if let index = exploreRepositories.firstIndex(where: { $0.id == repoID }),
           let personIndex = exploreRepositories[index].collaborators.firstIndex(where: {
               $0.id == collaboratorID
           }) {
            let current = exploreRepositories[index].collaborators[personIndex].role
            exploreRepositories[index].collaborators[personIndex].role = current.next
        }
    }

    func addCollaborator(to repoID: UUID, name: String, handle: String) {
        let newPerson = Collaborator(name: name, handle: handle, role: .read)

        if let index = repositories.firstIndex(where: { $0.id == repoID }) {
            guard !repositories[index].collaborators.contains(where: {
                $0.handle.caseInsensitiveCompare(handle) == .orderedSame
            }) else { return }
            repositories[index].collaborators.append(newPerson)
            return
        }

        if let index = exploreRepositories.firstIndex(where: { $0.id == repoID }) {
            guard !exploreRepositories[index].collaborators.contains(where: {
                $0.handle.caseInsensitiveCompare(handle) == .orderedSame
            }) else { return }
            exploreRepositories[index].collaborators.append(newPerson)
        }
    }

    func addReviewComment(_ body: String, path: String, line: Int, to id: UUID) {
        guard let index = pullRequests.firstIndex(where: { $0.id == id }) else { return }
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmedPath.isEmpty else { return }
        pullRequests[index].reviewComments.append(
            PRReviewComment(
                reviewer: profile.name,
                path: trimmedPath,
                line: max(1, line),
                time: "just now",
                body: trimmed
            )
        )
    }

    func addGist(filename: String, language: String, about: String, code: String, isPrivate: Bool) {
        let trimmedName = filename.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        let trimmedAbout = about.trimmingCharacters(in: .whitespacesAndNewlines)
        gists.insert(
            GistItem(
                filename: trimmedName,
                language: language,
                about: trimmedAbout.isEmpty ? "A new snippet." : trimmedAbout,
                code: code,
                isPrivate: isPrivate,
                updated: "just now",
                stars: 0,
                isMine: true,
                created: "just now"
            ),
            at: 0
        )
    }

    func updateGist(id: UUID, filename: String, about: String, code: String) {
        let trimmedName = filename.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty,
              let index = gists.firstIndex(where: { $0.id == id }) else { return }

        let trimmedAbout = about.trimmingCharacters(in: .whitespacesAndNewlines)
        gists[index].filename = trimmedName
        gists[index].about = trimmedAbout.isEmpty ? "A snippet in this gist." : trimmedAbout
        gists[index].code = code
        gists[index].updated = "just now"
    }

    func deleteGist(_ id: UUID) {
        guard let gist = gists.first(where: { $0.id == id }) else { return }
        gists.removeAll { $0.id == id }
        gistDeletionMessage = "Deleted \(gist.filename)"
    }

    func clearGistDeletionMessage() {
        gistDeletionMessage = nil
    }

    func toggleOrganisationMembership(_ id: UUID) {        guard let index = organisations.firstIndex(where: { $0.id == id }) else { return }
        organisations[index].isMember.toggle()
        organisations[index].memberCount += organisations[index].isMember ? 1 : -1
    }

    func togglePersonFollow(_ id: UUID) {
        guard let index = people.firstIndex(where: { $0.id == id }) else { return }
        people[index].isFollowing.toggle()
        people[index].followers += people[index].isFollowing ? 1 : -1
    }

    func addSavedSearch(name: String, query: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !trimmedQuery.isEmpty else { return }
        savedSearches.removeAll { $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame }
        savedSearches.append(SavedSearch(name: trimmedName, query: trimmedQuery))
    }

    func removeSavedSearch(_ id: UUID) {
        savedSearches.removeAll { $0.id == id }
    }

    func addDiscussionReply(_ body: String, to id: UUID) {        guard let index = discussions.firstIndex(where: { $0.id == id }) else { return }
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        discussions[index].replies.append(
            DiscussionReply(author: profile.name, time: "just now", body: trimmed)
        )
    }

    func addComment(_ body: String, to id: UUID) {
        guard let index = issues.firstIndex(where: { $0.id == id }) else { return }
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        issues[index].comments.append(
            IssueComment(author: profile.name, time: "just now", body: trimmed)
        )
        issues[index].activity.append(
            IssueActivityEvent(actor: profile.name, action: "commented", detail: trimmed)
        )
    }

    func toggleIssueReaction(_ kind: ReactionKind, commentID: UUID, issueID: UUID) {
        guard let issueIndex = issues.firstIndex(where: { $0.id == issueID }) else { return }
        guard let commentIndex = issues[issueIndex].comments.firstIndex(where: { $0.id == commentID }) else {
            return
        }
        issues[issueIndex].comments[commentIndex].reactions.toggle(kind)
    }

    func toggleReviewReaction(_ kind: ReactionKind, commentID: UUID, requestID: UUID) {
        guard let requestIndex = pullRequests.firstIndex(where: { $0.id == requestID }) else { return }
        guard let commentIndex = pullRequests[requestIndex].reviewComments.firstIndex(where: {
            $0.id == commentID
        }) else {
            return
        }
        pullRequests[requestIndex].reviewComments[commentIndex].reactions.toggle(kind)
    }

    func updateProfile(name: String, handle: String, bio: String, initials: String) {
        profile.name = name
        profile.handle = handle
        profile.bio = bio
        profile.initials = initials
    }

    func updateStatus(_ text: String) {
        status = text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func updateStatusDetails(isBusy: Bool, expiration: String, visibility: String) {
        statusIsBusy = isBusy
        statusExpiration = expiration
        statusVisibility = visibility
    }

    func updateProfileReadme(_ markdown: String) {
        profileReadme = markdown
        UserDefaults.standard.set(markdown, forKey: "profile.readme")
    }

    static let starterProfileReadme = """
    # Hardik

    Ha Freelance as Designer system

    ## Website

    https://design-system-studio-rbvn.bolt.host
    """

    func toggleMarketplaceInstall(_ id: UUID) {
        guard let index = marketplaceApps.firstIndex(where: { $0.id == id }) else { return }
        marketplaceApps[index].isInstalled.toggle()
    }

    func toggleCodespaceRunning(_ id: UUID) {
        guard let index = codespaces.firstIndex(where: { $0.id == id }) else { return }
        codespaces[index].isRunning.toggle()
    }

    @discardableResult
    func addCodespace(repository: String, branch: String, machine: String, region: String) -> CodespaceItem {
        let shortName = repository
            .split(separator: "/")
            .last
            .map(String.init) ?? repository
        let codespace = CodespaceItem(
            name: "\(shortName) — \(branch)",
            repository: "@\(profile.handle)/\(shortName)",
            machine: machine,
            region: region,
            lastUsed: "just now",
            isRunning: false
        )
        codespaces.insert(codespace, at: 0)
        return codespace
    }

    func deleteCodespace(_ id: UUID) {
        codespaces.removeAll { $0.id == id }
    }

    // MARK: - Copilot conversation

    func appendCopilotUser(_ text: String, model: String = "GPT-5.4 mini") {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if activeCopilotConversationID == nil {
            activeCopilotConversationID = UUID()
        }

        copilotMessages.append(
            CopilotMessage(role: .user, text: trimmed, model: nil, time: currentTime())
        )
        syncCopilotConversation(model: model)
    }

    func appendCopilotReply(to prompt: String, model: String) {
        copilotMessages.append(
            CopilotMessage(
                role: .copilot,
                text: copilotReply(for: prompt),
                model: model,
                time: currentTime()
            )
        )
        syncCopilotConversation(model: model)
    }

    /// Keeps the history entry for the open conversation in step with its messages.
    private func syncCopilotConversation(model: String) {
        guard let id = activeCopilotConversationID, !copilotMessages.isEmpty else { return }

        if let index = copilotConversations.firstIndex(where: { $0.id == id }) {
            copilotConversations[index].messages = copilotMessages
            copilotConversations[index].model = model
        } else {
            copilotConversations.insert(
                CopilotConversation(id: id, messages: copilotMessages, model: model, createdAt: Date()),
                at: 0
            )
        }
    }

    func startNewCopilotConversation() {
        activeCopilotConversationID = nil
        copilotMessages = []
    }

    func openCopilotConversation(_ id: UUID) {
        guard let conversation = copilotConversations.first(where: { $0.id == id }) else { return }
        activeCopilotConversationID = conversation.id
        copilotMessages = conversation.messages
    }

    private func currentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    private func copilotReply(for prompt: String) -> String {
        let lowered = prompt.lowercased()

        if containsAny(lowered, ["error", "crash", "bug", "flicker", "fails"]) {
            return "Start with the first frame in the stack trace owned by your code, not a framework. Reproduce it with the smallest possible view, then check whether the state changes twice per update cycle."
        }
        if lowered.contains("pong") || lowered.contains("game") {
            return "Model the ball and paddles as value types with a fixed-step update, then clamp the collision delta so 120Hz behaves like 60Hz. Draw with a Canvas and keep the score in a small observable model."
        }
        if lowered.contains("calculator") {
            return "A calculator is a state machine: an operands stack, a pending operation and a display string. Build the keypad as a grid, keep the model separate from the view, and unit-test each operation before wiring the buttons."
        }
        if lowered.contains("readme") {
            return "Open with one sentence on what the project does, then a short feature list, a quick-start snippet and a screenshot. Keep badges to two or three so the page stays readable."
        }
        if lowered.contains("mermaid") {
            return "Map each module to a node and each dependency to an arrow, grouping the layers with subgraphs. Keep it to the eight or so boxes a reader can hold in their head."
        }
        if lowered.contains("design") || lowered.contains("ui") || lowered.contains("glass") {
            return "Start from one surface style and one accent, then apply it everywhere: cards, chips and buttons. Increase spacing before adding decoration — depth reads best on a quiet background."
        }
        return "Here is how I would approach it: sketch the smallest version that proves the idea, keep the state in one place, and test the edge cases first. Once that works, the polish is straightforward."
    }

    private func containsAny(_ haystack: String, _ needles: [String]) -> Bool {
        needles.contains { haystack.contains($0) }
    }

    func addRepository(name: String, blurb: String) {
        let repo = RepoItem(
            name: name,
            language: "Swift",
            updated: "just now",
            stars: 0,
            blurb: blurb,
            isStarred: false
        )
        repositories.insert(repo, at: 0)
    }

    func updateRepository(
        originalName: String,
        name: String,
        blurb: String,
        isPrivate: Bool,
        defaultBranch: String,
        hasIssues: Bool,
        hasDiscussions: Bool,
        hasWiki: Bool
    ) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBlurb = blurb.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        func apply(_ repo: inout RepoItem) {
            repo.name = trimmedName
            repo.blurb = trimmedBlurb.isEmpty ? "No description yet." : trimmedBlurb
            repo.isPrivate = isPrivate
            repo.defaultBranch = defaultBranch
            repo.hasIssues = hasIssues
            repo.hasDiscussions = hasDiscussions
            repo.hasWiki = hasWiki
        }

        for index in repositories.indices where repositories[index].name == originalName {
            apply(&repositories[index])
        }

        for index in exploreRepositories.indices where exploreRepositories[index].name == originalName {
            apply(&exploreRepositories[index])
        }

        if trimmedName != originalName {
            for index in issues.indices where issues[index].repository == originalName {
                issues[index].repository = trimmedName
            }
            if let stored = releases[originalName] {
                releases.removeValue(forKey: originalName)
                releases[trimmedName] = stored
            }
        }
    }

    func markAllNotificationsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }

    func toggleNotificationRead(_ id: UUID) {
        guard let index = notifications.firstIndex(where: { $0.id == id }) else { return }
        notifications[index].isRead.toggle()
    }

    func deleteNotification(_ id: UUID) {
        notifications.removeAll { $0.id == id }
    }

    // MARK: - Sample data

    static let sampleRepositories: [RepoItem] = [
        RepoItem(
            name: "swiftui-lab",
            language: "Swift",
            updated: "2h ago",
            stars: 184,
            blurb: "Liquid glass components you can drop into any SwiftUI app.",
            isStarred: true
        ),
        RepoItem(
            name: "copilot-playground",
            language: "Swift",
            updated: "yesterday",
            stars: 96,
            blurb: "Prompt experiments behind the Copilot 3D assistant.",
            isStarred: true
        ),
        RepoItem(
            name: "liquid-glass-kit",
            language: "Swift",
            updated: "3d ago",
            stars: 62,
            blurb: "Frosted surfaces with real depth, tuned for iOS 26.",
            isStarred: true
        ),
        RepoItem(
            name: "pong-swiftui",
            language: "Swift",
            updated: "1w ago",
            stars: 41,
            blurb: "Pong rebuilt with SwiftUI only — no game engine.",
            isStarred: false
        ),
        RepoItem(
            name: "mermaid-forge",
            language: "TypeScript",
            updated: "2w ago",
            stars: 27,
            blurb: "Turns Swift types into Mermaid architecture diagrams.",
            isStarred: false
        ),
        RepoItem(
            name: "hardikarya30/-X-App-twitter-",
            language: "Swift",
            updated: "1w ago",
            stars: 12,
            blurb: "A Twitter-style feed rebuilt in SwiftUI.",
            isStarred: false
        ),
        RepoItem(
            name: "hardikarya30/Designing-Facebook-Ui-",
            language: "Swift",
            updated: "2w ago",
            stars: 18,
            blurb: "Facebook's interface recreated with SwiftUI layouts.",
            isStarred: false
        ),
        RepoItem(
            name: "hardikarya30/Instagram-app-",
            language: "Swift",
            updated: "3w ago",
            stars: 24,
            blurb: "An Instagram clone with a feed, stories and profiles.",
            isStarred: false
        )
    ]

    static let sampleIssues: [IssueItem] = [
        IssueItem(
            number: 128,
            title: "Fix toolbar animation",
            body: "The toolbar animation stutters when navigating between repository screens. The transition should remain smooth while the sidebar adapts to the available width.",
            code: nil,
            author: "Maya Chen",
            time: "4 hours ago",
            repository: "swiftui-lab",
            isOpen: true,
            comments: [],
            labels: ["bug"],
            activity: [
                IssueActivityEvent(
                    actor: "Maya Chen",
                    action: "opened this issue",
                    timestamp: Date().addingTimeInterval(-4 * 60 * 60)
                ),
                IssueActivityEvent(
                    actor: "Hardik Arya",
                    action: "added the bug label",
                    timestamp: Date().addingTimeInterval(-3.8 * 60 * 60)
                )
            ]
        ),
        IssueItem(
            number: 42,
            title: "Liquid glass tab bar flickers on iOS 26",
            body: "The tab bar flickers when switching between tabs on iOS 26. It happens intermittently, but seems more likely when returning to the app from the background. Attaching a minimal reproduction example below.",
            code: """
            TabView {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house") }
                ExploreView()
                    .tabItem { Label("Explore", systemImage: "safari") }
            }
            """,
            author: "Debbie",
            time: "2 days ago",
            repository: "swiftui-lab",
            isOpen: true,
            comments: [
                IssueComment(
                    author: "Debbie",
                    time: "2h ago",
                    body: "I can reproduce this on iPhone 16 Pro running iOS 26 beta 3. It doesn't seem to happen on iOS 18. Let me know if you need more details!"
                ),
                IssueComment(
                    author: "Hardik Arya",
                    time: "1h ago",
                    body: "Thanks for the report! I can reproduce this too. Looks like it's related to the new tab bar material. I'll investigate and share an update soon."
                ),
                IssueComment(
                    author: "Sam Okafor",
                    time: "30m ago",
                    body: "Same here on iPad. Happy to test a fix when you have one."
                )
            ],
            labels: ["bug", "design"],
            milestone: "v1.5",
            assignees: ["Sam Okafor"],
            activity: [
                IssueActivityEvent(
                    actor: "Debbie",
                    action: "opened this issue",
                    timestamp: Date().addingTimeInterval(-2 * 24 * 60 * 60)
                ),
                IssueActivityEvent(
                    actor: "Hardik Arya",
                    action: "added the bug label",
                    timestamp: Date().addingTimeInterval(-47 * 60 * 60)
                ),
                IssueActivityEvent(
                    actor: "Hardik Arya",
                    action: "added the design label",
                    timestamp: Date().addingTimeInterval(-46 * 60 * 60)
                ),
                IssueActivityEvent(
                    actor: "Hardik Arya",
                    action: "assigned Sam Okafor",
                    timestamp: Date().addingTimeInterval(-45 * 60 * 60)
                ),
                IssueActivityEvent(
                    actor: "Debbie",
                    action: "commented",
                    detail: "I can reproduce this on iPhone 16 Pro running iOS 26 beta 3. It doesn't seem to happen on iOS 18. Let me know if you need more details!",
                    timestamp: Date().addingTimeInterval(-2 * 60 * 60)
                ),
                IssueActivityEvent(
                    actor: "Hardik Arya",
                    action: "commented",
                    detail: "Thanks for the report! I can reproduce this too. Looks like it's related to the new tab bar material. I'll investigate and share an update soon.",
                    timestamp: Date().addingTimeInterval(-60 * 60)
                ),
                IssueActivityEvent(
                    actor: "Sam Okafor",
                    action: "commented",
                    detail: "Same here on iPad. Happy to test a fix when you have one.",
                    timestamp: Date().addingTimeInterval(-30 * 60)
                )
            ]
        ),
        IssueItem(
            number: 18,
            title: "Pong collision drifts at 120Hz",
            body: "At 120Hz the ball slowly drifts through the right paddle. It looks like the collision step assumes 60Hz.",
            code: nil,
            author: "Debbie",
            time: "yesterday",
            repository: "pong-swiftui",
            isOpen: true,
            comments: [
                IssueComment(
                    author: "Taylor",
                    time: "yesterday",
                    body: "Reproduced on iPad Pro. The delta time needs clamping."
                )
            ],
            assignees: ["Alex Chen"],
            activity: [
                IssueActivityEvent(
                    actor: "Debbie",
                    action: "opened this issue",
                    timestamp: Date().addingTimeInterval(-36 * 60 * 60)
                ),
                IssueActivityEvent(
                    actor: "Hardik Arya",
                    action: "assigned Alex Chen",
                    timestamp: Date().addingTimeInterval(-28 * 60 * 60)
                ),
                IssueActivityEvent(
                    actor: "Taylor",
                    action: "commented",
                    detail: "Reproduced on iPad Pro. The delta time needs clamping.",
                    timestamp: Date().addingTimeInterval(-24 * 60 * 60)
                )
            ]
        ),
        IssueItem(
            number: 7,
            title: "Mermaid export drops nested nodes",
            body: "Nested subgraphs lose their children when exporting to Mermaid. Flat graphs are fine.",
            code: nil,
            author: "Debbie",
            time: "3d ago",
            repository: "mermaid-forge",
            isOpen: true,
            comments: [],
            activity: [
                IssueActivityEvent(
                    actor: "Debbie",
                    action: "opened this issue",
                    timestamp: Date().addingTimeInterval(-3 * 24 * 60 * 60)
                )
            ]
        )
    ]

    static let samplePullRequests: [PullRequestItem] = [
        PullRequestItem(
            number: 42,
            title: "Add adaptive sidebar",
            body: "Adds an adaptive sidebar that responds to compact and regular layouts, keeping repository navigation accessible at every width.",
            repository: "swiftui-lab",
            author: "Jordan Lee",
            time: "6 hours ago",
            baseBranch: "main",
            headBranch: "feature/adaptive-sidebar",
            isOpen: false,
            isApproved: true,
            files: [
                PRFile(path: "Sources/Sidebar.swift", additions: 38, deletions: 12),
                PRFile(path: "Sources/RepositoryDetailView.swift", additions: 16, deletions: 4)
            ]
        ),
        PullRequestItem(
            number: 19,
            title: "Add 3D press animation to repo cards",
            body: "Adds a subtle 3D press animation to repository cards, giving tactile feedback when users press and hold.\n\nThis makes the interface feel more responsive and delightful, and aligns with the overall motion system in the app.",
            repository: "swiftui-lab",
            author: "Debbie",
            time: "2 days ago",
            baseBranch: "main",
            headBranch: "feature/press-animation",
            isOpen: true,
            isApproved: false,
            files: [
                PRFile(path: "Sources/GlassCard.swift", additions: 42, deletions: 8),
                PRFile(path: "Sources/RecipeView.swift", additions: 18, deletions: 3),
                PRFile(path: "Sources/AppStore.swift", additions: 6, deletions: 1),
                PRFile(path: "README.md", additions: 4, deletions: 0)
            ],
            reviewComments: [
                PRReviewComment(
                    reviewer: "Priya Desai",
                    path: "Sources/GlassCard.swift",
                    line: 42,
                    time: "1h ago",
                    body: "The new surface reads well, but the inner padding feels tight once the text size is bumped up."
                ),
                PRReviewComment(
                    reviewer: "Sam Okafor",
                    path: "Sources/AppStore.swift",
                    line: 6,
                    time: "40m ago",
                    body: "Clean change. Could you keep the comment above the counter so the next person knows why it starts at 22?"
                )
            ]
        ),
        PullRequestItem(
            number: 21,
            title: "Move copilot state into an observable store",
            body: "Extracts the Copilot conversation and model preferences out of the view into the shared store, so the thread survives tab switches.",
            repository: "copilot-playground",
            author: "Hardik Arya",
            time: "yesterday",
            baseBranch: "main",
            headBranch: "feature/copilot-store",
            isOpen: true,
            isApproved: false,
            files: [
                PRFile(path: "Sources/AppStore.swift", additions: 61, deletions: 4),
                PRFile(path: "Sources/CopilotView.swift", additions: 12, deletions: 38)
            ]
        )
    ]

    static let sampleDiscussions: [DiscussionItem] = [
        DiscussionItem(
            title: "What should the liquid glass kit cover next?",
            category: "Ideas",
            author: "Hardik Arya",
            time: "12 minutes ago",
            body: "I'm planning the next part of the Liquid Glass kit and would love your suggestions.\n\nWhat components, patterns or real-world examples would be most useful for you? Drop your ideas below!",
            replies: [
                DiscussionReply(
                    author: "Priya Desai",
                    time: "10 minutes ago",
                    body: "I'd love to see a deep dive on navigation patterns, especially with nested tabs."
                ),
                DiscussionReply(
                    author: "Daniel Kim",
                    time: "8 minutes ago",
                    body: "More real-world examples would be amazing — maybe a full app build, step by step?"
                ),
                DiscussionReply(
                    author: "Mei Lin",
                    time: "6 minutes ago",
                    body: "I'm really interested in animations and transitions. Some best practices would help a lot."
                ),
                DiscussionReply(
                    author: "Alex Chen",
                    time: "4 minutes ago",
                    body: "Components for data-heavy screens like tables and lists would be super useful."
                ),
                DiscussionReply(
                    author: "Taylor Brooks",
                    time: "2 minutes ago",
                    body: "Accessibility guidance would be fantastic — especially for dynamic type and contrast."
                )
            ]
        ),
        DiscussionItem(
            title: "Sharing SwiftUI 26 layout tricks",
            category: "General",
            author: "Taylor Brooks",
            time: "1 hour ago",
            body: "A thread for the layout tricks you keep reaching for in SwiftUI 26 — grids, safe area insets and container relative sizing.",
            replies: [
                DiscussionReply(
                    author: "Alex Chen",
                    time: "45 minutes ago",
                    body: "containerRelativeFrame has replaced almost all of my GeometryReaders."
                ),
                DiscussionReply(
                    author: "Priya Desai",
                    time: "30 minutes ago",
                    body: "Safe area insets plus scroll content margins fixed my sticky composer layout."
                )
            ]
        ),
        DiscussionItem(
            title: "Best way to mock the GitHub API on device?",
            category: "Q&A",
            author: "Sam Okafor",
            time: "yesterday",
            body: "I want to demo offline. Is a protocol-based fake the simplest way, or should I ship recorded JSON fixtures?",
            replies: [
                DiscussionReply(
                    author: "Hardik Arya",
                    time: "yesterday",
                    body: "Protocol plus a fixture loader has worked well for me — no network at all during demos."
                )
            ]
        ),
        DiscussionItem(
            title: "Show your profile README",
            category: "Show and tell",
            author: "Mei Lin",
            time: "2d ago",
            body: "Share the profile README you are proudest of, and what you changed to make it land.",
            replies: [
                DiscussionReply(
                    author: "Daniel Kim",
                    time: "2d ago",
                    body: "Kept mine to one paragraph, three links and a screenshot. It finally gets read."
                )
            ]
        ),
        DiscussionItem(
            title: "Pong physics, one year later",
            category: "Ideas",
            author: "Debbie",
            time: "4d ago",
            body: "Looking back at the Pong rebuild — what would you change about the collision model if you started today?",
            replies: []
        )
    ]

    static let sampleProjects: [SectionEntry] = [
        SectionEntry(
            title: "Mobile app refresh",
            subtitle: "5 tasks · 2 done",
            symbol: "square.stack.3d.up"
        ),
        SectionEntry(
            title: "Copilot 3D launch",
            subtitle: "4 tasks · 1 done",
            symbol: "square.stack.3d.up"
        ),
        SectionEntry(
            title: "Profile README refresh",
            subtitle: "3 tasks · 1 done",
            symbol: "square.stack.3d.up"
        ),
        SectionEntry(
            title: "Liquid glass kit v2",
            subtitle: "4 tasks · 2 done",
            symbol: "square.stack.3d.up"
        )
    ]

    static func sampleProjectCards(for projects: [SectionEntry]) -> [ProjectBoardCard] {
        let calendar = Calendar(identifier: .gregorian)
        func date(_ month: Int, _ day: Int) -> Date {
            calendar.date(from: DateComponents(year: 2025, month: month, day: day)) ?? Date()
        }

        return projects.flatMap { project in
            switch project.title {
            case "Mobile app refresh":
                return [
                    ProjectBoardCard(projectID: project.id, title: "Refresh repository header", description: "Update the repository header so the project name, branch and key actions are easier to scan.", label: "Design", issueNumber: 18, assignee: "Hardik Arya", dueDate: date(4, 28), status: .todo),
                    ProjectBoardCard(projectID: project.id, title: "Add empty states", description: "Create friendly empty-state layouts that explain what belongs in each section and how to get started.", label: "UI", issueNumber: 23, assignee: "Debbie", dueDate: date(5, 2), status: .todo),
                    ProjectBoardCard(projectID: project.id, title: "Build branch picker", description: "Add a searchable branch picker with clear selection and loading states.", label: "Development", issueNumber: 27, assignee: "Alex Chen", dueDate: date(4, 30), status: .inProgress),
                    ProjectBoardCard(projectID: project.id, title: "Write onboarding copy", description: "Polish the first-run guidance so new contributors can find the main repository tools quickly.", label: "Content", issueNumber: 12, assignee: "Priya Shah", dueDate: date(4, 20), status: .done),
                    ProjectBoardCard(projectID: project.id, title: "Update icon set", description: "Refresh the navigation symbols for a consistent weight and improved legibility.", label: "Design", issueNumber: 14, assignee: "Matt Wilson", dueDate: date(4, 18), status: .done)
                ]
            case "Copilot 3D launch":
                return [
                    ProjectBoardCard(projectID: project.id, title: "Review model picker states", description: "Check the model picker across loading, selected and unavailable states before launch.", label: "Design", issueNumber: 31, assignee: "Priya Desai", dueDate: date(5, 7), status: .todo),
                    ProjectBoardCard(projectID: project.id, title: "Finish launch checklist", description: "Confirm the release requirements, owners and final sign-off items for launch day.", label: "Content", issueNumber: 34, assignee: "Hardik Arya", dueDate: date(5, 9), status: .todo),
                    ProjectBoardCard(projectID: project.id, title: "Ship conversation history", description: "Save and restore conversations so users can return to earlier Copilot sessions.", label: "Development", issueNumber: 40, assignee: "Alex Chen", dueDate: date(5, 10), status: .inProgress),
                    ProjectBoardCard(projectID: project.id, title: "Update release notes", description: "Summarize the launch features and key improvements in the release notes.", label: "Content", issueNumber: 29, assignee: "Sam Okafor", dueDate: date(5, 2), status: .done)
                ]
            case "Profile README refresh":
                return [
                    ProjectBoardCard(projectID: project.id, title: "Draft profile introduction", description: "Write a concise introduction that highlights the profile owner's focus and current work.", label: "Content", issueNumber: 8, assignee: "Hardik Arya", dueDate: date(5, 6), status: .todo),
                    ProjectBoardCard(projectID: project.id, title: "Add project highlights", description: "Select and present a few standout projects with clear links and short summaries.", label: "UI", issueNumber: 9, assignee: "Debbie", dueDate: date(5, 8), status: .inProgress),
                    ProjectBoardCard(projectID: project.id, title: "Choose README template", description: "Pick a responsive README structure that keeps the introduction, projects and links easy to scan.", label: "Development", issueNumber: 11, assignee: "Priya Desai", dueDate: date(5, 3), status: .done)
                ]
            case "Liquid glass kit v2":
                return [
                    ProjectBoardCard(projectID: project.id, title: "Audit surface contrast", description: "Review text and control contrast on glass surfaces in both bright and dim viewing conditions.", label: "Design", issueNumber: 51, assignee: "Mei Lin", dueDate: date(5, 12), status: .todo),
                    ProjectBoardCard(projectID: project.id, title: "Build adaptive material samples", description: "Create reusable material examples that adapt naturally to compact and regular layouts.", label: "Development", issueNumber: 54, assignee: "Alex Chen", dueDate: date(5, 14), status: .inProgress),
                    ProjectBoardCard(projectID: project.id, title: "Document accessibility notes", description: "Record guidance for readable type, contrast and VoiceOver behavior across the kit.", label: "Content", issueNumber: 47, assignee: "Sam Okafor", dueDate: date(5, 9), status: .done),
                    ProjectBoardCard(projectID: project.id, title: "Refresh color tokens", description: "Tune the shared color tokens to keep accents and surfaces consistent across components.", label: "Design", issueNumber: 48, assignee: "Priya Desai", dueDate: date(5, 8), status: .done)
                ]
            default:
                return [
                    ProjectBoardCard(projectID: project.id, title: "Plan the first milestone", description: "Define the first milestone and agree on a small, testable delivery scope.", label: "Planning", assignee: "Hardik Arya", dueDate: date(5, 10), status: .todo),
                    ProjectBoardCard(projectID: project.id, title: "Build the first draft", description: "Put together an initial version of the work so the team can review the direction.", label: "Development", assignee: "Alex Chen", dueDate: date(5, 14), status: .inProgress),
                    ProjectBoardCard(projectID: project.id, title: "Review and share", description: "Gather feedback on the finished work and share the outcome with the team.", label: "Content", assignee: "Priya Desai", dueDate: date(5, 18), status: .done)
                ]
            }
        }
    }

    static func sampleProjectBoardActivity(
        for cards: [ProjectBoardCard],
        profileName: String
    ) -> [ProjectBoardActivityEvent] {
        let now = Date()
        let activityByProject = Dictionary(grouping: cards, by: \.projectID)

        return activityByProject.values.flatMap { projectCards in
            var events: [ProjectBoardActivityEvent] = []

            if let card = projectCards.first(where: { $0.status == .todo }) ?? projectCards.first {
                events.append(
                    ProjectBoardActivityEvent(
                        projectID: card.projectID,
                        actor: card.assignee ?? "Maya Chen",
                        cardTitle: card.title,
                        kind: .added,
                        status: card.status,
                        timestamp: now.addingTimeInterval(-24 * 60 * 60)
                    )
                )
            }

            if let card = projectCards.first(where: { $0.status != .todo }) {
                let previousStatus: ProjectBoardStatus = card.status == .done ? .inProgress : .todo
                events.append(
                    ProjectBoardActivityEvent(
                        projectID: card.projectID,
                        actor: profileName,
                        cardTitle: card.title,
                        kind: .moved,
                        previousStatus: previousStatus,
                        status: card.status,
                        timestamp: now.addingTimeInterval(-2 * 60 * 60)
                    )
                )
            }

            return events
        }
        .sorted { $0.timestamp > $1.timestamp }
    }

    static let sampleOrganisations: [OrganisationItem] = [
        OrganisationItem(
            name: "Arya Labs",
            handle: "@aryalabs",
            about: "Building open SwiftUI tools for everyone.",
            memberCount: 124,
            isMember: true
        ),
        OrganisationItem(
            name: "Liquid Glass Guild",
            handle: "@liquidglassguild",
            about: "Frosted surfaces, depth and motion on Apple platforms.",
            memberCount: 86,
            isMember: true
        ),
        OrganisationItem(
            name: "OpenSwift India",
            handle: "@openswiftindia",
            about: "A community for Swift developers across India.",
            memberCount: 312,
            isMember: false
        )
    ]

    static let sampleNotifications: [NotificationItem] = [
        NotificationItem(
            actor: "Debbie",
            action: "requested your review on #19 Add 3D press animation",
            body: nil,
            time: "2h ago",
            kind: .review,
            isRead: false,
            isToday: true
        ),
        NotificationItem(
            actor: "Alex",
            action: "starred your repository swiftui-lab",
            body: nil,
            time: "4h ago",
            kind: .star,
            isRead: false,
            isToday: true
        ),
        NotificationItem(
            actor: "Taylor",
            action: "mentioned you in a comment on #27 Improve onboarding flow",
            body: nil,
            time: "6h ago",
            kind: .mention,
            isRead: false,
            isToday: true
        ),
        NotificationItem(
            actor: "Arya Labs",
            action: "released v1.4",
            body: "New performance improvements and bug fixes.",
            time: "1d ago",
            kind: .release,
            isRead: true,
            isToday: false
        ),
        NotificationItem(
            actor: "Arya Labs",
            action: "invited you to Copilot 3D",
            body: "You've been added to the organisation as a contributor.",
            time: "2d ago",
            kind: .organisation,
            isRead: true,
            isToday: false
        )
    ]

    static let sampleExploreRepositories: [RepoItem] = [
        RepoItem(
            name: "swiftui-lab",
            language: "Swift",
            updated: "2h ago",
            stars: 184,
            blurb: "Liquid glass components for SwiftUI",
            isStarred: true,
            topics: ["Swift", "SwiftUI", "Liquid glass"]
        ),
        RepoItem(
            name: "glass-effects",
            language: "Swift",
            updated: "1d ago",
            stars: 96,
            blurb: "Beautiful liquid glass effects for iOS",
            isStarred: false,
            topics: ["Swift", "Liquid glass"]
        ),
        RepoItem(
            name: "swiftui-animations",
            language: "Swift",
            updated: "2d ago",
            stars: 72,
            blurb: "Smooth animations and transitions",
            isStarred: false,
            topics: ["Swift", "SwiftUI", "Design systems", "Liquid glass"]
        ),
        RepoItem(
            name: "copilot-patterns",
            language: "Swift",
            updated: "3d ago",
            stars: 58,
            blurb: "Prompt patterns for building with Copilot",
            isStarred: false,
            topics: ["AI", "Swift"]
        ),
        RepoItem(
            name: "design-system-kit",
            language: "Swift",
            updated: "5d ago",
            stars: 44,
            blurb: "Tokens and components for design systems",
            isStarred: false,
            topics: ["Design systems", "SwiftUI"]
        )
    ]

    static let sampleGists: [GistItem] = [
        GistItem(
            filename: "glass-card.swift",
            language: "Swift",
            about: "Reusable press animation for cards",
            code: """
            import SwiftUI

            struct GlassCard<Content: View>: View {
                @ViewBuilder var content: Content
                var body: some View { content }
            }
            """,
            isPrivate: false,
            updated: "2d ago",
            stars: 184,
            isMine: true
        ),
        GistItem(
            filename: "networking.swift",
            language: "Swift",
            about: "Simple network layer with async/await",
            code: """
            import Foundation

            func fetch<T: Decodable>(_ url: URL) async throws -> T {
                let (data, _) = try await URLSession.shared.data(from: url)
                return try JSONDecoder().decode(T.self, from: data)
            }
            """,
            isPrivate: false,
            updated: "5d ago",
            stars: 97,
            isMine: true
        ),
        GistItem(
            filename: "view-extensions.swift",
            language: "Swift",
            about: "Useful SwiftUI view modifiers",
            code: """
            import SwiftUI

            extension View {
                func cardStyle() -> some View {
                    padding(16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                }
            }
            """,
            isPrivate: false,
            updated: "1w ago",
            stars: 62,
            isMine: true
        ),
        GistItem(
            filename: "debounce.swift",
            language: "Swift",
            about: "Debounce helper for async tasks",
            code: """
            import Foundation

            final class Debouncer {
                private var task: Task<Void, Never>?
                func run(_ delay: Duration, _ action: @escaping () -> Void) {
                    task?.cancel()
                    task = Task { try? await Task.sleep(for: delay); action() }
                }
            }
            """,
            isPrivate: true,
            updated: "3w ago",
            stars: 421,
            isMine: false
        )
    ]

    static let sampleReleases: [RepositoryRelease] = [
        RepositoryRelease(
            tag: "v1.4.0",
            name: "Liquid glass surfaces",
            published: "yesterday",
            notes: "Reworked the glass card surface and added a lighter press state across every component."
        ),
        RepositoryRelease(
            tag: "v1.3.0",
            name: "Navigation transitions",
            published: "3 weeks ago",
            notes: "Smoother push and pop transitions, and the back gesture now feels native on every screen."
        ),
        RepositoryRelease(
            tag: "v1.2.1",
            name: "Tab bar polish",
            published: "1 month ago",
            notes: "Fixed the tab bar jumping when the keyboard appears and tightened its shadow."
        ),
        RepositoryRelease(
            tag: "v1.2.0",
            name: "First public release",
            published: "2 months ago",
            notes: "The first public cut of the kit: glass cards, pressable buttons and the shared theme palette."
        )
    ]

    static let sampleCodespaces: [CodespaceItem] = [
        CodespaceItem(
            name: "swiftui-lab — main",
            repository: "@hardikarya30/swiftui-lab",
            machine: "4 cores, 8 GB RAM",
            region: "Frankfurt",
            lastUsed: "2h ago",
            isRunning: true
        ),
        CodespaceItem(
            name: "copilot-playground — main",
            repository: "@hardikarya30/copilot-playground",
            machine: "2 cores, 8 GB RAM",
            region: "Frankfurt",
            lastUsed: "yesterday",
            isRunning: false
        )
    ]

    static let sampleMarketplaceApps: [MarketplaceApp] = [
        MarketplaceApp(
            name: "Copilot",
            handle: "@hardikarya30",
            blurb: "Your AI pair programmer. Get suggestions while you type, ask questions about your code and review pull requests faster.",
            installs: "1.2M",
            rating: "4.8",
            price: "Free",
            symbol: "sparkles",
            bullets: [
                "Inline code suggestions",
                "Ask Copilot in any file",
                "Automated pull request review"
            ]
        ),
        MarketplaceApp(
            name: "Render",
            handle: "@rendercloud",
            blurb: "Continuous integration and deploys with Render, the modern cloud for ambitious developers.",
            installs: "480K",
            rating: "4.6",
            price: "Free",
            symbol: "server.rack",
            bullets: [
                "Deploy on every push",
                "Preview environments",
                "Managed Postgres"
            ],
            category: "Deployment"
        ),
        MarketplaceApp(
            name: "LovableBot",
            handle: "@lovablebot",
            blurb: "Keep your Lovable project synced both ways.",
            installs: "96K",
            rating: "4.4",
            price: "Free",
            symbol: "arrow.triangle.2.circlepath",
            bullets: [
                "Two-way project sync",
                "Pull Lovable changes",
                "Push commits back"
            ]
        ),
        MarketplaceApp(
            name: "OpenCode",
            handle: "@opencode",
            blurb: "Login to OpenCode through Github Copilot.",
            installs: "72K",
            rating: "4.5",
            price: "Free",
            symbol: "terminal",
            bullets: [
                "Terminal-first agent",
                "Copilot sign-in",
                "Works in any repository"
            ]
        ),
        MarketplaceApp(
            name: "CodeRabbit",
            handle: "@coderabbitai",
            blurb: "Cut Code Review Time & Bugs in Half.",
            installs: "310K",
            rating: "4.7",
            price: "Free",
            symbol: "hare",
            bullets: [
                "AI pull request reviews",
                "Line-by-line suggestions",
                "Summaries on every PR"
            ],
            category: "Code review"
        ),
        MarketplaceApp(
            name: "Codemagic CI/CD",
            handle: "@codemagic",
            blurb: "Cloud-based continuous integration and delivery for Android, iOS, Flutter, React Native, Ionic and Unity...",
            installs: "240K",
            rating: "4.5",
            price: "Free",
            symbol: "hammer",
            bullets: [
                "Mobile-first pipelines",
                "Signed builds on every run",
                "Test and release in one place"
            ],
            category: "CI/CD"
        )
    ]

    static let samplePeople: [PersonItem] = [
        PersonItem(
            name: "Alex Chen",
            handle: "@alexchen",
            bio: "Building delightful interfaces with SwiftUI",
            topics: ["SwiftUI", "Design systems"],
            repositories: 8,
            followers: 512,
            following: 120,
            repos: [
                PersonRepo(name: "swiftui-lab", blurb: "Liquid glass components for SwiftUI", stars: 184),
                PersonRepo(name: "glass-effects", blurb: "Liquid glass effects for iOS", stars: 96),
                PersonRepo(name: "tab-motion", blurb: "Tab bar transitions that feel native", stars: 54)
            ],
            activity: [
                PersonActivity(title: "Pushed 4 commits", subtitle: "To swiftui-lab main", time: "1 day ago", symbol: "arrow.up.circle"),
                PersonActivity(title: "Starred liquid-glass-kit", subtitle: "A collection of liquid glass components", time: "3 days ago", symbol: "star")
            ]
        ),
        PersonItem(
            name: "Priya Desai",
            handle: "@priyadesai",
            bio: "Design systems, SwiftUI and a more colourful internet",
            topics: ["Design systems", "SwiftUI"],
            repositories: 15,
            followers: 874,
            following: 64,
            repos: [
                PersonRepo(name: "color-systems", blurb: "Tools for beautiful adaptive colour", stars: 96),
                PersonRepo(name: "token-kit", blurb: "Design tokens that scale", stars: 61),
                PersonRepo(name: "grid-lab", blurb: "Layout experiments in SwiftUI", stars: 38)
            ],
            activity: [
                PersonActivity(title: "Opened #27 Improve onboarding flow", subtitle: "In copilot-playground", time: "2 days ago", symbol: "arrow.triangle.pull")
            ]
        ),
        PersonItem(
            name: "Maya Patel",
            handle: "@mayapatel",
            bio: "Liquid glass experiments and motion",
            topics: ["Liquid glass"],
            repositories: 12,
            followers: 340,
            following: 89,
            repos: [
                PersonRepo(name: "liquid-glass-ui", blurb: "Fluid UI components for SwiftUI", stars: 412),
                PersonRepo(name: "motion-playground", blurb: "Small experiments with motion", stars: 230),
                PersonRepo(name: "color-systems", blurb: "Tools for beautiful adaptive color", stars: 96)
            ],
            activity: [
                PersonActivity(title: "Starred swiftui-lab", subtitle: "A collection of SwiftUI experiments", time: "2 days ago", symbol: "star"),
                PersonActivity(title: "Opened #42", subtitle: "Liquid glass tab bar flickers", time: "4 days ago", symbol: "arrow.triangle.pull")
            ]
        ),
        PersonItem(
            name: "Sam Okafor",
            handle: "@samokafor",
            bio: "AI tooling for iOS developers",
            topics: ["AI", "Swift"],
            repositories: 6,
            followers: 198,
            following: 42,
            repos: [
                PersonRepo(name: "prompt-patterns", blurb: "Reusable prompts for app builders", stars: 74),
                PersonRepo(name: "rag-for-swift", blurb: "On-device retrieval experiments", stars: 33)
            ],
            activity: [
                PersonActivity(title: "Released v0.9", subtitle: "prompt-patterns", time: "6 days ago", symbol: "tag")
            ]
        )
    ]
}
