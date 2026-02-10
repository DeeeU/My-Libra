//
//  ItemDetailView.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/10.
//

import SwiftUI
import SwiftData

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var item: Item

    @State private var showingEditSheet = false
    @State private var showingSellSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 写真セクション
                photoSection

                // 基本情報セクション
                basicInfoSection

                // 売却情報セクション（売却済みの場合）
                if item.status == .sold {
                    saleInfoSection
                }

                // メモセクション
                if let memo = item.memo, !memo.isEmpty {
                    memoSection(memo: memo)
                }
            }
            .padding()
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("編集", systemImage: "pencil")
                    }

                    if item.status == .owned {
                        Button {
                            showingSellSheet = true
                        } label: {
                            Label("売却", systemImage: "yensign.circle")
                        }
                    }

                    Divider()

                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditItemView(item: item)
        }
        .sheet(isPresented: $showingSellSheet) {
            SellItemView(item: item)
        }
        .alert("アイテムを削除", isPresented: $showingDeleteAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("削除", role: .destructive) {
                deleteItem()
            }
        } message: {
            Text("「\(item.name)」を削除しますか？この操作は取り消せません。")
        }
    }

    // MARK: - Sections

    private var photoSection: some View {
        Group {
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(height: 200)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                            Text("写真なし")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
            }
        }
    }

    private var basicInfoSection: some View {
        VStack(spacing: 0) {
            InfoRow(label: "カテゴリー", value: item.category, icon: "tag")
            Divider()
            InfoRow(label: "購入価格", value: item.purchasePrice.toCurrencyString(), icon: "yensign.circle")
            Divider()
            InfoRow(label: "購入日", value: item.purchaseDate.toJapaneseDateString(), icon: "calendar")
            Divider()
            InfoRow(label: "状態", value: item.condition.description, icon: "sparkles")
            Divider()
            HStack {
                Label("ステータス", systemImage: "flag")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                StatusBadge(status: item.status)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var saleInfoSection: some View {
        VStack(spacing: 0) {
            Text("売却情報")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

            if let salePrice = item.salePrice {
                InfoRow(label: "売却価格", value: salePrice.toCurrencyString(), icon: "yensign.circle.fill")
                Divider()
            }
            if let saleDate = item.saleDate {
                InfoRow(label: "売却日", value: saleDate.toJapaneseDateString(), icon: "calendar.badge.checkmark")
                Divider()
            }
            if let profit = item.profit {
                HStack {
                    Label("損益", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(profit.toSignedCurrencyString())
                        .font(.headline)
                        .foregroundStyle(Color.profitLoss(for: profit))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func memoSection(memo: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("メモ", systemImage: "note.text")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(memo)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Actions

    private func deleteItem() {
        modelContext.delete(item)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

#Preview {
    NavigationStack {
        ItemDetailView(item: Item(
            name: "テストアイテム",
            category: "カードゲーム",
            purchasePrice: 5000,
            purchaseDate: Date(),
            condition: .new,
            memo: "テストメモです"
        ))
    }
    .modelContainer(for: Item.self, inMemory: true)
}
