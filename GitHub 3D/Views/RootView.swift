//
//  RootView.swift
//  GitHub 3D
//
//  The tab container and the frosted bottom bar.
//

import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case inbox
    case explore
    case copilot

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .inbox: return "Inbox"
        case .explore: return "Explore"
        case .copilot: return "Copilot"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .inbox: return "tray.fill"
        case .explore: return "safari.fill"
        case .copilot: return "sparkles"
        }
    }

    var blurb: String {
        switch self {
        case .home: return "Your profile, activity and repositories."
        case .inbox: return "Notifications, mentions and review requests will land here."
        case .explore: return "Trending repositories, topics and people to follow."
        case .copilot: return "Ask Copilot, write code and review your work."
        }
    }
}

struct RootView: View {
    @Binding var isSignedIn: Bool

    @State private var tab: AppTab = .home
    @State private var showRepositories = false
    @State private var sidebarOpen = false
    @State private var sidebarDestination: SidebarSelection?
    @State private var profileMenuOpen = false
    @State private var showCodeAnalyst = false
    @State private var selectedRepository: RepoItem?
    @State private var selectedIssue: IssueItem?
    @State private var selectedProject: SectionEntry?
    @State private var selectedPullRequest: PullRequestItem?
    @State private var selectedDiscussion: DiscussionItem?
    @State private var selectedOrganisation: OrganisationItem?
    @State private var selectedPerson: PersonItem?
    @State private var selectedTopic: String?
    @State private var showEditProfile = false
    @State private var showSettings = false
    @State private var showSearch = false
    @State private var showGists = false
    @State private var selectedGist: GistItem?
    @State private var showProfileReadme = false
    @State private var insightsRepository: RepoItem?
    @State private var releasesRepository: RepoItem?
    @State private var activityRepository: RepoItem?
    @State private var showStars = false
    @State private var showSetStatus = false
    @State private var showOrganisations = false
    @State private var showMarketplace = false
    @State private var selectedMarketplaceApp: MarketplaceApp?
    @State private var showCodespaces = false
    @State private var selectedCodespace: CodespaceItem?
    @State private var settingsRepository: RepoItem?
    @State private var collaboratorsRepositoryID: UUID?
    @State private var diffTarget: PRDiffTarget?
    @State private var branchComparison: BranchComparisonRoute?
    @State private var showCopilotHistory = false
    @State private var showWatching = false

