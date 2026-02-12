//
//  ProfileView.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/13.
//

import SwiftUI
import Auth

struct ProfileView: View {
    @State private var viewModel = AuthViewModel()
    @State private var displayName = ""
    @State private var profile: Profile?
    @State private var isEditing = false
    @State private var showingLogoutConfirmation = false
    @Environment(\.dismiss) private var dismiss

    private let supabase = SupabaseManager.shared

    var body: some View {
        List {
            // Profile Section
            Section {
                if let profile = profile {
                    HStack {
                        Text("表示名")
                        Spacer()
                        if isEditing {
                            TextField("表示名", text: $displayName)
                                .multilineTextAlignment(.trailing)
                        } else {
                            Text(profile.displayName ?? "未設定")
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack {
                        Text("メール")
                        Spacer()
                        Text(supabase.currentUser?.email ?? "-")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            } header: {
                Text("プロフィール")
            }

            // Account Section
            Section {
                Button(role: .destructive) {
                    showingLogoutConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        Text("ログアウト")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("アカウント")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "保存" : "編集") {
                    if isEditing {
                        Task {
                            await viewModel.updateDisplayName(displayName)
                            profile?.displayName = displayName
                            isEditing = false
                        }
                    } else {
                        displayName = profile?.displayName ?? ""
                        isEditing = true
                    }
                }
            }
        }
        .alert("ログアウトしますか？", isPresented: $showingLogoutConfirmation) {
            Button("ログアウト", role: .destructive) {
                Task {
                    await viewModel.signOut()
                    dismiss()
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("ローカルデータは保持されます。")
        }
        .task {
            profile = try? await supabase.fetchProfile()
            displayName = profile?.displayName ?? ""
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
