//
//  Config.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/13.
//

import Foundation

enum SupabaseConfig {
    // ローカル開発用デフォルト値
    // 本番環境では環境変数または設定ファイルから読み込み
    static let url = URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "http://127.0.0.1:54321")!
    static let anonKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
    static let redirectURL = URL(string: "myLibra://auth/callback")!
    static let storageBucket = "item-images"
    static let maxImageSizeBytes = 512_000 // 500KB
}
