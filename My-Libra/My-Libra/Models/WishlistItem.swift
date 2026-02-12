//
//  WishlistItem.swift
//  My-Libra
//
//  Created by kanabuchi on 2025/10/22.
//

import Foundation
import SwiftData

/// 買い物リストアイテム
@Model
final class WishlistItem {
    var id: UUID
    var name: String
    var category: String
    var estimatedPrice: Double?
    var memo: String?
    var createdAt: Date
    var isPurchased: Bool

    // 同期用フィールド
    var userId: String?
    var syncStatus: SyncStatus
    var localUpdatedAt: Date
    var remoteUpdatedAt: Date?

    init(name: String, category: String, estimatedPrice: Double? = nil, memo: String? = nil) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.estimatedPrice = estimatedPrice
        self.memo = memo
        self.createdAt = Date()
        self.isPurchased = false
        self.userId = nil
        self.syncStatus = .local
        self.localUpdatedAt = Date()
        self.remoteUpdatedAt = nil
    }
}
