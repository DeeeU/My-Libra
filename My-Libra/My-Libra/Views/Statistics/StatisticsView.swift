//
//  StatisticsView.swift
//  My-Libra
//
//  Created by Claude on 2025/11/06.
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var totalPurchase: Decimal {
        items.reduce(0) { $0 + $1.purchasePrice }
    }

    var totalSale: Decimal {
        items.compactMap { $0.salePrice }.reduce(0, +)
    }

    var totalProfit: Decimal {
        totalSale - items.filter { $0.status == .sold }.reduce(0) { $0 + $1.purchasePrice }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // サマリーカード
                    VStack(spacing: 12) {
                        SummaryRow(title: "総購入額", value: totalPurchase.toCurrencyString(), color: .blue)
                        SummaryRow(title: "総売却額", value: totalSale.toCurrencyString(), color: .green)
                        SummaryRow(title: "純損益", value: totalProfit.toSignedCurrencyString(), color: Color.profitColor(for: totalProfit))
                        SummaryRow(title: "保有品数", value: "\(items.filter { $0.status == .owned }.count)個", color: .orange)
                    }
                    .cardStyle()
                    .padding()

                    if items.isEmpty {
                        ContentUnavailableView(
                            "データがありません",
                            systemImage: "chart.bar",
                            description: Text("商品を購入登録すると統計情報が表示されます")
                        )
                    }
                }
            }
            .navigationTitle("統計")
        }
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
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

#Preview {
    StatisticsView()
        .modelContainer(for: [WishlistItem.self, Category.self, Item.self])
}
