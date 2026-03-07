//
//  AuthViewModel.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/13.
//

import Foundation
import AuthenticationServices
import Auth

@Observable
final class AuthViewModel {
    var email = ""
    var password = ""
    var confirmPassword = ""
    var displayName = ""
    var isLoading = false
    var errorMessage: String?
    var showError = false

    private let supabase = SupabaseManager.shared

    var isAuthenticated: Bool { supabase.isAuthenticated }
    var currentUser: Auth.User? { supabase.currentUser }

    // MARK: - Email Auth

    func signIn() async {
        guard validateSignIn() else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await supabase.signIn(email: email, password: password)
            clearFields()
        } catch {
            errorMessage = "ログインに失敗しました: \(error.localizedDescription)"
            showError = true
        }
        isLoading = false
    }

    func signUp() async {
        guard validateSignUp() else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await supabase.signUp(email: email, password: password)
            clearFields()
        } catch {
            errorMessage = "登録に失敗しました: \(error.localizedDescription)"
            showError = true
        }
        isLoading = false
    }

    func signOut() async {
        isLoading = true
        do {
            try await supabase.signOut()
        } catch {
            errorMessage = "ログアウトに失敗しました: \(error.localizedDescription)"
            showError = true
        }
        isLoading = false
    }

    // MARK: - Apple Sign In

    func handleAppleSignIn(result: Result<ASAuthorization, Error>, nonce: String) async {
        isLoading = true
        errorMessage = nil
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: identityToken, encoding: .utf8) else {
                errorMessage = "Apple認証情報の取得に失敗しました"
                showError = true
                isLoading = false
                return
            }
            do {
                try await supabase.signInWithApple(idToken: idTokenString, nonce: nonce)
            } catch {
                errorMessage = "Appleサインインに失敗しました: \(error.localizedDescription)"
                showError = true
            }
        case .failure(let error):
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                errorMessage = "Appleサインインがキャンセルされました"
                showError = true
            }
        }
        isLoading = false
    }

    // MARK: - Profile

    func updateDisplayName(_ name: String) async {
        isLoading = true
        do {
            try await supabase.updateProfile(displayName: name)
        } catch {
            errorMessage = "プロフィール更新に失敗しました: \(error.localizedDescription)"
            showError = true
        }
        isLoading = false
    }

    // MARK: - Validation

    private func validateSignIn() -> Bool {
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "メールアドレスを入力してください"
            showError = true
            return false
        }
        if password.isEmpty {
            errorMessage = "パスワードを入力してください"
            showError = true
            return false
        }
        return true
    }

    private func validateSignUp() -> Bool {
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "メールアドレスを入力してください"
            showError = true
            return false
        }
        if password.count < 6 {
            errorMessage = "パスワードは6文字以上にしてください"
            showError = true
            return false
        }
        if password != confirmPassword {
            errorMessage = "パスワードが一致しません"
            showError = true
            return false
        }
        return true
    }

    private func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
    }
}
