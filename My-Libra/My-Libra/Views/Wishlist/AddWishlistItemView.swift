//
//  AddWishlistItemView.swift
//  My-Libra
//
//  Created by Claude on 2025/11/06.
//

import SwiftUI
import SwiftData

struct AddWishlistItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var categories: [Category]

    @State private var name: String = ""
    @State private var selectedCategory: Category?
    @State private var estimatedPrice: String = ""
    @State private var memo: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("基本情報") {
                    TextField("商品名", text: $name)
                        .autocorrectionDisabled()

                    Picker("カテゴリー", selection: $selectedCategory) {
                        Text("選択してください").tag(nil as Category?)
                        ForEach(categories) { category in
                            Text(category.name).tag(category as Category?)
                        }
                    }
                }

                Section("価格情報") {
                    HStack {
                        Text("¥")
                        TextField("予定価格", text: $estimatedPrice)
                            .keyboardType(.numberPad)
                    }
                }

                Section("メモ") {
                    TextEditor(text: $memo)
                        .frame(minHeight: 100)
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
                    Button("保存") {
                        saveItem()
                    }
                    .disabled(!isValid)
                }
            }
            .alert("エラー", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private var isValid: Bool {
        !name.trimmed.isEmpty && selectedCategory != nil
    }

    private func saveItem() {
        guard isValid else {
            alertMessage = "商品名とカテゴリーは必須です"
            showAlert = true
            return
        }

        let price: Decimal? = {
            guard !estimatedPrice.isEmpty else { return nil }
            return Decimal(string: estimatedPrice)
        }()

        let newItem = WishlistItem(
            name: name.trimmed,
            category: selectedCategory!.name,
            estimatedPrice: price,
            memo: memo.trimmed.nonEmpty
        )

        modelContext.insert(newItem)

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
    AddWishlistItemView()
        .modelContainer(for: [WishlistItem.self, Category.self, Item.self])
}
