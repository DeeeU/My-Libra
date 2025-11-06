//
//  ContentView.swift
//  My-Libra
//
//  Created by kanabuchi on 2025/10/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            WishlistView()
                .tabItem {
                    Label("買い物リスト", systemImage: "list.bullet")
                }

            OwnedItemsView()
                .tabItem {
                    Label("保有品", systemImage: "shippingbox")
                }

            StatisticsView()
                .tabItem {
                    Label("統計", systemImage: "chart.bar")
                }

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [WishlistItem.self, Category.self, Item.self])
}
