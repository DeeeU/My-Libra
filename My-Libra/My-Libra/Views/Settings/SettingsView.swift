//
//  SettingsView.swift
//  My-Libra
//
//  Created by Claude on 2025/11/06.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    @Query private var wishlistItems: [WishlistItem]
    @Query private var items: [Item]

    @State private var showExportSheet: Bool = false
    @State private var exportedCSVURL: URL?
    @State private var showDeleteAlert: Bool = false
    @State private var showExportSuccessAlert: Bool = false
    @State private var showExportErrorAlert: Bool = false
    @State private var exportError: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section("カテゴリー管理") {
                    NavigationLink {
                        CategoryManagementView()
                    } label: {
                        Label("カテゴリー編集", systemImage: "tag")
                    }

                    HStack {
                        Text("登録カテゴリー数")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(categories.count)個")
                    }
                    .font(.caption)
                }

                Section {
                    Button {
                        exportData()
                    } label: {
                        Label("データをエクスポート", systemImage: "square.and.arrow.up")
                    }

                    HStack {
                        Text("エクスポート可能データ")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(items.count)件")
                    }
                    .font(.caption)
                } header: {
                    Text("データ管理")
                } footer: {
                    Text("商品データをCSV形式でエクスポートできます")
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("全データを削除", systemImage: "trash")
                    }
                } footer: {
                    Text("全ての買い物リストと保有品データが削除されます。この操作は取り消せません。")
                }

                Section("アプリ情報") {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("ビルド")
                        Spacer()
                        Text("1")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("総データ数")
                        Spacer()
                        Text("\(wishlistItems.count + items.count)件")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
            .sheet(isPresented: $showExportSheet) {
                if let url = exportedCSVURL {
                    ActivityViewController(activityItems: [url])
                }
            }
            .alert("全データを削除", isPresented: $showDeleteAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("削除", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("全ての買い物リストと保有品データを削除します。この操作は取り消せません。よろしいですか?")
            }
            .alert("エクスポート成功", isPresented: $showExportSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("データのエクスポートが完了しました")
            }
            .alert("エクスポートエラー", isPresented: $showExportErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(exportError)
            }
        }
    }

    private func exportData() {
        guard !items.isEmpty else {
            exportError = "エクスポートするデータがありません"
            showExportErrorAlert = true
            return
        }

        do {
            let csvString = generateCSV()
            let fileName = "my-libra-export-\(Date().timeIntervalSince1970).csv"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

            try csvString.write(to: url, atomically: true, encoding: .utf8)

            exportedCSVURL = url
            showExportSheet = true
        } catch {
            exportError = "エクスポートに失敗しました: \(error.localizedDescription)"
            showExportErrorAlert = true
        }
    }

    private func generateCSV() -> String {
        var csv = "商品名,カテゴリー,購入価格,購入日,状態,ステータス,売却価格,売却日,損益,メモ\n"

        for item in items {
            let name = item.name.replacingOccurrences(of: ",", with: "、")
            let category = item.category
            let purchasePrice = "\(item.purchasePrice)"
            let purchaseDate = item.purchaseDate.toShortDateString()
            let condition = item.condition.description
            let status = item.status.description
            let salePrice = item.salePrice.map { "\($0)" } ?? ""
            let saleDate = item.saleDate?.toShortDateString() ?? ""
            let profit = item.profit.map { "\($0)" } ?? ""
            let memo = (item.memo ?? "").replacingOccurrences(of: ",", with: "、").replacingOccurrences(of: "\n", with: " ")

            csv += "\(name),\(category),\(purchasePrice),\(purchaseDate),\(condition),\(status),\(salePrice),\(saleDate),\(profit),\(memo)\n"
        }

        return csv
    }

    private func deleteAllData() {
        // 全てのWishlistItemを削除
        for item in wishlistItems {
            modelContext.delete(item)
        }

        // 全てのItemを削除
        for item in items {
            modelContext.delete(item)
        }

        try? modelContext.save()
    }
}

// MARK: - ActivityViewController (UIActivityViewController wrapper)

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [WishlistItem.self, Category.self, Item.self])
}
