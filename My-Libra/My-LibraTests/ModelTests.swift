//
//  ModelTests.swift
//  My-LibraTests
//
//  Created by kanabuchi on 2025/10/22.
//

import XCTest
import SwiftData
@testable import My_Libra

@MainActor
final class ModelTests: XCTestCase {
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

    // MARK: - Category Tests

    func testCategoryCreation() {
        let category = Category(name: "テスト", iconName: "star", isCustom: true, sortOrder: 10)

        XCTAssertNotNil(category.id)
        XCTAssertEqual(category.name, "テスト")
        XCTAssertEqual(category.iconName, "star")
        XCTAssertTrue(category.isCustom)
        XCTAssertEqual(category.sortOrder, 10)
    }

    func testPresetCategoriesCreation() {
        let presetCategories = Category.createPresetCategories()

        XCTAssertEqual(presetCategories.count, 7)
        XCTAssertEqual(presetCategories[0].name, "カードゲーム")
        XCTAssertFalse(presetCategories[0].isCustom)
    }

    // MARK: - WishlistItem Tests

    func testWishlistItemCreation() {
        let item = WishlistItem(
            name: "ポケモンカード",
            category: "カードゲーム",
            estimatedPrice: 1000,
            memo: "欲しい"
        )

        XCTAssertNotNil(item.id)
        XCTAssertEqual(item.name, "ポケモンカード")
        XCTAssertEqual(item.category, "カードゲーム")
        XCTAssertEqual(item.estimatedPrice, 1000)
        XCTAssertEqual(item.memo, "欲しい")
        XCTAssertFalse(item.isPurchased)
        XCTAssertNotNil(item.createdAt)
    }

    func testWishlistItemWithoutOptionalFields() {
        let item = WishlistItem(name: "テストアイテム", category: "その他")

        XCTAssertNil(item.estimatedPrice)
        XCTAssertNil(item.memo)
    }

    // MARK: - Item Tests

    func testItemCreation() {
        let item = Item(
            name: "スニーカー",
            category: "靴・スニーカー",
            purchasePrice: 15000,
            purchaseDate: Date(),
            condition: .new,
            memo: "限定品"
        )

        XCTAssertNotNil(item.id)
        XCTAssertEqual(item.name, "スニーカー")
        XCTAssertEqual(item.category, "靴・スニーカー")
        XCTAssertEqual(item.purchasePrice, 15000)
        XCTAssertEqual(item.condition, .new)
        XCTAssertEqual(item.memo, "限定品")
        XCTAssertEqual(item.status, .owned)
        XCTAssertNil(item.salePrice)
        XCTAssertNil(item.saleDate)
        XCTAssertNil(item.profit)
    }

    func testItemProfitCalculation() {
        let item = Item(
            name: "フィギュア",
            category: "フィギュア",
            purchasePrice: 3000,
            purchaseDate: Date(),
            condition: .new
        )

        // 売却前
        XCTAssertNil(item.profit)

        // 売却後（利益）
        item.markAsSold(salePrice: 5000, saleDate: Date())
        XCTAssertEqual(item.profit, 2000)
        XCTAssertEqual(item.status, .sold)
    }

    func testItemProfitCalculationWithLoss() {
        let item = Item(
            name: "本",
            category: "本・漫画",
            purchasePrice: 1000,
            purchaseDate: Date(),
            condition: .used
        )

        // 損失の場合
        item.markAsSold(salePrice: 500, saleDate: Date())
        XCTAssertEqual(item.profit, -500)
    }

    func testItemMarkAsSold() {
        let item = Item(
            name: "ゲーム",
            category: "ゲーム",
            purchasePrice: 6000,
            purchaseDate: Date(),
            condition: .used
        )

        let saleDate = Date()
        item.markAsSold(salePrice: 4000, saleDate: saleDate)

        XCTAssertEqual(item.status, .sold)
        XCTAssertEqual(item.salePrice, 4000)
        XCTAssertEqual(item.saleDate, saleDate)
        XCTAssertEqual(item.profit, -2000)
    }

    // MARK: - Edge Case Tests

    func testItemProfitZero() {
        let item = Item(
            name: "トントン",
            category: "カードゲーム",
            purchasePrice: 1000,
            purchaseDate: Date(),
            condition: .new
        )

        item.markAsSold(salePrice: 1000, saleDate: Date())
        XCTAssertEqual(item.profit, 0)
    }

    func testItemDefaultValues() {
        let item = Item(
            name: "デフォルト",
            category: "その他",
            purchasePrice: 0,
            purchaseDate: Date(),
            condition: .new
        )

        XCTAssertEqual(item.purchasePrice, 0)
        XCTAssertEqual(item.status, .owned)
        XCTAssertNil(item.imageData)
        XCTAssertNil(item.memo)
    }

