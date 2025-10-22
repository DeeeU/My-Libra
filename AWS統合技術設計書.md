# AWS統合 技術設計書 (フェーズ2)

## 1. 概要

### 1.1 目的
ローカル版iOSアプリにAWSバックエンドを統合し、以下を実現:
- クラウドへのデータバックアップ
- 複数デバイス間でのデータ同期
- 将来的なWeb版・Android版への拡張基盤

### 1.2 統合タイミング
- フェーズ1(ローカル版)完成後
- ユーザーフィードバック収集後
- MVP検証完了後

---

## 2. アーキテクチャ概要

### 2.1 全体構成
```
[iOS App (SwiftUI + SwiftData)]
         ↓
[AWS Amplify iOS SDK]
         ↓
    ┌────────────────────────────┐
    │      AWS Services          │
    ├────────────────────────────┤
    │  • Cognito (認証)          │
    │  • AppSync (GraphQL API)   │
    │  • DynamoDB (データベース)  │
    │  • S3 (画像ストレージ)      │
    │  • Lambda (ビジネスロジック)│
    └────────────────────────────┘
```

### 2.2 データフロー
```
ローカル(SwiftData) ←→ 同期層 ←→ AWS(DynamoDB/S3)
                    ↑
              Amplify DataStore
```

---

## 3. AWSサービス選定

### 3.1 認証: Amazon Cognito

#### 選定理由
- ユーザー管理が簡単
- メール/パスワード認証
- ソーシャルログイン対応
- MFA対応可能

#### 実装内容
- ユーザープール作成
- サインアップ/サインイン
- パスワードリセット
- トークン管理

#### 料金
- 月間アクティブユーザー(MAU)課金
- 最初の50,000 MAU: 無料
- 以降: $0.0055/MAU

---

### 3.2 API: AWS AppSync (GraphQL)

#### 選定理由
- リアルタイム同期
- オフライン対応
- 競合解決機能
- GraphQLの柔軟性

#### スキーマ設計

```graphql
# Category
type Category @model @auth(rules: [{ allow: owner }]) {
  id: ID!
  name: String!
  iconName: String!
  isCustom: Boolean!
  sortOrder: Int!
  owner: String
}

# WishlistItem
type WishlistItem @model @auth(rules: [{ allow: owner }]) {
  id: ID!
  name: String!
  category: String!
  estimatedPrice: Float
  memo: String
  createdAt: AWSDateTime!
  isPurchased: Boolean!
  owner: String
}

# Item
type Item @model @auth(rules: [{ allow: owner }]) {
  id: ID!
  name: String!
  category: String!
  purchasePrice: Float!
  purchaseDate: AWSDate!
  condition: ItemCondition!
  memo: String
  imageKey: String  # S3キー
  status: ItemStatus!
  salePrice: Float
  saleDate: AWSDate
  owner: String
}

enum ItemCondition {
  NEW
  USED
  DAMAGED
  JUNK
}

enum ItemStatus {
  OWNED
  SOLD
}
```

#### 料金
- クエリ/ミューテーション: $4.00/100万リクエスト
- リアルタイム更新: $2.00/100万分
- 最初の12ヶ月: 250,000リクエスト/月 無料

---

### 3.3 データベース: Amazon DynamoDB

#### 選定理由
- サーバーレス
- 自動スケーリング
- AppSyncとの統合が簡単
- 高速アクセス

#### テーブル設計
AppSyncが自動生成するため、手動設定不要

#### パーティションキー戦略
```
PK: owner#{userId}
SK: {modelType}#{id}

例:
PK: owner#user123
SK: Item#abc-def-123
```

#### 料金
- オンデマンド課金
- 書き込み: $1.25/100万リクエスト
- 読み取り: $0.25/100万リクエスト
- ストレージ: $0.25/GB/月
- 最初の12ヶ月: 25GB無料

---

### 3.4 ストレージ: Amazon S3

#### 選定理由
- 画像保存に最適
- 高い可用性
- CDN統合可能(CloudFront)
- ライフサイクル管理

#### バケット構成
```
my-libra-images/
├── public/          # 公開画像(将来)
└── protected/       # ユーザー別画像
    └── {userId}/
        └── items/
            └── {itemId}/
                └── image.jpg
```

#### 画像最適化
- アップロード時にリサイズ(Lambda)
- サムネイル生成
- WebP変換

#### 料金
- ストレージ: $0.023/GB/月(標準)
- PUT/COPY/POST/LIST: $0.005/1000リクエスト
- GET/SELECT: $0.0004/1000リクエスト
- 最初の12ヶ月: 5GB無料

---

### 3.5 サーバーレス関数: AWS Lambda (オプション)

