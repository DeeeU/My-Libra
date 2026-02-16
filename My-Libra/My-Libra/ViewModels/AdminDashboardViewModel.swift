//
//  AdminDashboardViewModel.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/16.
//

import Foundation
import SwiftUI

// MARK: - Admin Dashboard Data Models

struct DayOfWeekActivity: Identifiable {
    let id = UUID()
    let dayOfWeek: Int
    let dayLabel: String
    let purchaseCount: Int
}

struct PriceRangeData: Identifiable {
    let id = UUID()
    let range: String
    let count: Int
}

struct CategoryProfit: Identifiable {
    let id = UUID()
    let category: String
    let totalPurchase: Double
    let totalSale: Double
    let profit: Double
    let itemCount: Int
    let soldCount: Int

    var profitMargin: Double {
        totalSale > 0 ? (profit / totalSale) * 100 : 0
    }

    var roi: Double {
        totalPurchase > 0 ? (profit / totalPurchase) * 100 : 0
    }
}

struct WishlistConversionData: Identifiable {
    let id = UUID()
    let category: String
    let totalCount: Int
    let purchasedCount: Int

    var conversionRate: Double {
        totalCount > 0 ? Double(purchasedCount) / Double(totalCount) * 100 : 0
    }
}

struct DataHealthMetric: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let percentage: Double?
    let icon: String
    let color: Color
}

struct HighValueItem: Identifiable {
    let id: UUID
    let name: String
    let category: String
    let purchasePrice: Double
    let profit: Double?
}

// MARK: - ViewModel

@Observable
final class AdminDashboardViewModel {

    // MARK: - User Behavior Analytics

    func averagePurchasesPerMonth(from items: [Item]) -> Double {
        guard !items.isEmpty else { return 0 }

        let calendar = Calendar.current
        let dates = items.map { $0.purchaseDate }
        guard let earliest = dates.min(), let latest = dates.max() else { return 0 }

        let components = calendar.dateComponents([.month], from: earliest.startOfMonth, to: latest.startOfMonth)
        let months = max((components.month ?? 0) + 1, 1)

        return Double(items.count) / Double(months)
    }

    func purchasesByDayOfWeek(from items: [Item]) -> [DayOfWeekActivity] {
        let calendar = Calendar.current
        let dayLabels = ["日", "月", "火", "水", "木", "金", "土"]
        var counts = [Int](repeating: 0, count: 7)

        for item in items {
            let weekday = calendar.component(.weekday, from: item.purchaseDate)
            counts[weekday - 1] += 1
        }

        return (0..<7).map { index in
            DayOfWeekActivity(
                dayOfWeek: index + 1,
                dayLabel: dayLabels[index],
                purchaseCount: counts[index]
            )
        }
    }

    func averageWishlistToPurchaseDays(items: [Item], wishlistItems: [WishlistItem]) -> Double? {
        let purchasedWishlist = wishlistItems.filter { $0.isPurchased }
        guard !purchasedWishlist.isEmpty else { return nil }

        var totalDays: Double = 0
        var matchCount = 0

        for wishItem in purchasedWishlist {
            if let matchedItem = items.first(where: {
                $0.name.localizedCaseInsensitiveCompare(wishItem.name) == .orderedSame
                && $0.category == wishItem.category
            }) {
                let days = matchedItem.purchaseDate.timeIntervalSince(wishItem.createdAt) / 86400
                totalDays += max(days, 0)
                matchCount += 1
            }
        }

        guard matchCount > 0 else { return nil }
        return totalDays / Double(matchCount)
    }

    func wishlistConversionByCategory(from wishlistItems: [WishlistItem]) -> [WishlistConversionData] {
        let grouped = Dictionary(grouping: wishlistItems) { $0.category }
        return grouped.map { category, items in
            WishlistConversionData(
                category: category,
                totalCount: items.count,
                purchasedCount: items.filter { $0.isPurchased }.count
            )
        }
        .sorted { $0.conversionRate > $1.conversionRate }
    }

    // MARK: - Category Intelligence

    func categoryProfitAnalysis(from items: [Item]) -> [CategoryProfit] {
        let grouped = Dictionary(grouping: items) { $0.category }
        return grouped.map { category, categoryItems in
            let totalPurchase = categoryItems.reduce(0) { $0 + $1.purchasePrice }
            let soldItems = categoryItems.filter { $0.status == .sold }
            let totalSale = soldItems.compactMap { $0.salePrice }.reduce(0, +)
            let profit = soldItems.compactMap { $0.profit }.reduce(0, +)

            return CategoryProfit(
                category: category,
                totalPurchase: totalPurchase,
                totalSale: totalSale,
                profit: profit,
                itemCount: categoryItems.count,
                soldCount: soldItems.count
            )
        }
        .sorted { $0.totalPurchase > $1.totalPurchase }
    }

    func priceRangeDistribution(from items: [Item]) -> [PriceRangeData] {
        let ranges: [(label: String, min: Double, max: Double)] = [
            ("~¥1,000", 0, 1000),
            ("¥1,000~¥5,000", 1000, 5000),
            ("¥5,000~¥10,000", 5000, 10000),
            ("¥10,000~¥50,000", 10000, 50000),
            ("¥50,000~", 50000, .infinity)
        ]

        return ranges.map { range in
            let count = items.filter { item in
                if range.max == .infinity {
                    return item.purchasePrice >= range.min
                }
                return item.purchasePrice >= range.min && item.purchasePrice < range.max
            }.count
            return PriceRangeData(range: range.label, count: count)
        }
    }

    // MARK: - Financial Metrics

