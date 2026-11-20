//
//  EditProfileSheet.swift
//  GitHub 3D
//
//  Edit the display name, handle, bio and avatar initials.
//

import SwiftUI

struct EditProfileSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var handle = ""
    @State private var bio = ""
    @State private var initials = ""

    @State private var nameError: String?
    @State private var handleError: String?
    @State private var bioError: String?
    @State private var initialsError: String?

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && isValidHandle(handle.trimmingCharacters(in: .whitespacesAndNewlines))
            && isValidInitials(initials)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text("Edit profile")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Color.white.opacity(0.12)))
                }
                .buttonStyle(PressableStyle(scale: 0.9))
            }

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("DISPLAY NAME")
                TextField("Hardik Arya", text: $name)
                    .authField(isError: nameError != nil)
                errorText(nameError)
            }

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("HANDLE")
                HStack(spacing: 6) {
                    Text("@")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Palette.inkMuted)
                    TextField("hardikarya30", text: $handle)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .authField(isError: handleError != nil)
                errorText(handleError)
            }

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("BIO")
                TextField("iOS engineer · Swift & SwiftUI", text: $bio, axis: .vertical)
                    .lineLimit(2...4)
                    .authField(isError: bioError != nil)
                errorText(bioError)
            }

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("AVATAR INITIALS")
                TextField("HA", text: $initials)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .authField(isError: initialsError != nil)
                errorText(initialsError)
            }

            Spacer(minLength: 0)

            GradientActionButton(title: "Save") {
                save()
            }
            .disabled(!canSave)
            .opacity(canSave ? 1 : 0.5)

            Button {
                Haptics.tap()
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.10))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    )
            }
            .buttonStyle(PressableStyle())
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppBackdrop())
        .preferredColorScheme(.dark)
        .onAppear {
            name = store.profile.name
            handle = store.profile.handle
            bio = store.profile.bio
            initials = store.profile.initials
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .tracking(1.3)
            .foregroundStyle(Palette.inkFaint)
    }

    @ViewBuilder
    private func errorText(_ message: String?) -> some View {
        if let message {
            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(Color(hex: 0xFF8A8A))
        }
    }

    private func save() {
        nameError = nil
        handleError = nil
        bioError = nil
        initialsError = nil

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHandle = handle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedInitials = initials.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        var isValid = true

        if trimmedName.count < 2 {
            nameError = "Enter your display name."
            isValid = false
        }

        if !isValidHandle(trimmedHandle) {
            handleError = "Use 3 or more letters, numbers or hyphens."
            isValid = false
        }

        if trimmedBio.count > 160 {
            bioError = "Keep the bio under 160 characters."
            isValid = false
        }

        if !isValidInitials(trimmedInitials) {
            initialsError = "Use one or two letters."
            isValid = false
        }

        guard isValid else {
            Haptics.tap()
            return
        }

        Haptics.tap()
        store.updateProfile(
            name: trimmedName,
            handle: trimmedHandle,
            bio: trimmedBio,
            initials: trimmedInitials
        )
        dismiss()
    }

    private func isValidInitials(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (1...2).contains(trimmed.count) else { return false }
        return trimmed.unicodeScalars.allSatisfy { CharacterSet.letters.contains($0) }
    }
}

#Preview {
    EditProfileSheet()
        .environmentObject(AppStore())
}
