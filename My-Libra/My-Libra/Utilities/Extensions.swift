//
//  Extensions.swift
//  My-Libra
//
//  Created by Claude Code on 2025/11/04.
//

import SwiftUI
import Foundation

// MARK: - Date Extensions

extension Date {
    /// 日本語フォーマット: 2025年11月4日
    func toJapaneseDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// 短縮日本語フォーマット: 2025/11/04
    func toShortDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: self)
    }

    /// 年月フォーマット: 2025年11月
    func toYearMonthString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年MM月"
        return formatter.string(from: self)
    }

    /// 月の初日を取得
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    /// 月の最終日を取得
    var endOfMonth: Date {
        let calendar = Calendar.current
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth),
              let lastDay = calendar.date(byAdding: .day, value: -1, to: nextMonth) else {
            return self
        }
        return lastDay
    }
}

// MARK: - Double Extensions (Currency)

extension Double {
    /// 日本円フォーマット: ¥1,000
    func toCurrencyString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.currencySymbol = "¥"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "¥0"
    }

    /// 符号付き通貨フォーマット: +¥1,000 / -¥500
    func toSignedCurrencyString() -> String {
        let sign = self >= 0 ? "+" : ""
        return sign + toCurrencyString()
    }

    /// カンマ区切りフォーマット: 1,000
    func toNumberString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }
}

// MARK: - Optional Double Extensions

extension Optional where Wrapped == Double {
    /// Optional Double用の通貨フォーマット
    func toCurrencyString() -> String {
        guard let value = self else { return "-" }
        return value.toCurrencyString()
    }

    /// Optional Double用の符号付き通貨フォーマット
    func toSignedCurrencyString() -> String {
        guard let value = self else { return "-" }
        return value.toSignedCurrencyString()
    }
}

// MARK: - View Extensions

extension View {
    /// カード型スタイルを適用
    func cardStyle() -> some View {
        self
            .padding()
            .background(.background)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    /// セクションヘッダースタイルを適用
    func sectionHeaderStyle() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.secondary)
            .padding(.horizontal)
            .padding(.top, 8)
    }

    /// プライマリボタンスタイルを適用
    func primaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .cornerRadius(10)
    }

    /// セカンダリボタンスタイルを適用
    func secondaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundStyle(Color.accentColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.gray.opacity(0.2))
            .cornerRadius(10)
    }

    /// 入力フィールド背景スタイルを適用
    func inputFieldStyle() -> some View {
        self
            .padding()
            .background(.gray.opacity(0.2))
            .cornerRadius(8)
    }
}

// MARK: - Color Extensions

extension Color {
    /// 利益を表す緑色
    static let profit = Color.green

    /// 損失を表す赤色
    static let loss = Color.red

    /// 状態に応じた色を返す
    static func profitLoss(for value: Double?) -> Color {
        guard let value = value else { return .secondary }
        return value >= 0 ? .profit : .loss
    }
}

// MARK: - String Extensions

extension String {
    /// 文字列をDoubleに変換
    func toDouble() -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.numberStyle = .decimal
        return formatter.number(from: self)?.doubleValue
    }

    /// 空文字列チェック
    var isNotEmpty: Bool {
        !self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
