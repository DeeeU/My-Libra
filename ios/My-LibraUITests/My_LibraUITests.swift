//
//  My_LibraUITests.swift
//  My-LibraUITests
//
//  Created by kanabuchi on 2025/10/22.
//

import XCTest

final class My_LibraUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()

        // ロード画面の完了を待つ
        let tabBar = app.tabBars.firstMatch
        let exists = tabBar.waitForExistence(timeout: 5)
        XCTAssertTrue(exists, "TabBarが表示されるまで待機")
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Tab Navigation Tests

    @MainActor
    func testTabNavigation() throws {
        let tabBar = app.tabBars.firstMatch

        // 買い物リストタブ
        tabBar.buttons["買い物リスト"].tap()
        XCTAssertTrue(app.navigationBars["買い物リスト"].waitForExistence(timeout: 2))

        // 保有品タブ
        tabBar.buttons["保有品"].tap()
        XCTAssertTrue(app.navigationBars["保有品"].waitForExistence(timeout: 2))

        // 統計タブ
        tabBar.buttons["統計"].tap()
        XCTAssertTrue(app.navigationBars["統計"].waitForExistence(timeout: 2))

        // 設定タブ
        tabBar.buttons["設定"].tap()
        XCTAssertTrue(app.navigationBars["設定"].waitForExistence(timeout: 2))
    }

    // MARK: - Wishlist Tests

    @MainActor
    func testWishlistAddItem() throws {
        let tabBar = app.tabBars.firstMatch
        tabBar.buttons["買い物リスト"].tap()

        // 追加ボタンをタップ
        app.navigationBars.buttons.matching(identifier: "plus").firstMatch.tap()

        // フォームが表示されることを確認
        XCTAssertTrue(app.navigationBars["買い物リストに追加"].waitForExistence(timeout: 2))
    }

    // MARK: - Settings Tests

    @MainActor
    func testSettingsScreen() throws {
        let tabBar = app.tabBars.firstMatch
        tabBar.buttons["設定"].tap()

        // 設定画面の要素確認
        XCTAssertTrue(app.staticTexts["カテゴリー"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["データ管理"].exists)
        XCTAssertTrue(app.staticTexts["アプリ情報"].exists)
    }

    // MARK: - Launch Performance

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
