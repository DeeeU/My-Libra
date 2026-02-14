//
//  My_LibraApp.swift
//  My-Libra
//
//  Created by kanabuchi on 2025/10/22.
//

import SwiftUI
import SwiftData
import Combine

@main
struct My_LibraApp: App {
    var sharedModelContainer: ModelContainer = {
        let isUITesting = CommandLine.arguments.contains("--uitesting")
        do {
            if isUITesting {
                let config = ModelConfiguration(isStoredInMemoryOnly: true)
                return try ModelContainer(
                    for: Category.self, WishlistItem.self, Item.self,
                    configurations: config
                )
            }
            return try ModelContainer(
                for: Category.self,
                WishlistItem.self,
                Item.self
            )
        } catch {
            print("❌ ModelContainer作成エラー: \(error)")
            print("詳細: \(error.localizedDescription)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
                .environment(PlanManager.shared)
                .onAppear {
                    initializePresetCategories()
                }
                .task {
                    await PlanManager.shared.initialize()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    Task { await PlanManager.shared.refreshProStatus() }
                }
        }
        .modelContainer(sharedModelContainer)
    }

    /// 初回起動時にプリセットカテゴリーを登録
    @MainActor
    private func initializePresetCategories() {
        let context = sharedModelContainer.mainContext
        let fetchDescriptor = FetchDescriptor<Category>()

        do {
            let existingCategories = try context.fetch(fetchDescriptor)

            if existingCategories.isEmpty {
                let presetCategories = Category.createPresetCategories()
                for category in presetCategories {
                    context.insert(category)
                }
                try context.save()
                print("✅ プリセットカテゴリーを登録しました")
            }
        } catch {
            print("⚠️ カテゴリーの初期化エラー: \(error)")
        }
    }
}