#### 使用ケース
- 画像処理(リサイズ、変換)
- データバリデーション
- 統計計算
- バッチ処理

#### 実装例
```javascript
// 画像リサイズLambda
exports.handler = async (event) => {
    const s3 = new AWS.S3();
    const sharp = require('sharp');
    
    // S3から画像取得
    const image = await s3.getObject({...}).promise();
    
    // リサイズ処理
    const resized = await sharp(image.Body)
        .resize(800, 800, { fit: 'inside' })
        .jpeg({ quality: 80 })
        .toBuffer();
    
    // サムネイル生成
    const thumbnail = await sharp(image.Body)
        .resize(200, 200, { fit: 'cover' })
        .jpeg({ quality: 70 })
        .toBuffer();
    
    // S3に保存
    await Promise.all([
        s3.putObject({ Key: 'resized/...', Body: resized }).promise(),
        s3.putObject({ Key: 'thumbnail/...', Body: thumbnail }).promise()
    ]);
};
```

#### 料金
- 実行時間: $0.0000166667/GB-秒
- リクエスト: $0.20/100万リクエスト
- 常に無料: 100万リクエスト/月、400,000 GB-秒/月

---

## 4. AWS Amplify統合

### 4.1 Amplifyとは
- AWSサービスをモバイル/Webアプリに統合するフレームワーク
- CLI/Studioで簡単セットアップ
- iOS SDKで簡単実装

### 4.2 セットアップ手順

#### Step 1: Amplify CLI インストール
```bash
npm install -g @aws-amplify/cli
amplify configure
```

#### Step 2: プロジェクト初期化
```bash
cd My-Libra
amplify init

# 質問への回答:
# - Project name: My-Libra
# - Environment: dev
# - Default editor: Xcode
# - App type: ios
# - Configuration: (自動検出)
```

#### Step 3: 認証追加
```bash
amplify add auth

# 質問への回答:
# - Default configuration
# - Username (Email)
# - Advanced settings: No
```

#### Step 4: API追加
```bash
amplify add api

# 質問への回答:
# - GraphQL
# - API name: My-LibraAPI
# - Authorization mode: Amazon Cognito User Pool
# - Schema: 上記のGraphQLスキーマを使用
```

#### Step 5: Storage追加
```bash
amplify add storage

# 質問への回答:
# - Content (Images, audio, video, etc.)
# - Bucket name: mylibraimages
# - Auth/Guest access: Auth users only
# - Access: read/write
```

#### Step 6: デプロイ
```bash
amplify push
```

---

### 4.3 iOS SDK統合

#### Step 1: SPM (Swift Package Manager)で追加
```swift
// Package.swift または Xcode > File > Add Packages
dependencies: [
    .package(url: "https://github.com/aws-amplify/amplify-swift", from: "2.0.0")
]

// 追加するライブラリ:
// - Amplify
// - AWSCognitoAuthPlugin
// - AWSAPIPlugin
// - AWSDataStorePlugin
// - AWSS3StoragePlugin
```

#### Step 2: Amplify設定
```swift
// My_LibraApp.swift
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSS3StoragePlugin
import AWSDataStorePlugin

@main
struct My_LibraApp: App {
    init() {
        configureAmplify()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [WishlistItem.self, Item.self, Category.self])
    }
    
    func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.add(plugin: AWSDataStorePlugin(modelRegistration: AmplifyModels()))
            
            try Amplify.configure()
            print("✅ Amplify configured successfully")
        } catch {
            print("❌ Failed to configure Amplify: \(error)")
        }
    }
}
```

---

## 5. 同期戦略

### 5.1 DataStore vs 直接API呼び出し

#### DataStore (推奨)
**メリット**:
- オフライン対応自動
- 自動同期
- 競合解決
- ローカルキャッシュ

**デメリット**:
- 学習コスト
- 複雑性増加

#### 直接API呼び出し
**メリット**:
- シンプル
- 完全制御

**デメリット**:
- オフライン対応を自分で実装
- 同期ロジックを自分で実装

### 5.2 ハイブリッドアプローチ (推奨)

```
[SwiftData (ローカル)] 
         ↓
[同期マネージャー] ← 自作
         ↓
[Amplify API (クラウド)]
```

