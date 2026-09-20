//
//  LoginView.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/5/26.
//

import SwiftUI

struct LoginView: View {
    @Binding var activeRole: UserRole?
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // App icon
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.accentColor)
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "ticket.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                )
                .padding(.bottom, 20)

            // Title
            Text("Clean Ticket Flow")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 6)

            Text("Sign in with your Atomic ATM Services account.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 36)

            // Email field
            VStack(alignment: .leading, spacing: 6) {
                Text("Email")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                TextField("d.mclean@atomicatm.com", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .onChange(of: email) { showError = false }
            }
            .padding(.bottom, 16)

            // Password field
            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: password) { showError = false }
            }

            // Forgot password
            HStack {
                Spacer()
                Button("Forgot password?") { }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 10)
            .padding(.bottom, 28)

            // Inline error
            if showError {
                Text("Incorrect email or password.")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.bottom, 10)
            }

            // Sign in button
            Button {
                if let role = AuthService.shared.authenticate(email: email, password: password) {
                    activeRole = role
                } else {
                    showError = true
                }
            } label: {
                Text("Sign in")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(email.isEmpty || password.isEmpty)

            // Face ID
            Button {
                // TODO: biometric auth
            } label: {
                Text("Use Face ID")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.primary)
            .padding(.top, 14)

            Spacer()

            // Footer
            VStack(spacing: 4) {
                Text("Accounts are created by your dispatcher.")
                Text("Need help? Contact AAS support.")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
        }
        .padding(24)
        .background(Color(.systemBackground))
    }
}

#Preview {
    LoginView(activeRole: .constant(nil))
}
