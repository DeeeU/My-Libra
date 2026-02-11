//
//  StatisticsViewModelTests.swift
//  My-LibraTests
//
//  Created by Claude Code on 2026/02/11.
//

import XCTest
@testable import My_Libra

final class StatisticsViewModelTests: XCTestCase {
    var viewModel: StatisticsViewModel!

    override func setUp() {
        super.setUp()
        viewModel = StatisticsViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    private func makeItem(name: String, category: String, price: Double, date: Date = Date()) -> Item {
        Item(name: name, category: category, purchasePrice: price, purchaseDate: date, condition: .new)
    }

    private func makeSoldItem(name: String, category: String, purchasePrice: Double, salePrice: Double, date: Date = Date()) -> Item {
        let item = Item(name: name, category: category, purchasePrice: purchasePrice, purchaseDate: date, condition: .new)
        item.markAsSold(salePrice: salePrice, saleDate: date)
        return item
    }

    // MARK: - Total Tests

    func testTotalPurchaseAmount() {
        let items = [
            makeItem(name: "A", category: "カードゲーム", price: 1000),
            makeItem(name: "B", category: "カードゲーム", price: 2000)
        ]
        XCTAssertEqual(viewModel.totalPurchaseAmount(from: items), 3000)
    }

    func testTotalSaleAmount() {
        let items = [
            makeSoldItem(name: "A", category: "カードゲーム", purchasePrice: 1000, salePrice: 2000),
            makeSoldItem(name: "B", category: "カードゲーム", purchasePrice: 1500, salePrice: 3000)
        ]
        XCTAssertEqual(viewModel.totalSaleAmount(from: items), 5000)
    }

    func testTotalProfit() {
        let items = [
            makeSoldItem(name: "A", category: "カードゲーム", purchasePrice: 1000, salePrice: 2000),
            makeSoldItem(name: "B", category: "カードゲーム", purchasePrice: 1500, salePrice: 1000)
        ]
        XCTAssertEqual(viewModel.totalProfit(from: items), 500) // 1000 + (-500)
    }

    func testTotalProfitWithNoSales() {
        let items = [makeItem(name: "A", category: "カードゲーム", price: 1000)]
        XCTAssertEqual(viewModel.totalProfit(from: items), 0)
    }

    func testOwnedItemsCount() {
        let items = [
            makeItem(name: "A", category: "カードゲーム", price: 1000),
            makeSoldItem(name: "B", category: "カードゲーム", purchasePrice: 1000, salePrice: 2000),
            makeItem(name: "C", category: "靴・スニーカー", price: 3000)
        ]
        XCTAssertEqual(viewModel.ownedItemsCount(from: items), 2)
    }

    // MARK: - Category Data Tests

    func testCategoryData() {
        let items = [
            makeItem(name: "A", category: "カードゲーム", price: 1000),
            makeItem(name: "B", category: "カードゲーム", price: 2000),
            makeItem(name: "C", category: "靴・スニーカー", price: 5000)
        ]

        let data = viewModel.categoryData(from: items)
        XCTAssertEqual(data.count, 2)
        XCTAssertEqual(data.first?.category, "靴・スニーカー") // Sorted by amount desc
        XCTAssertEqual(data.first?.amount, 5000)
    }

    func testCategoryPercentage() {
        let items = [
            makeItem(name: "A", category: "カードゲーム", price: 3000),
            makeItem(name: "B", category: "靴・スニーカー", price: 7000)
        ]

        let pct = viewModel.categoryPercentage(3000, from: items)
        XCTAssertEqual(pct, "30%")
    }

    // MARK: - Period Filter Tests

    func testPeriodFilterAll() {
        let oldDate = Calendar.current.date(byAdding: .year, value: -2, to: Date())!
        let items = [
            makeItem(name: "A", category: "カードゲーム", price: 1000, date: oldDate),
            makeItem(name: "B", category: "カードゲーム", price: 2000)
        ]

        viewModel.selectedPeriod = .all
        let filtered = viewModel.filteredItems(from: items)
        XCTAssertEqual(filtered.count, 2)
    }

    func testPeriodFilterThisMonth() {
        let oldDate = Calendar.current.date(byAdding: .month, value: -2, to: Date())!
        let items = [
            makeItem(name: "古い", category: "カードゲーム", price: 1000, date: oldDate),
            makeItem(name: "今月", category: "カードゲーム", price: 2000)
        ]

        viewModel.selectedPeriod = .thisMonth
        let filtered = viewModel.filteredItems(from: items)
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.name, "今月")
    }

    // MARK: - Monthly Data Tests

    func testMonthlyData() {
        let items = [makeItem(name: "A", category: "カードゲーム", price: 1000)]
        let data = viewModel.monthlyData(from: items)
        XCTAssertFalse(data.isEmpty)
        XCTAssertEqual(data.last?.purchaseAmount, 1000)
    }

    // MARK: - Helper Tests

    func testAbbreviatedCurrency() {
        XCTAssertEqual(viewModel.abbreviatedCurrency(15000), "¥2万")
        XCTAssertEqual(viewModel.abbreviatedCurrency(5000), "¥5000")
        XCTAssertEqual(viewModel.abbreviatedCurrency(-15000), "-¥2万")
    }
}
