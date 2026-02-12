//
//  LoginView.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/13.
//

import SwiftUI
import AuthenticationServices
import CryptoKit

struct LoginView: View {
    @State private var viewModel = AuthViewModel()
    @State private var currentNonce: String?

    var body: some View {
        VStack(spacing: 16) {
            // Email
            TextField("メールアドレス", text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .inputFieldStyle()

            // Password
            SecureField("パスワード", text: $viewModel.password)
                .textContentType(.password)
                .inputFieldStyle()

            // Login Button
            Button {
                Task { await viewModel.signIn() }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                } else {
                    Text("ログイン")
                        .frame(maxWidth: .infinity)
                }
            }
            .primaryButtonStyle()
            .disabled(viewModel.isLoading)

            // Divider
            HStack {
                Rectangle().frame(height: 1).foregroundStyle(.tertiary)
                Text("または").font(.caption).foregroundStyle(.secondary)
                Rectangle().frame(height: 1).foregroundStyle(.tertiary)
            }

            // Sign in with Apple
            SignInWithAppleButton(.signIn) { request in
                let nonce = randomNonceString()
                currentNonce = nonce
                request.requestedScopes = [.fullName, .email]
                request.nonce = sha256(nonce)
            } onCompletion: { result in
                guard let nonce = currentNonce else { return }
                Task { await viewModel.handleAppleSignIn(result: result, nonce: nonce) }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .cornerRadius(12)
        }
        .alert("エラー", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Nonce Helpers

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

#Preview {
    LoginView()
}
