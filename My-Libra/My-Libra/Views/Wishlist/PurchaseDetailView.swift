//
//  PurchaseDetailView.swift
//  My-Libra
//
//  Created by Claude Code on 2025/11/05.
//

import SwiftUI
import SwiftData
import PhotosUI

struct PurchaseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let wishlistItem: WishlistItem

    @State private var purchasePrice = ""
    @State private var purchaseDate = Date()
    @State private var condition: ItemCondition = .new
    @State private var memo = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case price, memo
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("商品名")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(wishlistItem.name)
                    }

                    HStack {
                        Text("カテゴリー")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(wishlistItem.category)
                    }

                    if let estimatedPrice = wishlistItem.estimatedPrice {
                        HStack {
                            Text("予定価格")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(estimatedPrice.toCurrencyString())
                                .foregroundStyle(.blue)
                        }
                    }
                } header: {
                    Text("買い物リストから")
                }

                Section {
                    HStack {
                        Text("購入価格")
                        Spacer()
                        Text("¥")
                            .foregroundStyle(.secondary)
                        TextField("0", text: $purchasePrice)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .price)
                    }

                    DatePicker("購入日", selection: $purchaseDate, displayedComponents: .date)

                    Picker("商品の状態", selection: $condition) {
                        ForEach(ItemCondition.allCases, id: \.self) { condition in
                            Text(condition.description).tag(condition)
                        }
                    }
                } header: {
                    Text("購入情報")
                }

                Section {
                    if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                        HStack {
                            Spacer()
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(8)
                            Spacer()
                        }

                        Button("写真を削除", role: .destructive) {
                            self.imageData = nil
                            selectedPhoto = nil
                        }
                    } else {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Label("写真を追加", systemImage: "photo.on.rectangle.angled")
                        }
                    }
                } header: {
                    Text("写真")
                } footer: {
                    Text("商品の写真を追加できます（任意）")
                }

                Section {
                    TextField("メモ（任意）", text: $memo, axis: .vertical)
                        .lineLimit(3...6)
                        .focused($focusedField, equals: .memo)
                } header: {
                    Text("メモ")
                } footer: {
                    if let wishlistMemo = wishlistItem.memo, !wishlistMemo.isEmpty {
                        Text("買い物リストのメモ: \(wishlistMemo)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("購入記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        savePurchase()
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
            .onAppear {
                // 予定価格を購入価格の初期値として設定
                if let estimatedPrice = wishlistItem.estimatedPrice {
                    purchasePrice = String(format: "%.0f", estimatedPrice)
                }
                // 買い物リストのメモを初期値として設定
                if let wishlistMemo = wishlistItem.memo {
                    memo = wishlistMemo
                }
                // 価格フィールドにフォーカス
                focusedField = .price
            }
        }
    }

    // MARK: - Computed Properties

    private var isValid: Bool {
        let trimmed = purchasePrice.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && Double(trimmed) != nil
    }

    // MARK: - Actions

    private func savePurchase() {
        guard let price = Double(purchasePrice.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return
        }

        let trimmedMemo = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalMemo = trimmedMemo.isEmpty ? nil : trimmedMemo

        // 新しいItemを作成
        let newItem = Item(
            name: wishlistItem.name,
            category: wishlistItem.category,
            purchasePrice: price,
            purchaseDate: purchaseDate,
            condition: condition,
            memo: finalMemo,
            imageData: imageData
        )

        modelContext.insert(newItem)

        // 買い物リストアイテムを購入済みにマーク
        wishlistItem.isPurchased = true

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("❌ 購入記録の保存エラー: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WishlistItem.self, Category.self, Item.self, configurations: config)

    let sampleItem = WishlistItem(
        name: "サンプル商品",
        category: "カードゲーム",
        estimatedPrice: 5000,
        memo: "これはテストメモです"
    )
    container.mainContext.insert(sampleItem)

    return PurchaseDetailView(wishlistItem: sampleItem)
        .modelContainer(container)
}
