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
        storeKit.hasActiveSubscription || cachedProStatus
    }

    // MARK: - Feature Access

    func canAccess(_ feature: ProFeature) -> Bool {
        isPro
    }

    func canAddItem(currentCount: Int) -> Bool {
        isPro || currentCount < Self.freeItemLimit
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws {
        let transaction = try await storeKit.purchase(product)
        if transaction != nil {
            saveCachedProStatus(true)
        }
    }

    func restorePurchases() async {
        await storeKit.restorePurchases()
        saveCachedProStatus(storeKit.hasActiveSubscription)
    }

    // MARK: - Initialization

    func initialize() async {
        await storeKit.loadProducts()
        await storeKit.updateCurrentEntitlements()
        // Always update cache to reflect current StoreKit state (handles expiry)
        saveCachedProStatus(storeKit.hasActiveSubscription)
    }

    /// Call after any entitlement change to keep cache in sync
    func refreshProStatus() async {
        await storeKit.updateCurrentEntitlements()
        saveCachedProStatus(storeKit.hasActiveSubscription)
    }

    // MARK: - UserDefaults Cache

    private static let cachedProKey = "cachedProStatus"

    private var cachedProStatus: Bool {
        UserDefaults.standard.bool(forKey: Self.cachedProKey)
    }

    private func saveCachedProStatus(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: Self.cachedProKey)
    }

    private init() {}
}
