//
//  SettingsView.swift
//  My-Libra
//
//  Created by Claude Code on 2025/11/04.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]

    var body: some View {
        NavigationStack {
            List {
                // カテゴリー管理セクション
                Section {
                    NavigationLink {
                        Text("カテゴリー管理画面はPhase 6で実装予定です")
                            .navigationTitle("カテゴリー管理")
                    } label: {
                        Label("カテゴリー管理", systemImage: "folder.fill")
                    }
                } header: {
                    Text("カテゴリー")
                }

                // データ管理セクション
                Section {
                    Button {
                        // TODO: Phase 6でエクスポート機能を実装
                    } label: {
                        Label("データをエクスポート", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive) {
                        // TODO: データ削除確認ダイアログを実装
                    } label: {
                        Label("すべてのデータを削除", systemImage: "trash")
                    }
                } header: {
                    Text("データ管理")
                }

                // アプリ情報セクション
                Section {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "https://github.com/yourusername/My-Libra")!) {
                        HStack {
                            Text("GitHub")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("アプリ情報")
                }
            }
            .navigationTitle("設定")
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [Category.self])
}
