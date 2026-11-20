//
//  SetStatusSheet.swift
//  GitHub 3D
//
//  Set the short status shown in the sidebar and the profile menu.
//

import SwiftUI

struct SetStatusSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    @State private var isBusy = false
    @State private var expiration = "Never"
    @State private var visibility = "Everyone"

    private let characterLimit = 80

    private let suggestions: [(emoji: String, text: String)] = [
        ("🌴", "On vacation"),
        ("😏", "Out sick"),
        ("🏠", "Working from home"),
        ("🎯", "Focusing")
    ]

    private let expirations = ["Never", "30 minutes", "1 hour", "4 hours", "1 day", "1 week"]
    private let visibilities = ["Everyone", "Organisation"]

    private let ink = Color(hex: 0x1F2328)
    private let mutedInk = Color(hex: 0x59636E)
    private let hairline = Color(hex: 0xD0D7DE)
    private let fieldFill = Color(hex: 0xF6F8FA)
    private let green = Color(hex: 0x1F883D)

    private var remaining: Int {
        max(0, characterLimit - text.count)
    }

    private var currentEmoji: String {
        suggestions.first(where: { $0.text == text })?.emoji ?? "💬"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                header
                whatHappening
                suggestionChips
                busySection

                Divider()
                    .overlay(hairline)

                pickerSection(
                    title: "Expiration",
                    value: expiration,
                    options: expirations,
                    caption: "Your status will be cleared after the selected time.",
                    onSelect: { expiration = $0 }
                )

                pickerSection(
                    title: "Visible to",
                    value: visibility,
                    options: visibilities,
                    caption: "Limit status visibility to a single organization.",
                    onSelect: { visibility = $0 }
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .safeAreaInset(edge: .bottom) {
            footer
        }
        .preferredColorScheme(.light)
        .onAppear {
            if text.isEmpty {
                text = store.status
            }
            isBusy = store.statusIsBusy
            expiration = store.statusExpiration
            visibility = store.statusVisibility
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Text("Edit status")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(ink)

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(mutedInk)
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 2)
    }

    // MARK: Status

    private var whatHappening: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("What's happening")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(ink)

            HStack(spacing: 10) {
                Text(currentEmoji)
                    .font(.system(size: 30))
                    .frame(width: 56, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(hairline, lineWidth: 1)
                    )

                TextField("What's happening?", text: $text)
                    .font(.system(size: 18))
                    .foregroundStyle(ink)
                    .tint(green)
                    .padding(.horizontal, 12)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(hairline, lineWidth: 1)
                    )
                    .onChange(of: text) { _, newValue in
                        if newValue.count > characterLimit {
                            text = String(newValue.prefix(characterLimit))
                        }
                    }
            }

            Text("\(remaining) characters remaining")
                .font(.system(size: 16))
                .foregroundStyle(mutedInk)
                .padding(.leading, 66)
        }
    }

    private var suggestionChips: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ForEach(Array(suggestions.prefix(2)), id: \.text) { item in
                    suggestionChip(emoji: item.emoji, text: item.text)
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                ForEach(Array(suggestions.dropFirst(2)), id: \.text) { item in
                    suggestionChip(emoji: item.emoji, text: item.text)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private func suggestionChip(emoji: String, text suggestionText: String) -> some View {
        Button {
            Haptics.select()
            text = suggestionText
        } label: {
            HStack(spacing: 6) {
                Text(emoji)
                    .font(.system(size: 17))
                Text(suggestionText)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(mutedInk)
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .frame(height: 40)
            .background(Capsule().fill(fieldFill))
            .overlay(Capsule().strokeBorder(hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: Busy

    private var busySection: some View {
        HStack(alignment: .top, spacing: 14) {
            Button {
                Haptics.select()
                withAnimation(.easeOut(duration: 0.15)) {
                    isBusy.toggle()
                }
            } label: {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isBusy ? green : Color.white)
                    .frame(width: 26, height: 26)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(isBusy ? green : hairline, lineWidth: 1)
                    )
                    .overlay {
                        if isBusy {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                Text("Busy")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(ink)

                Text("When others mention you, assign you, or request your review, GitHub will let them know that you have limited availability.")
                    .font(.system(size: 17))
                    .foregroundStyle(mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: Pickers

    private func pickerSection(
        title: String,
        value: String,
        options: [String],
        caption: String,
        onSelect: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(ink)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        Haptics.select()
                        onSelect(option)
                    } label: {
                        if option == value {
                            Label(option, systemImage: "checkmark")
                        } else {
                            Text(option)
                        }
                    }
                }
            } label: {
                HStack {
                    Text(value)
                        .font(.system(size: 18))
                        .foregroundStyle(ink)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(mutedInk)
                }
                .padding(.horizontal, 12)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(hairline, lineWidth: 1)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Text(caption)
                .font(.system(size: 16))
                .foregroundStyle(mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Footer

    private var footer: some View {
        HStack(spacing: 12) {
            Button {
                Haptics.tap()
                clearStatus()
            } label: {
                Text("Clear status")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(fieldFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(hairline, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            Button {
                Haptics.tap()
                save()
            } label: {
                Text("Set status")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(green)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(Color.white)
        .overlay(alignment: .top) {
            Divider().overlay(hairline)
        }
    }

    private func save() {
        store.updateStatus(text)
        store.updateStatusDetails(
            isBusy: isBusy,
            expiration: expiration,
            visibility: visibility
        )
        dismiss()
    }

    private func clearStatus() {
        store.updateStatus("")
        store.updateStatusDetails(
            isBusy: false,
            expiration: "Never",
            visibility: "Everyone"
        )
        text = ""
        dismiss()
    }
}

#Preview {
    SetStatusSheet()
        .environmentObject(AppStore())
}
