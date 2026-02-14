//
//  PlanManager.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/13.
//

import StoreKit
import SwiftUI

@MainActor
@Observable
final class PlanManager {

    static let shared = PlanManager()
    static let freeItemLimit = 25

    let storeKit = StoreKitService()

    var isPro: Bool {
        if storeKit.hasActiveSubscription {
            return true
        }
        // オフライン時のフォールバック: キャッシュが有効期限内ならtrue
        return isCacheValid
    }

    // MARK: - Feature Access

    func canAccess(_ feature: ProFeature) -> Bool {
        isPro
    }

    func canAddItem(currentCount: Int) -> Bool {
        isPro || currentCount < Self.freeItemLimit
    }

    // MARK: - Purchase

    /// Returns the purchase result for UI feedback
    func purchase(_ product: Product) async throws -> PurchaseResult {
        let result = try await storeKit.purchase(product)
        if case .success = result {
            saveCachedProStatus(true)
        }
        return result
    }

    /// Returns true if purchases were restored successfully
    func restorePurchases() async -> Bool {
        await storeKit.restorePurchases()
        let isActive = storeKit.hasActiveSubscription
        saveCachedProStatus(isActive)
        return isActive
    }

    // MARK: - Initialization

    func initialize() async {
        await storeKit.loadProducts()
        await storeKit.updateCurrentEntitlements()
        saveCachedProStatus(storeKit.hasActiveSubscription)
    }

    /// Call on foreground return to refresh entitlements and keep cache in sync
    func refreshProStatus() async {
        await storeKit.updateCurrentEntitlements()
        saveCachedProStatus(storeKit.hasActiveSubscription)
    }

    // MARK: - UserDefaults Cache with Expiry

    private static let cachedProKey = "cachedProStatus"
    private static let cachedProTimestampKey = "cachedProTimestamp"
    /// Cache is valid for 7 days — after that, StoreKit must confirm
    private static let cacheValidityInterval: TimeInterval = 7 * 24 * 60 * 60

    private var isCacheValid: Bool {
        guard UserDefaults.standard.bool(forKey: Self.cachedProKey) else { return false }
        let timestamp = UserDefaults.standard.double(forKey: Self.cachedProTimestampKey)
        guard timestamp > 0 else { return false }
        let cacheDate = Date(timeIntervalSince1970: timestamp)
        return Date().timeIntervalSince(cacheDate) < Self.cacheValidityInterval
    }

    private func saveCachedProStatus(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: Self.cachedProKey)
        if value {
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: Self.cachedProTimestampKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.cachedProTimestampKey)
        }
    }

    private init() {}
}
