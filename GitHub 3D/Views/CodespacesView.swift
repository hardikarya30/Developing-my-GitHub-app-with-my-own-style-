//
//  CodespacesView.swift
//  GitHub 3D
//
//  Your cloud development environments.
//

import SwiftUI

struct CodespacesView: View {
    @EnvironmentObject private var store: AppStore

    var onBack: () -> Void = {}
    var onOpenCodespace: (CodespaceItem) -> Void = { _ in }
    var onCreatedCodespace: (CodespaceItem) -> Void = { _ in }

    @State private var showNewCodespace = false

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("\(store.codespaces.count) codespaces")
                        .font(.system(size: 15))
                        .foregroundStyle(Palette.inkMuted)

                    if store.codespaces.isEmpty {
                        emptyState
                    } else {
                        ForEach(store.codespaces) { codespace in
                            row(codespace)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
            }
        }
        .sheet(isPresented: $showNewCodespace) {
            NewCodespaceView { codespace in
                onCreatedCodespace(codespace)
            }
            .presentationDetents([.large])
            .presentationCornerRadius(32)
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            circleButton(symbol: "chevron.left") {
                Haptics.tap()
                onBack()
            }

            Spacer()

            Text("Codespaces")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            circleButton(symbol: "plus") {
                Haptics.tap()
                showNewCodespace = true
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

    // MARK: Row

    private func row(_ codespace: CodespaceItem) -> some View {
        Button {
            Haptics.tap()
            onOpenCodespace(codespace)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "terminal")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Palette.accentBright, Palette.accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(codespace.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Circle()
                            .fill(codespace.isRunning ? Color(hex: 0x3FB950) : Palette.inkFaint)
                            .frame(width: 7, height: 7)

                        Text(codespace.isRunning ? "Running" : "Stopped")
                            .font(.system(size: 13))
                            .foregroundStyle(Palette.inkMuted)

                        Text("·")
                            .foregroundStyle(Palette.inkFaint)

                        Text("Last used \(codespace.lastUsed)")
                            .font(.system(size: 13))
                            .foregroundStyle(Palette.inkFaint)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 6)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(hex: 0x32288C).opacity(0.85))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.99))
    }

    // MARK: Empty

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "terminal")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Palette.inkMuted)
                .frame(width: 64, height: 64)
                .background(Circle().fill(Color.white.opacity(0.08)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

            Text("No codespaces yet")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            Text("Start one from a repository and it will show up here.")
                .font(.system(size: 14))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .glassCard()
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        CodespacesView()
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
