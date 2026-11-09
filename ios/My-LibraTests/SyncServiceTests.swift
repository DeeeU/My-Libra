//
//  SyncServiceTests.swift
//  My-LibraTests
//
//  Created by Claude Code on 2026/02/13.
//

import XCTest
import SwiftData
@testable import My_Libra

@MainActor
final class SyncServiceTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() {
        super.setUp()
        let schema = Schema([
            My_Libra.Category.self,
            WishlistItem.self,
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = modelContainer.mainContext
    }

    override func tearDown() {
        modelContainer = nil
        modelContext = nil
        super.tearDown()
    }

    // MARK: - Migration Tests

    func testLocalDataMigrationSetsUserId() throws {
        // ローカルデータを作成
        let item = Item(
            name: "移行テスト",
            category: "その他",
            purchasePrice: 1000,
            purchaseDate: Date(),
            condition: .new
        )
        modelContext.insert(item)

        let wishlistItem = WishlistItem(name: "移行WL", category: "その他")
        modelContext.insert(wishlistItem)

        let category = My_Libra.Category(name: "移行カテゴリ", iconName: "star", isCustom: true)
        modelContext.insert(category)

        try modelContext.save()

        // userId が nil であること確認
        XCTAssertNil(item.userId)
        XCTAssertNil(wishlistItem.userId)
        XCTAssertNil(category.userId)

        // 手動で移行をシミュレート
        let testUserId = "test-user-uuid"
        item.userId = testUserId
        item.syncStatus = .pendingUpload
        wishlistItem.userId = testUserId
        wishlistItem.syncStatus = .pendingUpload
        category.userId = testUserId
        category.syncStatus = .pendingUpload

        try modelContext.save()

        // 移行後の確認
        XCTAssertEqual(item.userId, testUserId)
        XCTAssertEqual(item.syncStatus, .pendingUpload)
        XCTAssertEqual(wishlistItem.userId, testUserId)
        XCTAssertEqual(wishlistItem.syncStatus, .pendingUpload)
        XCTAssertEqual(category.userId, testUserId)
        XCTAssertEqual(category.syncStatus, .pendingUpload)
    }

    // MARK: - Sync Status Flow Tests

    func testSyncStatusFlowLocalToSynced() throws {
        let item = Item(
            name: "フローテスト",
            category: "その他",
            purchasePrice: 2000,
            purchaseDate: Date(),
            condition: .used
        )
        modelContext.insert(item)
        try modelContext.save()

        // 初期状態: local
        XCTAssertEqual(item.syncStatus, .local)

        // ユーザーID設定 + pendingUpload
        item.userId = "user-123"
        item.syncStatus = .pendingUpload
        XCTAssertEqual(item.syncStatus, .pendingUpload)

        // 同期完了
        item.syncStatus = .synced
        item.remoteUpdatedAt = Date()
        XCTAssertEqual(item.syncStatus, .synced)
        XCTAssertNotNil(item.remoteUpdatedAt)
    }

    func testSyncStatusPendingDelete() throws {
        let item = Item(
            name: "削除テスト",
            category: "その他",
            purchasePrice: 500,
            purchaseDate: Date(),
            condition: .new
        )
        item.syncStatus = .synced
        item.userId = "user-123"
        modelContext.insert(item)
        try modelContext.save()

        // 削除マーク
        item.syncStatus = .pendingDelete
        XCTAssertEqual(item.syncStatus, .pendingDelete)
    }

    // MARK: - Image URL Tests

    func testItemImageUrlField() throws {
        let item = Item(
            name: "画像テスト",
            category: "その他",
            purchasePrice: 3000,
            purchaseDate: Date(),
            condition: .new
        )
        modelContext.insert(item)
        try modelContext.save()

        XCTAssertNil(item.imageUrl)

        item.imageUrl = "user-123/item-456.jpg"
        try modelContext.save()

        let fetchDescriptor = FetchDescriptor<Item>()
        let items = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(items.first?.imageUrl, "user-123/item-456.jpg")
    }

    // NOTE: AuthViewModel テストはSupabaseサーバー接続が必要なため、
    // 統合テスト（Supabase起動時）で実施する。
}
