//
//  StatisticsView.swift
//  My-Libra
//
//  Created by Claude Code on 2025/11/04.
//

import SwiftUI
import SwiftData
import Charts

// MARK: - Period Filter

enum StatsPeriod: String, CaseIterable, Identifiable {
    case thisMonth = "今月"
    case threeMonths = "3ヶ月"
    case sixMonths = "6ヶ月"
    case thisYear = "今年"
    case all = "全期間"

    var id: String { rawValue }

    /// フィルター開始日を返す（nilは全期間）
    var startDate: Date? {
        let calendar = Calendar.current
        let now = Date()
        switch self {
        case .thisMonth:
            return now.startOfMonth
        case .threeMonths:
            return calendar.date(byAdding: .month, value: -3, to: now)
        case .sixMonths:
            return calendar.date(byAdding: .month, value: -6, to: now)
        case .thisYear:
            let components = calendar.dateComponents([.year], from: now)
            return calendar.date(from: components)
        case .all:
            return nil
        }
    }
}

// MARK: - Chart Data Models

struct CategorySpending: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
}

struct MonthlyData: Identifiable {
    let id = UUID()
    let month: Date
    let label: String
    let purchaseAmount: Double
    let profitLoss: Double
}

// MARK: - StatisticsView

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [Item]
    @State private var selectedPeriod: StatsPeriod = .all

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 期間フィルター
                    periodPicker

                    // サマリーカード
                    summarySection

                    // カテゴリ別支出（円グラフ）
                    if !categoryData.isEmpty {
                        categoryPieChartSection
                    }

                    // 月次購入額（棒グラフ）
                    if !monthlyData.isEmpty {
                        monthlyPurchaseChartSection
                    }

                    // 月次損益（折れ線グラフ）
                    if !monthlyDataWithSales.isEmpty {
                        monthlyProfitChartSection
                    }

                    // データなしの場合
                    if filteredItems.isEmpty {
                        emptyStateView
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("統計")
        }
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(StatsPeriod.allCases) { period in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedPeriod = period
                        }
                    } label: {
                        Text(period.rawValue)
                            .font(.subheadline)
                            .fontWeight(selectedPeriod == period ? .semibold : .regular)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedPeriod == period ? Color.accentColor : Color(.systemGray5))
                            .foregroundStyle(selectedPeriod == period ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }

    // MARK: - Summary Section

    private var summarySection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                SummaryCard(
                    title: "総購入額",
                    value: totalPurchaseAmount.toCurrencyString(),
                    icon: "cart.fill",
                    color: .blue
                )
                SummaryCard(
                    title: "総売却額",
                    value: totalSaleAmount.toCurrencyString(),
                    icon: "yensign.circle.fill",
                    color: .green
                )
            }
            HStack(spacing: 12) {
                SummaryCard(
                    title: "純損益",
                    value: totalProfit.toSignedCurrencyString(),
                    icon: "chart.line.uptrend.xyaxis",
                    color: totalProfit >= 0 ? .green : .red
                )
                SummaryCard(
                    title: "保有品数",
                    value: "\(ownedItemsCount)個",
                    icon: "shippingbox.fill",
                    color: .orange
                )
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Category Pie Chart

    private var categoryPieChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カテゴリ別支出")
                .sectionHeaderStyle()

            Chart(categoryData) { item in
                SectorMark(
                    angle: .value("金額", item.amount),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(by: .value("カテゴリ", item.category))
                .cornerRadius(4)
            }
            .chartLegend(position: .bottom, alignment: .center, spacing: 12)
            .frame(height: 240)
            .padding()
            .background(.background)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            .padding(.horizontal)

            // カテゴリ内訳リスト
            VStack(spacing: 8) {
                ForEach(categoryData) { item in
                    HStack {
                        Text(item.category)
                            .font(.subheadline)
                        Spacer()
                        Text(item.amount.toCurrencyString())
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(categoryPercentage(item.amount))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 45, alignment: .trailing)
                    }
                }
            }
            .padding()
            .background(.background)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
        }
    }

    // MARK: - Monthly Purchase Chart

    private var monthlyPurchaseChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("月次購入額")
                .sectionHeaderStyle()

            Chart(monthlyData) { data in
                BarMark(
                    x: .value("月", data.label),
                    y: .value("購入額", data.purchaseAmount)
                )
                .foregroundStyle(Color.blue.gradient)
                .cornerRadius(4)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(abbreviatedCurrency(v))
                                .font(.caption2)
                        }
                    }
                }
            }
            .frame(height: 200)
            .padding()
            .background(.background)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
        }
    }

    // MARK: - Monthly Profit/Loss Chart

    private var monthlyProfitChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("月次損益")
                .sectionHeaderStyle()

            Chart(monthlyDataWithSales) { data in
                LineMark(
                    x: .value("月", data.label),
                    y: .value("損益", data.profitLoss)
                )
                .foregroundStyle(Color.orange)
                .interpolationMethod(.catmullRom)
                .symbol(Circle())

                AreaMark(
                    x: .value("月", data.label),
                    y: .value("損益", data.profitLoss)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                RuleMark(y: .value("基準線", 0))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .foregroundStyle(.secondary.opacity(0.5))
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(abbreviatedCurrency(v))
                                .font(.caption2)
                        }
                    }
                }
            }
            .frame(height: 200)
            .padding()
            .background(.background)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis.ascending")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("データがありません")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("商品を登録すると統計が表示されます")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 60)
    }

    // MARK: - Computed Properties

    private var filteredItems: [Item] {
        guard let startDate = selectedPeriod.startDate else {
            return allItems
        }
        return allItems.filter { $0.purchaseDate >= startDate }
    }

    private var totalPurchaseAmount: Double {
        filteredItems.reduce(0) { $0 + $1.purchasePrice }
    }

    private var totalSaleAmount: Double {
        filteredItems.compactMap { $0.salePrice }.reduce(0, +)
    }

    private var totalProfit: Double {
        filteredItems.compactMap { $0.profit }.reduce(0, +)
    }

    private var ownedItemsCount: Int {
        filteredItems.filter { $0.status == .owned }.count
    }

    private var categoryData: [CategorySpending] {
        let grouped = Dictionary(grouping: filteredItems) { $0.category }
        return grouped.map { CategorySpending(category: $0.key, amount: $0.value.reduce(0) { $0 + $1.purchasePrice }) }
            .sorted { $0.amount > $1.amount }
    }

    private var monthlyData: [MonthlyData] {
        buildMonthlyData(from: filteredItems)
    }

    private var monthlyDataWithSales: [MonthlyData] {
        monthlyData.filter { data in
            data.profitLoss != 0 || filteredItems.contains { item in
                guard let saleDate = item.saleDate else { return false }
                return Calendar.current.isDate(saleDate, equalTo: data.month, toGranularity: .month)
            }
        }
    }

    // MARK: - Helper Methods

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

    private func categoryPercentage(_ amount: Double) -> String {
        let total = categoryData.reduce(0) { $0 + $1.amount }
        guard total > 0 else { return "0%" }
        let pct = (amount / total) * 100
        return String(format: "%.0f%%", pct)
    }

    private func abbreviatedCurrency(_ value: Double) -> String {
        let absValue = abs(value)
        let sign = value < 0 ? "-" : ""
        if absValue >= 10000 {
            return "\(sign)¥\(String(format: "%.0f", absValue / 10000))万"
        }
        return "\(sign)¥\(String(format: "%.0f", absValue))"
    }
}

// MARK: - Summary Card (2x2 Grid)

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                Spacer()
            }
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [Item.self, Category.self])
}
