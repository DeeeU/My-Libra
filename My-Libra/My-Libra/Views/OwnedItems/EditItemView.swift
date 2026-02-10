//
//  EditItemView.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/10.
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    @Bindable var item: Item

    @State private var name: String
    @State private var category: String
    @State private var purchasePriceString: String
    @State private var purchaseDate: Date
    @State private var condition: ItemCondition
    @State private var memo: String
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?

    @FocusState private var focusedField: Field?

    enum Field {
        case name, price, memo
    }

    init(item: Item) {
        self.item = item
        _name = State(initialValue: item.name)
        _category = State(initialValue: item.category)
        _purchasePriceString = State(initialValue: item.purchasePrice == 0 ? "" : String(format: "%.0f", item.purchasePrice))
        _purchaseDate = State(initialValue: item.purchaseDate)
        _condition = State(initialValue: item.condition)
        _memo = State(initialValue: item.memo ?? "")
        _imageData = State(initialValue: item.imageData)
    }

    private var isValid: Bool {
        name.isNotEmpty && !category.isEmpty && purchasePriceString.isNotEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("商品名", text: $name)
                        .focused($focusedField, equals: .name)

                    Picker("カテゴリー", selection: $category) {
                        ForEach(categories) { cat in
                            Label(cat.name, systemImage: cat.iconName)
                                .tag(cat.name)
                        }
                    }
                } header: {
                    Text("基本情報")
                }

                Section {
                    HStack {
                        Text("¥")
                        TextField("購入価格", text: $purchasePriceString)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .price)
                    }

                    DatePicker("購入日", selection: $purchaseDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ja_JP"))

                    Picker("状態", selection: $condition) {
                        ForEach(ItemCondition.allCases, id: \.self) { cond in
                            Text(cond.description).tag(cond)
                        }
                    }
                } header: {
                    Text("購入情報")
                }

                Section {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        HStack {
                            if let imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                Text("写真を変更")
                                    .foregroundStyle(Color.accentColor)
                            } else {
                                Image(systemName: "photo.badge.plus")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                                Text("写真を追加")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }

                    if imageData != nil {
                        Button(role: .destructive) {
                            imageData = nil
                        } label: {
                            Label("写真を削除", systemImage: "trash")
                        }
                    }
                } header: {
                    Text("写真")
                }

                Section {
                    TextField("メモ（任意）", text: $memo, axis: .vertical)
                        .lineLimit(3...6)
                        .focused($focusedField, equals: .memo)
                } header: {
                    Text("メモ")
                }
            }
            .navigationTitle("アイテム編集")
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
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
        }
    }

    private func saveChanges() {
        item.name = name
        item.category = category
        item.purchasePrice = Double(purchasePriceString) ?? item.purchasePrice
        item.purchaseDate = purchaseDate
        item.condition = condition
        item.memo = memo.isEmpty ? nil : memo
        item.imageData = imageData
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    EditItemView(item: Item(
        name: "テスト",
        category: "カードゲーム",
        purchasePrice: 3000,
        purchaseDate: Date(),
        condition: .new
    ))
    .modelContainer(for: [Item.self, Category.self], inMemory: true)
}
