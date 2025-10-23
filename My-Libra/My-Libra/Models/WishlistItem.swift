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
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String
    var estimatedPrice: Decimal?
    var memo: String?
    var createdAt: Date
    var isPurchased: Bool

    init(name: String, category: String, estimatedPrice: Decimal? = nil, memo: String? = nil) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.estimatedPrice = estimatedPrice
        self.memo = memo
        self.createdAt = Date()
        self.isPurchased = false
    }
}
