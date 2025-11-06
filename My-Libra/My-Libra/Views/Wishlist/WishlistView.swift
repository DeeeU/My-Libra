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
    @Query(sort: \WishlistItem.createdAt, order: .reverse)
    private var allWishlistItems: [WishlistItem]

    @Query private var categories: [Category]

    @State private var searchText: String = ""
    @State private var selectedCategory: String? = nil
    @State private var showAddSheet: Bool = false
    @State private var selectedItemForPurchase: WishlistItem?

    var filteredItems: [WishlistItem] {
        var items = allWishlistItems

        // カテゴリーフィルター
        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }

        // 検索フィルター
        if !searchText.isEmpty {
            items = items.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        return items
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // カテゴリーフィルター
                if !categories.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(
                                title: "すべて",
                                isSelected: selectedCategory == nil
                            ) {
                                selectedCategory = nil
                            }

                            ForEach(categories) { category in
                                FilterChip(
                                    title: category.name,
                                    isSelected: selectedCategory == category.name
                                ) {
                                    selectedCategory = category.name
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .background(Color(UIColor.systemBackground))
                }

                // リスト表示
                if filteredItems.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "買い物リストが空です" : "該当する商品が見つかりません",
                        systemImage: searchText.isEmpty ? "list.bullet" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "欲しい商品を追加してみましょう" : "別のキーワードで検索してください")
                    )
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            WishlistItemRow(item: item)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        deleteItem(item)
                                    } label: {
                                        Label("削除", systemImage: "trash")
                                    }

                                    Button {
                                        selectedItemForPurchase = item
                                    } label: {
                                        Label("購入", systemImage: "cart")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("買い物リスト")
            .searchable(text: $searchText, prompt: "商品名で検索")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddWishlistItemView()
            }
            .sheet(item: $selectedItemForPurchase) { item in
                PurchaseDetailView(wishlistItem: item)
            }
        }
    }

    private func deleteItem(_ item: WishlistItem) {
        modelContext.delete(item)
        try? modelContext.save()
    }
}

// MARK: - WishlistItemRow

struct WishlistItemRow: View {
    let item: WishlistItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.name)
                    .font(.headline)

                Spacer()

                if let price = item.estimatedPrice {
                    Text(price.toCurrencyString())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Text(item.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(6)

                Spacer()

                Text(item.createdAt.toShortDateString())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let memo = item.memo {
                Text(memo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - FilterChip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(UIColor.secondarySystemBackground))
                .foregroundStyle(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

#Preview {
    WishlistView()
        .modelContainer(for: [WishlistItem.self, Category.self, Item.self])
}
