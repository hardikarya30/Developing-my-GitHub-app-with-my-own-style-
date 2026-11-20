//
//  CopilotAppSheet.swift
//  GitHub 3D
//
//  The download-link form for the GitHub Copilot app.
//

import SwiftUI

struct CopilotAppSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var errorMessage: String?
    @State private var sentTo: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text("The GitHub Copilot app")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

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

            if let sentTo {
                confirmation(for: sentTo)
            } else {
                form
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppBackdrop())
        .preferredColorScheme(.dark)
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Copilot on the go. Enter your email and we will send the download link to your inbox.")
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            Text("EMAIL")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(Palette.inkFaint)
                .padding(.top, 4)

            TextField("you@example.com", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(.emailAddress)
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .tint(Palette.accentBright)
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            errorMessage == nil
                                ? Color.white.opacity(0.18)
                                : Color(hex: 0xFF8A8A).opacity(0.75),
                            lineWidth: 1
                        )
                )

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: 0xFF8A8A))
            }

            GradientActionButton(title: "Send me download link", systemImage: "paperplane") {
                submit()
            }
            .padding(.top, 4)

            Spacer(minLength: 0)
        }
    }

    private func confirmation(for address: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Palette.accentBright)
                .padding(.top, 8)

            Text("Link on its way")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            Text("We sent the download link to\n\(address).")
                .font(.system(size: 15))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            GradientActionButton(title: "Done") {
                dismiss()
            }
            .padding(.top, 10)

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    sentTo = nil
                    email = ""
                    errorMessage = nil
                }
            } label: {
                Text("Use another email")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Palette.inkFaint)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
    }

    private func submit() {
        let address = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidEmail(address) else {
            Haptics.tap()
            withAnimation(.easeOut(duration: 0.2)) {
                errorMessage = "Enter a valid email address."
            }
            return
        }

        errorMessage = nil
        Haptics.tap()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            sentTo = address
        }
    }

    private func isValidEmail(_ value: String) -> Bool {
        let parts = value.split(separator: "@")
        guard parts.count == 2, !parts[0].isEmpty, !parts[1].isEmpty else { return false }
        let domain = parts[1]
        return domain.contains(".") && !domain.hasPrefix(".") && !domain.hasSuffix(".")
    }
}

#Preview {
    CopilotAppSheet()
}
