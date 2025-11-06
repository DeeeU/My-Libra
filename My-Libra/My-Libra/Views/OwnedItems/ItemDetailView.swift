//
//  ItemDetailView.swift
//  My-Libra
//
//  Created by Claude on 2025/11/06.
//

import SwiftUI
import SwiftData

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let item: Item

    @State private var showEditSheet: Bool = false
    @State private var showSellSheet: Bool = false
    @State private var showDeleteAlert: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 写真表示
                if let imageData = item.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                } else {
                    // プレースホルダー画像
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .frame(height: 300)

                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            Text("写真なし")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }

                // 基本情報セクション
                VStack(alignment: .leading, spacing: 12) {
                    Text("基本情報")
                        .sectionHeaderStyle()

                    VStack(spacing: 16) {
                        InfoRow(label: "商品名", value: item.name)
                        InfoRow(label: "カテゴリー", value: item.category)
                        InfoRow(label: "状態", value: item.condition.description)
                        InfoRow(label: "購入価格", value: item.purchasePrice.toCurrencyString())
                        InfoRow(label: "購入日", value: item.purchaseDate.toJapaneseDateString())
                        InfoRow(label: "ステータス", value: item.status.description)
                    }
                    .cardStyle()
                }
                .padding(.horizontal)

                // 売却情報セクション（売却済みの場合のみ）
                if item.status == .sold {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("売却情報")
                            .sectionHeaderStyle()

                        VStack(spacing: 16) {
                            if let salePrice = item.salePrice {
                                InfoRow(label: "売却価格", value: salePrice.toCurrencyString())
                            }
                            if let saleDate = item.saleDate {
                                InfoRow(label: "売却日", value: saleDate.toJapaneseDateString())
                            }
                            if let profit = item.profit {
                                HStack {
                                    Text("損益")
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(profit.toSignedCurrencyString())
                                        .font(.headline)
                                        .foregroundStyle(Color.profitColor(for: profit))
                                }
                            }
                        }
                        .cardStyle()
                    }
                    .padding(.horizontal)
                }

                // メモセクション
                if let memo = item.memo {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("メモ")
                            .sectionHeaderStyle()

                        Text(memo)
                            .font(.body)
                            .cardStyle()
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if item.status == .owned {
                        Button {
                            showSellSheet = true
                        } label: {
                            Label("売却", systemImage: "yensign.circle")
                        }
                    }

                    Button {
                        showEditSheet = true
                    } label: {
                        Label("編集", systemImage: "pencil")
                    }

                    Divider()

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditItemView(item: item)
        }
        .sheet(isPresented: $showSellSheet) {
            SellItemView(item: item)
        }
        .alert("削除の確認", isPresented: $showDeleteAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("削除", role: .destructive) {
                deleteItem()
            }
        } message: {
            Text("この商品を削除してもよろしいですか？")
        }
    }

    private func deleteItem() {
        modelContext.delete(item)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - InfoRow

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundStyle(.primary)
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

    return NavigationStack {
        ItemDetailView(item: sampleItem)
    }
    .modelContainer(container)
}
