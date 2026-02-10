//
//  OwnedItemsView.swift
//  My-Libra
//
//  Created by Claude Code on 2025/11/04.
//

import SwiftUI
import SwiftData

struct OwnedItemsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.purchaseDate, order: .reverse) private var allItems: [Item]
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    @State private var searchText = ""
    @State private var selectedCategory: String = "すべて"
    @State private var selectedStatus: ItemStatus? = nil
    @State private var sortOption: SortOption = .dateDesc
    @State private var showingSortMenu = false

    enum SortOption: String, CaseIterable {
        case dateDesc = "購入日（新しい順）"
        case dateAsc = "購入日（古い順）"
        case priceDesc = "価格（高い順）"
        case priceAsc = "価格（安い順）"
        case name = "名前順"
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
                                isSelected: selectedCategory == "すべて"
                            ) {
                                selectedCategory = "すべて"
                            }

                            ForEach(categories) { category in
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

                // ステータスフィルター
                HStack(spacing: 8) {
                    StatusFilterButton(title: "全て", isSelected: selectedStatus == nil) {
                        selectedStatus = nil
                    }
                    StatusFilterButton(title: "保有中", isSelected: selectedStatus == .owned) {
                        selectedStatus = .owned
                    }
                    StatusFilterButton(title: "売却済み", isSelected: selectedStatus == .sold) {
                        selectedStatus = .sold
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 4)

                // リスト表示
                if filteredItems.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "アイテムがありません" : "該当するアイテムがありません",
                        systemImage: searchText.isEmpty ? "shippingbox" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "買い物リストから商品を購入済みにすると、ここに表示されます" : "検索条件を変更してください")
                    )
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            NavigationLink(value: item) {
                                OwnedItemRow(item: item)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteItem(item)
                                } label: {
                                    Label("削除", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("保有品")
            .searchable(text: $searchText, prompt: "商品名で検索")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button {
                                sortOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
            .navigationDestination(for: Item.self) { item in
                ItemDetailView(item: item)
            }
        }
    }

    // MARK: - Computed Properties

    private var filteredItems: [Item] {
        let filtered = allItems.filter { item in
            // ステータスフィルター
            if let status = selectedStatus, item.status != status {
                return false
            }

            // カテゴリーフィルター
            let categoryMatch = selectedCategory == "すべて" || item.category == selectedCategory

            // 検索フィルター
            let searchMatch = searchText.isEmpty || item.name.localizedCaseInsensitiveContains(searchText)

            return categoryMatch && searchMatch
        }

        return sorted(filtered)
    }

    private func sorted(_ items: [Item]) -> [Item] {
        switch sortOption {
        case .dateDesc:
            return items.sorted { $0.purchaseDate > $1.purchaseDate }
        case .dateAsc:
            return items.sorted { $0.purchaseDate < $1.purchaseDate }
        case .priceDesc:
            return items.sorted { $0.purchasePrice > $1.purchasePrice }
        case .priceAsc:
            return items.sorted { $0.purchasePrice < $1.purchasePrice }
        case .name:
            return items.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        }
    }

    // MARK: - Actions

    private func deleteItem(_ item: Item) {
        modelContext.delete(item)
        try? modelContext.save()
    }
}

// MARK: - Status Filter Button

struct StatusFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
                .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                .cornerRadius(8)
        }
    }
}

// MARK: - Owned Item Row

struct OwnedItemRow: View {
    let item: Item

    var body: some View {
        HStack(spacing: 12) {
            // サムネイル
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 56, height: 56)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    StatusBadge(status: item.status)
                }

                HStack {
                    Label(item.category, systemImage: "tag")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(item.purchasePrice.toCurrencyString())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }

                HStack {
                    Text(item.condition.description)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(item.purchaseDate.toShortDateString())
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                if item.status == .sold, let profit = item.profit {
                    HStack {
                        Text("損益:")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(profit.toSignedCurrencyString())
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.profitLoss(for: profit))
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: ItemStatus

    var body: some View {
        Text(status.description)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(status == .owned ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
            .foregroundStyle(status == .owned ? .green : .orange)
            .cornerRadius(4)
    }
}

#Preview {
    OwnedItemsView()
        .modelContainer(for: [Item.self, Category.self])
}
