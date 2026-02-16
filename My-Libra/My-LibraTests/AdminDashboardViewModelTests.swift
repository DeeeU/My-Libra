//
//  AdminDashboardViewModelTests.swift
//  My-LibraTests
//
//  Created by Claude Code on 2026/02/16.
//

import XCTest
@testable import My_Libra

final class AdminDashboardViewModelTests: XCTestCase {
    var viewModel: AdminDashboardViewModel!

    override func setUp() {
        super.setUp()
        viewModel = AdminDashboardViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeItem(name: String, category: String, price: Double, date: Date = Date()) -> Item {
        Item(name: name, category: category, purchasePrice: price, purchaseDate: date, condition: .new)
    }

    private func makeSoldItem(name: String, category: String, purchasePrice: Double, salePrice: Double, purchaseDate: Date = Date(), saleDate: Date? = nil) -> Item {
        let item = Item(name: name, category: category, purchasePrice: purchasePrice, purchaseDate: purchaseDate, condition: .new)
        item.markAsSold(salePrice: salePrice, saleDate: saleDate ?? purchaseDate)
        return item
    }

    private func makeWishlistItem(name: String, category: String, isPurchased: Bool = false) -> WishlistItem {
        let item = WishlistItem(name: name, category: category)
        item.isPurchased = isPurchased
        return item
    }

    // MARK: - Average Purchases Per Month

    func testAveragePurchasesPerMonthWithItems() {
        let calendar = Calendar.current
        let now = Date()
        let twoMonthsAgo = calendar.date(byAdding: .month, value: -2, to: now)!

        let items = [
            makeItem(name: "A", category: "カードゲーム", price: 1000, date: twoMonthsAgo),
            makeItem(name: "B", category: "カードゲーム", price: 2000, date: now),
            makeItem(name: "C", category: "カードゲーム", price: 3000, date: now)
        ]

        let avg = viewModel.averagePurchasesPerMonth(from: items)
        XCTAssertEqual(avg, 1.0, accuracy: 0.1) // 3 items over 3 months
    }

    func testAveragePurchasesPerMonthEmpty() {
        XCTAssertEqual(viewModel.averagePurchasesPerMonth(from: []), 0)
    }

    // MARK: - Purchases By Day Of Week

    func testPurchasesByDayOfWeekReturns7Days() {
        let data = viewModel.purchasesByDayOfWeek(from: [])
        XCTAssertEqual(data.count, 7)
    }

    func testPurchasesByDayOfWeekCorrectLabels() {
        let data = viewModel.purchasesByDayOfWeek(from: [])
        let labels = data.map { $0.dayLabel }
        XCTAssertEqual(labels, ["日", "月", "火", "水", "木", "金", "土"])
    }

    func testPurchasesByDayOfWeekCorrectCounts() {
        // Create items on known dates
        let calendar = Calendar.current
        // Find next Monday
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2 // Monday
        let monday = calendar.date(from: components)!

        let items = [
            makeItem(name: "A", category: "カードゲーム", price: 1000, date: monday),
            makeItem(name: "B", category: "カードゲーム", price: 2000, date: monday)
        ]

        let data = viewModel.purchasesByDayOfWeek(from: items)
        let mondayData = data.first { $0.dayLabel == "月" }
        XCTAssertEqual(mondayData?.purchaseCount, 2)
    }

    // MARK: - Wishlist To Purchase Days

    func testAverageWishlistToPurchaseDaysWithMatches() {
        let calendar = Calendar.current
        let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: Date())!

        let wishItem = makeWishlistItem(name: "テストカード", category: "カードゲーム", isPurchased: true)
        wishItem.createdAt = tenDaysAgo

        let item = makeItem(name: "テストカード", category: "カードゲーム", price: 1000)

        let avg = viewModel.averageWishlistToPurchaseDays(items: [item], wishlistItems: [wishItem])
        XCTAssertNotNil(avg)
        XCTAssertEqual(avg!, 10, accuracy: 1)
    }

    func testAverageWishlistToPurchaseDaysNoMatches() {
        let wishItem = makeWishlistItem(name: "A", category: "カードゲーム", isPurchased: true)
        let item = makeItem(name: "B", category: "靴・スニーカー", price: 1000)

        let avg = viewModel.averageWishlistToPurchaseDays(items: [item], wishlistItems: [wishItem])
        XCTAssertNil(avg)
    }

    func testAverageWishlistToPurchaseDaysNoPurchased() {
        let wishItem = makeWishlistItem(name: "A", category: "カードゲーム", isPurchased: false)
        let avg = viewModel.averageWishlistToPurchaseDays(items: [], wishlistItems: [wishItem])
        XCTAssertNil(avg)
    }

    // MARK: - Wishlist Conversion By Category

