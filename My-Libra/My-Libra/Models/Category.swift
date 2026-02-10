//
//  Category.swift
//  My-Libra
//
//  Created by kanabuchi on 2025/10/22.
//

import Foundation
import SwiftData

/// カテゴリーモデル
@Model
final class Category {
    var id: UUID
    var name: String
    var iconName: String
    var isCustom: Bool
    var sortOrder: Int

    init(name: String, iconName: String, isCustom: Bool = false, sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.isCustom = isCustom
        self.sortOrder = sortOrder
    }

    /// プリセットカテゴリーを生成
    static func createPresetCategories() -> [Category] {
        return [
            Category(name: "カードゲーム", iconName: "rectangle.portrait.on.rectangle.portrait", isCustom: false, sortOrder: 0),
            Category(name: "靴・スニーカー", iconName: "shoe", isCustom: false, sortOrder: 1),
            Category(name: "フィギュア", iconName: "figure.stand", isCustom: false, sortOrder: 2),
            Category(name: "本・漫画", iconName: "book", isCustom: false, sortOrder: 3),
            Category(name: "ゲーム", iconName: "gamecontroller", isCustom: false, sortOrder: 4),
            Category(name: "電子機器", iconName: "iphone", isCustom: false, sortOrder: 5),
            Category(name: "その他", iconName: "cube.box", isCustom: false, sortOrder: 6)
        ]
    }
}
