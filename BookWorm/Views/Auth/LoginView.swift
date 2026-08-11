import SwiftUI
import CoreData

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email    = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "books.vertical.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.accent)
                            .padding(.top, 60)
                        Text("BookWorm")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        Text("Your reading journey starts here")
                            .font(.subheadline)
                            .foregroundColor(AppColors.muted)
                    }
                    .padding(.bottom, 48)

                    // Form
                    VStack(spacing: 16) {
                        BWTextField(
                            placeholder: "Email address",
                            text: $email,
                            icon: "envelope.fill",
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )
                        BWTextField(
                            placeholder: "Password",
                            text: $password,
                            icon: "lock.fill",
                            isSecure: true
                        )

                        if let error = authVM.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                        }

                        Button {
                            authVM.login(email: email, password: password)
                        } label: {
                            HStack {
                                if authVM.isLoading {
                                    ProgressView().tint(.black)
                                } else {
                                    Text("Sign In")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.accent)
                            .cornerRadius(12)
                        }
                        .disabled(authVM.isLoading)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)

                    // Divider
                    HStack {
                        Rectangle().frame(height: 1).foregroundColor(AppColors.border)
                        Text("or").font(.caption).foregroundColor(AppColors.muted)
                        Rectangle().frame(height: 1).foregroundColor(AppColors.border)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)

                    // Sign-up
                    Button {
                        authVM.errorMessage = nil
                        showSignUp = true
                    } label: {
                        VStack(spacing: 4) {
                            Text("New to BookWorm?")
                                .font(.subheadline)
                                .foregroundColor(AppColors.muted)
                            Text("Create an account")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.accent)
                        }
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
                .environmentObject(authVM)
        }
    }
}

// MARK: - Shared text field component
struct BWTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.muted)
                .frame(width: 20)
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(autocapitalization)
                        .autocorrectionDisabled()
                }
            }
            .foregroundColor(.white)
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.border, lineWidth: 1))
    }
}

// MARK: - Shared colour tokens
enum AppColors {
    static let background = Color(red: 0.05, green: 0.05, blue: 0.10)
    static let surface    = Color(red: 0.10, green: 0.10, blue: 0.18)
    static let surface2   = Color(red: 0.13, green: 0.13, blue: 0.22)
    static let accent     = Color(red: 0.96, green: 0.78, blue: 0.09)   // gold/yellow
    static let muted      = Color(white: 0.55)
    static let border     = Color(white: 0.20)
    static let tag        = Color(red: 0.18, green: 0.36, blue: 0.72)
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel(context: PersistenceController.shared.container.viewContext))
}
