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

    @State private var viewModel = WishlistViewModel()
    @State private var showingAddSheet = false
    @State private var itemToPurchase: WishlistItem?
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastStyle: ToastStyle = .success

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // カテゴリーフィルター
                if !categories.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(
                                title: "すべて",
                                isSelected: viewModel.selectedCategory == "すべて"
                            ) {
                                viewModel.selectedCategory = "すべて"
                            }

                            ForEach(categories.sorted(by: { $0.sortOrder < $1.sortOrder })) { category in
                                FilterChip(
                                    title: category.name,
                                    icon: category.iconName,
                                    isSelected: viewModel.selectedCategory == category.name
                                ) {
                                    viewModel.selectedCategory = category.name
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .background(Color(.systemBackground))
                }

                // リスト表示
                let filtered = viewModel.filteredItems(from: allWishlistItems)
                if filtered.isEmpty {
                    ContentUnavailableView(
                        viewModel.searchText.isEmpty ? "買い物リストが空です" : "該当する商品がありません",
                        systemImage: viewModel.searchText.isEmpty ? "cart" : "magnifyingglass",
                        description: Text(viewModel.searchText.isEmpty ? "右上の「+」ボタンから商品を追加できます" : "検索条件を変更してください")
                    )
                } else {
                    List {
                        ForEach(filtered) { item in
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
            .searchable(text: $viewModel.searchText, prompt: "商品名で検索")
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
            .toast(isPresented: $showToast, message: toastMessage, style: toastStyle)
        }
    }

    // MARK: - Actions

    private func deleteItem(_ item: WishlistItem) {
        withAnimation {
            modelContext.delete(item)
            do {
                try modelContext.save()
            } catch {
                toastMessage = "削除に失敗しました"
                toastStyle = .error
                showToast = true
            }
        }
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
        .accessibilityElement(children: .combine)
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
        .accessibilityLabel("\(title)カテゴリー")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    WishlistView()
        .modelContainer(for: [WishlistItem.self, Category.self])
}
