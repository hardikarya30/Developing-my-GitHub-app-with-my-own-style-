//
//  AuthViews.swift
//  GitHub 3D
//
//  The welcome screen and the sign-in / sign-up forms that unlock the app.
//

import SwiftUI

enum AuthPage {
    case welcome
    case signIn
    case signUp
}

struct AuthFlowView: View {
    @Binding var isSignedIn: Bool

    @State private var page: AuthPage = .welcome

    var body: some View {
        ZStack {
            AppBackdrop()

            Group {
                switch page {
                case .welcome:
                    WelcomeAuthView(
                        onSignIn: { go(.signIn) },
                        onCreateAccount: { go(.signUp) },
                        onSocialSignUp: {
                            Haptics.tap()
                            isSignedIn = true
                        }
                    )
                    .transition(.opacity)
                case .signIn:
                    SignInView(
                        isSignedIn: $isSignedIn,
                        onBack: { go(.welcome) },
                        onCreateAccount: { go(.signUp) }
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                case .signUp:
                    SignUpView(
                        isSignedIn: $isSignedIn,
                        onBack: { go(.welcome) },
                        onSignIn: { go(.signIn) }
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func go(_ next: AuthPage) {        withAnimation(.spring(response: 0.42, dampingFraction: 0.9)) {
            page = next
        }
    }
}

// MARK: - Welcome

struct WelcomeAuthView: View {
    var onSignIn: () -> Void
    var onCreateAccount: () -> Void
    var onSocialSignUp: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 0)

            HAFreelanceMark(size: 96)
                .padding(.bottom, 6)

            Text("GitHub 3D")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)

            Text("Your profile, repositories and Copilot in one dark glass workspace.")
                .font(.system(size: 16))
                .foregroundStyle(Palette.inkMuted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12)

            Spacer(minLength: 0)

            VStack(spacing: 12) {
                GradientActionButton(title: "Sign in", systemImage: "arrow.right") {
                    Haptics.tap()
                    onSignIn()
                }

                Button {
                    Haptics.tap()
                    onCreateAccount()
                } label: {
                    Text("Create account")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white.opacity(0.10))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.20), lineWidth: 1)
                        )
                }
                .buttonStyle(PressableStyle())
            }
            .padding(.bottom, 12)

            Text("Don't have an account? Sign up with Google or Apple.")
                .font(.system(size: 13))
                .foregroundStyle(Palette.inkFaint)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.bottom, 4)

            Button {
                onSocialSignUp()
            } label: {
                HStack(spacing: 8) {
                    Text("G")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: 0x4285F4))
                    Text("Sign up with Google")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                )
            }
            .buttonStyle(PressableStyle())
            .padding(8)

            Button {
                onSocialSignUp()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.black)
                    Text("Sign up with Apple")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                )
            }
            .buttonStyle(PressableStyle())
            .padding(8)
        }
        .padding(20)
    }
}

// MARK: - Sign in

struct SignInView: View {
    @Binding var isSignedIn: Bool

    var onBack: () -> Void
    var onCreateAccount: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var emailError: String?
    @State private var passwordError: String?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                backButton

                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Sign in to keep building.")
                        .font(.system(size: 15))
                        .foregroundStyle(Palette.inkMuted)
                }

                formCard
            }
            .padding(8)
        }
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            fieldLabel("EMAIL ADDRESS")
            TextField("Enter your Email address", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(.emailAddress)
                .authField(isError: emailError != nil)

            if let emailError {
                Text(emailError)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: 0xFF8A8A))
            }

            fieldLabel("PASSWORD")
                .padding(.top, 4)
            SecureField("Enter password", text: $password)
                .textContentType(.password)
                .authField(isError: passwordError != nil)

            if let passwordError {
                Text(passwordError)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: 0xFF8A8A))
            }

            GradientActionButton(title: "Sign in") {
                submit()
            }
            .padding(8)

            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color.white.opacity(0.14))
                    .frame(height: 1)
                Text("or")
                    .font(.system(size: 13))
                    .foregroundStyle(Palette.inkFaint)
                Rectangle()
                    .fill(Color.white.opacity(0.14))
                    .frame(height: 1)
            }
            .padding(.vertical, 2)

            Button {
                signInWithApple()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 17, weight: .medium))
                    Text("Continue with Apple")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white)
                )
            }
            .buttonStyle(PressableStyle())

            Button {
                Haptics.tap()
                isSignedIn = true
            } label: {
                HStack(spacing: 8) {
                    Text("G")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: 0x4285F4))
                    Text("Continue with Google")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white)
                )
            }
            .buttonStyle(PressableStyle())

            Button {
                Haptics.select()
                onCreateAccount()
            } label: {
                HStack(spacing: 4) {
                    Text("New here?")
                        .foregroundStyle(Palette.inkMuted)
                    Text("Create account")
                        .foregroundStyle(Palette.accentBright)
                }
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .glassCard()
        .padding(8)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .tracking(1.3)
            .foregroundStyle(Palette.inkFaint)
    }

    private func submit() {
        emailError = nil
        passwordError = nil

        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        var isValid = true

        if !isValidEmail(trimmed) {
            emailError = "Enter a valid email address."
            isValid = false
        }
        if password.count < 6 {
            passwordError = "Your password needs at least 6 characters."
            isValid = false
        }

        guard isValid else {
            Haptics.tap()
            return
        }

        Haptics.tap()
        isSignedIn = true
    }

    private func signInWithApple() {
        Haptics.tap()
        isSignedIn = true
    }

    private var backButton: some View {
        Button {
            Haptics.tap()
            onBack()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(Circle().fill(Color.white.opacity(0.10)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.18), lineWidth: 1))
        }
        .buttonStyle(PressableStyle(scale: 0.9))
    }
}

