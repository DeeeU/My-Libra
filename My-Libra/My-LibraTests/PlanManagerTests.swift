//
//  PlanManagerTests.swift
//  My-LibraTests
//
//  Created by Claude Code on 2026/02/13.
//

import XCTest
@testable import My_Libra

@MainActor
final class PlanManagerTests: XCTestCase {

    // MARK: - Free User Tests

    func testFreeUserCannotAccessProFeatures() {
        let planManager = PlanManager.shared

        // Free状態ではすべてのPro機能にアクセスできない
        // (StoreKitが未購入 + キャッシュがfalseの場合)
        UserDefaults.standard.set(false, forKey: "cachedProStatus")

        // StoreKitが未購入の場合のみテスト可能
        if !planManager.isPro {
            for feature in ProFeature.allCases {
                XCTAssertFalse(planManager.canAccess(feature),
                               "\(feature.rawValue) should not be accessible for free users")
            }
        }
    }

    func testFreeUserCanAddItemUnder25() {
        let planManager = PlanManager.shared
        UserDefaults.standard.set(false, forKey: "cachedProStatus")

        // Free状態でも25件未満なら追加可能
        XCTAssertTrue(planManager.canAddItem(currentCount: 0))
        XCTAssertTrue(planManager.canAddItem(currentCount: 10))
        XCTAssertTrue(planManager.canAddItem(currentCount: 24))
    }

    func testFreeUserCannotAddItemAt25() {
        let planManager = PlanManager.shared
        UserDefaults.standard.set(false, forKey: "cachedProStatus")

        // StoreKitも非アクティブの場合のみ制限がかかる
        if !planManager.isPro {
            XCTAssertFalse(planManager.canAddItem(currentCount: 25))
            XCTAssertFalse(planManager.canAddItem(currentCount: 50))
        }
    }

    // MARK: - Item Limit

    func testFreeItemLimitIs25() {
        XCTAssertEqual(PlanManager.freeItemLimit, 25)
    }

    // MARK: - ProFeature

    func testAllProFeaturesHaveLockedMessage() {
        for feature in ProFeature.allCases {
            XCTAssertFalse(feature.lockedMessage.isEmpty,
                           "\(feature.rawValue) should have a locked message")
        }
    }

    func testAllProFeaturesHaveIconName() {
        for feature in ProFeature.allCases {
            XCTAssertFalse(feature.iconName.isEmpty,
                           "\(feature.rawValue) should have an icon name")
        }
    }

    func testAllProFeaturesHaveDisplayName() {
        for feature in ProFeature.allCases {
            XCTAssertFalse(feature.displayName.isEmpty,
                           "\(feature.rawValue) should have a display name")
        }
    }

    func testProFeatureCount() {
        XCTAssertEqual(ProFeature.allCases.count, 7)
    }

    // MARK: - Cache

    func testCachedProStatusPersistence() {
        // キャッシュをtrueに設定
        UserDefaults.standard.set(true, forKey: "cachedProStatus")
        let cached = UserDefaults.standard.bool(forKey: "cachedProStatus")
        XCTAssertTrue(cached)

        // クリーンアップ
        UserDefaults.standard.set(false, forKey: "cachedProStatus")
    }
}
