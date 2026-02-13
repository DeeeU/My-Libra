//
//  SyncCoordinator.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/13.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class SyncCoordinator {
    private let syncService = SyncService()

    private(set) var isSyncing = false
    private(set) var lastSyncDate: Date?
    var syncError: String?

    private let lastSyncKey = "lastSyncDate"

    init() {
        lastSyncDate = UserDefaults.standard.object(forKey: lastSyncKey) as? Date
    }

    // MARK: - Full Sync

    func performSync(context: ModelContext) async {
        guard SupabaseManager.shared.isAuthenticated else { return }
        guard !isSyncing else { return }

        isSyncing = true

        do {
            try await syncService.pushItems(from: context)
            try await syncService.pushWishlistItems(from: context)
            try await syncService.pushCategories(from: context)
            try await syncService.pullItems(into: context, since: lastSyncDate)
            try await syncService.pullWishlistItems(into: context, since: lastSyncDate)
            try await syncService.pullCategories(into: context, since: lastSyncDate)

            let now = Date()
            lastSyncDate = now
            syncError = nil
            UserDefaults.standard.set(now, forKey: lastSyncKey)
        } catch {
            syncError = "同期エラー: \(error.localizedDescription)"
        }

        isSyncing = false
    }

    // MARK: - Initial Migration

    func migrateIfNeeded(userId: String, context: ModelContext) {
        let migrationKey = "dataMigrated_\(userId)"
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }

        do {
            try syncService.migrateLocalData(userId: userId, context: context)
            UserDefaults.standard.set(true, forKey: migrationKey)
        } catch {
            syncError = "データ移行エラー: \(error.localizedDescription)"
        }
    }
}
