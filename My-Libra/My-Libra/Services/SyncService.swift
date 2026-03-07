//
//  SyncService.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/13.
//

import Foundation
import SwiftData
import Supabase

@MainActor
final class SyncService {
    private let supabase = SupabaseManager.shared

    // MARK: - Push (Local → Remote)

    func pushItems(from context: ModelContext) async throws {
        guard let userId = supabase.currentUser?.id else { return }

        let pendingRaw = SyncStatus.pendingUpload.rawValue
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate { $0.syncStatus.rawValue == pendingRaw }
        )
        let pendingItems = try context.fetch(descriptor)

        for item in pendingItems {
            let payload: [String: AnyJSON] = [
                "id": .string(item.id.uuidString),
                "user_id": .string(userId.uuidString),
                "name": .string(item.name),
                "category": .string(item.category),
                "purchase_price": .double(item.purchasePrice),
                "purchase_date": .string(item.purchaseDate.ISO8601Format()),
                "condition": .string(item.condition.rawValue),
                "memo": item.memo.map { .string($0) } ?? .null,
                "image_url": item.imageUrl.map { .string($0) } ?? .null,
                "status": .string(item.status.rawValue),
                "sale_price": item.salePrice.map { .double($0) } ?? .null,
                "sale_date": item.saleDate.map { .string($0.ISO8601Format()) } ?? .null,
            ]

            try await supabase.client.from("items")
                .upsert(payload)
                .execute()

            item.syncStatus = .synced
            item.remoteUpdatedAt = Date()
        }

        try context.save()
    }

    func pushWishlistItems(from context: ModelContext) async throws {
        guard let userId = supabase.currentUser?.id else { return }

        let pendingRaw = SyncStatus.pendingUpload.rawValue
        let descriptor = FetchDescriptor<WishlistItem>(
            predicate: #Predicate { $0.syncStatus.rawValue == pendingRaw }
        )
        let pendingItems = try context.fetch(descriptor)

        for item in pendingItems {
            let payload: [String: AnyJSON] = [
                "id": .string(item.id.uuidString),
                "user_id": .string(userId.uuidString),
                "name": .string(item.name),
                "category": .string(item.category),
                "estimated_price": item.estimatedPrice.map { .double($0) } ?? .null,
                "memo": item.memo.map { .string($0) } ?? .null,
                "is_purchased": .bool(item.isPurchased),
            ]

            try await supabase.client.from("wishlist_items")
                .upsert(payload)
                .execute()

            item.syncStatus = .synced
            item.remoteUpdatedAt = Date()
        }

        try context.save()
    }

    func pushCategories(from context: ModelContext) async throws {
        guard let userId = supabase.currentUser?.id else { return }

        let pendingRaw = SyncStatus.pendingUpload.rawValue
        let descriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.syncStatus.rawValue == pendingRaw }
        )
        let pendingItems = try context.fetch(descriptor)

        for category in pendingItems {
            let payload: [String: AnyJSON] = [
                "id": .string(category.id.uuidString),
                "user_id": .string(userId.uuidString),
                "name": .string(category.name),
                "icon_name": .string(category.iconName),
                "is_custom": .bool(category.isCustom),
                "sort_order": .integer(category.sortOrder),
            ]

            try await supabase.client.from("categories")
                .upsert(payload)
                .execute()

            category.syncStatus = .synced
            category.remoteUpdatedAt = Date()
        }

        try context.save()
    }

    // MARK: - Pull (Remote → Local)

    func pullItems(into context: ModelContext, since lastSync: Date?) async throws {
        guard supabase.currentUser != nil else { return }

        var query = supabase.client.from("items")
            .select()
            .eq("is_deleted", value: false)

        if let lastSync {
            query = query.gt("updated_at", value: lastSync.ISO8601Format())
        }

        let remoteItems: [RemoteItem] = try await query
            .execute()
            .value

        for remote in remoteItems {
            let remoteId = remote.id
            let descriptor = FetchDescriptor<Item>(
                predicate: #Predicate { item in item.id == remoteId }
            )
            let existing = try context.fetch(descriptor).first

            if let existing {
                if existing.syncStatus != .pendingUpload {
                    existing.name = remote.name
                    existing.category = remote.category
                    existing.purchasePrice = remote.purchasePrice
                    existing.purchaseDate = remote.purchaseDate
                    existing.condition = ItemCondition(rawValue: remote.condition) ?? .used
                    existing.memo = remote.memo
                    existing.imageUrl = remote.imageUrl
                    existing.status = ItemStatus(rawValue: remote.status) ?? .owned
                    existing.salePrice = remote.salePrice
                    existing.saleDate = remote.saleDate
                    existing.syncStatus = .synced
                    existing.remoteUpdatedAt = remote.updatedAt
                }
            } else {
                let newItem = Item(
                    name: remote.name,
                    category: remote.category,
                    purchasePrice: remote.purchasePrice,
                    purchaseDate: remote.purchaseDate,
                    condition: ItemCondition(rawValue: remote.condition) ?? .used,
                    memo: remote.memo
                )
                newItem.id = remote.id
                newItem.imageUrl = remote.imageUrl
                newItem.status = ItemStatus(rawValue: remote.status) ?? .owned
                newItem.salePrice = remote.salePrice
                newItem.saleDate = remote.saleDate
                newItem.userId = remote.userId.uuidString
                newItem.syncStatus = .synced
                newItem.remoteUpdatedAt = remote.updatedAt
                context.insert(newItem)
            }
        }

        try context.save()
    }

    func pullWishlistItems(into context: ModelContext, since lastSync: Date?) async throws {
        guard supabase.currentUser != nil else { return }

        var query = supabase.client.from("wishlist_items")
            .select()
            .eq("is_deleted", value: false)

        if let lastSync {
            query = query.gt("updated_at", value: lastSync.ISO8601Format())
        }

        let remoteItems: [RemoteWishlistItem] = try await query
            .execute()
            .value

        for remote in remoteItems {
            let remoteId = remote.id
            let descriptor = FetchDescriptor<WishlistItem>(
                predicate: #Predicate { item in item.id == remoteId }
            )
            let existing = try context.fetch(descriptor).first

            if let existing {
                if existing.syncStatus != .pendingUpload {
                    existing.name = remote.name
                    existing.category = remote.category
                    existing.estimatedPrice = remote.estimatedPrice
                    existing.memo = remote.memo
                    existing.isPurchased = remote.isPurchased
                    existing.syncStatus = .synced
                    existing.remoteUpdatedAt = remote.updatedAt
                }
            } else {
                let newItem = WishlistItem(
                    name: remote.name,
                    category: remote.category,
                    estimatedPrice: remote.estimatedPrice,
                    memo: remote.memo
                )
                newItem.id = remote.id
                newItem.isPurchased = remote.isPurchased
                newItem.userId = remote.userId.uuidString
                newItem.syncStatus = .synced
                newItem.remoteUpdatedAt = remote.updatedAt
                context.insert(newItem)
            }
        }

        try context.save()
    }

    func pullCategories(into context: ModelContext, since lastSync: Date?) async throws {
        guard supabase.currentUser != nil else { return }

        var query = supabase.client.from("categories")
            .select()
            .eq("is_deleted", value: false)

        if let lastSync {
            query = query.gt("updated_at", value: lastSync.ISO8601Format())
        }

        let remoteCategories: [RemoteCategory] = try await query
            .execute()
            .value

        for remote in remoteCategories {
            let remoteId = remote.id
            let descriptor = FetchDescriptor<Category>(
                predicate: #Predicate { cat in cat.id == remoteId }
            )
            let existing = try context.fetch(descriptor).first

            if let existing {
                if existing.syncStatus != .pendingUpload {
                    existing.name = remote.name
                    existing.iconName = remote.iconName
                    existing.isCustom = remote.isCustom
                    existing.sortOrder = remote.sortOrder
                    existing.syncStatus = .synced
                    existing.remoteUpdatedAt = remote.updatedAt
                }
            } else {
                let newCategory = Category(
                    name: remote.name,
                    iconName: remote.iconName,
                    isCustom: remote.isCustom,
                    sortOrder: remote.sortOrder
                )
                newCategory.id = remote.id
                newCategory.userId = remote.userId.uuidString
                newCategory.syncStatus = .synced
                newCategory.remoteUpdatedAt = remote.updatedAt
                context.insert(newCategory)
            }
        }

        try context.save()
    }

    // MARK: - Migration (既存ローカルデータにuserId付与)

    func migrateLocalData(userId: String, context: ModelContext) throws {
        let itemDescriptor = FetchDescriptor<Item>(
            predicate: #Predicate { $0.userId == nil }
        )
        let items = try context.fetch(itemDescriptor)
        for item in items {
            item.userId = userId
            item.syncStatus = .pendingUpload
        }

        let wishlistDescriptor = FetchDescriptor<WishlistItem>(
            predicate: #Predicate { $0.userId == nil }
        )
        let wishlistItems = try context.fetch(wishlistDescriptor)
        for item in wishlistItems {
            item.userId = userId
            item.syncStatus = .pendingUpload
        }

        let categoryDescriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.userId == nil }
        )
        let categories = try context.fetch(categoryDescriptor)
        for category in categories {
            category.userId = userId
            category.syncStatus = .pendingUpload
        }

        try context.save()
    }
}

