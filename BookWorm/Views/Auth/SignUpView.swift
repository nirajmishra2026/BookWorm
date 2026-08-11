import SwiftUI
import CoreData

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name     = ""
    @State private var email    = ""
    @State private var password = ""
    @State private var confirm  = ""

    private var passwordMismatch: Bool {
        !confirm.isEmpty && confirm != password
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(AppColors.muted)
                                .padding()
                        }
                        Spacer()
                    }

                    VStack(spacing: 6) {
                        Image(systemName: "person.badge.plus.fill")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.accent)
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Text("Join thousands of happy readers")
                            .font(.subheadline)
                            .foregroundColor(AppColors.muted)
                    }
                    .padding(.bottom, 36)

                    // Form
                    VStack(spacing: 16) {
                        BWTextField(
                            placeholder: "Full name",
                            text: $name,
                            icon: "person.fill"
                        )
                        BWTextField(
                            placeholder: "Email address",
                            text: $email,
                            icon: "envelope.fill",
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )
                        BWTextField(
                            placeholder: "Password (min 6 characters)",
                            text: $password,
                            icon: "lock.fill",
                            isSecure: true
                        )
                        BWTextField(
                            placeholder: "Confirm password",
                            text: $confirm,
                            icon: "lock.shield.fill",
                            isSecure: true
                        )

                        if passwordMismatch {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
                                Text("Passwords do not match").font(.caption).foregroundColor(.red)
                                Spacer()
                            }.padding(.horizontal, 4)
                        }

                        if let error = authVM.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
                                Text(error).font(.caption).foregroundColor(.red)
                                Spacer()
                            }.padding(.horizontal, 4)
                        }

                        // Welcome points banner
                        HStack(spacing: 8) {
                            Image(systemName: "gift.fill").foregroundColor(AppColors.accent)
                            Text("Get **50 gift points** as a welcome bonus!")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(12)
                        .background(AppColors.surface2)
                        .cornerRadius(10)

                        Button {
                            guard !passwordMismatch else { return }
                            authVM.signUp(name: name, email: email, password: password)
                        } label: {
                            Text("Create Account")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(name.isEmpty || email.isEmpty || password.isEmpty || passwordMismatch
                                            ? AppColors.accent.opacity(0.4)
                                            : AppColors.accent)
                                .cornerRadius(12)
                        }
                        .disabled(name.isEmpty || email.isEmpty || password.isEmpty || passwordMismatch)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 40)
                }
            }
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel(context: PersistenceController.shared.container.viewContext))
}
