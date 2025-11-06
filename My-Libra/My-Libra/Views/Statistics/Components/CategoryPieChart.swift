//
//  CategoryPieChart.swift
//  My-Libra
//
//  Created by Claude on 2025/11/06.
//

import SwiftUI
import Charts

struct CategoryData: Identifiable {
    let id = UUID()
    let category: String
    let amount: Decimal
    let count: Int

    var amountDouble: Double {
        NSDecimalNumber(decimal: amount).doubleValue
    }
}

struct CategoryPieChart: View {
    let items: [Item]

    var categoryData: [CategoryData] {
        let grouped = Dictionary(grouping: items, by: { $0.category })
        return grouped.map { category, items in
            CategoryData(
                category: category,
                amount: items.reduce(0) { $0 + $1.purchasePrice },
                count: items.count
            )
        }
        .sorted { $0.amount > $1.amount }
    }

    var totalAmount: Decimal {
        categoryData.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("カテゴリー別支出")
                .font(.headline)
                .padding(.horizontal)

            if categoryData.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("データがありません")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 20) {
                    // 円グラフ
                    Chart(categoryData) { data in
                        SectorMark(
                            angle: .value("金額", data.amountDouble),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(by: .value("カテゴリー", data.category))
                    }
                    .frame(height: 250)
                    .chartLegend(position: .bottom, alignment: .leading, spacing: 12)

                    // データ詳細
                    VStack(spacing: 8) {
                        ForEach(categoryData) { data in
                            HStack {
                                Circle()
                                    .fill(colorForCategory(data.category))
                                    .frame(width: 12, height: 12)

                                Text(data.category)
                                    .font(.subheadline)

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(data.amount.toCurrencyString())
                                        .font(.subheadline)
                                        .fontWeight(.semibold)

                                    if totalAmount > 0 {
                                        let percentage = (data.amountDouble / NSDecimalNumber(decimal: totalAmount).doubleValue) * 100
                                        Text("\(Int(percentage))%")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .cardStyle()
        .padding(.horizontal)
    }

    private func colorForCategory(_ category: String) -> Color {
        let index = abs(category.hashValue) % Color.categoryColors.count
        return Color.categoryColors[index]
    }
}

#Preview {
    let container = try! ModelContainer(for: WishlistItem.self, Category.self, Item.self)
    let context = container.mainContext

    let items = [
        Item(name: "カード1", category: "カードゲーム", purchasePrice: 5000, purchaseDate: Date(), condition: .used),
        Item(name: "カード2", category: "カードゲーム", purchasePrice: 3000, purchaseDate: Date(), condition: .new),
        Item(name: "靴1", category: "靴", purchasePrice: 10000, purchaseDate: Date(), condition: .new),
        Item(name: "フィギュア1", category: "フィギュア", purchasePrice: 7000, purchaseDate: Date(), condition: .used),
    ]

    for item in items {
        context.insert(item)
    }

    return ScrollView {
        CategoryPieChart(items: items)
    }
    .modelContainer(container)
}
