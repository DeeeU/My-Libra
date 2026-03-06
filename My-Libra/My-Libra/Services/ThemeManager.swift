//
//  ThemeManager.swift
//  My-Libra
//
//  Created by Claude Code on 2026/03/05.
//

import SwiftUI

/// アプリのテーマ設定
enum AppTheme: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    /// SwiftUIのカラースキームへ変換（systemはnilを返す）
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    /// 設定画面に表示するラベル
    var displayName: String {
        switch self {
        case .system: return "システム"
        case .light:  return "ライト"
        case .dark:   return "ダーク"
        }
    }

    /// アイコン（SF Symbol）
    var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }
}

/// テーマ設定を管理するクラス
@Observable
final class ThemeManager {
    static let shared = ThemeManager()

    private(set) var currentTheme: AppTheme

    var colorScheme: ColorScheme? {
        currentTheme.colorScheme
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appTheme") ?? AppTheme.system.rawValue
        currentTheme = AppTheme(rawValue: saved) ?? .system
    }

    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "appTheme")
    }
}
