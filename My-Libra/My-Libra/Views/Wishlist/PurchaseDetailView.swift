//
//  PurchaseDetailView.swift
//  My-Libra
//
//  Created by Claude on 2025/11/06.
//

import SwiftUI
import SwiftData
import PhotosUI

struct PurchaseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let wishlistItem: WishlistItem

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
                Section("商品情報") {
                    HStack {
                        Text("商品名")
                        Spacer()
                        Text(wishlistItem.name)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("カテゴリー")
                        Spacer()
                        Text(wishlistItem.category)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("購入情報") {
                    HStack {
                        Text("¥")
                        TextField("購入価格", text: $purchasePrice)
                            .keyboardType(.numberPad)
                    }

                    DatePicker("購入日", selection: $purchaseDate, displayedComponents: .date)

                    Picker("状態", selection: $condition) {
                        ForEach(ItemCondition.allCases, id: \.self) { condition in
                            Text(condition.description).tag(condition)
                        }
                    }
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
                }

                Section("メモ") {
                    TextEditor(text: $memo)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("購入登録")
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
            .alert("エラー", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                // 予定価格がある場合は購入価格の初期値として設定
                if let estimatedPrice = wishlistItem.estimatedPrice {
                    purchasePrice = "\(estimatedPrice)"
                }
                // メモがある場合は引き継ぐ
                if let wishlistMemo = wishlistItem.memo {
                    memo = wishlistMemo
                }
            }
        }
    }

    private var isValid: Bool {
        !purchasePrice.isEmpty && Decimal(string: purchasePrice) != nil
    }

    private func savePurchase() {
        guard isValid,
              let price = Decimal(string: purchasePrice) else {
            alertMessage = "購入価格を正しく入力してください"
            showAlert = true
            return
        }

        // 新しいItemを作成
        let newItem = Item(
            name: wishlistItem.name,
            category: wishlistItem.category,
            purchasePrice: price,
            purchaseDate: purchaseDate,
            condition: condition,
            memo: memo.trimmed.nonEmpty,
            imageData: selectedImageData
        )

        modelContext.insert(newItem)

        // WishlistItemを削除
        modelContext.delete(wishlistItem)

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

    // プレビュー用のサンプルデータ
    let sampleItem = WishlistItem(
        name: "ポケモンカード",
        category: "カードゲーム",
        estimatedPrice: Decimal(string: "5000"),
        memo: "欲しいカード"
    )
    context.insert(sampleItem)

    return PurchaseDetailView(wishlistItem: sampleItem)
        .modelContainer(container)
}
