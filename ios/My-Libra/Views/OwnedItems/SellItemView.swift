//
//  SellItemView.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/10.
//

import SwiftUI
import SwiftData

struct SellItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var item: Item

    @State private var salePriceString: String = ""
    @State private var saleDate: Date = Date()

    @FocusState private var priceFieldFocused: Bool

    private var salePrice: Double? {
        Double(salePriceString)
    }

    private var profitPreview: Double? {
        guard let price = salePrice else { return nil }
        return price - item.purchasePrice
    }

    private var isValid: Bool {
        salePrice != nil && salePrice! > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                // アイテム情報（読み取り専用）
                Section {
                    HStack {
                        Text("商品名")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(item.name)
                    }
                    HStack {
                        Text("購入価格")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(item.purchasePrice.toCurrencyString())
                    }
                    HStack {
                        Text("購入日")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(item.purchaseDate.toShortDateString())
                    }
                } header: {
                    Text("アイテム情報")
                }

                // 売却情報
                Section {
                    HStack {
                        Text("¥")
                        TextField("売却価格", text: $salePriceString)
                            .keyboardType(.numberPad)
                            .focused($priceFieldFocused)
                    }

                    DatePicker("売却日", selection: $saleDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                } header: {
                    Text("売却情報")
                }

                // 損益プレビュー
                if let profit = profitPreview {
                    Section {
                        HStack {
                            Text("購入価格")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(item.purchasePrice.toCurrencyString())
                        }
                        HStack {
                            Text("売却価格")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text((salePrice ?? 0).toCurrencyString())
                        }
                        HStack {
                            Text("損益")
                                .fontWeight(.semibold)
                            Spacer()
                            Text(profit.toSignedCurrencyString())
                                .fontWeight(.bold)
                                .foregroundStyle(Color.profitLoss(for: profit))
                        }
                    } header: {
                        Text("損益プレビュー")
                    }
                }
            }
            .navigationTitle("売却")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("売却を確定") {
                        sell()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                priceFieldFocused = true
            }
        }
    }

    private func sell() {
        guard let price = salePrice else { return }
        item.markAsSold(salePrice: price, saleDate: saleDate)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    SellItemView(item: Item(
        name: "テストアイテム",
        category: "カードゲーム",
        purchasePrice: 5000,
        purchaseDate: Date(),
        condition: .new
    ))
    .modelContainer(for: Item.self, inMemory: true)
}
