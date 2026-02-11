//
//  ExtensionsTests.swift
//  My-LibraTests
//
//  Created by Claude Code on 2026/02/11.
//

import XCTest
@testable import My_Libra

final class ExtensionsTests: XCTestCase {

    // MARK: - Date Extensions

    func testToShortDateString() {
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 4
        let date = Calendar.current.date(from: components)!

        XCTAssertEqual(date.toShortDateString(), "2025/11/04")
    }

    func testStartOfMonth() {
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 15
        let date = Calendar.current.date(from: components)!
        let startOfMonth = date.startOfMonth

        let resultComponents = Calendar.current.dateComponents([.year, .month, .day], from: startOfMonth)
        XCTAssertEqual(resultComponents.year, 2025)
        XCTAssertEqual(resultComponents.month, 11)
        XCTAssertEqual(resultComponents.day, 1)
    }

    // MARK: - Double Extensions

    func testToCurrencyString() {
        XCTAssertEqual((1000.0).toCurrencyString(), "¥1,000")
        XCTAssertEqual((0.0).toCurrencyString(), "¥0")
    }

    func testToSignedCurrencyString() {
        XCTAssertEqual((1000.0).toSignedCurrencyString(), "+¥1,000")
        XCTAssertEqual((-500.0).toSignedCurrencyString(), "-¥500")
    }

    func testToNumberString() {
        XCTAssertEqual((1000.0).toNumberString(), "1,000")
    }

    // MARK: - Optional Double Extensions

    func testOptionalToCurrencyString() {
        let value: Double? = 1000
        XCTAssertEqual(value.toCurrencyString(), "¥1,000")

        let nilValue: Double? = nil
        XCTAssertEqual(nilValue.toCurrencyString(), "-")
    }

    // MARK: - String Extensions

    func testToDouble() {
        XCTAssertEqual("1000".toDouble(), 1000)
        XCTAssertEqual("1,000".toDouble(), 1000)
    }

    func testIsNotEmpty() {
        XCTAssertTrue("hello".isNotEmpty)
        XCTAssertFalse("".isNotEmpty)
        XCTAssertFalse("  ".isNotEmpty)
    }
}
