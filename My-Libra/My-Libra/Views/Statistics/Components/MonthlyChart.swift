//
//  MonthlyChart.swift
//  My-Libra
//
//  Created by Claude on 2025/11/06.
//

import SwiftUI
import SwiftData
import Charts

struct MonthlyData: Identifiable {
    let id = UUID()
    let month: String
    let date: Date
    let purchaseAmount: Decimal
    let saleAmount: Decimal
    let profit: Decimal

    var purchaseDouble: Double {
        NSDecimalNumber(decimal: purchaseAmount).doubleValue
    }

    var saleDouble: Double {
        NSDecimalNumber(decimal: saleAmount).doubleValue
    }

    var profitDouble: Double {
        NSDecimalNumber(decimal: profit).doubleValue
    }
}

struct MonthlyChart: View {
    let items: [Item]

    var monthlyData: [MonthlyData] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: items) { item in
            calendar.dateComponents([.year, .month], from: item.purchaseDate)
        }

        return grouped.compactMap { components, items in
            guard let year = components.year,
                  let month = components.month,
                  let date = calendar.date(from: components) else {
                return nil
            }

            let purchaseAmount = items.reduce(0) { $0 + $1.purchasePrice }

            let soldItems = items.filter { $0.status == .sold }
            let saleAmount = soldItems.compactMap { $0.salePrice }.reduce(0, +)
            let soldPurchaseAmount = soldItems.reduce(0) { $0 + $1.purchasePrice }
            let profit = saleAmount - soldPurchaseAmount

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月"
            let monthString = formatter.string(from: date)

            return MonthlyData(
                month: monthString,
                date: date,
                purchaseAmount: purchaseAmount,
                saleAmount: saleAmount,
                profit: profit
            )
        }
        .sorted { $0.date < $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("月別推移")
                .font(.headline)
                .padding(.horizontal)

            if monthlyData.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("データがありません")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 24) {
                    // 購入額の棒グラフ
                    VStack(alignment: .leading, spacing: 8) {
                        Text("月別購入額")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        Chart(monthlyData) { data in
                            BarMark(
                                x: .value("月", data.month),
                                y: .value("購入額", data.purchaseDouble)
                            )
                            .foregroundStyle(.blue)
                        }
                        .frame(height: 200)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisValueLabel()
                                    .font(.caption2)
                            }
                        }
                        .chartYAxis {
                            AxisMarks { value in
                                AxisGridLine()
                                AxisValueLabel {
                                    if let intValue = value.as(Double.self) {
                                        Text("¥\(Int(intValue / 1000))k")
                                            .font(.caption2)
                                    }
                                }
                            }
                        }
                    }

                    // 損益の折れ線グラフ
                    VStack(alignment: .leading, spacing: 8) {
                        Text("月別損益")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        Chart(monthlyData) { data in
                            LineMark(
                                x: .value("月", data.month),
                                y: .value("損益", data.profitDouble)
                            )
                            .foregroundStyle(data.profit >= 0 ? .green : .red)
                            .interpolationMethod(.catmullRom)

                            PointMark(
                                x: .value("月", data.month),
                                y: .value("損益", data.profitDouble)
                            )
                            .foregroundStyle(data.profit >= 0 ? .green : .red)

                            RuleMark(y: .value("基準線", 0))
                                .foregroundStyle(.secondary)
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        }
                        .frame(height: 200)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisValueLabel()
                                    .font(.caption2)
                            }
                        }
                        .chartYAxis {
                            AxisMarks { value in
                                AxisGridLine()
                                AxisValueLabel {
                                    if let intValue = value.as(Double.self) {
                                        Text("¥\(Int(intValue / 1000))k")
                                            .font(.caption2)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .cardStyle()
        .padding(.horizontal)
    }
}

#Preview {
    let container = try! ModelContainer(for: WishlistItem.self, Category.self, Item.self)
    let context = container.mainContext

    let calendar = Calendar.current
    let now = Date()

    // 3ヶ月分のサンプルデータ
    for i in 0..<3 {
        let date = calendar.date(byAdding: .month, value: -i, to: now)!

        let item1 = Item(name: "商品\(i)-1", category: "カードゲーム", purchasePrice: Decimal(5000 + i * 1000), purchaseDate: date, condition: .used)
        let item2 = Item(name: "商品\(i)-2", category: "靴", purchasePrice: Decimal(10000 + i * 2000), purchaseDate: date, condition: .new)

        if i > 0 {
            item1.markAsSold(salePrice: Decimal(6000 + i * 1000), saleDate: date)
        }

        context.insert(item1)
        context.insert(item2)
    }

    let allItems = try! context.fetch(FetchDescriptor<Item>())

    ScrollView {
        MonthlyChart(items: allItems)
    }
    .modelContainer(container)
}
