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
    @Environment(PlanManager.self) private var planManager
    @Query(sort: \Item.purchaseDate, order: .reverse) private var allItems: [Item]
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    @State private var viewModel = ItemViewModel()

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

                            ForEach(categories) { category in
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

                // ステータスフィルター
                HStack(spacing: 8) {
                    StatusFilterButton(title: "全て", isSelected: viewModel.selectedStatus == nil) {
                        viewModel.selectedStatus = nil
                    }
                    StatusFilterButton(title: "保有中", isSelected: viewModel.selectedStatus == .owned) {
                        viewModel.selectedStatus = .owned
                    }
                    StatusFilterButton(title: "売却済み", isSelected: viewModel.selectedStatus == .sold) {
                        viewModel.selectedStatus = .sold
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 4)

                // リスト表示
                let filtered = viewModel.filteredItems(from: allItems)
                if filtered.isEmpty {
                    ContentUnavailableView(
                        viewModel.searchText.isEmpty ? "アイテムがありません" : "該当するアイテムがありません",
                        systemImage: viewModel.searchText.isEmpty ? "shippingbox" : "magnifyingglass",
                        description: Text(viewModel.searchText.isEmpty ? "買い物リストから商品を購入済みにすると、ここに表示されます" : "検索条件を変更してください")
                    )
                } else {
                    List {
                        ForEach(filtered) { item in
                            NavigationLink(value: item) {
                                OwnedItemRow(item: item, showProfit: planManager.canAccess(.profitDisplay))
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
            .searchable(text: $viewModel.searchText, prompt: "商品名で検索")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button {
                                viewModel.sortOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if viewModel.sortOption == option {
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

    // MARK: - Actions

    private func deleteItem(_ item: Item) {
        withAnimation {
            modelContext.delete(item)
            try? modelContext.save()
        }
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
        .accessibilityLabel("\(title)フィルター")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Owned Item Row

struct OwnedItemRow: View {
    let item: Item
    var showProfit: Bool = true

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

                if showProfit, item.status == .sold, let profit = item.profit {
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
        .accessibilityElement(children: .combine)
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
        .environment(PlanManager.shared)
}
