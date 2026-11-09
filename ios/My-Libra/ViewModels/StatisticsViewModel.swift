//
//  StatisticsViewModel.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/11.
//

import Foundation

@Observable
final class StatisticsViewModel {
    var selectedPeriod: StatsPeriod = .thisMonth

    func filteredItems(from items: [Item]) -> [Item] {
        guard let startDate = selectedPeriod.startDate else {
            return items
        }
        return items.filter { $0.purchaseDate >= startDate }
    }

    func totalPurchaseAmount(from items: [Item]) -> Double {
        filteredItems(from: items).reduce(0) { $0 + $1.purchasePrice }
    }

    func totalSaleAmount(from items: [Item]) -> Double {
        filteredItems(from: items).compactMap { $0.salePrice }.reduce(0, +)
    }

    func totalProfit(from items: [Item]) -> Double {
        filteredItems(from: items).compactMap { $0.profit }.reduce(0, +)
    }

    func ownedItemsCount(from items: [Item]) -> Int {
        filteredItems(from: items).filter { $0.status == .owned }.count
    }

    func categoryData(from items: [Item]) -> [CategorySpending] {
        let filtered = filteredItems(from: items)
        let grouped = Dictionary(grouping: filtered) { $0.category }
        return grouped.map { CategorySpending(category: $0.key, amount: $0.value.reduce(0) { $0 + $1.purchasePrice }) }
            .sorted { $0.amount > $1.amount }
    }

    func monthlyData(from items: [Item]) -> [MonthlyData] {
        let filtered = filteredItems(from: items)
        return buildMonthlyData(from: filtered)
    }

    func monthlyDataWithSales(from items: [Item]) -> [MonthlyData] {
        let filtered = filteredItems(from: items)
        let monthly = buildMonthlyData(from: filtered)
        return monthly.filter { data in
            data.profitLoss != 0 || filtered.contains { item in
                guard let saleDate = item.saleDate else { return false }
                return Calendar.current.isDate(saleDate, equalTo: data.month, toGranularity: .month)
            }
        }
    }

    func categoryPercentage(_ amount: Double, from items: [Item]) -> String {
        let total = categoryData(from: items).reduce(0) { $0 + $1.amount }
        guard total > 0 else { return "0%" }
        let pct = (amount / total) * 100
        return String(format: "%.0f%%", pct)
    }

    func abbreviatedCurrency(_ value: Double) -> String {
        let absValue = abs(value)
        let sign = value < 0 ? "-" : ""
        if absValue >= 10000 {
            return "\(sign)¥\(String(format: "%.0f", absValue / 10000))万"
        }
        return "\(sign)¥\(String(format: "%.0f", absValue))"
    }

    // MARK: - Private

    private func buildMonthlyData(from items: [Item]) -> [MonthlyData] {
        let calendar = Calendar.current
        guard let earliest = items.map({ $0.purchaseDate }).min() else { return [] }

        let startMonth = earliest.startOfMonth
        let endMonth = Date().startOfMonth

        var result: [MonthlyData] = []
        var current = startMonth

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月"

        while current <= endMonth {
            let monthItems = items.filter {
                calendar.isDate($0.purchaseDate, equalTo: current, toGranularity: .month)
            }
            let purchaseTotal = monthItems.reduce(0) { $0 + $1.purchasePrice }

            let soldItems = items.filter { item in
                guard let saleDate = item.saleDate else { return false }
                return calendar.isDate(saleDate, equalTo: current, toGranularity: .month)
            }
            let profitTotal = soldItems.compactMap { $0.profit }.reduce(0, +)

            result.append(MonthlyData(
                month: current,
                label: formatter.string(from: current),
                purchaseAmount: purchaseTotal,
                profitLoss: profitTotal
            ))

            guard let next = calendar.date(byAdding: .month, value: 1, to: current) else { break }
            current = next
        }

        return result
    }
}
