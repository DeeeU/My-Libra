//
//  UserProfileManager.swift
//  My-Libra
//
//  Created by Claude Code on 2026/03/06.
//

import Foundation
import Observation

@Observable
final class UserProfileManager {
    static let shared = UserProfileManager()

    private let userDefaultsKey = "userProfile"

    var profile: UserProfile {
        didSet { save() }
    }

    private init() {
        profile = Self.load()
    }

    // MARK: - Persistence

    private static func load() -> UserProfile {
        guard
            let data = UserDefaults.standard.data(forKey: "userProfile"),
            let decoded = try? JSONDecoder().decode(UserProfile.self, from: data)
        else {
            return UserProfile()
        }
        return decoded
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    // MARK: - Update

    func update(_ updated: UserProfile) {
        profile = updated
    }
}