    func testWishlistConversionByCategory() {
        let items = [
            makeWishlistItem(name: "A", category: "カードゲーム", isPurchased: true),
            makeWishlistItem(name: "B", category: "カードゲーム", isPurchased: false),
            makeWishlistItem(name: "C", category: "靴・スニーカー", isPurchased: true)
        ]

        let data = viewModel.wishlistConversionByCategory(from: items)
        XCTAssertEqual(data.count, 2)

        // 靴 should be first (100% conversion)
        let shoesData = data.first { $0.category == "靴・スニーカー" }
        XCTAssertEqual(shoesData?.conversionRate, 100)

        let cardData = data.first { $0.category == "カードゲーム" }
        XCTAssertEqual(cardData?.conversionRate, 50)
    }

    // MARK: - Category Profit Analysis

    func testCategoryProfitAnalysisSingleCategory() {
        let items = [
            makeItem(name: "A", category: "カードゲーム", price: 1000),
            makeSoldItem(name: "B", category: "カードゲーム", purchasePrice: 2000, salePrice: 3000)
        ]

        let data = viewModel.categoryProfitAnalysis(from: items)
        XCTAssertEqual(data.count, 1)
        XCTAssertEqual(data.first?.totalPurchase, 3000)
        XCTAssertEqual(data.first?.totalSale, 3000)
        XCTAssertEqual(data.first?.profit, 1000)
        XCTAssertEqual(data.first?.itemCount, 2)
        XCTAssertEqual(data.first?.soldCount, 1)
    }

    func testCategoryProfitAnalysisROI() {
        let items = [
            makeSoldItem(name: "A", category: "カードゲーム", purchasePrice: 1000, salePrice: 1500)
        ]

        let data = viewModel.categoryProfitAnalysis(from: items)
        XCTAssertEqual(data.first!.roi, 50, accuracy: 0.1) // (500/1000)*100
    }

    func testCategoryProfitAnalysisMultipleCategories() {
        let items = [
            makeItem(name: "A", category: "カードゲーム", price: 5000),
            makeItem(name: "B", category: "靴・スニーカー", price: 10000)
        ]

        let data = viewModel.categoryProfitAnalysis(from: items)
        XCTAssertEqual(data.count, 2)
        XCTAssertEqual(data.first?.category, "靴・スニーカー") // Sorted by totalPurchase desc
    }

    // MARK: - Price Range Distribution

    func testPriceRangeDistributionCorrectBuckets() {
        let items = [
            makeItem(name: "A", category: "カードゲーム", price: 500),
            makeItem(name: "B", category: "カードゲーム", price: 3000),
            makeItem(name: "C", category: "カードゲーム", price: 8000),
            makeItem(name: "D", category: "カードゲーム", price: 30000),
            makeItem(name: "E", category: "カードゲーム", price: 100000)
        ]

        let data = viewModel.priceRangeDistribution(from: items)
        XCTAssertEqual(data.count, 5)
        XCTAssertEqual(data[0].count, 1) // ~¥1,000
        XCTAssertEqual(data[1].count, 1) // ¥1,000~¥5,000
        XCTAssertEqual(data[2].count, 1) // ¥5,000~¥10,000
        XCTAssertEqual(data[3].count, 1) // ¥10,000~¥50,000
        XCTAssertEqual(data[4].count, 1) // ¥50,000~
    }

    func testPriceRangeDistributionEmpty() {
        let data = viewModel.priceRangeDistribution(from: [])
        XCTAssertEqual(data.count, 5)
        XCTAssertTrue(data.allSatisfy { $0.count == 0 })
    }

    // MARK: - High Value Items

    func testHighValueItemsLimit() {
        let items = (1...15).map { makeItem(name: "Item \($0)", category: "カードゲーム", price: Double($0 * 1000)) }
        let result = viewModel.highValueItems(from: items, limit: 5)
        XCTAssertEqual(result.count, 5)
    }

    func testHighValueItemsSortedByPrice() {
        let items = [
            makeItem(name: "安い", category: "カードゲーム", price: 1000),
            makeItem(name: "高い", category: "カードゲーム", price: 5000),
            makeItem(name: "中間", category: "カードゲーム", price: 3000)
        ]

        let result = viewModel.highValueItems(from: items)
        XCTAssertEqual(result.first?.name, "高い")
        XCTAssertEqual(result.last?.name, "安い")
    }

    // MARK: - Most Profitable Items

    func testMostProfitableItemsSortedByProfit() {
        let items = [
            makeSoldItem(name: "少利益", category: "カードゲーム", purchasePrice: 1000, salePrice: 1500),
            makeSoldItem(name: "高利益", category: "カードゲーム", purchasePrice: 1000, salePrice: 3000)
        ]

        let result = viewModel.mostProfitableItems(from: items)
        XCTAssertEqual(result.first?.name, "高利益")
    }

