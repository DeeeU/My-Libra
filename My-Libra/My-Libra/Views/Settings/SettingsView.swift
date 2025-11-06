//
//  SettingsView.swift
//  My-Libra
//
//  Created by Claude on 2025/11/06.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]

    var body: some View {
        NavigationStack {
            List {
                Section("カテゴリー管理") {
                    NavigationLink {
                        Text("カテゴリー管理画面（未実装）")
                    } label: {
                        Label("カテゴリー編集", systemImage: "tag")
                    }

                    Text("登録カテゴリー数: \(categories.count)個")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("データ管理") {
                    Button {
                        // TODO: データエクスポート処理
                    } label: {
                        Label("データをエクスポート", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive) {
                        // TODO: データ削除処理
                    } label: {
                        Label("全データを削除", systemImage: "trash")
                    }
                }

                Section("アプリ情報") {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("ビルド")
                        Spacer()
                        Text("1")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [WishlistItem.self, Category.self, Item.self])
}
