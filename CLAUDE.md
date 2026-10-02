# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**My-Libra** is an iOS application for managing hobby and collectible item purchases and sales. The app tracks purchases, sales, and calculates profits/losses with visualization features.

**Current Status**: Phase 1-6完了。サブスクリプション（Free/Pro）、Supabaseによるアカウント・クラウド同期も実装済み。現在はデザイン統一とApp Storeリリース準備のフェーズ（残タスクは `TODO.md` を参照）。

**Primary Language**: Japanese (documentation and UI)

## Technology Stack

### App
- **Language**: Swift 5.9+
- **Framework**: SwiftUI
- **Data Persistence**: SwiftData（オフラインファースト。ローカルが一次ストア）
- **Photo Handling**: PhotosUI
- **Charts**: Swift Charts framework
- **In-App Purchase**: StoreKit 2（Free / Pro プラン）
- **Minimum iOS**: 17.0

### Backend (Cloud Sync)
- **Platform**: Supabase（`supabase-swift` SDK）
- **Authentication**: Supabase Auth
- **Database**: PostgreSQL + RLS（`supabase/migrations/`）
- **Storage**: Supabase Storage（バケット `item-images`）
- 接続先は `Services/Config.swift`。現在は環境変数未設定時にローカル開発環境（`http://127.0.0.1:54321`）を使う。本番環境は未構築。
- 当初計画していたAWS構成（`AWS統合技術設計書.md`）は採用せず、Supabaseに置き換えた。

## Core Data Models

全モデル共通で同期用フィールドを持つ:
```swift
- userId: String?            // Supabase user ID (nil = ローカルのみ)
- syncStatus: SyncStatus     // local / synced / pendingUpload / pendingDelete
- localUpdatedAt: Date
- remoteUpdatedAt: Date?
```

### WishlistItem (買い物リスト)
Items the user wants to purchase in the future.
```swift
- id: UUID
- name: String
- category: String
- estimatedPrice: Double?
- memo: String?
- createdAt: Date
- isPurchased: Bool
```

### Item (購入済み商品)
Purchased items with tracking for sales and profit.
```swift
- id: UUID
- name: String
- category: String
- purchasePrice: Double
- purchaseDate: Date
- condition: ItemCondition (enum)
- memo: String?
- imageData: Data?
- imageUrl: String?   // Supabase Storage のパス
- status: ItemStatus (enum)
- salePrice: Double?
- saleDate: Date?
- profit: Double? // Computed property: salePrice - purchasePrice
```

### Category (カテゴリー)
User-customizable categories for items.
```swift
- id: UUID
- name: String
- iconName: String (SF Symbol name)
- isCustom: Bool
- sortOrder: Int
```

## Project Structure

```
My-Libra/                            # リポジトリルート
├── My-Libra/                        # Xcodeプロジェクト (xcodebuild はここで実行)
│   ├── My-Libra.xcodeproj
│   ├── My-Libra/
│   │   ├── My_LibraApp.swift        # App entry point
│   │   ├── ContentView.swift        # Main TabView
│   │   ├── Models/                  # Enums (ItemCondition, ItemStatus, SyncStatus), Category, WishlistItem, Item, ProFeature
│   │   ├── Views/
│   │   │   ├── Wishlist/            # 買い物リスト
│   │   │   ├── OwnedItems/          # 保有品（詳細・編集・売却）
│   │   │   ├── Statistics/          # 統計
│   │   │   ├── Settings/            # 設定・カテゴリー管理・SF Symbolピッカー
│   │   │   ├── Subscription/        # Paywall・プラン管理・アップグレード誘導
│   │   │   ├── Auth/                # ログイン・登録・プロフィール
│   │   │   ├── LaunchScreen/        # 起動アニメーション（天秤）
│   │   │   └── Components/          # 共通部品（Toast）
│   │   ├── ViewModels/              # Wishlist / Item / Statistics / Auth
│   │   ├── Services/                # Supabase・同期・StoreKit・PlanManager・Config
│   │   └── Utilities/               # Extensions, CSVExportService
│   ├── My-LibraTests/               # Unit tests
│   └── My-LibraUITests/
├── supabase/                        # DBマイグレーション・RLS・Storage設定
└── docs/                            # 認証・同期・API・サブスク等の設計書
```

## Key Features

1. **Wishlist Management** (買い物リスト): Track items to purchase
2. **Purchase Recording** (購入記録): Record price, date, condition with photos
3. **Sales Management** (売却管理): Record sales and auto-calculate profit/loss
4. **Statistics** (統計分析): Category-wise spending, monthly trends with charts
5. **Photo Management** (写真管理): Store product photos
6. **Category Management** (カテゴリー管理): Preset + custom categories
7. **Data Export** (データエクスポート): CSV export functionality

## UI Architecture

Main TabView with 4 tabs:
1. 📝 Wishlist (買い物リスト)
2. 📦 Owned Items (保有品)
3. 📊 Statistics (統計)
4. ⚙️ Settings (設定)

## Development Workflow

機能開発は以下のワークフローに従うこと。各ステップで適切なサブエージェントを活用する。
また、githubはmcpで接続するようにする。

