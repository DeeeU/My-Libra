# Supabase インフラ構成

## 概要

Self-hosted Supabase (Docker) を使用。将来的に Supabase Cloud (無料枠) へ移行可能。

## Docker 構成

`supabase start` で以下のサービスが起動:

| サービス | ポート | 用途 |
|---------|--------|------|
| API Gateway | 54321 | REST API (PostgREST) |
| PostgreSQL | 54322 | データベース |
| Studio | 54323 | 管理画面 (Web UI) |
| GoTrue | - | 認証サービス |
| Storage | - | ファイルストレージ |

## DB スキーマ

### profiles
`auth.users` を拡張するプロフィールテーブル。

| カラム | 型 | 備考 |
|--------|-----|------|
| id | UUID (PK, FK) | auth.users.id |
| display_name | TEXT | 表示名 |
| avatar_url | TEXT | アバター画像URL |
| created_at | TIMESTAMPTZ | 作成日時 |
| updated_at | TIMESTAMPTZ | 更新日時 (自動) |

### categories
| カラム | 型 | 備考 |
|--------|-----|------|
| id | UUID (PK) | |
| user_id | UUID (FK) | auth.users.id |
| name | TEXT | カテゴリー名 |
| icon_name | TEXT | SF Symbol 名 |
| is_custom | BOOLEAN | プリセット/カスタム |
| sort_order | INTEGER | 並び順 |
| is_deleted | BOOLEAN | 論理削除 |

### wishlist_items
| カラム | 型 | 備考 |
|--------|-----|------|
| id | UUID (PK) | |
| user_id | UUID (FK) | auth.users.id |
| name | TEXT | 商品名 |
| category | TEXT | カテゴリー名 |
| estimated_price | DOUBLE PRECISION | 予定価格 |
| memo | TEXT | メモ |
| is_purchased | BOOLEAN | 購入済みフラグ |
| is_deleted | BOOLEAN | 論理削除 |

### items
| カラム | 型 | 備考 |
|--------|-----|------|
| id | UUID (PK) | |
| user_id | UUID (FK) | auth.users.id |
| name | TEXT | 商品名 |
| category | TEXT | カテゴリー名 |
| purchase_price | DOUBLE PRECISION | 購入価格 |
| purchase_date | TIMESTAMPTZ | 購入日 |
| condition | TEXT | 状態 (新品/中古等) |
| memo | TEXT | メモ |
| image_url | TEXT | Storage パス |
| status | TEXT | owned/sold |
| sale_price | DOUBLE PRECISION | 売却価格 |
| sale_date | TIMESTAMPTZ | 売却日 |
| is_deleted | BOOLEAN | 論理削除 |

## RLS (Row Level Security)

全テーブルで RLS 有効。ポリシー: `auth.uid() = user_id`

| テーブル | SELECT | INSERT | UPDATE | DELETE |
|---------|--------|--------|--------|--------|
| profiles | own | - | own | - |
| categories | own | own | own | own |
| wishlist_items | own | own | own | own |
| items | own | own | own | own |

## Storage 設計

### item-images バケット
- **公開**: false (認証必要)
- **サイズ制限**: 5MB
- **許可MIME**: image/jpeg, image/png, image/heic, image/webp
- **パス構造**: `{user_id}/{item_id}.jpg`
- **RLSポリシー**: フォルダ名 = user_id で分離

## 管理画面 (Supabase Studio)

**URL**: `http://localhost:54323`

### 主な機能
- テーブルエディタ: 全データ閲覧・編集
- Authentication: ユーザー管理
- SQL Editor: 直接クエリ実行
- Storage: 画像ファイル管理
- API Docs: REST API ドキュメント自動生成

## セットアップ手順

```bash
# 1. Supabase CLI インストール
brew install supabase/tap/supabase

# 2. Docker Desktop を起動

# 3. プロジェクトルートで
supabase start

# 4. Studio にアクセス
open http://localhost:54323

# 5. 停止
supabase stop
```

## 環境変数

| 変数 | デフォルト値 | 用途 |
|------|------------|------|
| SUPABASE_URL | http://127.0.0.1:54321 | API URL |
| SUPABASE_ANON_KEY | (ローカル開発用キー) | 匿名キー |