    private func openRepository(_ repo: RepoItem) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            insightsRepository = nil
            releasesRepository = nil
            activityRepository = nil
            selectedRepository = repo
        }
    }

    private func openIssue(_ issue: IssueItem) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            selectedIssue = issue
        }
    }

    private func openProject(_ project: SectionEntry) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            selectedProject = project
        }
    }

    private func openPullRequest(_ request: PullRequestItem) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            selectedPullRequest = request
        }
    }

    private func openDiscussion(_ discussion: DiscussionItem) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            selectedDiscussion = discussion
        }
    }

    private func openOrganisation(_ organisation: OrganisationItem) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            selectedOrganisation = organisation
        }
    }

    private func openPerson(_ person: PersonItem) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            selectedPerson = person
        }
    }

    private func openTopic(_ topic: String) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            selectedTopic = topic
        }
    }

    private var tabBinding: Binding<AppTab> {
        Binding(
            get: { tab },
            set: { newValue in
                showRepositories = false
                showCodeAnalyst = false
                selectedRepository = nil
                insightsRepository = nil
                releasesRepository = nil
                activityRepository = nil
                showStars = false
                showOrganisations = false
                showMarketplace = false
                selectedMarketplaceApp = nil
                showCodespaces = false
                selectedCodespace = nil
                settingsRepository = nil
                collaboratorsRepositoryID = nil
                selectedIssue = nil
                selectedProject = nil
                branchComparison = nil
                sidebarDestination = nil
                showCopilotHistory = false
                showWatching = false
                tab = newValue
            }
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppBackdrop()

            Group {
                if showProfileReadme {
                    ProfileReadmeView {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                            showProfileReadme = false
                        }
                    }
                } else if let gist = selectedGist {
                    GistDetailView(gistID: gist.id) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                            selectedGist = nil
                        }
                    }
                } else if showGists {
                    GistsView(
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                showGists = false
                            }
                        },
                        onOpenGist: { gist in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                selectedGist = gist
                            }
                        }
                    )
                } else if showSearch {
                    SearchView(
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                showSearch = false
                            }
                        },
                        onOpenRepository: openRepository,
                        onOpenIssue: openIssue,
                        onOpenPullRequest: openPullRequest,
                        onOpenDiscussion: openDiscussion,
                        onOpenPerson: openPerson
                    )
                } else if showSettings {
                    SettingsView(
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                showSettings = false
                            }
                        },
                        onEditProfile: {
                            showEditProfile = true
                        },
                        onSignOut: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                showSettings = false
                                sidebarDestination = nil
                                showRepositories = false
                                showCodeAnalyst = false
                                tab = .home
                                isSignedIn = false
                            }
                        }
                    )
                } else if let issue = selectedIssue {
                    IssueDetailView(issueID: issue.id) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                            selectedIssue = nil
                        }
                    }
                } else if let project = selectedProject {
                    ProjectBoardView(projectID: project.id, projectName: project.title) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                            selectedProject = nil
                        }
                    }
                } else if let topic = selectedTopic {
                    TopicView(
                        topic: topic,
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                selectedTopic = nil
                            }
                        },
                        onOpenRepository: openRepository,
                        onOpenPerson: openPerson
                    )
                } else if let person = selectedPerson {
                    PersonProfileView(personID: person.id) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                            selectedPerson = nil
                        }
                    }
                } else if let organisation = selectedOrganisation {
                    OrganisationDetailView(organisationID: organisation.id) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                            selectedOrganisation = nil
                        }
                    }
                } else if showOrganisations {
                    OrganisationsView(
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                showOrganisations = false
                            }
                        },
                        onOpenOrganisation: openOrganisation
                    )
                } else if let marketplaceApp = selectedMarketplaceApp {
                    MarketplaceAppDetailView(
                        appID: marketplaceApp.id,
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                selectedMarketplaceApp = nil
                            }
                        }
                    )
                } else if showMarketplace {
                    MarketplaceView(
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                showMarketplace = false
                            }
                        },
                        onOpenApp: { app in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                selectedMarketplaceApp = app
                            }
                        }
                    )
                } else if let codespace = selectedCodespace {
                    CodespaceDetailView(
                        codespaceID: codespace.id,
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                selectedCodespace = nil
                            }
                        }
                    )
                } else if showCodespaces {
                    CodespacesView(
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                showCodespaces = false
                            }
                        },
                        onOpenCodespace: { codespace in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                selectedCodespace = codespace
                            }
                        },
                        onCreatedCodespace: { created in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                selectedCodespace = created
                            }
                        }
                    )
                } else if let discussion = selectedDiscussion {
                    DiscussionThreadView(discussionID: discussion.id) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                            selectedDiscussion = nil
                        }
                    }
                } else if let diff = diffTarget {
                    FileDiffView(
                        pullRequestID: diff.requestID,
                        filePath: diff.path,
                        fileOverride: diff.fileOverride,
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                diffTarget = nil
                            }
                        }
                    )
                } else if let comparison = branchComparison {
                    BranchComparisonView(
                        repo: comparison.repository,
                        branches: comparison.branches,
                        initialBaseBranch: comparison.initialBaseBranch,
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                branchComparison = nil
                            }
                        },
                        onOpenFile: { file in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                diffTarget = PRDiffTarget(
                                    requestID: nil,
                                    path: file.path,
                                    fileOverride: file
                                )
                            }
                        },
                        onOpenPullRequest: { request in
                            branchComparison = nil
                            openPullRequest(request)
                        }
                    )
                } else if let request = selectedPullRequest {
                    PullRequestDetailView(
                        pullRequestID: request.id,
                        onOpenFile: { path in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                diffTarget = PRDiffTarget(requestID: request.id, path: path)
                            }
                        },
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                selectedPullRequest = nil
                            }
                        }
                    )
                } else if showStars {
                    StarsView(
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                showStars = false
                            }
                        },
                        onOpenRepository: openRepository,
                        onExplore: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                showStars = false
                                tab = .explore
                            }
                        }
                    )
                } else if let releasesRepo = releasesRepository {
                    RepositoryReleasesView(
                        repo: releasesRepo,
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                releasesRepository = nil
                            }
                        }
                    )
                } else if let insights = insightsRepository {
                    RepositoryInsightsView(
                        repo: insights,
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                insightsRepository = nil
                            }
                        }
                    )
                } else if let activityRepo = activityRepository {
                    RepositoryActivityView(
                        repo: activityRepo,
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                activityRepository = nil
                            }
                        },
                        onOpenIssue: openIssue,
                        onOpenPullRequest: openPullRequest,
                        onOpenReleases: { opened in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                releasesRepository = opened
                            }
                        }
                    )
                } else if let repoID = collaboratorsRepositoryID {
                    CollaboratorsView(
                        repoID: repoID,
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                collaboratorsRepositoryID = nil
                            }
                        }
                    )
                } else if let settingsRepo = settingsRepository {
                    RepositorySettingsView(
                        repo: settingsRepo,
                        onCancel: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                settingsRepository = nil
                            }
                        },
                        onSaved: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                settingsRepository = nil
                            }
                        },
                        onOpenCollaborators: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                collaboratorsRepositoryID = settingsRepo.id
                            }
                        }
                    )
                } else if let repo = selectedRepository {
                    RepositoryDetailView(
                        repo: repo,
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                selectedRepository = nil
                            }
                        },
                        onOpenIssue: openIssue,
                        onOpenPullRequest: openPullRequest,
                        onOpenInsights: { opened in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                insightsRepository = opened
                            }
                        },
                        onOpenActivity: { opened in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                activityRepository = opened
                            }
                        },
                        onOpenReleases: { opened in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                releasesRepository = opened
                            }
                        },
                        onOpenSettings: { opened in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                settingsRepository = opened
                            }
                        },
                        onCompareBranches: { opened, currentBranch, branches in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                branchComparison = BranchComparisonRoute(
                                    repository: opened,
                                    branches: branches,
                                    initialBaseBranch: currentBranch
                                )
                            }
                        }
                    )
                } else if showCodeAnalyst {
                    CodeAnalystView {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                            showCodeAnalyst = false
                        }
                    }
                } else if let destination = sidebarDestination {
                    SidebarDestinationView(
                        selection: destination,
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                sidebarDestination = nil
                            }
                        },
                        onOpenIssue: openIssue,
                        onOpenPullRequest: openPullRequest,
                        onOpenDiscussion: openDiscussion,
                        onOpenProject: openProject
                    )
                } else if showCopilotHistory {
                    CopilotHistoryView {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                            showCopilotHistory = false
                        }
                    }
                } else if showWatching {
                    WatchingView(
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                showWatching = false
                            }
                        },
                        onOpenRepository: openRepository
                    )
                } else if showRepositories {
                    RepositoriesView(
                        onBack: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                showRepositories = false
                            }
                        },
                        onOpenRepository: openRepository,
                        onOpenWatching: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                showWatching = true
                            }
                        }
                    )
                } else {
                    tabContent
                }
            }

            BottomTabBar(
                selection: tabBinding,
                isLight: showCopilotHistory
                    || (tab == .copilot && !showRepositories && sidebarDestination == nil && !showCodeAnalyst && selectedRepository == nil)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 6)

            sidebarOverlay
            profileMenuOverlay
        }
        .preferredColorScheme(
            showCopilotHistory
                || (tab == .copilot && !showRepositories && sidebarDestination == nil && !showCodeAnalyst && selectedRepository == nil) ? .light : .dark
        )
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet()
                .presentationDetents([.height(620)])
                .presentationCornerRadius(32)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSetStatus) {
            SetStatusSheet()
                .presentationDetents([.large])
                .presentationCornerRadius(24)
                .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private var sidebarOverlay: some View {
        if sidebarOpen {
            ZStack(alignment: .leading) {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture { closeSidebar() }
                    .transition(.opacity)

                HStack(spacing: 0) {
                    SidebarDrawer(
                        active: activeSidebarItem,
                        onSelect: { selection in
                            select(sidebar: selection)
                        },
                        onOpenRepository: openRepository,
                        onSetStatus: {
                            Haptics.tap()
                            closeSidebar()
                            showSetStatus = true
                        },
                        onCreateRepository: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                sidebarOpen = false
                                sidebarDestination = nil
                                showCodeAnalyst = false
                                showRepositories = true
                            }
                        },
                        onOpenProfile: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                sidebarOpen = false
                            }
                            showEditProfile = true
                        },
                        onOpenRepositories: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                sidebarOpen = false
                                sidebarDestination = nil
                                showCodeAnalyst = false
                                showRepositories = true
                            }
                        },
                        onOpenStars: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                sidebarOpen = false
                                sidebarDestination = nil
                                showCodeAnalyst = false
                                showRepositories = false
                                selectedRepository = nil
                                showStars = true
                            }
                        },
                        onOpenOrganisations: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                sidebarOpen = false
                                sidebarDestination = nil
                                showCodeAnalyst = false
                                showRepositories = false
                                selectedOrganisation = nil
                                showOrganisations = true
                            }
                        },
                        onOpenGists: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                sidebarOpen = false
                            }
                            showGists = true
                        },
                        onOpenSettings: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                sidebarOpen = false
                            }
                            showSettings = true
                        },
                        onSignOut: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                sidebarOpen = false
                                sidebarDestination = nil
                                showRepositories = false
                                showCodeAnalyst = false
                                tab = .home
                            }
                            isSignedIn = false
                        },
                        onClose: { closeSidebar() }
                    )
                    .frame(width: 320)

                    Spacer(minLength: 0)
                }
                .ignoresSafeArea()
                .transition(.move(edge: .leading))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .zIndex(10)
        }
    }

    @ViewBuilder
    private var profileMenuOverlay: some View {
        if profileMenuOpen {
            ZStack(alignment: .trailing) {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture { closeProfileMenu() }
                    .transition(.opacity)

                HStack(spacing: 0) {
                    Spacer(minLength: 0)

                    ProfileMenuDrawer(
                        onSelect: { item in
                            if item == .stars {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                    profileMenuOpen = false
                                    sidebarDestination = nil
                                    showRepositories = false
                                    showCodeAnalyst = false
                                    selectedRepository = nil
                                    showStars = true
                                }
                            } else {
                                closeProfileMenu()
                            }
                        },
                        onSetStatus: {
                            Haptics.tap()
                            closeProfileMenu()
                            showSetStatus = true
                        },
                        onCreateRepository: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                profileMenuOpen = false
                                sidebarDestination = nil
                                showRepositories = true
                            }
                        },
                        onEditProfile: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                profileMenuOpen = false
                            }
                            showEditProfile = true
                        },
                        onOpenSettings: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                profileMenuOpen = false
                            }
                            showSettings = true
                        },
                        onOpenGists: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                profileMenuOpen = false
                            }
                            showGists = true
                        },
                        onOpenProfileReadme: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                profileMenuOpen = false
                            }
                            showProfileReadme = true
                        },
                        onSignOut: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                profileMenuOpen = false
                                sidebarDestination = nil
                                showRepositories = false
                                showCodeAnalyst = false
                                tab = .home
                                isSignedIn = false
                            }
                        },
                        onClose: { closeProfileMenu() }
                    )
                    .frame(width: 320)
                }
                .ignoresSafeArea()
                .transition(.move(edge: .trailing))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .zIndex(11)
        }
    }

    private func closeProfileMenu() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            profileMenuOpen = false
        }
    }

    private var activeSidebarItem: SidebarSelection? {
        if showCodeAnalyst {
            return .codeAnalyst
        }
        if showMarketplace {
            return .marketplace
        }
        if showCodespaces {
            return .codespaces
        }
        if let sidebarDestination {
            return sidebarDestination
        }
        if showRepositories {
            return .repositories
        }
        return tab == .home ? .home : nil
    }

    private func closeSidebar() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            sidebarOpen = false
        }
    }

    private func select(sidebar selection: SidebarSelection) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            sidebarOpen = false
            showMarketplace = false
            selectedMarketplaceApp = nil
            showCodespaces = false
            selectedCodespace = nil

            if selection == .home {
                sidebarDestination = nil
                showRepositories = false
                showCodeAnalyst = false
                tab = .home
            } else if selection == .copilot {
                sidebarDestination = nil
                showRepositories = false
                showCodeAnalyst = false
                tab = .copilot
            } else if selection == .marketplace {
                sidebarDestination = nil
                showRepositories = false
                showCodeAnalyst = false
                showMarketplace = true
            } else if selection == .codespaces {
                sidebarDestination = nil
                showRepositories = false
                showCodeAnalyst = false
                showCodespaces = true
            } else if selection == .codeAnalyst {
                sidebarDestination = nil
                showRepositories = false
                showCodeAnalyst = true
            } else {
                showRepositories = false
                showCodeAnalyst = false
                sidebarDestination = selection
            }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch tab {
        case .home:
            HomeView(
                onOpenInbox: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        tab = .inbox
                    }
                },
                onOpenRepositories: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                        showRepositories = true
                    }
                },
                onOpenMenu: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                        profileMenuOpen = false
                        sidebarOpen = true
                    }
                },
                onOpenSearch: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                        showSearch = true
                    }
                },
                onOpenProfileMenu: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                        sidebarOpen = false
                        profileMenuOpen = true
                    }
                },
                onOpenRepository: openRepository,
                onOpenIssue: openIssue,
                onOpenPullRequest: openPullRequest,
                onOpenDiscussion: openDiscussion,
                onOpenOrganisation: openOrganisation,
                onOpenProject: openProject
            )
        case .inbox:
            InboxView(onOpenMenu: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                    profileMenuOpen = false
                    sidebarOpen = true
                }
            })
        case .explore:
            ExploreView(
                onOpenMenu: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                        profileMenuOpen = false
                        sidebarOpen = true
                    }
                },
                onOpenRepository: openRepository,
                onOpenPerson: openPerson,
                onOpenTopic: openTopic
            )
        case .copilot:
            CopilotView(
                onBack: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        tab = .home
                    }
                },
                onOpenHistory: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                        showCopilotHistory = true
                    }
                }
            )
        }
    }
}