// MARK: - Sign up

struct SignUpView: View {
    @Binding var isSignedIn: Bool

    var onBack: () -> Void
    var onSignIn: () -> Void

    @State private var name = ""
    @State private var handle = ""
    @State private var email = ""
    @State private var password = ""
    @State private var nameError: String?
    @State private var handleError: String?
    @State private var emailError: String?
    @State private var passwordError: String?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                backButton

                VStack(alignment: .leading, spacing: 4) {
                    Text("Create account")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Set up your profile and start building.")
                        .font(.system(size: 15))
                        .foregroundStyle(Palette.inkMuted)
                }

                formCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 40)
        }
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            fieldLabel("NAME")
            TextField("Your name", text: $name)
                .textContentType(.name)
                .authField(isError: nameError != nil)
            errorText(nameError)

            fieldLabel("USERNAME")
                .padding(.top, 4)
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

            fieldLabel("EMAIL ADDRESS")
                .padding(.top, 4)
            TextField("you@example.com", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(.emailAddress)
                .authField(isError: emailError != nil)
            errorText(emailError)

            fieldLabel("PASSWORD")
                .padding(.top, 4)
            SecureField("Choose a password", text: $password)
                .textContentType(.newPassword)
                .authField(isError: passwordError != nil)
            errorText(passwordError)

            GradientActionButton(title: "Create account") {
                submit()
            }
            .padding(.top, 6)

            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color.white.opacity(0.14))
                    .frame(height: 1)
                Text("or")
                    .font(.system(size: 13))
                    .foregroundStyle(Palette.inkFaint)
                Rectangle()
                    .fill(Color.white.opacity(0.14))
                    .frame(height: 1)
            }
            .padding(.vertical, 2)

            Button {
                Haptics.tap()
                isSignedIn = true
            } label: {
                HStack(spacing: 8) {
                    Text("G")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: 0x4285F4))
                    Text("Sign up with Google")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                )
            }
            .buttonStyle(PressableStyle())
            .padding(8)

            Button {
                Haptics.tap()
                isSignedIn = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.black)
                    Text("Sign up with Apple")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                )
            }
            .buttonStyle(PressableStyle())
            .padding(8)

            Button {
                Haptics.select()
                onSignIn()
            } label: {
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .foregroundStyle(Palette.inkMuted)
                    Text("Sign in")
                        .foregroundStyle(Palette.accentBright)
                }
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .glassCard()
        .padding(10)
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

    private func submit() {
        nameError = nil
        handleError = nil
        emailError = nil
        passwordError = nil

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHandle = handle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        var isValid = true

        if trimmedName.count < 2 {
            nameError = "Enter your name."
            isValid = false
        }
        if !isValidHandle(trimmedHandle) {
            handleError = "Use 3 or more letters, numbers or hyphens."
            isValid = false
        }
        if !isValidEmail(trimmedEmail) {
            emailError = "Enter a valid email address."
            isValid = false
        }
        if password.count < 6 {
            passwordError = "Your password needs at least 6 characters."
            isValid = false
        }

        guard isValid else {
            Haptics.tap()
            return
        }

        Haptics.tap()
        isSignedIn = true
    }

    private var backButton: some View {
        Button {
            Haptics.tap()
            onBack()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(Circle().fill(Color.white.opacity(0.10)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.18), lineWidth: 1))
        }
        .buttonStyle(PressableStyle(scale: 0.9))
    }
}

// MARK: - Shared validation and field style

func isValidEmail(_ value: String) -> Bool {
    let parts = value.split(separator: "@")
    guard parts.count == 2, !parts[0].isEmpty, !parts[1].isEmpty else { return false }
    let domain = parts[1]
    return domain.contains(".") && !domain.hasPrefix(".") && !domain.hasSuffix(".")
}

func isValidHandle(_ value: String) -> Bool {
    guard value.count >= 3 else { return false }
    let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
    return value.unicodeScalars.allSatisfy { allowed.contains($0) }
}

private struct AuthFieldModifier: ViewModifier {
    var isError: Bool

    func body(content: Content) -> some View {
        content
            .font(.system(size: 16))
            .foregroundStyle(.white)
            .tint(Palette.accentBright)
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        isError ? Color(hex: 0xFF8A8A).opacity(0.8) : Color.white.opacity(0.14),
                        lineWidth: 1
                    )
            )
    }
}

extension View {
    func authField(isError: Bool = false) -> some View {
        modifier(AuthFieldModifier(isError: isError))
    }
}

#Preview {
    AuthFlowView(isSignedIn: .constant(false))
}
