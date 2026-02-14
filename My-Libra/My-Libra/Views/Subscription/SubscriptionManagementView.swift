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
                Button("購入を復元") {
                    Task { await planManager.restorePurchases() }
                }

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
}

#Preview {
    NavigationStack {
        SubscriptionManagementView()
    }
    .environment(PlanManager.shared)
}
