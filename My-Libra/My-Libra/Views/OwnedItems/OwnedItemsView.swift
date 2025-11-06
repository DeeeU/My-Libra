//
//  OwnedItemsView.swift
//  My-Libra
//
//  Created by Claude on 2025/11/06.
//

import SwiftUI
import SwiftData

struct OwnedItemsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Item> { $0.status == .owned })
    private var ownedItems: [Item]

    var body: some View {
        NavigationStack {
            List {
                if ownedItems.isEmpty {
                    ContentUnavailableView(
                        "保有品がありません",
                        systemImage: "shippingbox",
                        description: Text("買い物リストから商品を購入登録してみましょう")
                    )
                } else {
                    ForEach(ownedItems) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.purchasePrice.toCurrencyString())
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(item.condition.description)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .navigationTitle("保有品")
        }
    }
}

#Preview {
    OwnedItemsView()
        .modelContainer(for: [WishlistItem.self, Category.self, Item.self])
}
