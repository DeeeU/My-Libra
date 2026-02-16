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
    @Environment(PlanManager.self) private var planManager
    @Query private var categories: [Category]
    @Query private var items: [Item]
    @Query private var wishlistItems: [WishlistItem]

    @State private var showingDeleteConfirmation = false
    @State private var showingExportShare = false
    @State private var exportFileURL: URL?
    @State private var showingDeleteComplete = false
    @State private var showingExportError = false
    @State private var showingDeleteError = false
    @State private var showingPaywall = false
    @State private var showingAdminAuth = false
    @State private var showingAdminDashboard = false

    var body: some View {
        NavigationStack {
            List {
                // サブスクリプションセクション
                Section {
                    NavigationLink {
                        SubscriptionManagementView()
                    } label: {
                        HStack {
                            Label("サブスクリプション", systemImage: "crown.fill")
                            Spacer()
                            Text(planManager.isPro ? "Pro" : "Free")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(planManager.isPro ? Color.yellow.opacity(0.2) : Color(.systemGray5))
                                .foregroundStyle(planManager.isPro ? .orange : .secondary)
                                .cornerRadius(4)
                        }
                    }
                } header: {
                    Text("プラン")
                }

                // カテゴリー管理セクション
                Section {
                    NavigationLink {
                        CategoryManagementView()
                    } label: {
                        Label("カテゴリー管理", systemImage: "folder.fill")
                    }
                } header: {
                    Text("カテゴリー")
                } footer: {
                    Text("カテゴリー数: \(categories.count)件")
                }

                // データ管理セクション
                Section {
                    Button {
                        if planManager.canAccess(.csvExport) {
                            exportData()
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        HStack {
                            Label("データをエクスポート", systemImage: "square.and.arrow.up")
                            if !planManager.canAccess(.csvExport) {
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .disabled(items.isEmpty && wishlistItems.isEmpty)

                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("すべてのデータを削除", systemImage: "trash")
                    }
                    .disabled(items.isEmpty && wishlistItems.isEmpty && customCategoryCount == 0)
                } header: {
                    Text("データ管理")
                } footer: {
                    Text("保有品: \(items.count)件 / 買い物リスト: \(wishlistItems.count)件")
                }

                // アプリ情報セクション
                Section {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                    .onLongPressGesture(minimumDuration: 3) {
                        showingAdminAuth = true
                    }
                    .navigationDestination(isPresented: $showingAdminDashboard) {
                        AdminDashboardView()
                    }

                    HStack {
                        Text("ビルド")
                        Spacer()
                        Text(buildNumber)
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "https://github.com/DeeeU/My-Libra")!) {
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
            .alert("すべてのデータを削除しますか？", isPresented: $showingDeleteConfirmation) {
                Button("削除する", role: .destructive) {
                    deleteAllData()
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("買い物リスト、保有品、カスタムカテゴリーのデータがすべて削除されます。この操作は取り消せません。")
            }
            .alert("削除完了", isPresented: $showingDeleteComplete) {
                Button("OK") {}
            } message: {
                Text("すべてのデータを削除しました。")
            }
            .alert("エクスポートエラー", isPresented: $showingExportError) {
                Button("OK") {}
            } message: {
                Text("CSVファイルの作成に失敗しました。")
            }
            .alert("削除エラー", isPresented: $showingDeleteError) {
                Button("OK") {}
            } message: {
                Text("データの削除中にエラーが発生しました。")
            }
            .sheet(isPresented: $showingExportShare) {
                if let url = exportFileURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingAdminAuth) {
                AdminAuthView {
                    showingAdminDashboard = true
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var customCategoryCount: Int {
        categories.filter { $0.isCustom }.count
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    // MARK: - Actions

    private func exportData() {
        let csvString = CSVExportService.exportAll(items: items, wishlistItems: wishlistItems)
        if let url = CSVExportService.writeToTemporaryFile(csvString: csvString) {
            exportFileURL = url
            showingExportShare = true
        } else {
            showingExportError = true
        }
    }

    private func deleteAllData() {
        // 全Itemを削除
        for item in items {
            modelContext.delete(item)
        }

        // 全WishlistItemを削除
        for item in wishlistItems {
            modelContext.delete(item)
        }

        // カスタムカテゴリーのみ削除
        for category in categories where category.isCustom {
            modelContext.delete(category)
        }

        do {
            try modelContext.save()
            showingDeleteComplete = true
        } catch {
            print("データの削除エラー: \(error)")
            showingDeleteError = true
        }
    }
}

// MARK: - ShareSheet (UIActivityViewController wrapper)

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
        .modelContainer(for: [Category.self, Item.self, WishlistItem.self])
        .environment(PlanManager.shared)
}
