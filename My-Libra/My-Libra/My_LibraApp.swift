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
        let schema = Schema([
            Category.self,
            WishlistItem.self,
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // 初回起動時にプリセットカテゴリーを登録
            let context = container.mainContext
            let fetchDescriptor = FetchDescriptor<Category>()
            let existingCategories = try? context.fetch(fetchDescriptor)

            if existingCategories?.isEmpty ?? true {
                let presetCategories = Category.createPresetCategories()
                for category in presetCategories {
                    context.insert(category)
                }
                try? context.save()
            }

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
