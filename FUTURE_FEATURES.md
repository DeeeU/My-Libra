# 今後の施策リスト

## 発売日通知機能

ユーザーがフォローしているカテゴリの新商品発売日を取得し、ローカル通知で知らせる機能。

### 実装構成（案）

- データ取得: `URLSession` + `BGTaskScheduler`（1日1回バックグラウンドfetch）
- 通知: `UNUserNotificationCenter`（ローカル通知）
- UI: 発売カレンダー画面 + カテゴリごとのフォロー設定

---

### Phase 1: API連携（実装難易度: 低）

#### ポケモンカード
- **データソース**: [pokemontcg.io](https://pokemontcg.io/) / [TCGdex](https://tcgdex.dev/)
- pokemontcg.io: 無料REST API。セットごとに `releaseDate` フィールドあり
- TCGdex: 多言語対応（日本語セットもカバー）、REST + GraphQL
- 日本版は英語版より2〜3ヶ月先行発売（2月・5月・8月・11月パターン）
- **実装難易度**: 低

#### 遊戯王
- **データソース**: [YGOPRODeck API v7](https://ygoprodeck.com/api-guide/)
- 無料API。`ocg_date`（日本発売日）と `tcg_date`（海外発売日）を直接取得可能
- `dateregion=ocg` パラメータでOCGフィルタリング対応
- カードセット情報: `db.ygoprodeck.com/api/v7/cardsetsinfo.php`
- **実装難易度**: 低

#### ワンピースTCG
- **データソース**: [OPTCG API](https://optcgapi.com/) / [JustTCG API](https://justtcg.com/docs)
- OPTCG API: OP-01〜OP-11 + スターターデッキ対応。主に英語版
- 日本版の発売日は公式サイト（onepiece-cardgame.com）からscraping必要
- 公式Twitter: [@ONEPIECE_tcg](https://x.com/ONEPIECE_tcg)
- **実装難易度**: 低〜中

#### ドラゴンボールカード / デジモンTCG
- **データソース**: [API TCG](https://www.apitcg.com/) / [JustTCG API](https://justtcg.com/docs)
- 複数TCGをまとめてカバーするマルチゲームAPI
- **実装難易度**: 低〜中

#### Magic: The Gathering
- **データソース**: [Scryfall API](https://scryfall.com/docs/api)
- 非常に高品質な無料API。セット発売日を構造化データで取得可能
- **実装難易度**: 低

---

### Phase 2: 構造化Webデータ（実装難易度: 中）

#### Apple製品
- **データソース**: Wikidata SPARQL / Apple Newsroom RSS
- 公式APIなし。Wikidataから構造化データをSPARQLクエリで取得可能
- 新製品はApple Newsroom RSSまたはMacRumorsで追跡
- グローバル同時発売のため日本固有の対応は不要
- **実装難易度**: 中

#### ガンプラ（Gundam Model Kits）
- **データソース**: [Bandai Hobbyサイト](https://global.bandai-hobby.net/en-us/schedule/)
- APIなしだが、公式サイトに構造化された発売スケジュールページあり
- [HobbySearch](https://www.1999.co.jp/eng/list/releaselist/109) にも発売日リストあり
- 日本市場で非常に需要が高い
- **実装難易度**: 中

#### Nintendo（ゲーム機・ソフト）
- **データソース**: Wikipedia / Wikidata
- APIなし。Wikidata SPARQLまたはWikipediaのMediaWiki APIから取得
- Nintendo Directの発表をトリガーに更新
- **実装難易度**: 中

#### フィギュア（TAMASHII NATIONS / S.H.Figuarts）
- **データソース**: [TAMASHII Web カレンダー](https://tamashiiweb.com/calendar/)
- 月別発売カレンダーページあり（scraping対象）
- **実装難易度**: 中

---

### Phase 3: 高難度（実装難易度: 高）

#### Nike（スニーカー）
- **データソース**: なし（公式API非公開）
- Nike SNKRSはAkamai bot対策あり。直接scrapingは困難
- 代替手段: SNKRDUNK（スニーカーダンク）のカレンダーページscraping
- 他候補: SoleRetriever、Fullress、SneakerWars（日本向けニュースサイト）
- TOS違反リスクあり。商用scrapingサービス（Apify等）は有料
- **実装難易度**: 高

#### ユニオンアリーナ
- **データソース**: [Fandom Wiki](https://unionarena-tcg.fandom.com/)（CC-BY-SA）
- 公式・サードパーティAPIともになし
- 公式サイト（unionarena-tcg.com）のニュースページscraping
- 年間リリース数が少ない（6〜8製品）ため手動管理も選択肢
- 公式Twitter: [@UNION_ARENA_TCG](https://x.com/union_arena_tcg)
- **実装難易度**: 高

#### ヴァイスシュヴァルツ
- **データソース**: ブシロード公式サイト（APIなし）
- 日本市場で人気だがデータソースが乏しい
- **実装難易度**: 高

#### Supreme / ストリートウェア
- **データソース**: なし（SupremeCommunity等のコミュニティサイト）
- Drop情報はコミュニティ駆動。安定したデータソースがない
- **実装難易度**: 高

---

## その他の検討中施策

（今後追加予定）
