# My-Libra

趣味・コレクション品の売買履歴を管理するiOSアプリ

<div align="center">

**カードゲーム、靴、フィギュアなど、あなたのコレクションを簡単管理**

[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)]()
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)]()
[![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-green.svg)]()
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)]()

</div>

---

## 📱 概要

My-Libraは、趣味・コレクション品の購入と販売を記録し、支出や損益を可視化するiOSアプリです。

### 主な機能

- 📝 **買い物リスト**: 欲しいものを事前にリスト化
- 🛍️ **購入記録**: 価格、日付、状態を個別管理
- 💰 **売却管理**: 売却価格を記録し、損益を自動計算
- 📊 **統計分析**: カテゴリー別支出、月別推移をグラフで可視化
- 📷 **写真管理**: 商品写真を保存
- 🏷️ **カテゴリー管理**: プリセット + カスタムカテゴリー
- 📤 **データエクスポート**: CSV形式で出力
- ⚖️ **ロード画面**: 天秤アニメーション付き起動画面

---

## 🎯 ターゲットユーザー

- カードゲームトレーダー
- スニーカーコレクター
- フィギュア収集家
- 本・漫画の転売をしている方
- 趣味の支出を管理したい方

---

## 🚀 開発状況

### フェーズ1: ローカル版 (開発中)
- ✅ 設計完了
- ✅ Xcodeプロジェクト作成完了
- ✅ Phase 1: データモデル実装完了
  - Enums, Category, WishlistItem, Item
  - SwiftData統合
  - テスト14件すべて成功
- ✅ Phase 2: アプリ基盤構築完了
  - ユーティリティ拡張実装 (Date, Double, View, Color, String)
  - TabView実装 (4タブ)
  - 各タブの基本ビュー作成
- ✅ Phase 3: 買い物リスト機能完了
  - WishlistView (検索・カテゴリフィルター・スワイプアクション)
  - AddWishlistItemView (バリデーション付きフォーム)
  - PurchaseDetailView (買い物リスト→購入済み変換)
- ✅ Phase 4: 保有品管理機能完了
  - OwnedItemsView (フィルター・ソート・検索)
  - ItemDetailView / EditItemView / SellItemView
  - 売却処理・損益計算・写真管理
- ✅ Phase 5: 統計機能完了
  - 期間フィルター (今月/3ヶ月/6ヶ月/今年/全期間)
  - サマリーカード (2x2グリッド)
  - カテゴリ別支出円グラフ (Swift Charts SectorMark)
  - 月次購入額棒グラフ (BarMark)
  - 月次損益折れ線グラフ (LineMark + AreaMark)
- ✅ Phase 6: 設定機能完了
  - カテゴリー管理 (追加/編集/削除/アイコン選択)
  - CSVデータエクスポート
  - データ全削除
  - アプリ情報表示
- ✅ Phase 7: ViewModel実装完了
  - WishlistViewModel / ItemViewModel / StatisticsViewModel
  - @Observable + ビジネスロジック分離
- ✅ Phase 8: UI/UX改善完了
  - 天秤アニメーション付きロード画面
  - トースト通知 (成功/エラー/情報)
  - アクセシビリティ対応 (VoiceOver)
  - withAnimationによるリスト操作アニメーション
- ✅ Phase 9: テスト強化完了
  - 52テスト全成功
  - ViewModel / Extension / CSVテスト
- ✅ Phase 10: リリース準備完了
  - プライバシーポリシー / App Storeメタデータ
  - バージョン 1.0.0
- ✅ 管理ダッシュボード機能追加
  - PIN認証ゲート (AdminAuthManager / AdminAuthView)
  - ダッシュボード画面 (AdminDashboardView / AdminDashboardViewModel)
  - 売上・カテゴリ分析・在庫管理ビュー
  - テスト45件追加 (AdminAuthManagerTests 16件 + AdminDashboardViewModelTests 29件)

### フェーズ2: クラウド同期 + 認証 (実装済み)
- ✅ Phase 11: Supabase統合
  - Supabase Auth（メール/パスワード認証）
  - Apple Sign In対応
  - RLS (Row Level Security) によるデータ保護
  - アイテム・買い物リストのクラウド同期
  - 写真のクラウドストレージ (Supabase Storage)
  - オフライン対応（ローカル優先 + バックグラウンド同期）
  - 「ログインせずに使う」スキップフロー

### フェーズ3: サブスクリプション (設計完了・実装待ち)
- ⏳ Phase 12: Free/Pro プラン導入
  - StoreKit 2 Auto-Renewable Subscription
  - 月額 ¥150 / 年額 ¥1,500（17%割引）
  - 7日間無料トライアル
  - 機能制限: アイテム25件上限、写真・統計・CSV・同期をPro限定

---

## 🛠️ 技術スタック

