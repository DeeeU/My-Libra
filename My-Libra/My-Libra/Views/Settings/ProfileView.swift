//
//  ProfileView.swift
//  My-Libra
//
//  Created by Claude Code on 2026/03/06.
//

import SwiftUI

struct ProfileView: View {
    @Environment(UserProfileManager.self) private var profileManager
    @State private var showingEdit = false

    private var profile: UserProfile { profileManager.profile }

    var body: some View {
        List {
            // アバター・名前セクション
            Section {
                HStack(spacing: 16) {
                    avatarView
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.isConfigured ? profile.username : "未設定")
                            .font(.title3.bold())
                            .foregroundStyle(profile.isConfigured ? .primary : .secondary)
                        if !profile.bio.isEmpty {
                            Text(profile.bio)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }

            // プロフィール詳細セクション
            Section("プロフィール情報") {
                profileRow(label: "ユーザーネーム",
                           value: profile.username,
                           icon: "person.fill")

                profileRow(label: "メールアドレス",
                           value: profile.email,
                           icon: "envelope.fill")

                profileRow(label: "性別",
                           value: profile.gender.description,
                           icon: "person.2.fill")

                profileRow(label: "年代",
                           value: profile.ageGroup.description,
                           icon: "calendar")
            }

            // 登録日セクション
            Section {
                HStack {
                    Label("利用開始日", systemImage: "clock.fill")
                    Spacer()
                    Text(profile.joinedAt, style: .date)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("プロフィール")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("編集") {
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditProfileView()
        }
    }

    // MARK: - Sub Views

    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.7), .purple.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 64, height: 64)

            Text(avatarInitial)
                .font(.title.bold())
                .foregroundStyle(.white)
        }
    }

    private var avatarInitial: String {
        let name = profile.username.trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "?" : String(name.prefix(1)).uppercased()
    }

    private func profileRow(label: String, value: String, icon: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
            Spacer()
            Text(value.isEmpty ? "未設定" : value)
                .foregroundStyle(value.isEmpty ? .secondary : .primary)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environment(UserProfileManager.shared)
    }
}
