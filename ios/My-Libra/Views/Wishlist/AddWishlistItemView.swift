//
//  AddWishlistItemView.swift
//  My-Libra
//
//  Created by Claude Code on 2025/11/05.
//

import SwiftUI
import SwiftData

struct AddWishlistItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var categories: [Category]

    @State private var name = ""
    @State private var selectedCategory = ""
    @State private var estimatedPrice = ""
    @State private var memo = ""
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case name, price, memo
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("商品名", text: $name)
                        .focused($focusedField, equals: .name)

                    Picker("カテゴリー", selection: $selectedCategory) {
                        Text("選択してください").tag("")
                        ForEach(sortedCategories) { category in
                            HStack {
                                Image(systemName: category.iconName)
                                Text(category.name)
                            }
                            .tag(category.name)
                        }
                    }
                } header: {
                    Text("基本情報")
                }

                Section {
                    HStack {
                        Text("¥")
                            .foregroundStyle(.secondary)
                        TextField("0", text: $estimatedPrice)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .price)
                    }
                } header: {
                    Text("価格")
                } footer: {
                    Text("予定価格は省略可能です")
                }

                Section {
                    TextField("メモ（任意）", text: $memo, axis: .vertical)
                        .lineLimit(3...6)
                        .focused($focusedField, equals: .memo)
                } header: {
                    Text("メモ")
                }
            }
            .navigationTitle("買い物リストに追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        saveItem()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                // 初回表示時にデフォルトカテゴリーを設定
                if selectedCategory.isEmpty, let firstCategory = sortedCategories.first {
                    selectedCategory = firstCategory.name
                }
                // 名前フィールドにフォーカス
                focusedField = .name
            }
        }
    }

    // MARK: - Computed Properties

    private var sortedCategories: [Category] {
        categories.sorted(by: { $0.sortOrder < $1.sortOrder })
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !selectedCategory.isEmpty
    }

    // MARK: - Actions

    private func saveItem() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        let price: Double? = {
            let trimmed = estimatedPrice.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : Double(trimmed)
        }()

        let trimmedMemo = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalMemo = trimmedMemo.isEmpty ? nil : trimmedMemo

        let newItem = WishlistItem(
            name: trimmedName,
            category: selectedCategory,
            estimatedPrice: price,
            memo: finalMemo
        )

        modelContext.insert(newItem)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("❌ 買い物リストアイテムの保存エラー: \(error)")
        }
    }
}

#Preview {
    AddWishlistItemView()
        .modelContainer(for: [WishlistItem.self, Category.self])
}
