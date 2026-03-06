//
//  Enums.swift
//  My-Libra
//
//  Created by kanabuchi on 2025/10/22.
//

import Foundation

/// ユーザーの性別
enum Gender: String, Codable, CaseIterable {
    case male = "男性"
    case female = "女性"
    case other = "その他"
    case preferNotToSay = "回答しない"

    var description: String { rawValue }
}

/// ユーザーの年代
enum AgeGroup: String, Codable, CaseIterable {
    case teens = "10代"
    case twenties = "20代"
    case thirties = "30代"
    case forties = "40代"
    case fifties = "50代"
    case sixtyPlus = "60代以上"
    case preferNotToSay = "回答しない"

    var description: String { rawValue }
}

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
