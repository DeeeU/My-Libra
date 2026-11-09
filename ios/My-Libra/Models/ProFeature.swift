//
//  ProFeature.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/13.
//

import Foundation

enum ProFeature: String, CaseIterable {
    case unlimitedItems
    case photos
    case customCategories
    case statistics
    case csvExport
    case cloudSync
    case profitDisplay

    var lockedMessage: String {
        switch self {
        case .unlimitedItems:
            return "Proプランでアイテムを無制限に登録できます"
        case .photos:
            return "Proプランで写真を追加できます"
        case .customCategories:
            return "Proプランでカスタムカテゴリーを管理できます"
        case .statistics:
            return "Proプランで統計機能を利用できます"
        case .csvExport:
            return "ProプランでCSVエクスポートが利用できます"
        case .cloudSync:
            return "Proプランでクラウド同期が利用できます"
        case .profitDisplay:
            return "Proプランで損益表示が利用できます"
        }
    }

    var iconName: String {
        switch self {
        case .unlimitedItems: return "infinity"
        case .photos: return "photo"
        case .customCategories: return "folder.badge.plus"
        case .statistics: return "chart.bar.fill"
        case .csvExport: return "square.and.arrow.up"
        case .cloudSync: return "icloud.and.arrow.up"
        case .profitDisplay: return "chart.line.uptrend.xyaxis"
        }
    }

    var displayName: String {
        switch self {
        case .unlimitedItems: return "無制限アイテム登録"
        case .photos: return "写真管理"
        case .customCategories: return "カスタムカテゴリー"
        case .statistics: return "統計分析"
        case .csvExport: return "CSVエクスポート"
        case .cloudSync: return "クラウド同期"
        case .profitDisplay: return "損益表示"
        }
    }

    /// Free プランでの制限説明
    var freeDescription: String {
        switch self {
        case .unlimitedItems: return "25件まで"
        case .photos: return "利用不可"
        case .customCategories: return "プリセットのみ"
        case .statistics: return "ロック"
        case .csvExport: return "利用不可"
        case .cloudSync: return "利用不可"
        case .profitDisplay: return "売却記録のみ"
        }
    }

    /// Pro プランでの説明
    var proDescription: String {
        switch self {
        case .unlimitedItems: return "無制限"
        case .photos: return "写真添付"
        case .customCategories: return "追加/編集/削除"
        case .statistics: return "全機能"
        case .csvExport: return "利用可能"
        case .cloudSync: return "利用可能"
        case .profitDisplay: return "利益計算表示"
        }
    }
}