    func testMostProfitableItemsExcludesUnsold() {
        let items = [
            makeItem(name: "未売却", category: "カードゲーム", price: 1000),
            makeSoldItem(name: "売却済み", category: "カードゲーム", purchasePrice: 1000, salePrice: 2000)
        ]

        let result = viewModel.mostProfitableItems(from: items)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "売却済み")
    }

    // MARK: - Overall ROI

    func testOverallROIPositive() {
        let items = [
            makeSoldItem(name: "A", category: "カードゲーム", purchasePrice: 1000, salePrice: 1500)
        ]

        XCTAssertEqual(viewModel.overallROI(from: items), 50, accuracy: 0.1)
    }

    func testOverallROINegative() {
        let items = [
            makeSoldItem(name: "A", category: "カードゲーム", purchasePrice: 1000, salePrice: 500)
        ]

        XCTAssertEqual(viewModel.overallROI(from: items), -50, accuracy: 0.1)
    }

    func testOverallROINoSales() {
        let items = [makeItem(name: "A", category: "カードゲーム", price: 1000)]
        XCTAssertEqual(viewModel.overallROI(from: items), 0)
    }

    // MARK: - Average Holding Period

    func testAverageHoldingPeriodWithSoldItems() {
        let calendar = Calendar.current
        let purchaseDate = calendar.date(byAdding: .day, value: -30, to: Date())!
        let saleDate = Date()

        let items = [
            makeSoldItem(name: "A", category: "カードゲーム", purchasePrice: 1000, salePrice: 1500, purchaseDate: purchaseDate, saleDate: saleDate)
        ]

        let avg = viewModel.averageHoldingPeriod(from: items)
        XCTAssertNotNil(avg)
        XCTAssertEqual(avg!, 30, accuracy: 1)
    }

    func testAverageHoldingPeriodNoSoldItems() {
        let items = [makeItem(name: "A", category: "カードゲーム", price: 1000)]
        XCTAssertNil(viewModel.averageHoldingPeriod(from: items))
    }

    // MARK: - Data Health Metrics

    func testDataHealthMetricsPhotoRate() {
        let itemWithPhoto = makeItem(name: "A", category: "カードゲーム", price: 1000)
        itemWithPhoto.imageData = Data([0x00])
        let itemWithout = makeItem(name: "B", category: "カードゲーム", price: 2000)

        let metrics = viewModel.dataHealthMetrics(items: [itemWithPhoto, itemWithout], wishlistItems: [])
        let photoMetric = metrics.first { $0.label == "写真添付率" }
        XCTAssertEqual(photoMetric?.percentage, 50)
    }

    func testDataHealthMetricsMemoRate() {
        let itemWithMemo = makeItem(name: "A", category: "カードゲーム", price: 1000)
        itemWithMemo.memo = "テストメモ"
        let itemWithout = makeItem(name: "B", category: "カードゲーム", price: 2000)

        let metrics = viewModel.dataHealthMetrics(items: [itemWithMemo, itemWithout], wishlistItems: [])
        let memoMetric = metrics.first { $0.label == "メモ記入率" }
        XCTAssertEqual(memoMetric?.percentage, 50)
    }

    func testDataHealthMetricsEmpty() {
        let metrics = viewModel.dataHealthMetrics(items: [], wishlistItems: [])
        XCTAssertFalse(metrics.isEmpty)

        let photoMetric = metrics.first { $0.label == "写真添付率" }
        XCTAssertEqual(photoMetric?.percentage, 0)
    }

    // MARK: - Generate Admin Report

    func testGenerateAdminReportNotEmpty() {
        let items = [makeItem(name: "A", category: "カードゲーム", price: 1000)]
        let report = viewModel.generateAdminReport(items: items, wishlistItems: [])
        XCTAssertFalse(report.isEmpty)
    }

    func testGenerateAdminReportContainsBOM() {
        let report = viewModel.generateAdminReport(items: [], wishlistItems: [])
        XCTAssertTrue(report.hasPrefix("\u{FEFF}"))
    }

    func testGenerateAdminReportContainsSections() {
        let items = [makeItem(name: "A", category: "カードゲーム", price: 1000)]
        let report = viewModel.generateAdminReport(items: items, wishlistItems: [])
        XCTAssertTrue(report.contains("管理レポート"))
        XCTAssertTrue(report.contains("=== 概要 ==="))
        XCTAssertTrue(report.contains("=== カテゴリー別分析 ==="))
        XCTAssertTrue(report.contains("=== 曜日別購入数 ==="))
        XCTAssertTrue(report.contains("=== データヘルス ==="))
    }
}