#### 同期マネージャーの実装
```swift
class SyncManager: ObservableObject {
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // アップロード
    func syncToCloud() async throws {
        isSyncing = true
        defer { isSyncing = false }
        
        // ローカルの変更をクラウドへ
        let localItems = try modelContext.fetch(FetchDescriptor<Item>())
        
        for item in localItems where item.needsSync {
            try await uploadItem(item)
            item.needsSync = false
        }
        
        lastSyncDate = Date()
    }
    
    // ダウンロード
    func syncFromCloud() async throws {
        isSyncing = true
        defer { isSyncing = false }
        
        // クラウドの変更をローカルへ
        let cloudItems = try await fetchCloudItems()
        
        for cloudItem in cloudItems {
            if let localItem = try findLocalItem(id: cloudItem.id) {
                // 競合解決(最終更新日で判定)
                if cloudItem.updatedAt > localItem.updatedAt {
                    updateLocalItem(localItem, with: cloudItem)
                }
            } else {
                // 新規作成
                createLocalItem(from: cloudItem)
            }
        }
        
        lastSyncDate = Date()
    }
    
    private func uploadItem(_ item: Item) async throws {
        // 画像アップロード(ある場合)
        var imageKey: String?
        if let imageData = item.imageData {
            imageKey = try await uploadImage(imageData, itemId: item.id)
        }
        
        // GraphQL Mutation
        let mutation = CreateItemMutation(
            input: CreateItemInput(
                id: item.id.uuidString,
                name: item.name,
                category: item.category,
                purchasePrice: Double(truncating: item.purchasePrice as NSNumber),
                purchaseDate: item.purchaseDate.iso8601String,
                condition: item.condition.rawValue,
                imageKey: imageKey,
                status: item.status.rawValue
                // ... その他のフィールド
            )
        )
        
        _ = try await Amplify.API.mutate(request: .mutation(of: mutation))
    }
    
    private func uploadImage(_ imageData: Data, itemId: UUID) async throws -> String {
        let key = "items/\(itemId.uuidString)/image.jpg"
        
        try await Amplify.Storage.uploadData(
            key: key,
            data: imageData,
            options: .init(
                accessLevel: .protected,
                metadata: ["contentType": "image/jpeg"]
            )
        ).value
        
        return key
    }
    
    private func fetchCloudItems() async throws -> [CloudItem] {
        let query = ListItemsQuery()
        let result = try await Amplify.API.query(request: .query(of: query))
        
        switch result {
        case .success(let data):
            return data.listItems?.items ?? []
        case .failure(let error):
            throw error
        }
    }
}
```

---

## 6. 認証フロー

### 6.1 サインアップ
```swift
func signUp(email: String, password: String) async throws {
    let userAttributes = [
        AuthUserAttribute(.email, value: email)
    ]
    
    let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
    
    let result = try await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: options
    )
    
    if case .confirmUser = result.nextStep {
        // メール確認が必要
        // 確認コード入力画面へ
    }
}

func confirmSignUp(email: String, code: String) async throws {
    try await Amplify.Auth.confirmSignUp(
        for: email,
        confirmationCode: code
    )
}
```

### 6.2 サインイン
```swift
func signIn(email: String, password: String) async throws {
    let result = try await Amplify.Auth.signIn(
        username: email,
        password: password
    )
    
    if result.isSignedIn {
        // サインイン成功
        // メイン画面へ
    }
}
```

### 6.3 サインアウト
```swift
func signOut() async throws {
    try await Amplify.Auth.signOut()
}
```

### 6.4 セッション管理
```swift
func checkCurrentUser() async throws -> Bool {
    let session = try await Amplify.Auth.fetchAuthSession()
    return session.isSignedIn
}
```

---

## 7. エラーハンドリング

### 7.1 ネットワークエラー
```swift
do {
    try await syncToCloud()
} catch {
    if let apiError = error as? APIError {
        switch apiError {
        case .networkError:
            // オフライン状態
            showAlert("インターネット接続を確認してください")
        case .operationError:
            // API エラー
            showAlert("同期に失敗しました")
        default:
            break
        }
    }
}
```

### 7.2 認証エラー
```swift
catch {
    if let authError = error as? AuthError {
        switch authError {
        case .notAuthorized:
            // 再ログインが必要
            navigateToLogin()
        case .sessionExpired:
            // トークン期限切れ
            try await refreshSession()
        default:
            break
        }
    }
}
```

---

## 8. コスト見積もり

### 8.1 想定ユーザー数
- アクティブユーザー: 1,000人/月
- 1人あたりアイテム数: 100個
- 1人あたり画像数: 50枚
- 1人あたり同期頻度: 10回/日

### 8.2 月間コスト試算

#### Cognito
- 1,000 MAU × $0 (50,000まで無料) = **$0**

#### AppSync
- 1,000ユーザー × 10回/日 × 30日 = 300,000リクエスト
- 300,000 × $4/100万 = **$1.20**

#### DynamoDB
- 書き込み: 300,000 × $1.25/100万 = **$0.38**
- 読み取り: 300,000 × $0.25/100万 = **$0.08**
- ストレージ: (1,000 × 100 × 1KB) = 100MB = **$0.03**

