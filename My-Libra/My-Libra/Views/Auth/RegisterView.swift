//
//  RegisterView.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/13.
//

import SwiftUI

struct RegisterView: View {
    @State private var viewModel = AuthViewModel()

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
            SecureField("パスワード（6文字以上）", text: $viewModel.password)
                .textContentType(.newPassword)
                .inputFieldStyle()

            // Confirm Password
            SecureField("パスワード（確認）", text: $viewModel.confirmPassword)
                .textContentType(.newPassword)
                .inputFieldStyle()

            // Register Button
            Button {
                Task { await viewModel.signUp() }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                } else {
                    Text("アカウント作成")
                        .frame(maxWidth: .infinity)
                }
            }
            .primaryButtonStyle()
            .disabled(viewModel.isLoading)
        }
        .alert("エラー", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    RegisterView()
}
