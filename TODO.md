# My-Libra App Store リリース準備 TODO

## 完了済み

- [x] Phase 1: データモデル（Enums, Category, WishlistItem, Item）
- [x] Phase 2: アプリ基盤（SwiftData, TabView, Extensions）
- [x] Phase 3: 買い物リスト機能
- [x] Phase 4: 保有品管理機能
- [x] Phase 5: 統計機能（Swift Charts）
- [x] Phase 6: 設定機能（カテゴリー管理・CSV エクスポート・全データ削除・アプリ情報）
- [x] サブスクリプション機能（StoreKit 2 / Free・Pro プラン）
- [x] 統計画面の Free ユーザー向けマスキング表示
- [x] アカウント機能（Supabase Auth: ログイン・登録・プロフィール）
- [x] クラウド同期基盤（Supabase DB / Storage、オフラインファースト同期、画像同期）
- [x] PrivacyInfo.xcprivacy 作成（UserDefaults の CA92.1 宣言）
- [x] NSPhotoLibraryUsageDescription 追加（Info.plist キー）
- [x] デプロイメントターゲットを iOS 18.0 → 17.0 に変更（全6箇所）

---

## 開発タスク

### Phase 6 の残り
- [ ] アプリ情報: ライセンス表記（OSS ライセンス一覧。supabase-swift 等）を追加（バージョン・ビルド・GitHub リンクは実装済み）

### Supabase 本番環境
- [ ] 本番用 Supabase プロジェクトを作成し、`supabase/migrations/` を適用
- [ ] `Services/Config.swift` の接続先を本番に切り替える仕組み（現在は環境変数未設定時に `http://127.0.0.1:54321` を使用）
- [ ] 認証のリダイレクト URL（`myLibra://auth/callback`）を本番側に登録
- [ ] プライバシーポリシーにクラウド同期時のデータ取り扱いを追記

### デザイン統一（アイコンベースのリブランディング）

#### 高優先度
- [ ] AccentColor をオレンジ/ゴールド系（#F5A623 等）に設定（現在未設定＝青）
- [ ] ハードコードされた `.blue` を AccentColor に統一（WishlistView L147, OwnedItemsView L194, PurchaseDetailView L55, StatisticsView L188/L290）
- [ ] ランチスクリーンの天秤をアイコンの色（オレンジ/ゴールド）に合わせる

#### 中優先度
- [ ] フィルターUI統一（FilterChip / StatusFilterButton / PeriodPicker を共通コンポーネント化）
- [ ] cornerRadius の統一ルール策定（8 / 12 / 16 の3段階に整理）
- [ ] 設定画面: セクションアイコンに個別カラー（crown=ゴールド, folder=オレンジ, trash=赤 等）
- [ ] 設定画面: サブスクリプション行をプロモーションバナー風に強化
- [ ] StatusBadge の売却済み色をアイコンのオレンジと差別化（パープルやティール等）

#### 低優先度
- [ ] SummaryCard のカラーパレットをアイコンのトーンに合わせて見直し
- [ ] グラフの BarMark 配色をオレンジ〜ゴールド系グラデーションに変更
- [ ] 空状態のイラスト/アイコンをアプリのブランドに合わせて改善
- [ ] 設定画面: アプリ情報セクションにアイコン+アプリ名ヘッダー追加
- [ ] 設定画面: データ削除ボタンを別セクション（最下部）に分離
- [ ] TabBarアイコンの差別化検討（cart/shippingbox が似た印象）

### バグ修正・改善
- [ ] 既知のバグがあれば対応
- [ ] パフォーマンス最適化（大量データでの動作確認）

---

## リリース準備（必須）

### 4. Apple Developer アカウントでコード署名設定
- [ ] Apple Developer Program に登録（年額 ¥15,800）
- [ ] Xcode で DEVELOPMENT_TEAM を設定
- [ ] 自動署名 (Automatic Signing) を有効化
- [ ] 実機ビルドで動作確認

### 5. App Store Connect でサブスク商品・メタデータ登録
- [ ] App Store Connect でアプリを新規作成（Bundle ID: `DeeeU.My-Libra`）
- [ ] サブスクリプショングループ「My-Libra Pro」を作成
  - [ ] 月額プラン `com.deeu.mylibra.pro.monthly`（¥150、7日間無料トライアル）
  - [ ] 年額プラン `com.deeu.mylibra.pro.yearly`（¥1,500、7日間無料トライアル）
- [ ] App Store メタデータ入力
  - [ ] アプリ名・サブタイトル
  - [ ] 説明文（日本語）
  - [ ] キーワード
  - [ ] カテゴリ（ライフスタイル / ファイナンス）
  - [ ] 年齢制限レーティング
  - [ ] スクリーンショット（6.7インチ・6.1インチ）
  - [ ] アプリプレビュー動画（任意）

### 6. プライバシーポリシーの Web ホスティング
- [ ] PRIVACY_POLICY.md を Web ページとして公開（GitHub Pages 等）
- [ ] 利用規約ページも作成・公開
- [ ] App Store Connect にプライバシーポリシー URL を登録
- [ ] PaywallView のリンクを実際の URL に更新

## 推奨（品質向上）

### 7. アクセシビリティ強化
- [ ] 全インタラクティブ要素に `.accessibilityLabel` を追加
- [ ] 価格・日付に `.accessibilityValue` を設定
- [ ] チャート（Swift Charts）のアクセシビリティ対応
- [ ] Dynamic Type のテスト
- [ ] VoiceOver での全画面通しテスト

### 8. オンボーディング画面の追加（任意）
- [ ] 初回起動時のチュートリアル / ウォークスルー
- [ ] 主要機能のハイライト（3〜4画面）
- [ ] スキップ可能な設計

## 提出前の最終チェック

- [ ] TestFlight で実機テスト
- [ ] クラッシュ・メモリリークの確認（Instruments）
- [ ] ダークモードの全画面目視確認
- [ ] iPad レイアウトの確認
- [ ] App Store Review Guidelines の確認
  - [ ] 4.3 スパム — 類似アプリとの差別化
  - [ ] 3.1.1 アプリ内課金 — サブスクの復元ボタン必須（✅ 実装済み）
  - [ ] 5.1.1 プライバシー — データ収集の透明性

---

## リリース手順（順番どおりに実施）

1. **デザイン統一・Supabase 本番環境の構築** → PR マージ
2. **Apple Developer 登録** → コード署名設定・実機ビルド確認
3. **プライバシーポリシー公開** → GitHub Pages 等で URL を取得
4. **App Store Connect 設定** → アプリ作成・サブスク商品登録・メタデータ入力
5. **TestFlight 配信** → 実機テスト（自分 + ベータテスター）
6. **最終チェック** → ダークモード・iPad・アクセシビリティ確認
7. **App Store 審査提出** → 審査通過後リリース
