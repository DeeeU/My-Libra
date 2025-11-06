//
//  Extensions.swift
//  My-Libra
//
//  Created by Claude on 2025/11/06.
//

import Foundation
import SwiftUI

// MARK: - Date Extensions

extension Date {
    /// 日本語形式で日付を表示（例: 2025年11月6日）
    func toJapaneseDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// 短い形式で日付を表示（例: 2025/11/06）
    func toShortDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: self)
    }

    /// 年月を取得（例: 2025年11月）
    func toYearMonthString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年MM月"
        return formatter.string(from: self)
    }

    /// 指定した期間内かどうかをチェック
    func isInPeriod(from startDate: Date, to endDate: Date) -> Bool {
        return self >= startDate && self <= endDate
    }
}

// MARK: - Decimal Extensions

extension Decimal {
    /// 通貨形式で表示（例: ¥1,000）
    func toCurrencyString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.currencySymbol = "¥"
        formatter.maximumFractionDigits = 0 // 小数点以下を表示しない

        return formatter.string(from: self as NSDecimalNumber) ?? "¥0"
    }

    /// 通貨形式で表示（符号付き、例: +¥1,000 または -¥500）
    func toSignedCurrencyString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.currencySymbol = "¥"
        formatter.maximumFractionDigits = 0
        formatter.positivePrefix = "+"
        formatter.negativePrefix = "-"

        return formatter.string(from: self as NSDecimalNumber) ?? "¥0"
    }

    /// 数値を安全にDecimalに変換
    static func from(_ string: String) -> Decimal? {
        return Decimal(string: string)
    }
}

// MARK: - View Extensions

extension View {
    /// カスタムカードスタイル
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    /// セクションヘッダースタイル
    func sectionHeaderStyle() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.primary)
            .padding(.horizontal)
            .padding(.top, 8)
    }

    /// プライマリボタンスタイル
    func primaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .cornerRadius(12)
    }

    /// セカンダリボタンスタイル
    func secondaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.accentColor)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
    }
}

// MARK: - String Extensions

extension String {
    /// 空文字列でない場合のみ返す
    var nonEmpty: String? {
        return self.isEmpty ? nil : self
    }

    /// トリミング（前後の空白を削除）
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Color Extensions

extension Color {
    /// カテゴリーアイコンのカラーパレット
    static let categoryColors: [Color] = [
        .blue, .green, .orange, .purple, .pink,
        .red, .yellow, .cyan, .indigo, .mint
    ]

    /// 損益の色を取得
    static func profitColor(for profit: Decimal?) -> Color {
        guard let profit = profit else { return .secondary }
        if profit > 0 {
            return .green
        } else if profit < 0 {
            return .red
        } else {
            return .secondary
        }
    }
}
