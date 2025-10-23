//
//  Item.swift
//  My-Libra
//
//  Created by kanabuchi on 2025/10/22.
//

import Foundation
import SwiftData

/// 購入済みアイテム
@Model
final class Item {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String
    var purchasePrice: Decimal
    var purchaseDate: Date
    var condition: ItemCondition
    var memo: String?
    @Attribute(.externalStorage) var imageData: Data?
    var status: ItemStatus
    var salePrice: Decimal?
    var saleDate: Date?

    /// 損益（計算プロパティ）
    var profit: Decimal? {
        guard let salePrice = salePrice else { return nil }
        return salePrice - purchasePrice
    }

    init(
        name: String,
        category: String,
        purchasePrice: Decimal,
        purchaseDate: Date,
        condition: ItemCondition,
        memo: String? = nil,
        imageData: Data? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.purchasePrice = purchasePrice
        self.purchaseDate = purchaseDate
        self.condition = condition
        self.memo = memo
        self.imageData = imageData
        self.status = .owned
        self.salePrice = nil
        self.saleDate = nil
    }

    /// 売却処理
    func markAsSold(salePrice: Decimal, saleDate: Date) {
        self.status = .sold
        self.salePrice = salePrice
        self.saleDate = saleDate
    }
}
