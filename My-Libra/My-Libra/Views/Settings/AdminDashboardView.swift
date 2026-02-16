//
//  AdminDashboardView.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/16.
//

import SwiftUI
import SwiftData
import Charts

struct AdminDashboardView: View {
    @Query private var allItems: [Item]
    @Query private var allWishlistItems: [WishlistItem]
    @State private var viewModel = AdminDashboardViewModel()
    @State private var showingExportShare = false
    @State private var exportFileURL: URL?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                overviewSection
                behaviorSection
                categoryIntelligenceSection
                financialMetricsSection
                dataHealthSection
                exportSection
            }
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("管理ダッシュボード")
        .sheet(isPresented: $showingExportShare) {
            if let url = exportFileURL {
                ShareSheet(activityItems: [url])
            }
        }
    }

    // MARK: - Overview Section

    private var overviewSection: some View {
        VStack(spacing: 12) {
            let avgPerMonth = viewModel.averagePurchasesPerMonth(from: allItems)
            let roi = viewModel.overallROI(from: allItems)
            let healthMetrics = viewModel.dataHealthMetrics(items: allItems, wishlistItems: allWishlistItems)
            let photoMetric = healthMetrics.first { $0.label == "写真添付率" }

            HStack(spacing: 12) {
                SummaryCard(
                    title: "総アイテム数",
                    value: "\(allItems.count + allWishlistItems.count)件",
                    icon: "archivebox.fill",
                    color: .blue
                )
                SummaryCard(
                    title: "月平均購入数",
                    value: String(format: "%.1f件", avgPerMonth),
                    icon: "calendar.badge.clock",
                    color: .orange
                )
            }
            HStack(spacing: 12) {
                SummaryCard(
                    title: "総合ROI",
                    value: String(format: "%.1f%%", roi),
                    icon: "chart.line.uptrend.xyaxis",
                    color: roi >= 0 ? .green : .red
                )
                SummaryCard(
                    title: "データ完全率",
                    value: photoMetric?.value ?? "0%",
                    icon: "checkmark.seal.fill",
                    color: .purple
                )
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Behavior Section

    private var behaviorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("行動分析")
                .sectionHeaderStyle()

            // 曜日別購入チャート
            let dayData = viewModel.purchasesByDayOfWeek(from: allItems)
            if !allItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("曜日別購入数")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal)

                    Chart(dayData) { data in
                        BarMark(
                            x: .value("曜日", data.dayLabel),
                            y: .value("件数", data.purchaseCount)
                        )
                        .foregroundStyle(Color.blue.gradient)
                        .cornerRadius(4)
                    }
                    .frame(height: 180)
                    .padding()
                    .background(.background)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                }
            }

            // 行動指標
            VStack(spacing: 0) {
                let avgDays = viewModel.averageWishlistToPurchaseDays(items: allItems, wishlistItems: allWishlistItems)
                let avgPerMonth = viewModel.averagePurchasesPerMonth(from: allItems)

                metricRow(
                    icon: "clock.fill",
                    label: "ウィッシュリスト→購入 平均日数",
                    value: avgDays.map { String(format: "%.1f日", $0) } ?? "データ不足"
                )

                Divider().padding(.leading, 44)

                metricRow(
                    icon: "bag.fill",
                    label: "月平均購入数",
                    value: String(format: "%.1f件", avgPerMonth)
                )
            }
            .background(.background)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            .padding(.horizontal)

            // ウィッシュリスト転換率
            let conversionData = viewModel.wishlistConversionByCategory(from: allWishlistItems)
            if !conversionData.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ウィッシュリスト転換率")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal)

                    VStack(spacing: 0) {
                        ForEach(Array(conversionData.enumerated()), id: \.element.id) { index, data in
                            HStack {
                                Text(data.category)
                                    .font(.subheadline)
                                Spacer()
                                Text("\(data.purchasedCount)/\(data.totalCount)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(String(format: "%.0f%%", data.conversionRate))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .frame(width: 50, alignment: .trailing)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)

                            if index < conversionData.count - 1 {
                                Divider().padding(.leading)
                            }
                        }
                    }
                    .background(.background)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Category Intelligence Section

    private var categoryIntelligenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カテゴリー分析")
                .sectionHeaderStyle()

            let categoryData = viewModel.categoryProfitAnalysis(from: allItems)

            if !categoryData.isEmpty {
                // カテゴリー別ROIチャート
                VStack(alignment: .leading, spacing: 8) {
                    Text("カテゴリー別ROI")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal)

                    Chart(categoryData) { data in
                        BarMark(
                            x: .value("ROI", data.roi),
                            y: .value("カテゴリー", data.category)
                        )
                        .foregroundStyle(data.roi >= 0 ? Color.green.gradient : Color.red.gradient)
                        .cornerRadius(4)
                    }
                    .chartXAxis {
                        AxisMarks { value in
                            AxisGridLine()
                            AxisValueLabel {
                                if let v = value.as(Double.self) {
                                    Text(String(format: "%.0f%%", v))
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                    .frame(height: CGFloat(max(categoryData.count * 40, 120)))
                    .padding()
                    .background(.background)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                }

                // カテゴリー別詳細リスト
                VStack(spacing: 0) {
                    ForEach(Array(categoryData.enumerated()), id: \.element.id) { index, data in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(data.category)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(data.itemCount)件")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("購入: \(data.totalPurchase.toCurrencyString())")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("損益: \(data.profit.toSignedCurrencyString())")
                                        .font(.caption)
                                        .foregroundStyle(Color.profitLoss(for: data.profit))
                                }
                            }
                            if data.soldCount > 0 {
                                Text("ROI: \(String(format: "%.1f%%", data.roi)) / 売却: \(data.soldCount)件")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)

                        if index < categoryData.count - 1 {
                            Divider().padding(.leading)
                        }
                    }
                }
                .background(.background)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                .padding(.horizontal)
            }

            // 価格帯分布
            let priceData = viewModel.priceRangeDistribution(from: allItems)
            if !allItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("価格帯分布")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal)

                    Chart(priceData) { data in
                        BarMark(
                            x: .value("価格帯", data.range),
                            y: .value("件数", data.count)
                        )
                        .foregroundStyle(Color.orange.gradient)
                        .cornerRadius(4)
                    }
                    .frame(height: 180)
                    .padding()
                    .background(.background)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                }
            }

            if categoryData.isEmpty && allItems.isEmpty {
                emptyStateView(message: "カテゴリーデータがありません")
            }
        }
    }

    // MARK: - Financial Metrics Section

    private var financialMetricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("財務指標")
                .sectionHeaderStyle()

            // 平均保有期間
            let holdingPeriod = viewModel.averageHoldingPeriod(from: allItems)
            VStack(spacing: 0) {
                metricRow(
                    icon: "hourglass",
                    label: "平均保有期間（売却済み）",
                    value: holdingPeriod.map { String(format: "%.0f日", $0) } ?? "データ不足"
                )
            }
            .background(.background)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            .padding(.horizontal)

            // 高額アイテム TOP10
            let highValue = viewModel.highValueItems(from: allItems)
            if !highValue.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("高額アイテム TOP\(highValue.count)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal)

                    VStack(spacing: 0) {
                        ForEach(Array(highValue.enumerated()), id: \.element.id) { index, item in
                            HStack {
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24)
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                    Text(item.category)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(item.purchasePrice.toCurrencyString())
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)

                            if index < highValue.count - 1 {
                                Divider().padding(.leading, 44)
                            }
                        }
                    }
                    .background(.background)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                }
            }

            // 利益 TOP10
            let profitable = viewModel.mostProfitableItems(from: allItems)
            if !profitable.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("利益 TOP\(profitable.count)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal)

                    VStack(spacing: 0) {
                        ForEach(Array(profitable.enumerated()), id: \.element.id) { index, item in
                            HStack {
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24)
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                    Text(item.category)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if let profit = item.profit {
                                    Text(profit.toSignedCurrencyString())
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color.profitLoss(for: profit))
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)

                            if index < profitable.count - 1 {
                                Divider().padding(.leading, 44)
                            }
                        }
                    }
                    .background(.background)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                }
            }

            if allItems.isEmpty {
                emptyStateView(message: "アイテムデータがありません")
            }
        }
    }

    // MARK: - Data Health Section

    private var dataHealthSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("データヘルス")
                .sectionHeaderStyle()

            let metrics = viewModel.dataHealthMetrics(items: allItems, wishlistItems: allWishlistItems)

            VStack(spacing: 0) {
                ForEach(Array(metrics.enumerated()), id: \.element.id) { index, metric in
                    HStack(spacing: 12) {
                        Image(systemName: metric.icon)
                            .font(.title3)
                            .foregroundStyle(metric.color)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(metric.label)
                                .font(.subheadline)
                            if let percentage = metric.percentage {
                                ProgressView(value: percentage, total: 100)
                                    .tint(metric.color)
                            }
                        }

                        Spacer()

                        Text(metric.value)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)

                    if index < metrics.count - 1 {
                        Divider().padding(.leading, 52)
                    }
                }
            }
            .background(.background)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
        }
    }

    // MARK: - Export Section

    private var exportSection: some View {
        VStack(spacing: 12) {
            Button {
                let report = viewModel.generateAdminReport(items: allItems, wishlistItems: allWishlistItems)
                let dateString = Date().toShortDateString().replacingOccurrences(of: "/", with: "-")
                let fileName = "admin-report-\(dateString).csv"
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                do {
                    try report.write(to: tempURL, atomically: true, encoding: .utf8)
                    exportFileURL = tempURL
                    showingExportShare = true
                } catch {
                    print("レポートエクスポートエラー: \(error)")
                }
            } label: {
                Label("管理レポートをエクスポート", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .primaryButtonStyle()
            .padding(.horizontal)
        }
    }

    // MARK: - Helper Views

    private func metricRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 28)
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    private func emptyStateView(message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis.ascending")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    NavigationStack {
        AdminDashboardView()
    }
    .modelContainer(for: [Item.self, WishlistItem.self, Category.self])
}
