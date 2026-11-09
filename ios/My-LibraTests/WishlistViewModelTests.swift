//
//  WishlistViewModelTests.swift
//  My-LibraTests
//
//  Created by Claude Code on 2026/02/11.
//

import XCTest
@testable import My_Libra

final class WishlistViewModelTests: XCTestCase {
    var viewModel: WishlistViewModel!

    override func setUp() {
        super.setUp()
        viewModel = WishlistViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Filter Tests

    func testFilterExcludesPurchasedItems() {
        let items = [
            WishlistItem(name: "未購入", category: "カードゲーム"),
            makePurchasedItem(name: "購入済み", category: "カードゲーム")
        ]

        let result = viewModel.filteredItems(from: items)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "未購入")
    }

    func testFilterByCategory() {
        let items = [
            WishlistItem(name: "カード1", category: "カードゲーム"),
            WishlistItem(name: "靴1", category: "靴・スニーカー")
        ]

        viewModel.selectedCategory = "カードゲーム"
        let result = viewModel.filteredItems(from: items)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "カード1")
    }

    func testFilterAllCategory() {
        let items = [
            WishlistItem(name: "カード1", category: "カードゲーム"),
            WishlistItem(name: "靴1", category: "靴・スニーカー")
        ]

        viewModel.selectedCategory = "すべて"
        let result = viewModel.filteredItems(from: items)
        XCTAssertEqual(result.count, 2)
    }

    func testFilterBySearch() {
        let items = [
            WishlistItem(name: "ポケモンカード", category: "カードゲーム"),
            WishlistItem(name: "スニーカー", category: "靴・スニーカー")
        ]

        viewModel.searchText = "ポケモン"
        let result = viewModel.filteredItems(from: items)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "ポケモンカード")
    }

    // MARK: - Helpers

    private func makePurchasedItem(name: String, category: String) -> WishlistItem {
        let item = WishlistItem(name: name, category: category)
        item.isPurchased = true
        return item
    }
}
