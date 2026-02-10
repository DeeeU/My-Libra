//
//  WishlistView.swift
//  My-Libra
//
//  Created by Claude Code on 2025/11/04.
//

import SwiftUI
import SwiftData

struct WishlistView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WishlistItem.createdAt, order: .reverse) private var allWishlistItems: [WishlistItem]
    @Query private var categories: [Category]

    @State private var searchText = ""
    @State private var selectedCategory: String = "すべて"
    @State private var showingAddSheet = false
    @State private var itemToPurchase: WishlistItem?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // カテゴリーフィルター
                if !categories.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(
                                title: "すべて",
                                isSelected: selectedCategory == "すべて"
                            ) {
                                selectedCategory = "すべて"
                            }

                            ForEach(categories.sorted(by: { $0.sortOrder < $1.sortOrder })) { category in
                                FilterChip(
                                    title: category.name,
                                    icon: category.iconName,
                                    isSelected: selectedCategory == category.name
                                ) {
                                    selectedCategory = category.name
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .background(Color(.systemBackground))
                }

                // リスト表示
                if filteredItems.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "買い物リストが空です" : "該当する商品がありません",
                        systemImage: searchText.isEmpty ? "cart" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "右上の「+」ボタンから商品を追加できます" : "検索条件を変更してください")
                    )
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            WishlistItemRow(item: item)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteItem(item)
                                    } label: {
                                        Label("削除", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    Button {
                                        itemToPurchase = item
                                    } label: {
                                        Label("購入", systemImage: "cart.fill.badge.plus")
                                    }
                                    .tint(.green)
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("買い物リスト")
            .searchable(text: $searchText, prompt: "商品名で検索")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddWishlistItemView()
            }
            .sheet(item: $itemToPurchase) { item in
                PurchaseDetailView(wishlistItem: item)
            }
        }
    }

    // MARK: - Computed Properties

    private var filteredItems: [WishlistItem] {
        allWishlistItems.filter { item in
            // 購入済みフィルター
            guard !item.isPurchased else { return false }

            // カテゴリーフィルター
            let categoryMatch = selectedCategory == "すべて" || item.category == selectedCategory

            // 検索フィルター
            let searchMatch = searchText.isEmpty || item.name.localizedCaseInsensitiveContains(searchText)

            return categoryMatch && searchMatch
        }
    }

    // MARK: - Actions

    private func deleteItem(_ item: WishlistItem) {
        modelContext.delete(item)
        try? modelContext.save()
    }
}

// MARK: - Wishlist Item Row

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
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
            }

            HStack {
                Label(item.category, systemImage: "tag")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(item.createdAt.toShortDateString())
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if let memo = item.memo, !memo.isEmpty {
                Text(memo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .foregroundStyle(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

#Preview {
    WishlistView()
        .modelContainer(for: [WishlistItem.self, Category.self])
}