    func highValueItems(from items: [Item], limit: Int = 10) -> [HighValueItem] {
        items
            .sorted { $0.purchasePrice > $1.purchasePrice }
            .prefix(limit)
            .map { HighValueItem(id: $0.id, name: $0.name, category: $0.category, purchasePrice: $0.purchasePrice, profit: $0.profit) }
    }

    func mostProfitableItems(from items: [Item], limit: Int = 10) -> [HighValueItem] {
        items
            .filter { $0.status == .sold }
            .sorted { ($0.profit ?? 0) > ($1.profit ?? 0) }
            .prefix(limit)
            .map { HighValueItem(id: $0.id, name: $0.name, category: $0.category, purchasePrice: $0.purchasePrice, profit: $0.profit) }
    }

    func overallROI(from items: [Item]) -> Double {
        let soldItems = items.filter { $0.status == .sold }
        guard !soldItems.isEmpty else { return 0 }

        let totalInvestment = soldItems.reduce(0) { $0 + $1.purchasePrice }
        guard totalInvestment > 0 else { return 0 }

        let totalProfit = soldItems.compactMap { $0.profit }.reduce(0, +)
        return (totalProfit / totalInvestment) * 100
    }

    func averageHoldingPeriod(from items: [Item]) -> Double? {
        let soldItems = items.filter { $0.status == .sold }
        guard !soldItems.isEmpty else { return nil }

        var totalDays: Double = 0
        var count = 0

        for item in soldItems {
            guard let saleDate = item.saleDate else { continue }
            let days = saleDate.timeIntervalSince(item.purchaseDate) / 86400
            totalDays += max(days, 0)
            count += 1
        }

        guard count > 0 else { return nil }
        return totalDays / Double(count)
    }

    // MARK: - Data Health

    func dataHealthMetrics(items: [Item], wishlistItems: [WishlistItem]) -> [DataHealthMetric] {
        var metrics: [DataHealthMetric] = []

        let totalItems = items.count
        let totalWishlist = wishlistItems.count

        metrics.append(DataHealthMetric(
            label: "総アイテム数",
            value: "\(totalItems)件",
            percentage: nil,
            icon: "shippingbox.fill",
            color: .blue
        ))

        metrics.append(DataHealthMetric(
            label: "買い物リスト数",
            value: "\(totalWishlist)件",
            percentage: nil,
            icon: "list.bullet",
            color: .orange
        ))

        let photoRate = totalItems > 0
            ? Double(items.filter { $0.imageData != nil }.count) / Double(totalItems) * 100
            : 0
        metrics.append(DataHealthMetric(
            label: "写真添付率",
            value: String(format: "%.0f%%", photoRate),
            percentage: photoRate,
            icon: "photo.fill",
            color: .purple
        ))

        let memoRate = totalItems > 0
            ? Double(items.filter { $0.memo != nil && !($0.memo?.isEmpty ?? true) }.count) / Double(totalItems) * 100
            : 0
        metrics.append(DataHealthMetric(
            label: "メモ記入率",
            value: String(format: "%.0f%%", memoRate),
            percentage: memoRate,
            icon: "note.text",
            color: .green
        ))

        let soldRate = totalItems > 0
            ? Double(items.filter { $0.status == .sold }.count) / Double(totalItems) * 100
            : 0
        metrics.append(DataHealthMetric(
            label: "売却済み率",
            value: String(format: "%.0f%%", soldRate),
            percentage: soldRate,
            icon: "tag.fill",
            color: .red
        ))

        let wishlistConversion = totalWishlist > 0
            ? Double(wishlistItems.filter { $0.isPurchased }.count) / Double(totalWishlist) * 100
            : 0
        metrics.append(DataHealthMetric(
            label: "ウィッシュリスト購入率",
            value: String(format: "%.0f%%", wishlistConversion),
            percentage: wishlistConversion,
            icon: "cart.badge.checkmark",
            color: .teal
        ))

        return metrics
    }

    // MARK: - Export

    func generateAdminReport(items: [Item], wishlistItems: [WishlistItem]) -> String {
        var lines: [String] = []
        let bom = "\u{FEFF}"

        // サマリーセクション
        lines.append("管理レポート")
        lines.append("生成日時,\(Date().toJapaneseDateString())")
        lines.append("")

        // 概要
        lines.append("=== 概要 ===")
        lines.append("総アイテム数,\(items.count)")
        lines.append("買い物リスト数,\(wishlistItems.count)")
        lines.append("月平均購入数,\(String(format: "%.1f", averagePurchasesPerMonth(from: items)))")
        lines.append("総合ROI,\(String(format: "%.1f%%", overallROI(from: items)))")
        lines.append("")

        // カテゴリー別損益
        lines.append("=== カテゴリー別分析 ===")
        lines.append("カテゴリー,アイテム数,総購入額,総売却額,損益,ROI")
        for cp in categoryProfitAnalysis(from: items) {
            lines.append("\(cp.category),\(cp.itemCount),\(String(format: "%.0f", cp.totalPurchase)),\(String(format: "%.0f", cp.totalSale)),\(String(format: "%.0f", cp.profit)),\(String(format: "%.1f%%", cp.roi))")
        }
        lines.append("")

        // 曜日別購入数
        lines.append("=== 曜日別購入数 ===")
        lines.append("曜日,購入数")
        for day in purchasesByDayOfWeek(from: items) {
            lines.append("\(day.dayLabel),\(day.purchaseCount)")
        }
        lines.append("")

        // データヘルス
        lines.append("=== データヘルス ===")
        for metric in dataHealthMetrics(items: items, wishlistItems: wishlistItems) {
            lines.append("\(metric.label),\(metric.value)")
        }

        return bom + lines.joined(separator: "\n")
    }
}
