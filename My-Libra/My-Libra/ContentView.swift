//
//  ContentView.swift
//  My-Libra
//
//  Created by kanabuchi on 2025/10/22.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // 買い物リスト
            WishlistView()
                .tabItem {
                    Label("買い物リスト", systemImage: "cart")
                }
                .tag(0)

            // 保有品
            OwnedItemsView()
                .tabItem {
                    Label("保有品", systemImage: "shippingbox")
                }
                .tag(1)

            // 統計
            StatisticsView()
                .tabItem {
                    Label("統計", systemImage: "chart.bar")
                }
                .tag(2)

            // 設定
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Category.self, WishlistItem.self, Item.self])
}
