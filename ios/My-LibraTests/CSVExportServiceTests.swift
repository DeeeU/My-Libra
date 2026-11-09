//
//  CSVExportServiceTests.swift
//  My-LibraTests
//
//  Created by Claude Code on 2026/02/11.
//

import XCTest
@testable import My_Libra

final class CSVExportServiceTests: XCTestCase {

    // MARK: - Item Export Tests

    func testExportItems() {
        let item = Item(name: "テスト", category: "カードゲーム", purchasePrice: 1000, purchaseDate: Date(), condition: .new, memo: "メモ")
        let csv = CSVExportService.exportItems([item])

        XCTAssertTrue(csv.contains("テスト"))
        XCTAssertTrue(csv.contains("カードゲーム"))
        XCTAssertTrue(csv.contains("1000"))
        XCTAssertTrue(csv.contains("商品名"))
    }

    func testExportWishlistItems() {
        let item = WishlistItem(name: "欲しい物", category: "靴・スニーカー", estimatedPrice: 5000)
        let csv = CSVExportService.exportWishlistItems([item])

        XCTAssertTrue(csv.contains("欲しい物"))
        XCTAssertTrue(csv.contains("靴・スニーカー"))
        XCTAssertTrue(csv.contains("5000"))
    }

    // MARK: - CSV Escape Tests

    func testCSVEscapeComma() {
        let item = WishlistItem(name: "カンマ,入り", category: "その他")
        let csv = CSVExportService.exportWishlistItems([item])
        XCTAssertTrue(csv.contains("\"カンマ,入り\""))
    }

    func testCSVEscapeQuotes() {
        let item = WishlistItem(name: "引用\"入り", category: "その他")
        let csv = CSVExportService.exportWishlistItems([item])
        XCTAssertTrue(csv.contains("\"引用\"\"入り\""))
    }
}
