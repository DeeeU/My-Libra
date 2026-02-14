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
    @Environment(PlanManager.self) private var planManager
    @Query private var allItems: [Item]
    @State private var viewModel = StatisticsViewModel()
    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    periodPicker

                    summarySection

                    let catData = viewModel.categoryData(from: allItems)
                    if !catData.isEmpty {
                        categoryPieChartSection(catData)
                    }

                    let monthly = viewModel.monthlyData(from: allItems)
                    if !monthly.isEmpty {
                        monthlyPurchaseChartSection(monthly)
                    }

                    let monthlyWithSales = viewModel.monthlyDataWithSales(from: allItems)
                    if !monthlyWithSales.isEmpty {
                        monthlyProfitChartSection(monthlyWithSales)
                    }

                    if viewModel.filteredItems(from: allItems).isEmpty {
                        emptyStateView
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("統計")
            .overlay {
                if !planManager.canAccess(.statistics) {
                    statisticsLockOverlay
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }

    // MARK: - Lock Overlay

    private var statisticsLockOverlay: some View {
        ZStack {
            Color(.systemBackground).opacity(0.95)
            VStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                Text("統計機能はPro限定です")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text("Proプランで詳細な統計分析をご利用いただけます")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                Button {
                    showingPaywall = true
                } label: {
                    Text("Pro にアップグレード")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .ignoresSafeArea()
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(StatsPeriod.allCases) { period in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedPeriod = period
                        }
                    } label: {
                        Text(period.rawValue)
                            .font(.subheadline)
                            .fontWeight(viewModel.selectedPeriod == period ? .semibold : .regular)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedPeriod == period ? Color.accentColor : Color(.systemGray5))
                            .foregroundStyle(viewModel.selectedPeriod == period ? .white : .primary)
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
            let totalPurchase = viewModel.totalPurchaseAmount(from: allItems)
            let totalSale = viewModel.totalSaleAmount(from: allItems)
            let profit = viewModel.totalProfit(from: allItems)
            let ownedCount = viewModel.ownedItemsCount(from: allItems)

            HStack(spacing: 12) {
                SummaryCard(
                    title: "総購入額",
                    value: totalPurchase.toCurrencyString(),
                    icon: "cart.fill",
                    color: .blue
                )
                SummaryCard(
                    title: "総売却額",
                    value: totalSale.toCurrencyString(),
                    icon: "yensign.circle.fill",
                    color: .green
                )
            }
            HStack(spacing: 12) {
                SummaryCard(
                    title: "純損益",
                    value: profit.toSignedCurrencyString(),
                    icon: "chart.line.uptrend.xyaxis",
                    color: profit >= 0 ? .green : .red
                )
                SummaryCard(
                    title: "保有品数",
                    value: "\(ownedCount)個",
                    icon: "shippingbox.fill",
                    color: .orange
                )
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Category Pie Chart

    private func categoryPieChartSection(_ categoryData: [CategorySpending]) -> some View {
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

            VStack(spacing: 8) {
                ForEach(categoryData) { item in
                    HStack {
                        Text(item.category)
                            .font(.subheadline)
                        Spacer()
                        Text(item.amount.toCurrencyString())
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(viewModel.categoryPercentage(item.amount, from: allItems))
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

    private func monthlyPurchaseChartSection(_ monthlyData: [MonthlyData]) -> some View {
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
                            Text(viewModel.abbreviatedCurrency(v))
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

    private func monthlyProfitChartSection(_ monthlyDataWithSales: [MonthlyData]) -> some View {
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
                            Text(viewModel.abbreviatedCurrency(v))
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
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [Item.self, Category.self])
        .environment(PlanManager.shared)
}
