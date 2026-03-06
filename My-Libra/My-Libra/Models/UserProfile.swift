//
//  UserProfile.swift
//  My-Libra
//
//  Created by Claude Code on 2026/03/06.
//

import Foundation

/// ユーザープロフィール（UserDefaultsに保存）
struct UserProfile: Codable, Equatable {
    var username: String
    var email: String
    var gender: Gender
    var ageGroup: AgeGroup
    var bio: String
    var joinedAt: Date

    init(
        username: String = "",
        email: String = "",
        gender: Gender = .preferNotToSay,
        ageGroup: AgeGroup = .preferNotToSay,
        bio: String = "",
        joinedAt: Date = .now
    ) {
        self.username = username
        self.email = email
        self.gender = gender
        self.ageGroup = ageGroup
        self.bio = bio
        self.joinedAt = joinedAt
    }

    /// プロフィールが一度でも設定されているか
    var isConfigured: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