// MARK: - Remote Models (Supabase JSON mapping)

struct RemoteWishlistItem: Codable, Sendable {
    let id: UUID
    let userId: UUID
    let name: String
    let category: String
    let estimatedPrice: Double?
    let memo: String?
    let isPurchased: Bool
    let createdAt: Date
    let updatedAt: Date
    let isDeleted: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name, category
        case estimatedPrice = "estimated_price"
        case memo
        case isPurchased = "is_purchased"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isDeleted = "is_deleted"
    }
}

struct RemoteCategory: Codable, Sendable {
    let id: UUID
    let userId: UUID
    let name: String
    let iconName: String
    let isCustom: Bool
    let sortOrder: Int
    let createdAt: Date
    let updatedAt: Date
    let isDeleted: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case iconName = "icon_name"
        case isCustom = "is_custom"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isDeleted = "is_deleted"
    }
}

struct RemoteItem: Codable, Sendable {
    let id: UUID
    let userId: UUID
    let name: String
    let category: String
    let purchasePrice: Double
    let purchaseDate: Date
    let condition: String
    let memo: String?
    let imageUrl: String?
    let status: String
    let salePrice: Double?
    let saleDate: Date?
    let createdAt: Date
    let updatedAt: Date
    let isDeleted: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name, category
        case purchasePrice = "purchase_price"
        case purchaseDate = "purchase_date"
        case condition, memo
        case imageUrl = "image_url"
        case status
        case salePrice = "sale_price"
        case saleDate = "sale_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isDeleted = "is_deleted"
    }
}
