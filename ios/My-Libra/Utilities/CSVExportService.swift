//
//  CSVExportService.swift
//  My-Libra
//
//  Created by Claude Code on 2025/02/11.
//

import Foundation

/// CSVエクスポートサービス
enum CSVExportService {

    // MARK: - Public Methods

    /// 保有品データをCSV文字列に変換
    static func exportItems(_ items: [Item]) -> String {
        let header = itemHeader
        let rows = items.map { itemFields($0).joined(separator: ",") }
        return buildCSV(header: header, rows: rows)
    }

    /// 買い物リストデータをCSV文字列に変換
    static func exportWishlistItems(_ wishlistItems: [WishlistItem]) -> String {
        let header = wishlistHeader
        let rows = wishlistItems.map { wishlistItemFields($0).joined(separator: ",") }
        return buildCSV(header: header, rows: rows)
    }

    /// 全データをCSV文字列に変換
    static func exportAll(items: [Item], wishlistItems: [WishlistItem]) -> String {
        var lines: [String] = []

        // 保有品セクション
        lines.append(itemHeader)
        for item in items {
            lines.append(itemFields(item).joined(separator: ","))
        }

        lines.append("")

        // 買い物リストセクション
        lines.append(wishlistHeader)
        for item in wishlistItems {
            lines.append(wishlistItemFields(item).joined(separator: ","))
        }

        let bom = "\u{FEFF}"
        return bom + lines.joined(separator: "\n")
    }

    /// CSVデータを一時ファイルに書き出してURLを返す
    static func writeToTemporaryFile(csvString: String) -> URL? {
        let dateString = Date().toShortDateString().replacingOccurrences(of: "/", with: "-")
        let fileName = "my-libra-export-\(dateString).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            print("CSVファイルの書き出しエラー: \(error)")
            return nil
        }
    }

    // MARK: - Private Helpers

    private static let itemHeader = "商品名,カテゴリー,購入価格,購入日,状態,ステータス,売却価格,売却日,損益,メモ"
    private static let wishlistHeader = "商品名,カテゴリー,予定価格,作成日,購入済み,メモ"

    private static func itemFields(_ item: Item) -> [String] {
        [
            escapeCSV(item.name),
            escapeCSV(item.category),
            formatPrice(item.purchasePrice),
            item.purchaseDate.toShortDateString(),
            item.condition.rawValue,
            item.status.rawValue,
            item.salePrice.map { formatPrice($0) } ?? "",
            item.saleDate?.toShortDateString() ?? "",
            item.profit.map { formatPrice($0) } ?? "",
            escapeCSV(item.memo ?? "")
        ]
    }

    private static func wishlistItemFields(_ item: WishlistItem) -> [String] {
        [
            escapeCSV(item.name),
            escapeCSV(item.category),
            item.estimatedPrice.map { formatPrice($0) } ?? "",
            item.createdAt.toShortDateString(),
            item.isPurchased ? "はい" : "いいえ",
            escapeCSV(item.memo ?? "")
        ]
    }

    private static func formatPrice(_ value: Double) -> String {
        String(format: "%.0f", value)
    }

    private static func escapeCSV(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return value
    }

    private static func buildCSV(header: String, rows: [String]) -> String {
        let bom = "\u{FEFF}"
        return bom + ([header] + rows).joined(separator: "\n")
    }
}
