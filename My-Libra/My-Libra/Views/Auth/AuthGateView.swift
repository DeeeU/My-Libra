//
//  AuthGateView.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/13.
//

import SwiftUI
import SwiftData
import Auth

struct AuthGateView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var supabase = SupabaseManager.shared
    @State private var syncCoordinator = SyncCoordinator()
    @AppStorage("authSkipped") private var isSkipped = false

    var body: some View {
        Group {
            if supabase.isLoading {
                ProgressView()
            } else if supabase.isAuthenticated || isSkipped {
                ContentView()
            } else {
                AuthView(isSkipped: $isSkipped)
            }
        }
        .onChange(of: supabase.isAuthenticated) { _, newValue in
            if newValue, let userId = supabase.currentUser?.id.uuidString {
                syncCoordinator.migrateIfNeeded(userId: userId, context: modelContext)
                Task { await syncCoordinator.performSync(context: modelContext) }
            }
        }
    }
}

#Preview {
    AuthGateView()
        .modelContainer(for: [Category.self, WishlistItem.self, Item.self], inMemory: true)
}
