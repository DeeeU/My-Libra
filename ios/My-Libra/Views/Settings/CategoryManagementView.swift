//
//  CategoryManagementView.swift
//  My-Libra
//
//  Created by Claude Code on 2025/02/11.
//

import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PlanManager.self) private var planManager
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    @State private var showingAddSheet = false
    @State private var categoryToEdit: Category?
    @State private var categoryToDelete: Category?
    @State private var showingDeleteAlert = false
    @State private var itemCountForDelete = 0
    @State private var showingPaywall = false

    var body: some View {
        List {
            // プリセットカテゴリー
            Section {
                ForEach(presetCategories) { category in
                    categoryRow(category)
                }
            } header: {
                Text("プリセット")
            }

            // カスタムカテゴリー
            Section {
                if planManager.canAccess(.customCategories) {
                    ForEach(customCategories) { category in
                        categoryRow(category)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    prepareDelete(category)
                                } label: {
                                    Label("削除", systemImage: "trash")
                                }
                            }
                            .onTapGesture {
                                categoryToEdit = category
                            }
                    }
                    .onMove(perform: moveCustomCategories)
                } else {
                    // Free: 既存カスタムカテゴリは表示のみ
                    ForEach(customCategories) { category in
                        categoryRow(category)
                    }
                    if customCategories.isEmpty {
                        UpgradePromptView(feature: .customCategories) {
                            showingPaywall = true
                        }
                        .listRowInsets(EdgeInsets())
                    }
                }
            } header: {
                HStack {
                    Text("カスタム")
                    if !planManager.canAccess(.customCategories) {
                        Spacer()
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            } footer: {
                if planManager.canAccess(.customCategories) && customCategories.isEmpty {
                    Text("右上の＋ボタンでカテゴリーを追加できます")
                }
            }
        }
        .navigationTitle("カテゴリー管理")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    if planManager.canAccess(.customCategories) {
                        showingAddSheet = true
                    } else {
                        showingPaywall = true
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
            if planManager.canAccess(.customCategories) {
                ToolbarItem(placement: .primaryAction) {
                    EditButton()
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddEditCategoryView()
        }
        .sheet(item: $categoryToEdit) { category in
            AddEditCategoryView(editingCategory: category)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .alert("カテゴリーを削除", isPresented: $showingDeleteAlert) {
            Button("削除する", role: .destructive) {
                if let category = categoryToDelete {
                    deleteCategory(category)
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            if itemCountForDelete > 0 {
                Text("このカテゴリーを使用しているアイテムが\(itemCountForDelete)件あります。削除するとカテゴリーが「その他」に変更されます。")
            } else {
                Text("「\(categoryToDelete?.name ?? "")」を削除しますか？")
            }
        }
    }

    // MARK: - Subviews

    private func categoryRow(_ category: Category) -> some View {
        HStack(spacing: 12) {
            Image(systemName: category.iconName)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 32, height: 32)

            Text(category.name)

            Spacer()

            if category.isCustom {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("プリセット")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }

    // MARK: - Constants

    private static let fallbackCategoryName = "その他"

    // MARK: - Computed Properties

    private var presetCategories: [Category] {
        categories.filter { !$0.isCustom }
    }

    private var customCategories: [Category] {
        categories.filter { $0.isCustom }
    }

    // MARK: - Actions

    private func prepareDelete(_ category: Category) {
        categoryToDelete = category

        // このカテゴリーを使用しているアイテム数を取得
        let categoryName = category.name
        let itemDescriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> { $0.category == categoryName }
        )
        let wishlistDescriptor = FetchDescriptor<WishlistItem>(
            predicate: #Predicate<WishlistItem> { $0.category == categoryName }
        )

        let itemCount = (try? modelContext.fetchCount(itemDescriptor)) ?? 0
        let wishlistCount = (try? modelContext.fetchCount(wishlistDescriptor)) ?? 0
        itemCountForDelete = itemCount + wishlistCount

        showingDeleteAlert = true
    }

    private func deleteCategory(_ category: Category) {
        let categoryName = category.name

        // 関連アイテムのカテゴリーを「その他」に変更
        let itemDescriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> { $0.category == categoryName }
        )
        if let items = try? modelContext.fetch(itemDescriptor) {
            for item in items {
                item.category = Self.fallbackCategoryName
            }
        }

        let wishlistDescriptor = FetchDescriptor<WishlistItem>(
            predicate: #Predicate<WishlistItem> { $0.category == categoryName }
        )
        if let wishlistItems = try? modelContext.fetch(wishlistDescriptor) {
            for item in wishlistItems {
                item.category = Self.fallbackCategoryName
            }
        }

        modelContext.delete(category)

        do {
            try modelContext.save()
        } catch {
            print("カテゴリーの削除エラー: \(error)")
        }
    }

    private func moveCustomCategories(from source: IndexSet, to destination: Int) {
        var customs = customCategories
        customs.move(fromOffsets: source, toOffset: destination)

        // プリセットカテゴリーの後のsortOrderを再計算
        let presetMaxOrder = presetCategories.map(\.sortOrder).max() ?? -1
        for (index, category) in customs.enumerated() {
            category.sortOrder = presetMaxOrder + 1 + index
        }

        do {
            try modelContext.save()
        } catch {
            print("カテゴリーの並び替えエラー: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        CategoryManagementView()
    }
    .modelContainer(for: [Category.self, Item.self, WishlistItem.self])
    .environment(PlanManager.shared)
}
