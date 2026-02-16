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
    @State private var showingPINChange = false
    @State private var showingPINResetConfirm = false
    @State private var adminAuth = AdminAuthManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                overviewSection
                behaviorSection
                categoryIntelligenceSection
                financialMetricsSection
                dataHealthSection
                exportSection
                securitySection
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
        .sheet(isPresented: $showingPINChange) {
            AdminPINChangeView()
        }
        .alert("管理者PINをリセット", isPresented: $showingPINResetConfirm) {
            Button("リセット", role: .destructive) {
                adminAuth.resetPIN()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("PINがリセットされます。次回アクセス時に新しいPINの設定が必要です。")
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

    // MARK: - Security Section

    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("セキュリティ")
                .sectionHeaderStyle()

            VStack(spacing: 0) {
                Button {
                    showingPINChange = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "key.fill")
                            .font(.title3)
                            .foregroundStyle(.blue)
                            .frame(width: 28)
                        Text("管理者PINを変更")
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)

                Divider().padding(.leading, 52)

                Button {
                    showingPINResetConfirm = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title3)
                            .foregroundStyle(.red)
                            .frame(width: 28)
                        Text("PINをリセット")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
            .background(.background)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
        }
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

// MARK: - PIN Change View

struct AdminPINChangeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var adminAuth = AdminAuthManager.shared
    @State private var currentPIN = ""
    @State private var newPIN = ""
    @State private var confirmPIN = ""
    @State private var step = 0 // 0: current, 1: new, 2: confirm
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "key.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.accent)

                VStack(spacing: 8) {
                    Text(stepTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(stepSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // PIN dots
                HStack(spacing: 16) {
                    ForEach(0..<6, id: \.self) { index in
                        Circle()
                            .fill(index < currentPINInput.count ? Color.accentColor : Color(.systemGray4))
                            .frame(width: 14, height: 14)
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: currentPINInput)

                // Numpad
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                    ForEach(1...9, id: \.self) { number in
                        Button {
                            appendDigit(String(number))
                        } label: {
                            Text("\(number)")
                                .font(.title)
                                .fontWeight(.medium)
                                .frame(width: 72, height: 72)
                                .background(Color(.systemGray5))
                                .clipShape(Circle())
                        }
                    }
                    Color.clear.frame(width: 72, height: 72)
                    Button {
                        appendDigit("0")
                    } label: {
                        Text("0")
                            .font(.title)
                            .fontWeight(.medium)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                    Button {
                        deleteDigit()
                    } label: {
                        Image(systemName: "delete.backward")
                            .font(.title2)
                            .frame(width: 72, height: 72)
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Spacer()
                Spacer()
            }
            .padding(.horizontal, 40)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
    }

    private var currentPINInput: String {
        switch step {
        case 0: return currentPIN
        case 1: return newPIN
        default: return confirmPIN
        }
    }

    private var stepTitle: String {
        switch step {
        case 0: return "現在のPIN"
        case 1: return "新しいPIN"
        default: return "新しいPINを確認"
        }
    }

    private var stepSubtitle: String {
        switch step {
        case 0: return "現在の管理者PINを入力してください"
        case 1: return "新しい6桁のPINを入力してください"
        default: return "確認のため同じPINを入力してください"
        }
    }

    private func appendDigit(_ digit: String) {
        errorMessage = nil
        switch step {
        case 0:
            currentPIN += digit
            if currentPIN.count == 6 { verifyCurrentPIN() }
        case 1:
            newPIN += digit
            if newPIN.count == 6 { withAnimation { step = 2 } }
        default:
            confirmPIN += digit
            if confirmPIN.count == 6 { commitChange() }
        }
    }

    private func deleteDigit() {
        errorMessage = nil
        switch step {
        case 0: if !currentPIN.isEmpty { currentPIN.removeLast() }
        case 1: if !newPIN.isEmpty { newPIN.removeLast() }
        default: if !confirmPIN.isEmpty { confirmPIN.removeLast() }
        }
    }

    private func verifyCurrentPIN() {
        if adminAuth.authenticate(pin: currentPIN) {
            withAnimation { step = 1 }
        } else {
            withAnimation {
                errorMessage = "PINが正しくありません"
                currentPIN = ""
            }
        }
    }

    private func commitChange() {
        if newPIN == confirmPIN {
            if adminAuth.setupPIN(newPIN) {
                dismiss()
            } else {
                withAnimation {
                    errorMessage = "PINの保存に失敗しました"
                    newPIN = ""
                    confirmPIN = ""
                    step = 1
                }
            }
        } else {
            withAnimation {
                errorMessage = "PINが一致しません。やり直してください"
                newPIN = ""
                confirmPIN = ""
                step = 1
            }
        }
    }
}

#Preview {
    NavigationStack {
        AdminDashboardView()
    }
    .modelContainer(for: [Item.self, WishlistItem.self, Category.self])
}
