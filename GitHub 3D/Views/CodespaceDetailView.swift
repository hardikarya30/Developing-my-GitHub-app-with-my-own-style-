//
//  CodespaceDetailView.swift
//  GitHub 3D
//
//  One cloud codespace: its machine, status, and start / stop / delete actions.
//

import SwiftUI

struct CodespaceDetailView: View {
    @EnvironmentObject private var store: AppStore

    var codespaceID: UUID
    var onBack: () -> Void = {}

    @State private var showDeleteConfirmation = false

    private var codespace: CodespaceItem? {
        store.codespaces.first(where: { $0.id == codespaceID })
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)

            if let codespace {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        hero(codespace)
                        machineCard(codespace)
                        powerButton(codespace)
                        actions
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 130)
                }
            }
        }
        .alert("Delete codespace?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteCodespace()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This codespace and its unsaved work will be removed.")
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

            Text("Codespace")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            circleButton(symbol: "ellipsis") {
                Haptics.tap()
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

    // MARK: Hero

    private func hero(_ codespace: CodespaceItem) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Palette.accentBright, Palette.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 96, height: 96)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white.opacity(0.10))
                            .padding(12)
                    )
                    .overlay(
                        Image(systemName: "terminal")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .shadow(color: Palette.accentBright.opacity(0.40), radius: 18, x: 0, y: 10)

                VStack(alignment: .leading, spacing: 4) {
                    Text(codespace.name)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.leading)

                    Text(codespace.repository)
                        .font(.system(size: 16))
                        .foregroundStyle(Palette.inkMuted)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    statusChip(isRunning: codespace.isRunning)
                        .padding(.top, 2)
                }

                Spacer(minLength: 0)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    private func statusChip(isRunning: Bool) -> some View {
        HStack(spacing: 7) {
            Circle()
                .fill(isRunning ? Color(hex: 0x3FB950) : Palette.inkMuted)
                .frame(width: 8, height: 8)

            Text(isRunning ? "Running" : "Stopped")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isRunning ? Color(hex: 0x3FB950) : Palette.inkMuted)
        }
        .padding(.horizontal, 12)
        .frame(height: 32)
        .background(
            Capsule().fill(
                isRunning
                    ? Color(hex: 0x3FB950).opacity(0.18)
                    : Color.white.opacity(0.10)
            )
        )
        .overlay(
            Capsule().strokeBorder(
                isRunning
                    ? Color(hex: 0x3FB950).opacity(0.40)
                    : Color.white.opacity(0.16),
                lineWidth: 1
            )
        )
    }

    // MARK: Machine

    private func machineCard(_ codespace: CodespaceItem) -> some View {
        VStack(spacing: 0) {
            detailRow(label: "Machine", value: codespace.machine, showsDivider: true)
            detailRow(label: "Region", value: codespace.region, showsDivider: true)
            detailRow(label: "Last used", value: codespace.lastUsed, showsDivider: false)
        }
        .padding(.horizontal, 18)
        .glassCard()
    }

    private func detailRow(label: String, value: String, showsDivider: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(label)
                    .font(.system(size: 16))
                    .foregroundStyle(Palette.inkMuted)

                Spacer(minLength: 8)

                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(height: 54)

            if showsDivider {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
            }
        }
    }

    // MARK: Power

    private func powerButton(_ codespace: CodespaceItem) -> some View {
        Button {
            Haptics.select()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                store.toggleCodespaceRunning(codespace.id)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: codespace.isRunning ? "stop.fill" : "play.fill")
                    .font(.system(size: 15, weight: .semibold))
                Text(codespace.isRunning ? "Stop codespace" : "Start codespace")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
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
            .shadow(color: Palette.accent.opacity(0.45), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(PressableStyle())
    }

    // MARK: Actions

    private var actions: some View {
        HStack(spacing: 12) {
            Button {
                Haptics.tap()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.forward.square")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Open in browser")
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
                )
            }
            .buttonStyle(PressableStyle())

            Button {
                Haptics.tap()
                showDeleteConfirmation = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Delete codespace")
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .foregroundStyle(Color(hex: 0xFF8A8A))
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(hex: 0xFF5A5A).opacity(0.16))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color(hex: 0xFF5A5A).opacity(0.35), lineWidth: 1)
                )
            }
            .buttonStyle(PressableStyle())
        }
    }

    private func deleteCodespace() {
        guard let codespace else { return }
        Haptics.tap()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            store.deleteCodespace(codespace.id)
        }
        onBack()
    }
}

#Preview {
    ZStack {
        AppBackdrop()
        CodespaceDetailView(codespaceID: AppStore.sampleCodespaces[0].id)
    }
    .environmentObject(AppStore())
    .preferredColorScheme(.dark)
}
