//
//  ImageSyncService.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/13.
//

import Foundation
import UIKit
import Supabase

actor ImageSyncService {
    private let supabase = SupabaseManager.shared

    // MARK: - Upload

    func uploadImage(data: Data, itemId: UUID) async throws -> String {
        guard let userId = supabase.currentUser?.id else {
            throw ImageSyncError.notAuthenticated
        }

        // 画像を圧縮 (500KB以下)
        let compressedData = compressImage(data: data, maxBytes: SupabaseConfig.maxImageSizeBytes)

        let path = "\(userId.uuidString)/\(itemId.uuidString).jpg"

        try await supabase.client.storage
            .from(SupabaseConfig.storageBucket)
            .upload(path, data: compressedData, options: .init(contentType: "image/jpeg", upsert: true))

        return path
    }

    // MARK: - Download

    func downloadImage(path: String) async throws -> Data {
        try await supabase.client.storage
            .from(SupabaseConfig.storageBucket)
            .download(path: path)
    }

    // MARK: - Delete

    func deleteImage(path: String) async throws {
        try await supabase.client.storage
            .from(SupabaseConfig.storageBucket)
            .remove(paths: [path])
    }

    // MARK: - Compression

    private func compressImage(data: Data, maxBytes: Int) -> Data {
        guard let image = UIImage(data: data) else { return data }

        var quality: CGFloat = 0.8
        var compressed = image.jpegData(compressionQuality: quality) ?? data

        while compressed.count > maxBytes && quality > 0.1 {
            quality -= 0.1
            compressed = image.jpegData(compressionQuality: quality) ?? data
        }

        // サイズ超過の場合はリサイズ
        if compressed.count > maxBytes {
            let scale = sqrt(Double(maxBytes) / Double(compressed.count))
            let newSize = CGSize(
                width: image.size.width * scale,
                height: image.size.height * scale
            )
            let renderer = UIGraphicsImageRenderer(size: newSize)
            let resized = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }
            compressed = resized.jpegData(compressionQuality: 0.7) ?? compressed
        }

        return compressed
    }
}

enum ImageSyncError: LocalizedError {
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "画像アップロードにはログインが必要です"
        }
    }
}