    // MARK: - Sync Field Tests

    func testItemSyncFieldDefaults() {
        let item = Item(
            name: "同期テスト",
            category: "その他",
            purchasePrice: 1000,
            purchaseDate: Date(),
            condition: .new
        )

        XCTAssertNil(item.userId)
        XCTAssertEqual(item.syncStatus, .local)
        XCTAssertNotNil(item.localUpdatedAt)
        XCTAssertNil(item.remoteUpdatedAt)
        XCTAssertNil(item.imageUrl)
    }

    func testWishlistItemSyncFieldDefaults() {
        let item = WishlistItem(name: "同期テスト", category: "その他")

        XCTAssertNil(item.userId)
        XCTAssertEqual(item.syncStatus, .local)
        XCTAssertNotNil(item.localUpdatedAt)
        XCTAssertNil(item.remoteUpdatedAt)
    }

    func testCategorySyncFieldDefaults() {
        let category = Category(name: "同期テスト", iconName: "star")

        XCTAssertNil(category.userId)
        XCTAssertEqual(category.syncStatus, .local)
        XCTAssertNotNil(category.localUpdatedAt)
        XCTAssertNil(category.remoteUpdatedAt)
    }

    func testSyncStatusEnum() {
        XCTAssertEqual(SyncStatus.local.rawValue, "ローカルのみ")
        XCTAssertEqual(SyncStatus.synced.rawValue, "同期済み")
        XCTAssertEqual(SyncStatus.pendingUpload.rawValue, "アップロード待ち")
        XCTAssertEqual(SyncStatus.pendingDelete.rawValue, "削除待ち")
        XCTAssertEqual(SyncStatus.allCases.count, 4)
    }

    func testItemSyncStatusUpdate() {
        let item = Item(
            name: "ステータス変更テスト",
            category: "その他",
            purchasePrice: 500,
            purchaseDate: Date(),
            condition: .used
        )

        item.syncStatus = .pendingUpload
        XCTAssertEqual(item.syncStatus, .pendingUpload)

        item.syncStatus = .synced
        item.userId = "test-user-id"
        item.remoteUpdatedAt = Date()
        XCTAssertEqual(item.syncStatus, .synced)
        XCTAssertEqual(item.userId, "test-user-id")
        XCTAssertNotNil(item.remoteUpdatedAt)
    }

    func testWishlistItemPurchasedFlag() {
        let item = WishlistItem(name: "テスト", category: "その他")
        XCTAssertFalse(item.isPurchased)
        item.isPurchased = true
        XCTAssertTrue(item.isPurchased)
    }

    // MARK: - Enum Tests

    func testItemConditionEnum() {
        XCTAssertEqual(ItemCondition.new.rawValue, "新品")
        XCTAssertEqual(ItemCondition.used.rawValue, "中古")
        XCTAssertEqual(ItemCondition.damaged.rawValue, "傷あり")
        XCTAssertEqual(ItemCondition.junk.rawValue, "ジャンク")

        XCTAssertEqual(ItemCondition.allCases.count, 4)
    }

    func testItemStatusEnum() {
        XCTAssertEqual(ItemStatus.owned.rawValue, "保有中")
        XCTAssertEqual(ItemStatus.sold.rawValue, "売却済み")

        XCTAssertEqual(ItemStatus.allCases.count, 2)
    }

    // MARK: - SwiftData Integration Tests

    func testCategorySaveAndFetch() throws {
        let category = My_Libra.Category(name: "テストカテゴリー", iconName: "star", isCustom: true, sortOrder: 1)
        modelContext.insert(category)
        try modelContext.save()

        let fetchDescriptor = FetchDescriptor<My_Libra.Category>()
        let categories = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(categories.count, 1)
        XCTAssertEqual(categories.first?.name, "テストカテゴリー")
    }

    func testWishlistItemSaveAndFetch() throws {
        let item = WishlistItem(name: "テスト商品", category: "その他")
        modelContext.insert(item)
        try modelContext.save()

        let fetchDescriptor = FetchDescriptor<WishlistItem>()
        let items = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "テスト商品")
    }

    func testItemSaveAndFetch() throws {
        let item = Item(
            name: "テストアイテム",
            category: "その他",
            purchasePrice: 1000,
            purchaseDate: Date(),
            condition: .new
        )
        modelContext.insert(item)
        try modelContext.save()

        let fetchDescriptor = FetchDescriptor<Item>()
        let items = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "テストアイテム")
    }
}
