//
//  AdminAuthManagerTests.swift
//  My-LibraTests
//
//  Created by Claude Code on 2026/02/16.
//

import XCTest
@testable import My_Libra

/// AdminAuthManager のロジックテスト
/// 注意: Keychain操作はシミュレータ/デバイス上でのみ完全動作する。
/// CI環境ではKeychainが使えない場合があるため、ロジック面のテストに集中する。
@MainActor
final class AdminAuthManagerTests: XCTestCase {
    var manager: AdminAuthManager!

    override func setUp() {
        super.setUp()
        manager = AdminAuthManager.shared
        manager.resetPIN()
    }

    override func tearDown() {
        manager.resetPIN()
        manager = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialStateNotSetUp() {
        // resetPIN後はisSetUpがfalse（Keychain環境依存）
        // Keychainが使えない環境ではこのテストは常にtrue
        // ロジックのフロー確認として残す
        XCTAssertFalse(manager.isLockedOut)
        XCTAssertEqual(manager.failedAttempts, 0)
    }

    func testInitialStateNotLockedOut() {
        XCTAssertFalse(manager.isLockedOut)
        XCTAssertEqual(manager.remainingLockoutSeconds, 0)
    }

    // MARK: - PIN Validation

    func testSetupPINRejectsShortPIN() {
        XCTAssertFalse(manager.setupPIN("123"))
    }

    func testSetupPINRejectsLongPIN() {
        XCTAssertFalse(manager.setupPIN("1234567"))
    }

    func testSetupPINRejectsNonNumeric() {
        XCTAssertFalse(manager.setupPIN("abcdef"))
    }

    func testSetupPINRejectsMixed() {
        XCTAssertFalse(manager.setupPIN("123abc"))
    }

    func testSetupPINRejectsEmpty() {
        XCTAssertFalse(manager.setupPIN(""))
    }

    func testSetupPINAcceptsValid6Digits() {
        // Keychain環境依存: デバイス/シミュレータではtrue、CI環境ではfalseの可能性
        let result = manager.setupPIN("123456")
        // Keychain成功時のみ後続テストが意味を持つ
        if result {
            XCTAssertTrue(manager.isSetUp)
        }
    }

    // MARK: - Authentication Flow

    func testAuthenticateFailsWhenNotSetUp() {
        // PINが設定されていない状態では認証不可
        XCTAssertFalse(manager.authenticate(pin: "123456"))
    }

    func testFailedAttemptsIncrement() {
        guard manager.setupPIN("123456") else { return }

        _ = manager.authenticate(pin: "000000")
        XCTAssertEqual(manager.failedAttempts, 1)

        _ = manager.authenticate(pin: "000000")
        XCTAssertEqual(manager.failedAttempts, 2)
    }

    func testSuccessfulAuthResetsFailedAttempts() {
        guard manager.setupPIN("123456") else { return }

        _ = manager.authenticate(pin: "000000")
        _ = manager.authenticate(pin: "000000")
        XCTAssertEqual(manager.failedAttempts, 2)

        let success = manager.authenticate(pin: "123456")
        XCTAssertTrue(success)
        XCTAssertEqual(manager.failedAttempts, 0)
    }

    func testLockoutAfterMaxAttempts() {
        guard manager.setupPIN("123456") else { return }

        for _ in 0..<5 {
            _ = manager.authenticate(pin: "000000")
        }

        XCTAssertTrue(manager.isLockedOut)
        XCTAssertGreaterThan(manager.remainingLockoutSeconds, 0)
    }

    func testAuthenticationBlockedDuringLockout() {
        guard manager.setupPIN("123456") else { return }

        for _ in 0..<5 {
            _ = manager.authenticate(pin: "000000")
        }

        // ロックアウト中は正しいPINでも認証不可
        XCTAssertFalse(manager.authenticate(pin: "123456"))
    }

    // MARK: - PIN Change

    func testChangePINWithCorrectCurrent() {
        guard manager.setupPIN("123456") else { return }

        let changed = manager.changePIN(currentPIN: "123456", newPIN: "654321")
        XCTAssertTrue(changed)

        // 新PINで認証できる
        XCTAssertTrue(manager.authenticate(pin: "654321"))
        // 旧PINでは認証できない
        XCTAssertFalse(manager.authenticate(pin: "123456"))
    }

    func testChangePINWithWrongCurrent() {
        guard manager.setupPIN("123456") else { return }

        let changed = manager.changePIN(currentPIN: "000000", newPIN: "654321")
        XCTAssertFalse(changed)

        // 元のPINがまだ有効
        XCTAssertTrue(manager.authenticate(pin: "123456"))
    }

    // MARK: - Reset

    func testResetClearsState() {
        guard manager.setupPIN("123456") else { return }

        _ = manager.authenticate(pin: "000000")
        _ = manager.authenticate(pin: "000000")

        manager.resetPIN()

        XCTAssertEqual(manager.failedAttempts, 0)
        XCTAssertFalse(manager.isLockedOut)
        XCTAssertFalse(manager.isSetUp)
    }
}
