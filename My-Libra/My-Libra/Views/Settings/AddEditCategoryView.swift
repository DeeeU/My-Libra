//
//  AddEditCategoryView.swift
//  My-Libra
//
//  Created by Claude Code on 2025/02/11.
//

import SwiftUI
import SwiftData

struct AddEditCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    let editingCategory: Category?

    @State private var name: String
    @State private var selectedIcon: String
    @State private var showingSymbolPicker = false
    @FocusState private var nameFieldFocused: Bool

    init(editingCategory: Category? = nil) {
        self.editingCategory = editingCategory
        _name = State(initialValue: editingCategory?.name ?? "")
        _selectedIcon = State(initialValue: editingCategory?.iconName ?? "star.fill")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("カテゴリー名", text: $name)
                        .focused($nameFieldFocused)
                } header: {
                    Text("カテゴリー名")
                }

                Section {
                    Button {
                        showingSymbolPicker = true
                    } label: {
                        HStack {
                            Image(systemName: selectedIcon)
                                .font(.title2)
                                .foregroundStyle(Color.accentColor)
                                .frame(width: 40, height: 40)
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(8)

                            Text("アイコンを選択")
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("アイコン")
                }
            }
            .navigationTitle(isEditMode ? "カテゴリーを編集" : "カテゴリーを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditMode ? "保存" : "追加") {
                        saveCategory()
                    }
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showingSymbolPicker) {
                SFSymbolPickerView(selectedIcon: $selectedIcon)
            }
            .onAppear {
                nameFieldFocused = true
            }
        }
    }

    // MARK: - Computed Properties

    private var isEditMode: Bool {
        editingCategory != nil
    }

    private var isValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }

        // 重複チェック（編集中の自分自身は除外）
        let isDuplicate = categories.contains { category in
            category.name == trimmedName && category.id != editingCategory?.id
        }
        return !isDuplicate
    }

    // MARK: - Actions

    private func saveCategory() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if let category = editingCategory {
            // 編集モード: カテゴリー名変更時はアイテムも更新
            let oldName = category.name
            category.name = trimmedName
            category.iconName = selectedIcon

            if oldName != trimmedName {
                updateItemsCategory(from: oldName, to: trimmedName)
            }
        } else {
            // 追加モード
            let maxSortOrder = categories.map(\.sortOrder).max() ?? -1
            let newCategory = Category(
                name: trimmedName,
                iconName: selectedIcon,
                isCustom: true,
                sortOrder: maxSortOrder + 1
            )
            modelContext.insert(newCategory)
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("カテゴリーの保存エラー: \(error)")
        }
    }

    private func updateItemsCategory(from oldName: String, to newName: String) {
        // Itemのカテゴリーを更新
        let itemDescriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> { $0.category == oldName }
        )
        if let items = try? modelContext.fetch(itemDescriptor) {
            for item in items {
                item.category = newName
            }
        }

        // WishlistItemのカテゴリーを更新
        let wishlistDescriptor = FetchDescriptor<WishlistItem>(
            predicate: #Predicate<WishlistItem> { $0.category == oldName }
        )
        if let wishlistItems = try? modelContext.fetch(wishlistDescriptor) {
            for item in wishlistItems {
                item.category = newName
            }
        }
    }
}

#Preview {
    AddEditCategoryView()
        .modelContainer(for: [Category.self, Item.self, WishlistItem.self])
}
