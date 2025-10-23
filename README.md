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
- 🔄 Phase 2: 基本UI構築中
- ⏳ リリース準備

### フェーズ2: クラウド版 (予定)
- ⏳ AWS統合
- ⏳ 複数デバイス同期
- ⏳ バックアップ機能

---

## 🛠️ 技術スタック

### フェーズ1 (ローカル版)
- **言語**: Swift 5.9+
- **フレームワーク**: SwiftUI
- **データ永続化**: SwiftData
- **写真選択**: PhotosUI
- **グラフ**: Charts
- **最小OS**: iOS 17.0

### フェーズ2 (クラウド版)
- **バックエンド**: AWS Amplify
- **認証**: Amazon Cognito
- **API**: AWS AppSync (GraphQL)
- **データベース**: Amazon DynamoDB
- **ストレージ**: Amazon S3
- **サーバーレス**: AWS Lambda

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
│   ├── Wishlist/                    # 買い物リスト
│   ├── OwnedItems/                  # 保有品
│   ├── Statistics/                  # 統計
│   └── Settings/                    # 設定
├── ViewModels/                      # ビジネスロジック
└── Utilities/                       # ユーティリティ
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
- AWS統合
- クラウド同期
- 複数デバイス対応
- バックアップ・復元

### v3.0.0 (将来)
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
- [ ] フェーズ1実装
- [ ] TestFlightベータ配信
- [ ] App Store公開

### 2026 Q1
- [ ] ユーザーフィードバック収集
- [ ] UI/UX改善
- [ ] AWS統合設計

### 2026 Q2
- [ ] フェーズ2実装(AWS統合)
- [ ] 複数デバイス同期
- [ ] v2.0.0リリース

### 2026 Q3以降
- [ ] Web版開発
- [ ] Android版開発
- [ ] API公開

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
