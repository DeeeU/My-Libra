//
//  SellItemView.swift
//  My-Libra
//
//  Created by Claude on 2025/11/06.
//

import SwiftUI
import SwiftData

struct SellItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let item: Item

    @State private var salePrice: String = ""
    @State private var saleDate: Date = Date()
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var estimatedProfit: Decimal? {
        guard let price = Decimal(string: salePrice) else { return nil }
        return price - item.purchasePrice
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("商品情報") {
                    HStack {
                        Text("商品名")
                        Spacer()
                        Text(item.name)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("購入価格")
                        Spacer()
                        Text(item.purchasePrice.toCurrencyString())
                            .foregroundStyle(.secondary)
                    }
                }

                Section("売却情報") {
                    HStack {
                        Text("¥")
                        TextField("売却価格", text: $salePrice)
                            .keyboardType(.numberPad)
                    }

                    DatePicker("売却日", selection: $saleDate, displayedComponents: .date)
                }

                // 損益プレビュー
                if let profit = estimatedProfit {
                    Section("損益") {
                        HStack {
                            Text("予想損益")
                                .font(.headline)
                            Spacer()
                            Text(profit.toSignedCurrencyString())
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.profitColor(for: profit))
                        }
                        .padding(.vertical, 8)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("売却価格")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                if let price = Decimal(string: salePrice) {
                                    Text(price.toCurrencyString())
                                }
                            }

                            HStack {
                                Text("購入価格")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(item.purchasePrice.toCurrencyString())
                            }

                            Divider()

                            HStack {
                                Text("差額")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(profit.toSignedCurrencyString())
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.profitColor(for: profit))
                            }
                        }
                        .font(.subheadline)
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("売却処理について", systemImage: "info.circle")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("この商品のステータスが「売却済み」に変更されます。売却後も商品情報は保持され、統計データとして利用されます。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("売却登録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("売却") {
                        sellItem()
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
        !salePrice.isEmpty && Decimal(string: salePrice) != nil
    }

    private func sellItem() {
        guard isValid,
              let price = Decimal(string: salePrice) else {
            alertMessage = "売却価格を正しく入力してください"
            showAlert = true
            return
        }

        item.markAsSold(salePrice: price, saleDate: saleDate)

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

    let sampleItem = Item(
        name: "ポケモンカード",
        category: "カードゲーム",
        purchasePrice: Decimal(string: "5000")!,
        purchaseDate: Date(),
        condition: .used,
        memo: "レアカード"
    )
    context.insert(sampleItem)

    return SellItemView(item: sampleItem)
        .modelContainer(container)
}
