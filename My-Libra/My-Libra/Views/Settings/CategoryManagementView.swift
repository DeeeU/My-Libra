//
//  CategoryManagementView.swift
//  My-Libra
//
//  Created by Claude on 2025/11/06.
//

import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    @State private var showAddSheet: Bool = false
    @State private var editingCategory: Category?

    var presetCategories: [Category] {
        categories.filter { !$0.isCustom }
    }

    var customCategories: [Category] {
        categories.filter { $0.isCustom }
    }

    var body: some View {
        List {
            Section {
                ForEach(presetCategories) { category in
                    CategoryRow(category: category, isEditable: false)
                }
            } header: {
                Text("プリセットカテゴリー")
            } footer: {
                Text("プリセットカテゴリーは編集・削除できません")
            }

            Section {
                if customCategories.isEmpty {
                    Text("カスタムカテゴリーがありません")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                } else {
                    ForEach(customCategories) { category in
                        CategoryRow(category: category, isEditable: true)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteCategory(category)
                                } label: {
                                    Label("削除", systemImage: "trash")
                                }

                                Button {
                                    editingCategory = category
                                } label: {
                                    Label("編集", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                }
            } header: {
                Text("カスタムカテゴリー")
            } footer: {
                Text("カスタムカテゴリーは自由に追加・編集・削除できます")
            }
        }
        .navigationTitle("カテゴリー管理")
        .navigationBarTitleDisplayMode(.inline)
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
            AddCategoryView()
        }
        .sheet(item: $editingCategory) { category in
            EditCategoryView(category: category)
        }
    }

    private func deleteCategory(_ category: Category) {
        modelContext.delete(category)
        try? modelContext.save()
    }
}

// MARK: - CategoryRow

struct CategoryRow: View {
    let category: Category
    let isEditable: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.iconName)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)

            Text(category.name)
                .font(.body)

            Spacer()

            if !isEditable {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - AddCategoryView

struct AddCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var categories: [Category]

    @State private var name: String = ""
    @State private var selectedIconName: String = "tag.fill"
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    let iconOptions = [
        "tag.fill", "gamecontroller.fill", "figure.walk", "book.fill",
        "tv.fill", "music.note", "car.fill", "bicycle",
        "camera.fill", "paintbrush.fill", "hammer.fill", "wrench.fill",
        "cart.fill", "bag.fill", "gift.fill", "star.fill"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("カテゴリー情報") {
                    TextField("カテゴリー名", text: $name)
                        .autocorrectionDisabled()
                }

                Section("アイコン") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
                        ForEach(iconOptions, id: \.self) { iconName in
                            Button {
                                selectedIconName = iconName
                            } label: {
                                VStack {
                                    Image(systemName: iconName)
                                        .font(.title)
                                        .foregroundStyle(selectedIconName == iconName ? .white : .blue)
                                        .frame(width: 50, height: 50)
                                        .background(selectedIconName == iconName ? Color.blue : Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("カテゴリーを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveCategory()
                    }
                    .disabled(name.trimmed.isEmpty)
                }
            }
            .alert("エラー", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func saveCategory() {
        guard !name.trimmed.isEmpty else { return }

        // 重複チェック
        if categories.contains(where: { $0.name == name.trimmed }) {
            alertMessage = "同じ名前のカテゴリーが既に存在します"
            showAlert = true
            return
        }

        let nextSortOrder = (categories.map { $0.sortOrder }.max() ?? -1) + 1

        let newCategory = Category(
            name: name.trimmed,
            iconName: selectedIconName,
            isCustom: true,
            sortOrder: nextSortOrder
        )

        modelContext.insert(newCategory)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = "保存に失敗しました: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

// MARK: - EditCategoryView

struct EditCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var categories: [Category]

    let category: Category

    @State private var name: String = ""
    @State private var selectedIconName: String = "tag.fill"
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    let iconOptions = [
        "tag.fill", "gamecontroller.fill", "figure.walk", "book.fill",
        "tv.fill", "music.note", "car.fill", "bicycle",
        "camera.fill", "paintbrush.fill", "hammer.fill", "wrench.fill",
        "cart.fill", "bag.fill", "gift.fill", "star.fill"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("カテゴリー情報") {
                    TextField("カテゴリー名", text: $name)
                        .autocorrectionDisabled()
                }

                Section("アイコン") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
                        ForEach(iconOptions, id: \.self) { iconName in
                            Button {
                                selectedIconName = iconName
                            } label: {
                                VStack {
                                    Image(systemName: iconName)
                                        .font(.title)
                                        .foregroundStyle(selectedIconName == iconName ? .white : .blue)
                                        .frame(width: 50, height: 50)
                                        .background(selectedIconName == iconName ? Color.blue : Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("カテゴリーを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveChanges()
                    }
                    .disabled(name.trimmed.isEmpty)
                }
            }
            .alert("エラー", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                name = category.name
                selectedIconName = category.iconName
            }
        }
    }

    private func saveChanges() {
        guard !name.trimmed.isEmpty else { return }

        // 重複チェック（自分以外）
        if categories.contains(where: { $0.id != category.id && $0.name == name.trimmed }) {
            alertMessage = "同じ名前のカテゴリーが既に存在します"
            showAlert = true
            return
        }

        category.name = name.trimmed
        category.iconName = selectedIconName

        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = "保存に失敗しました: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

#Preview {
    NavigationStack {
        CategoryManagementView()
    }
    .modelContainer(for: [WishlistItem.self, Category.self, Item.self])
}