#### S3
- ストレージ: (1,000 × 50 × 500KB) = 25GB × $0.023 = **$0.58**
- PUT: (1,000 × 5/月 × $0.005/1000) = **$0.03**
- GET: (1,000 × 50/月 × $0.0004/1000) = **$0.02**

#### Lambda (画像処理)
- 実行回数: 5,000回/月
- 実行時間: 1秒/回
- (5,000 × 1秒 × 512MB × $0.0000166667) = **$0.04**

#### データ転送
- 画像ダウンロード: 約10GB/月 = **$0.90**

### 8.3 合計
**月間: 約 $3.26**
**年間: 約 $39.12**

※ 1,000ユーザーの場合、1ユーザーあたり約$0.003/月

---

## 9. セキュリティ

### 9.1 認証・認可
- Cognito User Pool
- JWTトークン
- API Gatewayレベルでの認証
- DynamoDBの行レベルセキュリティ

### 9.2 データ暗号化
- 転送時: TLS 1.2+
- 保管時: AES-256
- S3: デフォルトで暗号化

### 9.3 アクセス制御
```graphql
@auth(rules: [
  { allow: owner, operations: [create, read, update, delete] }
])
```

### 9.4 IAM ポリシー
- 最小権限の原則
- Lambdaには必要最小限の権限のみ付与

---

## 10. モニタリング & ロギング

### 10.1 CloudWatch
- API リクエスト数
- エラー率
- レイテンシー
- Lambda実行時間

### 10.2 X-Ray
- 分散トレーシング
- パフォーマンスボトルネック特定

### 10.3 アラート設定
- エラー率 > 5%
- レイテンシー > 2秒
- Lambda失敗率 > 1%

---

## 11. バックアップ & リカバリ

### 11.1 DynamoDB
- ポイントインタイムリカバリ(PITR)有効化
- 日次バックアップ

### 11.2 S3
- バージョニング有効化
- ライフサイクルポリシー
  - 30日後に標準IA
  - 90日後にGlacier

---

## 12. 開発環境 vs 本番環境

### 12.1 環境分離
```bash
# 開発環境
amplify env add dev
amplify push

# 本番環境
amplify env add prod
amplify push
```

### 12.2 環境ごとの設定
- 開発: 制約緩い、コスト最小
- 本番: セキュリティ強化、パフォーマンス重視

---

## 13. デプロイメント

### 13.1 CI/CD パイプライン
```yaml
# GitHub Actions例
name: Deploy to AWS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
      - name: Deploy backend
        run: |
          npm install -g @aws-amplify/cli
          amplify push --yes
```

### 13.2 ロールバック戦略
- Amplifyは前のバージョンに簡単に戻せる
- DynamoDBのバックアップから復元

---

## 14. 将来の拡張

### 14.1 Web版
- React/Vue.js
- Amplify JS SDK
- 同じバックエンド利用

### 14.2 Android版
- Kotlin
- Amplify Android SDK
- 同じバックエンド利用

### 14.3 API公開
- API Keyでの外部アクセス
- Rate Limiting
- Usage Plans

---

## 15. 移行手順 (ローカル → クラウド)

### Step 1: AWS環境構築
```bash
amplify init
amplify add auth
amplify add api
amplify add storage
amplify push
```

### Step 2: iOS SDKインストール
- SPMで追加
- Amplify設定

### Step 3: 認証画面追加
- SignUpView
- SignInView
- 既存アプリに統合

### Step 4: 同期マネージャー実装
- SyncManager作成
- アップロード/ダウンロードロジック

### Step 5: UI統合
- 同期ボタン追加
- 同期状態表示
- エラーハンドリング

### Step 6: テスト
- 同期動作確認
- オフライン動作確認
- 競合解決確認

### Step 7: 段階的ロールアウト
- TestFlightでベータ配信
- フィードバック収集
- 本番リリース

---

## 付録A: 便利なAmplifyコマンド

```bash
# 状態確認
amplify status

# ローカル開発
amplify mock api

# ログ確認
amplify console api

# 環境削除
amplify delete

# スキーマ更新
amplify update api
amplify push
```

---

## 付録B: トラブルシューティング

### B.1 Amplify設定がうまくいかない
```bash
# キャッシュクリア
rm -rf amplify/.config
amplify init
```

### B.2 同期が動作しない
- ネットワーク確認
- 認証トークン確認
- CloudWatch Logsでエラー確認

### B.3 画像アップロードが遅い
- 画像を事前リサイズ
- 非同期アップロード
- プログレス表示

---

**作成日**: 2025年10月22日
**バージョン**: 1.0
**対象フェーズ**: フェーズ2 (AWS統合)