### 1. ブランチ作成
最新の `main` からフィーチャーブランチを作成する。
```bash
git checkout main && git pull origin main
git checkout -b feature/<phase-or-feature-name>
```

### 2. 調査 (Explore agent)
`Explore` サブエージェントで既存コードベースのパターン・構造を調査する。

### 3. 設計 (Plan agent)
`Plan` サブエージェントで実装計画を設計し、ユーザーに承認を得る。

### 4. 実装
計画に基づいてコードを実装する。

### 5. テスト実行
ビルドとテストを実行して動作を確認する。
```bash
# Build
xcodebuild build -project My-Libra.xcodeproj -scheme My-Libra \
  -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -configuration Debug CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO

# Test
xcodebuild test -project My-Libra.xcodeproj -scheme My-Libra \
  -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```
Working directory: `My-Libra/`

### 6. レビュー (3エージェント並列実行)
以下の3つのレビューエージェントを**並列**で実行する。すべてのレビューが完了してから次に進む。
- `diff-validator` — 変更の整合性・制約違反チェック
- `code-stability-reviewer` — 安定性・潜在バグチェック
- `coderabbit:code-reviewer` — 包括的なコード品質レビュー

### 7. PR作成
コミットしてリモートにプッシュし、MCP github tools (`mcp__github__create_pull_request`) でPRを作成する。
`gh` CLIは未認証のため使用しない。

## Development Commands

### Build and Run
```bash
# Working directory: My-Libra/
xcodebuild -project My-Libra.xcodeproj -scheme My-Libra \
  -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' build

# Open in Xcode
open My-Libra/My-Libra.xcodeproj
```

### Run Tests
```bash
# Run all tests
xcodebuild test -project My-Libra.xcodeproj -scheme My-Libra \
  -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
```

## Implementation Guidelines

### SwiftData Setup
- Use `@Model` macro for data models
- Configure ModelContainer in App entry point
- Use `@Query` in views for reactive data binding

### Currency Type
現状の実装では価格系プロパティは `Double` 型。当初方針は `Decimal` だったが、Phase 2以降 `Double` で実装されている。型を変更する場合はSwiftDataのマイグレーションとSupabaseスキーマへの影響を考慮すること。

### Date Handling
Store dates as `Date` type in SwiftData. Format for display using `Date.FormatStyle` for proper Japanese localization.

### Photo Storage
Images are stored as `Data?` in SwiftData (local), and uploaded to Supabase Storage (`imageUrl`) when cloud sync is enabled (`ImageSyncService`).

### Category System
Implement preset categories (カードゲーム, 靴, フィギュア, 本・漫画, etc.) with ability for users to add custom categories.

### Profit Calculation
Implement as computed property:
```swift
var profit: Decimal? {
    guard let salePrice = salePrice else { return nil }
    return salePrice - purchasePrice
}
```

## Localization

- Primary language: Japanese
- UI text should be in Japanese
- Use SF Symbols for icons (language-independent)
- Consider adding English support in future versions

## Testing Scenarios

When implementing features, ensure these scenarios work:
1. Add item to wishlist
2. Convert wishlist item to purchased item
3. View owned items list
4. Add photo to item
5. Mark item as sold
6. View statistics and profit/loss
7. Add custom category
8. Export data to CSV

## Privacy & Data

- 未ログイン時: すべてのデータはSwiftDataでローカル保存。外部通信なし
- ログイン時: Supabaseと同期（RLSでユーザーごとにデータを分離）

## Development Phases

### 完了
- Phase 1: データモデル (Enums, Category, WishlistItem, Item)
- Phase 2: アプリ基盤 (SwiftData, TabView, Extensions)
- Phase 3: 買い物リスト機能
- Phase 4: 保有品管理機能
- Phase 5: 統計機能 (Swift Charts)
- Phase 6: 設定機能 (カテゴリー管理, CSVエクスポート, 全データ削除, アプリ情報)
- サブスクリプション (StoreKit 2, Free/Pro, 統計のFree向けマスキング)
- アカウント・クラウド同期 (Supabase Auth / DB / Storage, オフラインファースト同期)

### 次のフェーズ
- デザイン統一（AccentColor設定、ハードコード色の置き換え等）
- Supabase本番環境の構築と接続先切り替え
- アクセシビリティ強化
- App Storeリリース準備（署名、App Store Connect、プライバシーポリシー公開、TestFlight）

### 将来
発売日通知機能など（`FUTURE_FEATURES.md`）

## Notes for AI Development

- README.md contains comprehensive Japanese specifications
- Project structure follows standard SwiftUI + SwiftData architecture
- Use iOS 17.0+ APIs (SwiftData, modern SwiftUI features)
- 残タスクの一覧は `TODO.md`、設計書は `docs/` を参照
- Follow Apple's Human Interface Guidelines for iOS
- Implement proper error handling for data operations
- Support both Light and Dark modes
- Ensure accessibility (VoiceOver, Dynamic Type)
- CI/CD: GitHub Actions on macos-15 (`.github/workflows/swift.yml`)
