//
//  CopilotView.swift
//  GitHub 3D
//
//  The light Copilot dashboard: greeting, message card and model controls.
//

import SwiftUI

enum CopilotPalette {
    static let canvas = Color(hex: 0xDBE7F5)
    static let ink = Color(hex: 0x101F3C)
    static let inkMuted = Color(hex: 0x6A7C96)
    static let violet = Color(hex: 0x5A3DD3)
    static let line = Color(hex: 0xC7D2E6)
}

struct CopilotModel: Identifiable, Hashable {
    var name: String
    var detail: String

    var id: String { name }

    static let all: [CopilotModel] = [
        CopilotModel(name: "GPT-5.4 mini", detail: "Fast and cost-efficient"),
        CopilotModel(name: "GPT-5.2", detail: "Versatile and highly intelligent"),
        CopilotModel(name: "GPT-5.4", detail: "Most powerful at complex tasks")
    ]
}

enum Optimisation: String, CaseIterable, Identifiable {
    case efficiency
    case balance
    case intelligence

    var id: String { rawValue }

    var title: String {
        switch self {
        case .efficiency: return "Efficiency"
        case .balance: return "Balance"
        case .intelligence: return "Intelligence"
        }
    }

    var detail: String {
        switch self {
        case .efficiency: return "Prioritises speed and efficiency"
        case .balance: return "Balances speed and intelligence"
        case .intelligence: return "Prioritises intelligence"
        }
    }

    var symbol: String {
        switch self {
        case .efficiency: return "bolt.fill"
        case .balance: return "scalemass.fill"
        case .intelligence: return "brain"
        }
    }
}

// MARK: - Backdrop

