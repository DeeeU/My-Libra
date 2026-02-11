//
//  ItemViewModelTests.swift
//  My-LibraTests
//
//  Created by Claude Code on 2026/02/11.
//

import XCTest
@testable import My_Libra

final class ItemViewModelTests: XCTestCase {
    var viewModel: ItemViewModel!

    override func setUp() {
        super.setUp()
        viewModel = ItemViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    private func makeItem(name: String, category: String, price: Double, date: Date = Date(), status: ItemStatus = .owned) -> Item {
        let item = Item(name: name, category: category, purchasePrice: price, purchaseDate: date, condition: .new)
        if status == .sold {
            item.markAsSold(salePrice: price + 1000, saleDate: Date())
        }
        return item
    }

    // MARK: - Filter Tests

    func testFilterByCategory() {
        let items = [
            makeItem(name: "カード1", category: "カードゲーム", price: 1000),
            makeItem(name: "靴1", category: "靴・スニーカー", price: 5000)
        ]

        viewModel.selectedCategory = "カードゲーム"
        let result = viewModel.filteredItems(from: items)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "カード1")
    }

    func testFilterByStatus() {
        let items = [
            makeItem(name: "保有品", category: "カードゲーム", price: 1000, status: .owned),
            makeItem(name: "売却済み品", category: "カードゲーム", price: 2000, status: .sold)
        ]

        viewModel.selectedStatus = .owned
        let result = viewModel.filteredItems(from: items)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "保有品")
    }

    func testFilterBySearch() {
        let items = [
            makeItem(name: "ポケモンカード", category: "カードゲーム", price: 1000),
            makeItem(name: "スニーカー", category: "靴・スニーカー", price: 5000)
        ]

        viewModel.searchText = "スニーカー"
        let result = viewModel.filteredItems(from: items)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "スニーカー")
    }

    // MARK: - Sort Tests

    func testSortByPriceDesc() {
        let items = [
            makeItem(name: "安い", category: "カードゲーム", price: 1000),
            makeItem(name: "高い", category: "カードゲーム", price: 5000)
        ]

        viewModel.sortOption = .priceDesc
        let result = viewModel.filteredItems(from: items)
        XCTAssertEqual(result.first?.name, "高い")
    }

    func testSortByPriceAsc() {
        let items = [
            makeItem(name: "高い", category: "カードゲーム", price: 5000),
            makeItem(name: "安い", category: "カードゲーム", price: 1000)
        ]

        viewModel.sortOption = .priceAsc
        let result = viewModel.filteredItems(from: items)
        XCTAssertEqual(result.first?.name, "安い")
    }

    func testSortByName() {
        let items = [
            makeItem(name: "Bアイテム", category: "カードゲーム", price: 1000),
            makeItem(name: "Aアイテム", category: "カードゲーム", price: 1000)
        ]

        viewModel.sortOption = .name
        let result = viewModel.filteredItems(from: items)
        XCTAssertEqual(result.first?.name, "Aアイテム")
    }
}