### フェーズ1 (ローカル版)
- **言語**: Swift 5.9+
- **フレームワーク**: SwiftUI
- **データ永続化**: SwiftData
- **写真選択**: PhotosUI
- **グラフ**: Charts
- **最小OS**: iOS 17.0

### フェーズ2 (クラウド同期)
- **バックエンド**: Supabase (PostgreSQL)
- **認証**: Supabase Auth + Apple Sign In
- **API**: Supabase REST API (PostgREST)
- **ストレージ**: Supabase Storage (写真)
- **セキュリティ**: Row Level Security (RLS)

### フェーズ3 (サブスクリプション)
- **課金**: StoreKit 2 (Auto-Renewable Subscription)
- **プラン管理**: PlanManager (@Observable singleton)

---

## 📁 ドキュメント

### 📚 必読ドキュメント

1. **[仕様書](./仕様書.md)**
   - プロジェクト全体の要件定義
   - 機能一覧
   - データモデル
   - UI/UX設計

2. **[開発タスク一覧](./開発タスク一覧.md)**
   - フェーズごとのタスク
   - チェックリスト
   - 見積もり時間

3. **[Claude Code開発指示書](./Claude_Code開発指示書.md)**
   - 実装ガイド
   - コード例
   - トラブルシューティング

4. **[AWS統合技術設計書](./AWS統合技術設計書.md)**
   - AWSアーキテクチャ
   - 統合手順
   - コスト見積もり

---

## 🏗️ アーキテクチャ

```
My-Libra/
├── My_LibraApp.swift               # アプリエントリーポイント
├── Models/                          # データモデル
│   ├── Enums.swift
│   ├── Category.swift
│   ├── WishlistItem.swift
│   └── Item.swift
├── Views/                           # SwiftUI Views
│   ├── ContentView.swift
│   ├── LaunchScreen/                # ロード画面
│   ├── Components/                  # 共通コンポーネント
│   ├── Wishlist/                    # 買い物リスト
│   ├── OwnedItems/                  # 保有品
│   ├── Statistics/                  # 統計
│   └── Settings/                    # 設定 + 管理ダッシュボード
├── ViewModels/                      # ビジネスロジック (@Observable)
│   ├── WishlistViewModel.swift
│   ├── ItemViewModel.swift
│   ├── StatisticsViewModel.swift
│   └── AdminDashboardViewModel.swift
├── Services/                        # サービス層
│   └── AdminAuthManager.swift
└── Utilities/                       # ユーティリティ
    ├── Extensions.swift
    └── CSVExportService.swift
```

---

## 💾 データモデル

### 主要エンティティ

#### WishlistItem (買い物リスト)
```swift
- id: UUID
- name: String
- category: String
- estimatedPrice: Decimal?
- memo: String?
- createdAt: Date
- isPurchased: Bool
```

#### Item (購入済み商品)
```swift
- id: UUID
- name: String
- category: String
- purchasePrice: Decimal
- purchaseDate: Date
- condition: ItemCondition
- memo: String?
- imageData: Data?
- status: ItemStatus
- salePrice: Decimal?
- saleDate: Date?
- profit: Decimal? (計算プロパティ)
```

#### Category (カテゴリー)
```swift
- id: UUID
- name: String
- iconName: String
- isCustom: Bool
- sortOrder: Int
```

---

## 🎨 UI設計

### 画面構成

```
TabView
├─ 📝 買い物リスト
│  ├─ リスト表示
│  ├─ 新規追加
│  └─ 購入詳細入力
│
├─ 📦 保有品
│  ├─ 一覧表示
│  ├─ 詳細表示
│  ├─ 編集
│  └─ 売却入力
│
├─ 📊 統計
│  ├─ サマリーカード
│  ├─ 円グラフ
│  └─ 月別グラフ
│
└─ ⚙️ 設定
   ├─ カテゴリー管理
   ├─ データエクスポート
   └─ アプリ情報
```

---

## 🚦 始め方

### 必要な環境

- macOS Sonoma以降
- Xcode 15.0以上
- iOS 17.0以降のシミュレーター or 実機

### セットアップ

1. **リポジトリをクローン**
```bash
git clone https://github.com/yourusername/My-Libra.git
cd My-Libra
```

2. **Xcodeでプロジェクトを開く**
```bash
open My-Libra.xcodeproj
```

3. **ビルド & 実行**
- Xcode で `Command + R`
- シミュレーターまたは実機でテスト

---

## 📝 開発の流れ

### 1. データモデル実装
- Enums定義
- Category, WishlistItem, Item モデル作成

### 2. 基本UI構築
- ContentView (TabView)
- 各タブの基本レイアウト

### 3. 買い物リスト機能
- リスト表示
- 追加・削除
- 購入済み変換