struct BottomTabBar: View {
    @EnvironmentObject private var store: AppStore

    @Binding var selection: AppTab
    var isLight: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { item in
                Button {
                    Haptics.select()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selection = item
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: item.symbol)
                            .font(.system(size: 20, weight: .semibold))
                            .overlay(alignment: .topTrailing) {
                                if item == .inbox && store.unreadNotificationCount > 0 {
                                    Text("\(store.unreadNotificationCount)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 4)
                                        .frame(minWidth: 17, minHeight: 17)
                                        .background(Capsule().fill(Palette.accentBright))
                                        .overlay(Capsule().strokeBorder(Color.white.opacity(0.8), lineWidth: 0.8))
                                        .offset(x: 10, y: -7)
                                        .accessibilityLabel("\(store.unreadNotificationCount) unread notifications")
                                }
                            }
                        Text(item.title)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(itemColor(for: item))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        if selection == item {
                            activeBackground
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background {
            barBackground
        }
    }

    private func itemColor(for item: AppTab) -> Color {
        if selection == item {
            return isLight ? CopilotPalette.violet : .white
        }
        return isLight ? Color(hex: 0x7C8CA3) : Palette.inkFaint
    }

    @ViewBuilder
    private var activeBackground: some View {
        if isLight {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.white, lineWidth: 1)
                )
                .shadow(color: CopilotPalette.violet.opacity(0.18), radius: 12, x: 0, y: 6)
        } else {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Palette.accentBright.opacity(0.55), Palette.accent.opacity(0.45)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                )
                .shadow(color: Palette.accentBright.opacity(0.35), radius: 14, x: 0, y: 6)
        }
    }

    @ViewBuilder
    private var barBackground: some View {
        if isLight {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.white.opacity(0.62))
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.85), lineWidth: 1)
                )
                .shadow(color: Color(hex: 0x1B2A55).opacity(0.12), radius: 22, x: 0, y: 12)
        } else {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Palette.surface.opacity(0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.14), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.30), .white.opacity(0.16)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color(hex: 0x140D4D).opacity(0.55), radius: 24, x: 0, y: 16)
        }
    }
}


struct PlaceholderScreen: View {
    var tab: AppTab

    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Palette.accentBright, Palette.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 96, height: 96)
                    .shadow(color: Palette.accentBright.opacity(0.55), radius: 24, y: 10)

                Image(systemName: tab.symbol)
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text(tab.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)

            Text(tab.blurb)
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)

            Text("Coming soon")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Palette.inkMuted)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Capsule().fill(Color.white.opacity(0.10)))
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.16), lineWidth: 1))
                .padding(.top, 4)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 30)
        .padding(.bottom, 110)
    }
}

#Preview {
    RootView(isSignedIn: .constant(true))
        .environmentObject(AppStore())
}