struct CopilotBackdrop: View {
    var body: some View {
        ZStack {
            CopilotPalette.canvas

            RadialGradient(
                colors: [Color.white.opacity(0.85), .clear],
                center: UnitPoint(x: 0.85, y: 0.02),
                startRadius: 0,
                endRadius: 340
            )

            RadialGradient(
                colors: [CopilotPalette.violet.opacity(0.18), .clear],
                center: UnitPoint(x: 0.08, y: 0.92),
                startRadius: 0,
                endRadius: 320
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Copilot screen

struct CopilotView: View {
    @EnvironmentObject private var store: AppStore

    @AppStorage("copilot.model.name") private var modelName: String = "GPT-5.4 mini"
    @AppStorage("copilot.auto") private var autoMode: Bool = true
    @AppStorage("copilot.optimisation") private var optimisationRaw: String = Optimisation.balance.rawValue

    @State private var errorText: String = ""
    @State private var message: String = "Help me find the root cause of this error"
    @State private var showModels = false
    @State private var showUpgrade = false
    @State private var showCreateIssue = false
    @State private var activePersona: CopilotPersona?
    @State private var activeGit: GitReference?
    @State private var pendingToast: String?
    @State private var toast: String?
    @State private var isThinking = false

    var onBack: () -> Void = {}
    var onOpenHistory: () -> Void = {}

    private var selectedModel: CopilotModel {
        CopilotModel.all.first(where: { $0.name == modelName }) ?? CopilotModel.all[0]
    }

    private var optimisation: Optimisation {
        Optimisation(rawValue: optimisationRaw) ?? .balance
    }

    var body: some View {
        ZStack {
            CopilotBackdrop()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 10)

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            greeting
                            messageCard
                            historyRow
                            conversation
                            modelControls(proxy: proxy)
                            upgradeLink
                            optimisedSection
                            quickActions
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 134)
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            if let toast {
                CopilotToast(text: toast)
                    .padding(.bottom, 118)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showModels) {
            CopilotModelSheet(selectedName: selectedModel.name) { model in
                modelName = model.name
            }
            .presentationDetents([.height(430)])
            .presentationCornerRadius(32)
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showUpgrade) {
            CopilotUpgradeSheet()
                .presentationDetents([.height(430)])
                .presentationCornerRadius(32)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showCreateIssue, onDismiss: showPendingToast) {
            CopilotCreateIssueSheet { message in
                pendingToast = message
            }
            .presentationDetents([.large])
            .presentationCornerRadius(32)
            .preferredColorScheme(.light)
        }
        .sheet(item: $activePersona, onDismiss: showPendingToast) { persona in
            CopilotPersonaSheet(persona: persona) {
                pendingToast = "\(persona.title) is on it"
            }
            .presentationDetents([.height(330)])
            .presentationCornerRadius(32)
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $activeGit) { reference in
            CopilotGitReferenceSheet(reference: reference)
                .presentationDetents([.large])
                .presentationCornerRadius(32)
                .presentationDragIndicator(.visible)
        }
        .preferredColorScheme(.light)
    }

    // MARK: Toast

    private func showPendingToast() {
        guard let pending = pendingToast else { return }
        pendingToast = nil
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            toast = pending
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            guard toast == pending else { return }
            withAnimation(.easeOut(duration: 0.25)) {
                toast = nil
            }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Button {
                Haptics.tap()
                onBack()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(CopilotPalette.ink)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white.opacity(0.78)))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.9), lineWidth: 1))
            }
            .buttonStyle(PressableStyle(scale: 0.92))

            Spacer()

            Text("Copilot")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(CopilotPalette.ink)

            Spacer()

            AvatarView(initials: store.profile.initials, size: 42)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .lightGlass(fill: Color.white.opacity(0.55), radius: 28)
    }

    // MARK: Greeting

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Good afternoon,\nMe \(store.profile.name).")
                .font(.system(size: 33, weight: .bold))
                .tracking(-0.5)
                .foregroundStyle(CopilotPalette.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text("What are we building today?")
                .font(.system(size: 17))
                .foregroundStyle(CopilotPalette.inkMuted)
        }
        .padding(.top, 4)
    }

    // MARK: Message card

    private var messageCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MESSAGE")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.6)
                .foregroundStyle(CopilotPalette.violet)

            Text(message)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(CopilotPalette.ink)
                .fixedSize(horizontal: false, vertical: true)

            DashedDivider()
                .stroke(CopilotPalette.line, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .frame(height: 1)
                .padding(.vertical, 2)

            TextField("Paste the error here…", text: $errorText, axis: .vertical)
                .font(.system(size: 16))
                .foregroundStyle(CopilotPalette.ink)
                .tint(CopilotPalette.violet)
                .lineLimit(1...5)
                .frame(minHeight: 52, alignment: .topLeading)

            HStack {
                Spacer()
                sendButton
            }
            .padding(.top, 2)
        }
        .padding(20)
        .lightGlass(fill: Color(hex: 0xF8F6FF).opacity(0.96), radius: 28)
    }

    private var sendButton: some View {
        Button {
            send()
        } label: {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 54, height: 54)
                .background(Circle().fill(CopilotPalette.violet))
                .overlay(Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1))
                .shadow(color: CopilotPalette.violet.opacity(0.45), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(PressableStyle(scale: 0.92))
    }

    private func send() {
        let typed = errorText.trimmingCharacters(in: .whitespacesAndNewlines)
        let prompt = typed.isEmpty ? message : typed
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        Haptics.tap()
        let model = selectedModel.name
        store.appendCopilotUser(prompt, model: model)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            errorText = ""
            isThinking = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                store.appendCopilotReply(to: prompt, model: model)
                isThinking = false
            }
        }
    }

    // MARK: History

    private var historyRow: some View {
        Button {
            Haptics.tap()
            onOpenHistory()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(CopilotPalette.violet)
                    .frame(width: 46, height: 46)
                    .background(Circle().fill(CopilotPalette.violet.opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text("History")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(CopilotPalette.ink)

                    Text(historySubtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(CopilotPalette.inkMuted)
                        .lineLimit(1)
                }

                Spacer(minLength: 6)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(CopilotPalette.inkMuted)
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 64)
            .lightGlass(fill: Color.white.opacity(0.82), radius: 22)
        }
        .buttonStyle(PressableStyle(scale: 0.99))
    }

    private var historySubtitle: String {
        let count = store.copilotConversations.count
        if count == 0 { return "No conversations yet" }
        if count == 1 { return "1 conversation this session" }
        return "\(count) conversations this session"
    }

    // MARK: Conversation

    private var conversation: some View {
        VStack(alignment: .leading, spacing: 10) {
            if store.copilotMessages.isEmpty {
                emptyConversation
            } else {
                ForEach(store.copilotMessages) { message in
                    messageBubble(message)
                }
            }

            if isThinking {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(CopilotPalette.violet)
                        .scaleEffect(0.8)
                    Text("Copilot is writing…")
                        .font(.system(size: 13))
                        .foregroundStyle(CopilotPalette.inkMuted)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 4)
                .transition(.opacity)
            }
        }
    }

    private var emptyConversation: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(CopilotPalette.violet)

            Text("Ask Copilot anything — paste an error, describe a feature, or pick a shortcut.")
                .font(.system(size: 13))
                .foregroundStyle(CopilotPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.8), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func messageBubble(_ message: CopilotMessage) -> some View {
        if message.role == .user {
            HStack {
                Spacer(minLength: 40)

                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.trailing)

                    Text(message.time)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [CopilotPalette.violet, Color(hex: 0x3B35AF)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            }
        } else {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .semibold))
                    Text(message.model ?? "Copilot")
                        .font(.system(size: 12, weight: .semibold))
                    Spacer(minLength: 4)
                    Text(message.time)
                        .font(.system(size: 11))
                        .foregroundStyle(CopilotPalette.inkMuted)
                }
                .foregroundStyle(CopilotPalette.violet)

                Text(message.text)
                    .font(.system(size: 15))
                    .foregroundStyle(CopilotPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.92))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.9), lineWidth: 1)
            )
        }
    }

    // MARK: Model controls

    private func modelControls(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                modelPill
                autoPill
            }

            Button {
                Haptics.select()
                withAnimation(.easeInOut(duration: 0.4)) {
                    proxy.scrollTo("optimised", anchor: .center)
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "scope")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(CopilotPalette.violet)

                    HStack(spacing: 4) {
                        Text("Optimised for:")
                            .foregroundStyle(CopilotPalette.inkMuted)
                        Text(optimisation.title)
                            .foregroundStyle(CopilotPalette.ink)
                    }
                    .font(.system(size: 16, weight: .medium))

                    Spacer(minLength: 6)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(CopilotPalette.inkMuted)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .lightGlass(fill: Color.white.opacity(0.82), radius: 22)
            }
            .buttonStyle(PressableStyle())
        }
    }

    private var modelPill: some View {
        Button {
            Haptics.tap()
            showModels = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "cpu")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(CopilotPalette.violet)

                Text("Models · \(selectedModel.name)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(CopilotPalette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(CopilotPalette.inkMuted)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .lightGlass(fill: Color.white.opacity(0.82), radius: 22)
        }
        .buttonStyle(PressableStyle())
    }

    private var autoPill: some View {
        HStack(spacing: 8) {
            Text("Auto")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(CopilotPalette.ink)

            Toggle("Auto", isOn: $autoMode)
                .labelsHidden()
                .tint(CopilotPalette.violet)
                .scaleEffect(0.8)
                .frame(width: 44)
        }
        .padding(.leading, 16)
        .padding(.trailing, 8)
        .frame(width: 148)
        .frame(height: 56)
        .lightGlass(fill: Color.white.opacity(0.82), radius: 22)
    }

    private var upgradeLink: some View {
        Button {
            Haptics.tap()
            showUpgrade = true
        } label: {
            Text("Upgrade for more models and higher limits")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(CopilotPalette.violet)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: Optimisation

    private var optimisedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Optimised for")
                .font(.system(size: 15))
                .foregroundStyle(CopilotPalette.inkMuted)
                .padding(.top, 2)

            ForEach(Optimisation.allCases) { option in
                optimisationRow(option)
            }
        }
        .id("optimised")
    }

    private func optimisationRow(_ option: Optimisation) -> some View {
        let isSelected = optimisation == option

        return Button {
            Haptics.select()
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                optimisationRaw = option.rawValue
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: option.symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isSelected ? CopilotPalette.violet : CopilotPalette.ink.opacity(0.45))
                    .frame(width: 46, height: 46)
                    .background(
                        Circle()
                            .fill(isSelected ? CopilotPalette.violet.opacity(0.14) : Color(hex: 0xE9EEF7))
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(option.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(CopilotPalette.ink)
                    Text(option.detail)
                        .font(.system(size: 14))
                        .foregroundStyle(CopilotPalette.inkMuted)
                }

                Spacer(minLength: 6)

                if isSelected {
                    ZStack {
                        Circle()
                            .fill(CopilotPalette.violet)
                            .frame(width: 26, height: 26)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                } else {
                    Circle()
                        .strokeBorder(Color(hex: 0xD3DBEA), lineWidth: 1.5)
                        .frame(width: 26, height: 26)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(isSelected ? CopilotPalette.violet.opacity(0.08) : Color.white.opacity(0.86))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        isSelected ? CopilotPalette.violet.opacity(0.55) : Color.white.opacity(0.9),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .shadow(color: Color(hex: 0x1B2A55).opacity(0.08), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(PressableStyle(scale: 0.985))
    }

    // MARK: Quick actions

    private var quickActions: some View {
        CopilotQuickActionsBar(
            onPersona: { persona in
                activePersona = persona
            },
            onCreateIssue: {
                showCreateIssue = true
            },
            onWriteCode: { prompt in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    message = prompt.prompt
                }
            },
            onGit: { reference in
                activeGit = reference
            }
        )
    }
}

// MARK: - Dashed divider

struct DashedDivider: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

// MARK: - Model sheet

struct CopilotModelSheet: View {
    var selectedName: String
    var onSelect: (CopilotModel) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showUpgrade = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Models")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(CopilotPalette.ink)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(CopilotPalette.ink)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.white.opacity(0.9)))
                }
                .buttonStyle(PressableStyle(scale: 0.9))
            }

            Text("Pick the model that fits the job.")
                .font(.system(size: 15))
                .foregroundStyle(CopilotPalette.inkMuted)

            VStack(spacing: 10) {
                ForEach(CopilotModel.all) { model in
                    let isSelected = model.name == selectedName

                    Button {
                        Haptics.select()
                        onSelect(model)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(model.name)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(CopilotPalette.ink)
                                Text(model.detail)
                                    .font(.system(size: 14))
                                    .foregroundStyle(CopilotPalette.inkMuted)
                                    .lineLimit(1)
                            }

                            Spacer(minLength: 6)

                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(CopilotPalette.violet)
                            } else {
                                Circle()
                                    .strokeBorder(Color(hex: 0xD3DBEA), lineWidth: 1.5)
                                    .frame(width: 22, height: 22)
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(isSelected ? CopilotPalette.violet.opacity(0.08) : Color.white.opacity(0.85))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(
                                    isSelected ? CopilotPalette.violet.opacity(0.5) : Color.white.opacity(0.9),
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(PressableStyle(scale: 0.98))
                }
            }

            Button {
                showUpgrade = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Upgrade for more models and higher limits")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(CopilotPalette.violet)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(CopilotPalette.canvas)
        .preferredColorScheme(.light)
        .sheet(isPresented: $showUpgrade) {
            CopilotUpgradeSheet()
                .presentationDetents([.height(430)])
                .presentationCornerRadius(32)
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Upgrade sheet

struct CopilotUpgradeSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let benefits: [(symbol: String, title: String, detail: String)] = [
        ("sparkles", "Newest models first", "GPT-5.4 and every model shipped after it."),
        ("gauge", "Higher limits", "More messages and more requests every day."),
        ("doc.text", "Longer context", "Bring entire codebases into one conversation."),
        ("bolt.fill", "Priority speed", "Faster responses at peak hours.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("More models. Higher limits.")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(CopilotPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(CopilotPalette.ink)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.white.opacity(0.9)))
                }
                .buttonStyle(PressableStyle(scale: 0.9))
            }

            Text("Upgrade Copilot 3D to unlock the full model line-up and the room to use it.")
                .font(.system(size: 15))
                .foregroundStyle(CopilotPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 8) {
                ForEach(benefits, id: \.title) { benefit in
                    HStack(spacing: 12) {
                        Image(systemName: benefit.symbol)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(CopilotPalette.violet)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(CopilotPalette.violet.opacity(0.12)))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(benefit.title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(CopilotPalette.ink)
                            Text(benefit.detail)
                                .font(.system(size: 13))
                                .foregroundStyle(CopilotPalette.inkMuted)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.85))
                    )
                }
            }

            Spacer(minLength: 0)

            Button {
                dismiss()
            } label: {
                Text("Got it")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(CopilotPalette.violet)
                    )
                    .shadow(color: CopilotPalette.violet.opacity(0.35), radius: 16, x: 0, y: 8)
            }
            .buttonStyle(PressableStyle())
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(CopilotPalette.canvas)
        .preferredColorScheme(.light)
    }
}

#Preview {
    CopilotView()
        .environmentObject(AppStore())
}
