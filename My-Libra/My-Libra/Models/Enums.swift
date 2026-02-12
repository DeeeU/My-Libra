//
//  Enums.swift
//  My-Libra
//
//  Created by kanabuchi on 2025/10/22.
//

import Foundation

/// 商品の状態
enum ItemCondition: String, Codable, CaseIterable {
    case new = "新品"
    case used = "中古"
    case damaged = "傷あり"
    case junk = "ジャンク"

    /// 表示用の説明文
    var description: String {
        return self.rawValue
    }
}

/// 商品のステータス
enum ItemStatus: String, Codable, CaseIterable {
    case owned = "保有中"
    case sold = "売却済み"

    /// 表示用の説明文
    var description: String {
        return self.rawValue
    }
}

/// 同期ステータス
enum SyncStatus: String, Codable, CaseIterable {
    case local = "ローカルのみ"
    case synced = "同期済み"
    case pendingUpload = "アップロード待ち"
    case pendingDelete = "削除待ち"
}
