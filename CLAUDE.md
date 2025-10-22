# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**My-Libra** is an iOS application for managing hobby and collectible item purchases and sales. The app tracks purchases, sales, and calculates profits/losses with visualization features.

**Current Status**: Project is in the planning/specification phase. The Xcode project and Swift code have not been created yet. Only documentation (README.md) exists.

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

## Development Commands

**Note**: Xcode project doesn't exist yet. When created, use:

### Build and Run
```bash
# Open Xcode project
open My-Libra.xcodeproj

# Or build from command line (after project creation)
xcodebuild -scheme My-Libra -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### Run Tests
```bash
# Run all tests
xcodebuild test -scheme My-Libra -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test
xcodebuild test -scheme My-Libra -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:My-LibraTests/YourTestCase
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

### Phase 1 (Current Target)
Focus on local-only functionality with SwiftData. No AWS integration yet.

### Phase 2 (Future)
AWS integration, cloud sync, multi-device support.

## Notes for AI Development

- README.md contains comprehensive Japanese specifications
- Project structure follows standard SwiftUI + SwiftData architecture
- Use iOS 17.0+ APIs (SwiftData, modern SwiftUI features)
- Follow Apple's Human Interface Guidelines for iOS
- Implement proper error handling for data operations
- Support both Light and Dark modes
- Ensure accessibility (VoiceOver, Dynamic Type)
