//
//  SupabaseManager.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/13.
//

import Foundation
import Supabase
import Auth

@Observable
final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private(set) var currentUser: User?
    private(set) var isAuthenticated = false
    private(set) var isLoading = true

    private init() {
        client = SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.anonKey
        )
        Task { await observeAuthState() }
    }

    // MARK: - Auth State

    private func observeAuthState() async {
        for await (event, session) in client.auth.authStateChanges {
            await MainActor.run {
                switch event {
                case .initialSession:
                    self.currentUser = session?.user
                    self.isAuthenticated = session != nil
                    self.isLoading = false
                case .signedIn:
                    self.currentUser = session?.user
                    self.isAuthenticated = true
                case .signedOut:
                    self.currentUser = nil
                    self.isAuthenticated = false
                case .tokenRefreshed:
                    self.currentUser = session?.user
                default:
                    break
                }
            }
        }
    }

    // MARK: - Auth Methods

    func signUp(email: String, password: String) async throws {
        try await client.auth.signUp(email: email, password: password)
    }

    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    func signInWithApple(idToken: String, nonce: String) async throws {
        try await client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    // MARK: - Profile

    func fetchProfile() async throws -> Profile? {
        guard let userId = currentUser?.id else { return nil }
        return try await client.from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value
    }

    func updateProfile(displayName: String) async throws {
        guard let userId = currentUser?.id else { return }
        try await client.from("profiles")
            .update(["display_name": displayName])
            .eq("id", value: userId.uuidString)
            .execute()
    }
}

// MARK: - Profile Model (Supabase)

struct Profile: Codable, Sendable {
    let id: UUID
    var displayName: String?
    var avatarUrl: String?
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
