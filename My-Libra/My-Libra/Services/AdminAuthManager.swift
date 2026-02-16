//
//  AdminAuthManager.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/16.
//

import Foundation
import Security

/// 管理者認証マネージャー（Keychain + ロックアウト）
@MainActor
@Observable
final class AdminAuthManager {

    static let shared = AdminAuthManager()

    private static let pinKeychainKey = "com.deeu.mylibra.admin.pin"
    private static let maxFailedAttempts = 5
    private static let lockoutDuration: TimeInterval = 5 * 60 // 5分

    private(set) var failedAttempts = 0
    private(set) var lockoutUntil: Date?

    var isSetUp: Bool {
        loadPIN() != nil
    }

    var isLockedOut: Bool {
        guard let lockoutUntil else { return false }
        if Date() >= lockoutUntil {
            self.lockoutUntil = nil
            self.failedAttempts = 0
            return false
        }
        return true
    }

    var remainingLockoutSeconds: Int {
        guard let lockoutUntil else { return 0 }
        return max(0, Int(lockoutUntil.timeIntervalSince(Date())))
    }

    // MARK: - PIN Setup

    func setupPIN(_ pin: String) -> Bool {
        guard pin.count == 6, pin.allSatisfy(\.isNumber) else { return false }
        return savePIN(pin)
    }

    // MARK: - Authentication

    func authenticate(pin: String) -> Bool {
        guard !isLockedOut else { return false }

        guard let storedPIN = loadPIN() else { return false }

        if pin == storedPIN {
            failedAttempts = 0
            lockoutUntil = nil
            return true
        }

        failedAttempts += 1
        if failedAttempts >= Self.maxFailedAttempts {
            lockoutUntil = Date().addingTimeInterval(Self.lockoutDuration)
        }
        return false
    }

    // MARK: - PIN Change

    func changePIN(currentPIN: String, newPIN: String) -> Bool {
        guard authenticate(pin: currentPIN) else { return false }
        return setupPIN(newPIN)
    }

    // MARK: - Reset (データ全削除時用)

    func resetPIN() {
        deletePIN()
        failedAttempts = 0
        lockoutUntil = nil
    }

    // MARK: - Keychain Operations

    private func savePIN(_ pin: String) -> Bool {
        deletePIN()

        guard let data = pin.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.pinKeychainKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    private func loadPIN() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.pinKeychainKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func deletePIN() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.pinKeychainKey
        ]
        SecItemDelete(query as CFDictionary)
    }

    private init() {}
}
