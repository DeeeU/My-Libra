//
//  OwnedItemsView.swift
//  My-Libra
//
//  Created by Claude on 2025/11/06.
//

import SwiftUI
import SwiftData

enum ItemSortOption: String, CaseIterable {
    case purchaseDateDesc = "購入日（新しい順）"
    case purchaseDateAsc = "購入日（古い順）"
    case priceDesc = "価格（高い順）"
    case priceAsc = "価格（安い順）"
    case nameAsc = "名前（あいうえお順）"
}

struct OwnedItemsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [Item]
    @Query private var categories: [Category]

    @State private var searchText: String = ""
    @State private var selectedCategory: String? = nil
    @State private var selectedStatus: ItemStatus? = .owned
    @State private var sortOption: ItemSortOption = .purchaseDateDesc

    var filteredAndSortedItems: [Item] {
        var items = allItems

        // ステータスフィルター
        if let status = selectedStatus {
            items = items.filter { $0.status == status }
        }

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

        // ソート
        switch sortOption {
        case .purchaseDateDesc:
            items.sort { $0.purchaseDate > $1.purchaseDate }
        case .purchaseDateAsc:
            items.sort { $0.purchaseDate < $1.purchaseDate }
        case .priceDesc:
            items.sort { $0.purchasePrice > $1.purchasePrice }
        case .priceAsc:
            items.sort { $0.purchasePrice < $1.purchasePrice }
        case .nameAsc:
            items.sort { $0.name < $1.name }
        }

        return items
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // フィルターバー
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // ステータスフィルター
                        Menu {
                            Button("すべて") {
                                selectedStatus = nil
                            }
                            ForEach(ItemStatus.allCases, id: \.self) { status in
                                Button(status.description) {
                                    selectedStatus = status
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedStatus?.description ?? "すべて")
                                Image(systemName: "chevron.down")
                            }
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(16)
                        }

                        // カテゴリーフィルター
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

                // リスト表示
                if filteredAndSortedItems.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "商品がありません" : "該当する商品が見つかりません",
                        systemImage: searchText.isEmpty ? "shippingbox" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "買い物リストから商品を購入登録してみましょう" : "別のキーワードで検索してください")
                    )
                } else {
                    List {
                        ForEach(filteredAndSortedItems) { item in
                            NavigationLink(destination: ItemDetailView(item: item)) {
                                OwnedItemRow(item: item)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("保有品")
            .searchable(text: $searchText, prompt: "商品名で検索")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("並び替え", selection: $sortOption) {
                            ForEach(ItemSortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
        }
    }
}

// MARK: - OwnedItemRow

struct OwnedItemRow: View {
    let item: Item

    var body: some View {
        HStack(spacing: 12) {
            // サムネイル画像
            if let imageData = item.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.secondarySystemBackground))
                        .frame(width: 60, height: 60)

                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
            }

            // 商品情報
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(item.category)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)

                    Text(item.condition.description)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(4)
                }

                HStack {
                    Text(item.purchasePrice.toCurrencyString())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if item.status == .sold, let profit = item.profit {
                        Text("(\(profit.toSignedCurrencyString()))")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.profitColor(for: profit))
                    }
                }
            }

            Spacer()

            // ステータスバッジ
            if item.status == .sold {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("売却済み")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    OwnedItemsView()
        .modelContainer(for: [WishlistItem.self, Category.self, Item.self])
}
