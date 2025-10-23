//
//  My_LibraApp.swift
//  My-Libra
//
//  Created by kanabuchi on 2025/10/22.
//

import SwiftUI
import SwiftData

@main
struct My_LibraApp: App {
    var sharedModelContainer: ModelContainer = {
        do {
            // SwiftDataのスキーマを直接ModelContainerに渡す（シンプルな方法）
            let container = try ModelContainer(
                for: Category.self, WishlistItem.self, Item.self
            )
            return container
        } catch {
            print("❌ ModelContainer作成エラー: \(error)")
            print("詳細: \(error.localizedDescription)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    initializePresetCategories()
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