### 4. 保有品管理機能
- 一覧表示
- 詳細表示
- 編集・売却

### 5. 統計機能
- サマリー計算
- グラフ表示

### 6. 設定機能
- カテゴリー管理
- データエクスポート

---

## 🧪 テスト

### 手動テストシナリオ

1. ✅ 買い物リストに商品を追加
2. ✅ 購入済みに変換
3. ✅ 保有品一覧で確認
4. ✅ 写真を追加
5. ✅ 売却処理
6. ✅ 統計で損益を確認
7. ✅ カテゴリーを追加
8. ✅ データをCSV出力

### UIテスト

- ライトモード / ダークモード
- 各デバイスサイズ (iPhone SE ~ iPhone 15 Pro Max)
- 横向き表示
- アクセシビリティ (VoiceOver, Dynamic Type)

---

## 📊 統計画面プレビュー

### サマリーカード
- **総購入額**: ¥150,000
- **総売却額**: ¥120,000
- **純損益**: -¥30,000
- **保有品数**: 45個

### グラフ
- **カテゴリー別支出** (円グラフ)
- **月別購入額** (棒グラフ)
- **月別損益** (折れ線グラフ)

---

## 🔐 プライバシー

- すべてのデータはローカルに保存 (フェーズ1)
- 写真はデバイス内に保存
- 外部サーバーへのデータ送信なし
- 将来的にはユーザー管理のクラウドバックアップ (フェーズ2)

---

## 📦 リリース予定

### v1.0.0 (フェーズ1)
- ローカルストレージ版
- 基本的なCRUD機能
- 統計・グラフ表示
- データエクスポート

### v2.0.0 (フェーズ2)
- Supabase統合
- クラウド同期
- 複数デバイス対応
- Apple Sign In

### v3.0.0 (フェーズ3)
- Free/Pro サブスクリプション
- StoreKit 2 課金機能
- 機能ゲーティング

### v4.0.0 (将来)
- バーコードスキャン
- OCR (レシート読み取り)
- Web版
- Android版

---

## 🐛 既知の問題

現在、既知の問題はありません。

バグを見つけた場合は、[Issues](https://github.com/yourusername/My-Libra/issues)で報告してください。

---

## 🤝 コントリビューション

プルリクエストを歓迎します!

1. フォーク
2. 機能ブランチ作成 (`git checkout -b feature/AmazingFeature`)
3. コミット (`git commit -m 'Add some AmazingFeature'`)
4. プッシュ (`git push origin feature/AmazingFeature`)
5. プルリクエスト作成

---

## 📄 ライセンス

このプロジェクトは MIT ライセンスの下でライセンスされています。

詳細は [LICENSE](LICENSE) ファイルを参照してください。

---

## 👤 作者

**Your Name**

- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

---

## 🙏 謝辞

- [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- [SwiftData](https://developer.apple.com/xcode/swiftdata/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [AWS Amplify](https://aws.amazon.com/amplify/)

---

## 📈 ロードマップ

### 2025 Q4
- [x] 仕様策定
- [x] Phase 1-2: データモデル・アプリ基盤
- [x] Phase 3-4: 買い物リスト・保有品管理
- [x] Phase 5: 統計機能
- [x] Phase 6: 設定機能

### 2026 Q1
- [x] Phase 7: ViewModel実装
- [x] Phase 8: UI/UX改善・ロード画面
- [x] Phase 9: テスト強化 (52テスト)
- [x] Phase 10: リリース準備
- [ ] TestFlightベータ配信
- [ ] App Store公開

### 2026 Q1-Q2
- [x] Phase 11: Supabase統合 (認証 + クラウド同期)
- [ ] Phase 12: Free/Pro サブスクリプション
- [ ] v2.0.0リリース (クラウド同期)
- [ ] v3.0.0リリース (サブスクリプション)

### 2026 Q3以降
- [ ] Web版開発
- [ ] Android版開発

---

## 💡 アイデア・提案

新機能のアイデアや改善提案がある場合は、[Discussions](https://github.com/yourusername/My-Libra/discussions)で議論しましょう!

---

## 📞 サポート

問題が発生した場合:

1. [ドキュメント](./docs/)を確認
2. [FAQ](./docs/FAQ.md)を確認
3. [Issues](https://github.com/yourusername/My-Libra/issues)で報告
4. [Discussions](https://github.com/yourusername/My-Libra/discussions)で質問

---

## ⭐ スターをください!

このプロジェクトが役に立った場合は、ぜひスターをください!

---

<div align="center">

**Made with ❤️ and Swift**

[🏠 ホーム](https://github.com/yourusername/My-Libra) •
[📖 ドキュメント](./docs/) •
[🐛 バグ報告](https://github.com/yourusername/My-Libra/issues) •
[💬 議論](https://github.com/yourusername/My-Libra/discussions)

</div>
