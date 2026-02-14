//
//  SubscriptionManagementView.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/13.
//

import SwiftUI

struct SubscriptionManagementView: View {
    @Environment(PlanManager.self) private var planManager
    @State private var showingPaywall = false
    @State private var isRestoring = false
    @State private var showingRestoreResult = false
    @State private var restoreSucceeded = false

    var body: some View {
        List {
            Section {
                HStack {
                    Text("現在のプラン")
                    Spacer()
                    Text(currentPlanName)
                        .foregroundStyle(.secondary)
                }

                if planManager.isPro {
                    HStack {
                        Text("ステータス")
                        Spacer()
                        Text("有効")
                            .foregroundStyle(.green)
                    }
                }
            } header: {
                Text("プラン情報")
            }

            if !planManager.isPro {
                Section {
                    Button {
                        showingPaywall = true
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                            Text("Pro にアップグレード")
                        }
                    }
                }
            }

            Section {
                Button {
                    Task { await performRestore() }
                } label: {
                    HStack {
                        Text("購入を復元")
                        Spacer()
                        if isRestoring {
                            ProgressView()
                        }
                    }
                }
                .disabled(isRestoring)

                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                    Link(destination: url) {
                        HStack {
                            Text("サブスクリプションを管理")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text("管理")
            }
        }
        .navigationTitle("サブスクリプション")
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .alert(restoreSucceeded ? "復元完了" : "復元結果", isPresented: $showingRestoreResult) {
            Button("OK") {}
        } message: {
            Text(restoreSucceeded
                 ? "Proプランが復元されました。"
                 : "復元できるサブスクリプションが見つかりませんでした。")
        }
    }

    private var currentPlanName: String {
        if planManager.isPro {
            if planManager.storeKit.purchasedProductIDs.contains("com.deeu.mylibra.pro.yearly") {
                return "Pro（年額）"
            } else if planManager.storeKit.purchasedProductIDs.contains("com.deeu.mylibra.pro.monthly") {
                return "Pro（月額）"
            }
            return "Pro"
        }
        return "Free"
    }

    private func performRestore() async {
        isRestoring = true
        defer { isRestoring = false }

        restoreSucceeded = await planManager.restorePurchases()
        showingRestoreResult = true
    }
}

#Preview {
    NavigationStack {
        SubscriptionManagementView()
    }
    .environment(PlanManager.shared)
}
