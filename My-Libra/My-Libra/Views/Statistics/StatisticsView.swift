//
//  StatisticsView.swift
//  My-Libra
//
//  Created by Claude Code on 2025/11/04.
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [Item]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // サマリーカード
                    VStack(spacing: 16) {
                        SummaryCardRow(
                            title: "総購入額",
                            value: totalPurchaseAmount.toCurrencyString(),
                            icon: "cart.fill",
                            color: .blue
                        )

                        SummaryCardRow(
                            title: "総売却額",
                            value: totalSaleAmount.toCurrencyString(),
                            icon: "yensign.circle.fill",
                            color: .green
                        )

                        SummaryCardRow(
                            title: "純損益",
                            value: totalProfit.toSignedCurrencyString(),
                            icon: "chart.line.uptrend.xyaxis",
                            color: totalProfit >= 0 ? .green : .red
                        )

                        SummaryCardRow(
                            title: "保有品数",
                            value: "\(ownedItemsCount)個",
                            icon: "shippingbox.fill",
                            color: .orange
                        )
                    }
                    .padding()

                    // グラフエリア(Phase 5で実装予定)
                    VStack(alignment: .leading) {
                        Text("詳細統計")
                            .sectionHeaderStyle()
                        Text("グラフ表示はPhase 5で実装予定です")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
            }
            .navigationTitle("統計")
        }
    }

    // MARK: - Computed Properties

    private var totalPurchaseAmount: Double {
        allItems.reduce(0) { $0 + $1.purchasePrice }
    }

    private var totalSaleAmount: Double {
        allItems.compactMap { $0.salePrice }.reduce(0, +)
    }

    private var totalProfit: Double {
        allItems.compactMap { $0.profit }.reduce(0, +)
    }

    private var ownedItemsCount: Int {
        allItems.filter { $0.status == ItemStatus.owned }.count
    }
}

// MARK: - Summary Card Row

struct SummaryCardRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            Spacer()
        }
        .cardStyle()
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [Item.self])
}
