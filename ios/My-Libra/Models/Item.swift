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
    var id: UUID
    var name: String
    var category: String
    var purchasePrice: Double
    var purchaseDate: Date
    var condition: ItemCondition
    var memo: String?
    var imageData: Data?
    var status: ItemStatus
    var salePrice: Double?
    var saleDate: Date?

    // 同期用フィールド
    var userId: String?
    var syncStatus: SyncStatus
    var localUpdatedAt: Date
    var remoteUpdatedAt: Date?
    var imageUrl: String?

    /// 損益（計算プロパティ）
    var profit: Double? {
        guard let salePrice = salePrice else { return nil }
        return salePrice - purchasePrice
    }

    init(
        name: String,
        category: String,
        purchasePrice: Double,
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
        self.userId = nil
        self.syncStatus = .local
        self.localUpdatedAt = Date()
        self.remoteUpdatedAt = nil
        self.imageUrl = nil
    }

    /// 売却処理
    func markAsSold(salePrice: Double, saleDate: Date) {
        self.status = .sold
        self.salePrice = salePrice
        self.saleDate = saleDate
    }
}
