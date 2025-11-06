//
//  EditItemView.swift
//  My-Libra
//
//  Created by Claude on 2025/11/06.
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var categories: [Category]

    let item: Item

    @State private var name: String = ""
    @State private var selectedCategoryName: String = ""
    @State private var purchasePrice: String = ""
    @State private var purchaseDate: Date = Date()
    @State private var condition: ItemCondition = .used
    @State private var memo: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("基本情報") {
                    TextField("商品名", text: $name)
                        .autocorrectionDisabled()

                    Picker("カテゴリー", selection: $selectedCategoryName) {
                        ForEach(categories) { category in
                            Text(category.name).tag(category.name)
                        }
                    }

                    Picker("状態", selection: $condition) {
                        ForEach(ItemCondition.allCases, id: \.self) { condition in
                            Text(condition.description).tag(condition)
                        }
                    }
                }

                Section("購入情報") {
                    HStack {
                        Text("¥")
                        TextField("購入価格", text: $purchasePrice)
                            .keyboardType(.numberPad)
                    }

                    DatePicker("購入日", selection: $purchaseDate, displayedComponents: .date)
                }

                Section("写真") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        if let imageData = selectedImageData,
                           let uiImage = UIImage(data: imageData) {
                            HStack {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                Spacer()

                                Text("写真を変更")
                                    .foregroundStyle(.blue)
                            }
                        } else {
                            Label("写真を選択", systemImage: "photo")
                        }
                    }
                    .onChange(of: selectedPhoto) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }

                    if selectedImageData != nil {
                        Button(role: .destructive) {
                            selectedImageData = nil
                            selectedPhoto = nil
                        } label: {
                            Label("写真を削除", systemImage: "trash")
                        }
                    }
                }

                Section("メモ") {
                    TextEditor(text: $memo)
                        .frame(minHeight: 100)
                }

                // 売却情報（売却済みの場合のみ表示）
                if item.status == .sold {
                    Section("売却情報") {
                        if let salePrice = item.salePrice {
                            HStack {
                                Text("売却価格")
                                Spacer()
                                Text(salePrice.toCurrencyString())
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if let saleDate = item.saleDate {
                            HStack {
                                Text("売却日")
                                Spacer()
                                Text(saleDate.toShortDateString())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("商品を編集")
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
                    .disabled(!isValid)
                }
            }
            .alert("エラー", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                loadItemData()
            }
        }
    }

    private var isValid: Bool {
        !name.trimmed.isEmpty && !purchasePrice.isEmpty && Decimal(string: purchasePrice) != nil
    }

    private func loadItemData() {
        name = item.name
        selectedCategoryName = item.category
        purchasePrice = "\(item.purchasePrice)"
        purchaseDate = item.purchaseDate
        condition = item.condition
        memo = item.memo ?? ""
        selectedImageData = item.imageData
    }

    private func saveChanges() {
        guard isValid,
              let price = Decimal(string: purchasePrice) else {
            alertMessage = "入力内容を確認してください"
            showAlert = true
            return
        }

        item.name = name.trimmed
        item.category = selectedCategoryName
        item.purchasePrice = price
        item.purchaseDate = purchaseDate
        item.condition = condition
        item.memo = memo.trimmed.nonEmpty
        item.imageData = selectedImageData

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
    let container = try! ModelContainer(for: WishlistItem.self, Category.self, Item.self)
    let context = container.mainContext

    let sampleCategory = Category(name: "カードゲーム", iconName: "gamecontroller", isCustom: false, sortOrder: 0)
    context.insert(sampleCategory)

    let sampleItem = Item(
        name: "ポケモンカード",
        category: "カードゲーム",
        purchasePrice: Decimal(string: "5000")!,
        purchaseDate: Date(),
        condition: .used,
        memo: "レアカード"
    )
    context.insert(sampleItem)

    return EditItemView(item: sampleItem)
        .modelContainer(container)
}
