//
//  EditProfileView.swift
//  My-Libra
//
//  Created by Claude Code on 2026/03/06.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(UserProfileManager.self) private var profileManager
    @Environment(\.dismiss) private var dismiss

    @State private var username: String = ""
    @State private var email: String = ""
    @State private var gender: Gender = .preferNotToSay
    @State private var ageGroup: AgeGroup = .preferNotToSay
    @State private var bio: String = ""

    @State private var showingDiscardAlert = false
    @FocusState private var focusedField: Field?

    private enum Field { case username, email, bio }

    private var hasChanges: Bool {
        let p = profileManager.profile
        return username != p.username
            || email != p.email
            || gender != p.gender
            || ageGroup != p.ageGroup
            || bio != p.bio
    }

    var body: some View {
        NavigationStack {
            Form {
                // アバタープレビュー
                Section {
                    HStack {
                        Spacer()
                        avatarView
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)

                // 基本情報
                Section("基本情報") {
                    HStack {
                        Label("ユーザーネーム", systemImage: "person.fill")
                        TextField("例：コレクター太郎", text: $username)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .username)
                    }

                    HStack {
                        Label("メールアドレス", systemImage: "envelope.fill")
                        TextField("例：user@example.com", text: $email)
                            .multilineTextAlignment(.trailing)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .focused($focusedField, equals: .email)
                    }
                }

                // 属性情報
                Section("属性情報") {
                    Picker(selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { g in
                            Text(g.description).tag(g)
                        }
                    } label: {
                        Label("性別", systemImage: "person.2.fill")
                    }

                    Picker(selection: $ageGroup) {
                        ForEach(AgeGroup.allCases, id: \.self) { a in
                            Text(a.description).tag(a)
                        }
                    } label: {
                        Label("年代", systemImage: "calendar")
                    }
                }

                // ひとこと
                Section {
                    TextField("コレクションへのこだわりなど（任意）",
                              text: $bio,
                              axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                        .focused($focusedField, equals: .bio)
                } header: {
                    Text("ひとこと自己紹介")
                } footer: {
                    Text("将来のクラウド機能で他のコレクターと繋がる際に表示されます。")
                }
            }
            .navigationTitle("プロフィール編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        if hasChanges {
                            showingDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .disabled(username.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .keyboard) {
                    Button("完了") { focusedField = nil }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .alert("変更を破棄しますか？", isPresented: $showingDiscardAlert) {
                Button("破棄する", role: .destructive) { dismiss() }
                Button("編集を続ける", role: .cancel) {}
            }
        }
        .onAppear { loadCurrentProfile() }
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
                .frame(width: 80, height: 80)

            Text(avatarInitial)
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
        }
    }

    private var avatarInitial: String {
        let name = username.trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "?" : String(name.prefix(1)).uppercased()
    }

    // MARK: - Actions

    private func loadCurrentProfile() {
        let p = profileManager.profile
        username = p.username
        email = p.email
        gender = p.gender
        ageGroup = p.ageGroup
        bio = p.bio
    }

    private func save() {
        var updated = profileManager.profile
        updated.username = username.trimmingCharacters(in: .whitespaces)
        updated.email = email.trimmingCharacters(in: .whitespaces)
        updated.gender = gender
        updated.ageGroup = ageGroup
        updated.bio = bio.trimmingCharacters(in: .whitespaces)
        profileManager.update(updated)
        dismiss()
    }
}

#Preview {
    EditProfileView()
        .environment(UserProfileManager.shared)
}
