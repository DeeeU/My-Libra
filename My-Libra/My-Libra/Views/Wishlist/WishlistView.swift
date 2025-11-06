//
//  WishlistView.swift
//  My-Libra
//
//  Created by Claude on 2025/11/06.
//

import SwiftUI
import SwiftData

struct WishlistView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var wishlistItems: [WishlistItem]

    var body: some View {
        NavigationStack {
            List {
                if wishlistItems.isEmpty {
                    ContentUnavailableView(
                        "買い物リストが空です",
                        systemImage: "list.bullet",
                        description: Text("欲しい商品を追加してみましょう")
                    )
                } else {
                    ForEach(wishlistItems) { item in
                        Text(item.name)
                    }
                }
            }
            .navigationTitle("買い物リスト")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // TODO: 新規追加処理
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    WishlistView()
        .modelContainer(for: [WishlistItem.self, Category.self, Item.self])
}
