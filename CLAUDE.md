# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**My-Libra** is an iOS application for managing hobby and collectible item purchases and sales. The app tracks purchases, sales, and calculates profits/losses with visualization features.

**Current Status**: Phase 1-5完了。Phase 6（設定機能）が次のフェーズ。

**Primary Language**: Japanese (documentation and UI)

## Technology Stack

### Phase 1 (Local Version - In Development)
- **Language**: Swift 5.9+
- **Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Photo Handling**: PhotosUI
- **Charts**: Swift Charts framework
- **Minimum iOS**: 17.0

### Phase 2 (Cloud Version - Planned)
- **Backend**: AWS Amplify
- **Authentication**: Amazon Cognito
- **API**: AWS AppSync (GraphQL)
- **Database**: Amazon DynamoDB
- **Storage**: Amazon S3
- **Serverless**: AWS Lambda

## Core Data Models

### WishlistItem (買い物リスト)
Items the user wants to purchase in the future.
```swift
- id: UUID
- name: String
- category: String
- estimatedPrice: Decimal?
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
- purchasePrice: Decimal
- purchaseDate: Date
- condition: ItemCondition (enum)
- memo: String?
- imageData: Data?
- status: ItemStatus (enum)
- salePrice: Decimal?
- saleDate: Date?
- profit: Decimal? // Computed property: salePrice - purchasePrice
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

## Project Structure (Planned)

```
My-Libra/
├── My_LibraApp.swift               # App entry point
├── Models/                          # SwiftData models
│   ├── Enums.swift                 # ItemCondition, ItemStatus, etc.
│   ├── Category.swift
│   ├── WishlistItem.swift
│   └── Item.swift
├── Views/                           # SwiftUI Views
│   ├── ContentView.swift           # Main TabView
│   ├── Wishlist/                   # Wishlist screens
│   ├── OwnedItems/                 # Owned items screens
│   ├── Statistics/                 # Statistics/Charts screens
│   └── Settings/                   # Settings screens
├── ViewModels/                      # Business logic
└── Utilities/                       # Helper functions
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

### Decimal Type for Currency
Use `Decimal` type (not `Double`) for all price-related properties to ensure precision in financial calculations.

### Date Handling
Store dates as `Date` type in SwiftData. Format for display using `Date.FormatStyle` for proper Japanese localization.

### Photo Storage
Store images as `Data?` type in SwiftData for Phase 1 (local storage). Migrate to S3 URLs in Phase 2.

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

- Phase 1: All data stored locally using SwiftData
- Photos stored on device
- No external server communication
- Phase 2: User-controlled cloud backup via AWS

## Development Phases

### Phase 1-5 (完了)
- Phase 1: データモデル (Enums, Category, WishlistItem, Item)
- Phase 2: アプリ基盤 (SwiftData, TabView, Extensions)
- Phase 3: 買い物リスト機能
- Phase 4: 保有品管理機能
- Phase 5: 統計機能 (Swift Charts)

### Phase 6 (次のフェーズ)
設定機能 (カテゴリー管理, データエクスポート, アプリ情報)

### フェーズ2 (将来)
AWS統合, クラウド同期, 複数デバイス対応

## Notes for AI Development

- README.md contains comprehensive Japanese specifications
- Project structure follows standard SwiftUI + SwiftData architecture
- Use iOS 17.0+ APIs (SwiftData, modern SwiftUI features)
- Follow Apple's Human Interface Guidelines for iOS
- Implement proper error handling for data operations
- Support both Light and Dark modes
- Ensure accessibility (VoiceOver, Dynamic Type)
- CI/CD: GitHub Actions on macos-15 (`.github/workflows/swift.yml`)
