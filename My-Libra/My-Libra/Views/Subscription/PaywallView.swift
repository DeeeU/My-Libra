//
//  PaywallView.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/13.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(PlanManager.self) private var planManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlan: PlanType = .yearly
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var errorMessage: String?
    @State private var showingPendingAlert = false
    @State private var showingRestoreResult = false
    @State private var restoreSucceeded = false

    enum PlanType {
        case monthly, yearly
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featureComparisonSection
                    planSelectionSection
                    purchaseButton
                    restoreAndTerms
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Pro にアップグレード")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
            .alert("エラー", isPresented: .init(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .alert("承認待ち", isPresented: $showingPendingAlert) {
                Button("OK") {}
            } message: {
                Text("購入の承認待ちです。保護者の承認後に自動的にProが有効になります。")
            }
            .alert(restoreSucceeded ? "復元完了" : "復元結果", isPresented: $showingRestoreResult) {
                Button("OK") {
                    if restoreSucceeded { dismiss() }
                }
            } message: {
                Text(restoreSucceeded
                     ? "Proプランが復元されました。"
                     : "復元できるサブスクリプションが見つかりませんでした。")
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)

            Text("My-Libra Pro")
                .font(.title)
                .fontWeight(.bold)

            Text("すべての機能をアンロック")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    // MARK: - Feature Comparison

    private var featureComparisonSection: some View {
        VStack(spacing: 0) {
            // ヘッダー行
            HStack {
                Text("機能")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Free")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(width: 70)
                Text("Pro")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.yellow)
                    .frame(width: 70)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.systemGray5))

            ForEach(ProFeature.allCases, id: \.rawValue) { feature in
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: feature.iconName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        Text(feature.displayName)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Text(feature.freeDescription)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: 70)

                    Text(feature.proDescription)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.green)
                        .frame(width: 70)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                if feature != ProFeature.allCases.last {
                    Divider().padding(.horizontal, 16)
                }
            }
        }
        .background(.background)
        .cornerRadius(12)
    }

    // MARK: - Plan Selection

    private var planSelectionSection: some View {
        VStack(spacing: 12) {
            if planManager.storeKit.productsLoadError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("商品情報を取得できませんでした")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)

                Button("再読み込み") {
                    Task { await planManager.storeKit.loadProducts() }
                }
                .font(.subheadline)
            } else {
                // 年額プラン
                planCard(
                    type: .yearly,
                    title: "年額プラン",
                    price: planManager.storeKit.yearlyProduct?.displayPrice ?? "¥1,500",
                    period: "/年",
                    badge: "17%お得",
                    isSelected: selectedPlan == .yearly
                )

                // 月額プラン
                planCard(
                    type: .monthly,
                    title: "月額プラン",
                    price: planManager.storeKit.monthlyProduct?.displayPrice ?? "¥150",
                    period: "/月",
                    badge: nil,
                    isSelected: selectedPlan == .monthly
                )
            }
        }
    }

    private func planCard(
        type: PlanType,
        title: String,
        price: String,
        period: String,
        badge: String?,
        isSelected: Bool
    ) -> some View {
        Button {
            selectedPlan = type
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.headline)
                        if let badge {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .foregroundStyle(.white)
                                .cornerRadius(4)
                        }
                    }
                    Text("7日間無料トライアル")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text(price)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(period)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Purchase Button

    private var purchaseButton: some View {
        Button {
            Task { await performPurchase() }
        } label: {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("7日間無料で試す")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(purchaseButtonDisabled ? Color.gray : Color.accentColor)
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .disabled(purchaseButtonDisabled)
    }

    private var purchaseButtonDisabled: Bool {
        isPurchasing || planManager.storeKit.products.isEmpty
    }

    // MARK: - Restore & Terms

    private var restoreAndTerms: some View {
        VStack(spacing: 12) {
            Button {
                Task { await performRestore() }
            } label: {
                if isRestoring {
                    ProgressView()
                } else {
                    Text("購入を復元")
                }
            }
            .font(.subheadline)
            .disabled(isRestoring)

            VStack(spacing: 4) {
                Text("サブスクリプションは自動更新されます。")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("無料トライアル終了後に課金が開始されます。")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("いつでもAppleの設定からキャンセルできます。")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                if let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                    Link("利用規約", destination: termsURL)
                        .font(.caption2)
                }
                if let privacyURL = URL(string: "https://github.com/DeeeU/My-Libra/blob/main/PRIVACY_POLICY.md") {
                    Link("プライバシーポリシー", destination: privacyURL)
                        .font(.caption2)
                }
            }
        }
    }

    // MARK: - Actions

    private func performPurchase() async {
        isPurchasing = true
        defer { isPurchasing = false }

        let product: Product?
        switch selectedPlan {
        case .monthly: product = planManager.storeKit.monthlyProduct
        case .yearly: product = planManager.storeKit.yearlyProduct
        }

        guard let product else {
            errorMessage = "商品情報を取得できませんでした"
            return
        }

        do {
            let result = try await planManager.purchase(product)
            switch result {
            case .success:
                dismiss()
            case .pending:
                showingPendingAlert = true
            case .userCancelled:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func performRestore() async {
        isRestoring = true
        defer { isRestoring = false }

        restoreSucceeded = await planManager.restorePurchases()
        showingRestoreResult = true
    }
}

#Preview {
    PaywallView()
        .environment(PlanManager.shared)
}
