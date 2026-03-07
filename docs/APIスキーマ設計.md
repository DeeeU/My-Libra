# API スキーマ設計

## 概要

Supabase PostgREST が PostgreSQL テーブルから自動生成する REST API を使用。
RLS により全エンドポイントでユーザー認証が必要。

## ベース URL

- ローカル: `http://127.0.0.1:54321/rest/v1/`
- ヘッダー: `Authorization: Bearer {access_token}`, `apikey: {anon_key}`

## エンドポイント一覧

### Profiles

| メソッド | パス | 説明 |
|---------|------|------|
| GET | `/profiles?id=eq.{uuid}` | 自分のプロフィール取得 |
| PATCH | `/profiles?id=eq.{uuid}` | プロフィール更新 |

### Categories

| メソッド | パス | 説明 |
|---------|------|------|
| GET | `/categories` | カテゴリー一覧 |
| POST | `/categories` | カテゴリー作成 |
| PUT | `/categories` | カテゴリー upsert |
| PATCH | `/categories?id=eq.{uuid}` | カテゴリー更新 |
| DELETE | `/categories?id=eq.{uuid}` | カテゴリー削除 |

### Wishlist Items

| メソッド | パス | 説明 |
|---------|------|------|
| GET | `/wishlist_items` | 買い物リスト一覧 |
| GET | `/wishlist_items?updated_at=gt.{iso8601}` | 差分取得 |
| POST | `/wishlist_items` | アイテム作成 |
| PUT | `/wishlist_items` | アイテム upsert |
| PATCH | `/wishlist_items?id=eq.{uuid}` | アイテム更新 |
| DELETE | `/wishlist_items?id=eq.{uuid}` | アイテム削除 |

### Items

| メソッド | パス | 説明 |
|---------|------|------|
| GET | `/items` | 保有品一覧 |
| GET | `/items?is_deleted=eq.false&updated_at=gt.{iso8601}` | 差分取得 |
| POST | `/items` | アイテム作成 |
| PUT | `/items` | アイテム upsert |
| PATCH | `/items?id=eq.{uuid}` | アイテム更新 |
| DELETE | `/items?id=eq.{uuid}` | アイテム削除 |

## RLS ポリシー詳細

### profiles テーブル
```sql
-- SELECT: 自分のプロフィールのみ
CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

-- UPDATE: 自分のプロフィールのみ
CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);
```

### データテーブル共通パターン (categories / wishlist_items / items)
```sql
-- SELECT
USING (auth.uid() = user_id);

-- INSERT
WITH CHECK (auth.uid() = user_id);

-- UPDATE
USING (auth.uid() = user_id);

-- DELETE
USING (auth.uid() = user_id);
```

## Storage API

### 画像アップロード
```
POST /storage/v1/object/item-images/{user_id}/{item_id}.jpg
Content-Type: image/jpeg
Authorization: Bearer {access_token}
```

### 画像ダウンロード
```
GET /storage/v1/object/item-images/{path}
Authorization: Bearer {access_token}
```

### Storage RLS
```sql
-- フォルダ名 (1階層目) がユーザーIDと一致する場合のみアクセス許可
auth.uid()::text = (storage.foldername(name))[1]
```

## iOS SDK での使用例

```swift
// Upsert
try await supabase.client.from("items")
    .upsert(payload)
    .execute()

// Filtered Select
try await supabase.client.from("items")
    .select()
    .eq("is_deleted", value: false)
    .gt("updated_at", value: lastSync.ISO8601Format())
    .execute()
    .value

// Storage Upload
try await supabase.client.storage
    .from("item-images")
    .upload(path, data: data, options: .init(contentType: "image/jpeg", upsert: true))
```
