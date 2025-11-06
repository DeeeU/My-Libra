//
//  StatisticsView.swift
//  My-Libra
//
//  Created by Claude on 2025/11/06.
//

import SwiftUI
import SwiftData

enum PeriodFilter: String, CaseIterable {
    case all = "全期間"
    case thisMonth = "今月"
    case last3Months = "過去3ヶ月"
    case last6Months = "過去6ヶ月"
    case thisYear = "今年"
}

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [Item]

    @State private var selectedPeriod: PeriodFilter = .all

    var filteredItems: [Item] {
        let calendar = Calendar.current
        let now = Date()

        switch selectedPeriod {
        case .all:
            return allItems
        case .thisMonth:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return allItems.filter { $0.purchaseDate >= startOfMonth }
        case .last3Months:
            let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now)!
            return allItems.filter { $0.purchaseDate >= threeMonthsAgo }
        case .last6Months:
            let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now)!
            return allItems.filter { $0.purchaseDate >= sixMonthsAgo }
        case .thisYear:
            let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
            return allItems.filter { $0.purchaseDate >= startOfYear }
        }
    }

    var totalPurchase: Decimal {
        filteredItems.reduce(0) { $0 + $1.purchasePrice }
    }

    var totalSale: Decimal {
        filteredItems.compactMap { $0.salePrice }.reduce(0, +)
    }

    var totalProfit: Decimal {
        totalSale - filteredItems.filter { $0.status == .sold }.reduce(0) { $0 + $1.purchasePrice }
    }

    var ownedCount: Int {
        filteredItems.filter { $0.status == .owned }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 期間フィルターピッカー
                    Picker("期間", selection: $selectedPeriod) {
                        ForEach(PeriodFilter.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // サマリーカード
                    VStack(spacing: 12) {
                        SummaryRow(title: "総購入額", value: totalPurchase.toCurrencyString(), color: .blue, icon: "cart.fill")
                        SummaryRow(title: "総売却額", value: totalSale.toCurrencyString(), color: .green, icon: "yensign.circle.fill")
                        SummaryRow(title: "純損益", value: totalProfit.toSignedCurrencyString(), color: Color.profitColor(for: totalProfit), icon: "chart.line.uptrend.xyaxis")
                        SummaryRow(title: "保有品数", value: "\(ownedCount)個", color: .orange, icon: "shippingbox.fill")
                    }
                    .cardStyle()
                    .padding(.horizontal)

                    if filteredItems.isEmpty {
                        ContentUnavailableView(
                            "データがありません",
                            systemImage: "chart.bar",
                            description: Text("商品を購入登録すると統計情報が表示されます")
                        )
                        .padding(.vertical, 40)
                    } else {
                        // カテゴリー別円グラフ
                        CategoryPieChart(items: filteredItems)

                        // 月別グラフ
                        MonthlyChart(items: filteredItems)

                        // 追加の統計情報
                        AdditionalStatsView(items: filteredItems)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("統計")
        }
    }
}

// MARK: - SummaryRow

struct SummaryRow: View {
    let title: String
    let value: String
    let color: Color
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .frame(width: 30)
            }

            Text(title)
                .font(.body)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.headline)
                .foregroundStyle(color)
        }
    }
}

// MARK: - AdditionalStatsView

struct AdditionalStatsView: View {
    let items: [Item]

    var averagePurchasePrice: Decimal {
        guard !items.isEmpty else { return 0 }
        let total = items.reduce(0) { $0 + $1.purchasePrice }
        return total / Decimal(items.count)
    }

    var soldCount: Int {
        items.filter { $0.status == .sold }.count
    }

    var soldRate: Double {
        guard !items.isEmpty else { return 0 }
        return Double(soldCount) / Double(items.count) * 100
    }

    var profitableCount: Int {
        items.filter { item in
            guard let profit = item.profit else { return false }
            return profit > 0
        }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("その他の統計")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 12) {
                HStack {
                    Text("平均購入価格")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(averagePurchasePrice.toCurrencyString())
                        .font(.headline)
                }

                HStack {
                    Text("売却済み商品数")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(soldCount)個")
                        .font(.headline)
                }

                HStack {
                    Text("売却率")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.1f%%", soldRate))
                        .font(.headline)
                }

                if soldCount > 0 {
                    HStack {
                        Text("利益が出た商品")
                            .font(.body)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(profitableCount)個")
                            .font(.headline)
                            .foregroundStyle(.green)
                    }
                }
            }
            .cardStyle()
        }
        .padding(.horizontal)
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [WishlistItem.self, Category.self, Item.self])
}
