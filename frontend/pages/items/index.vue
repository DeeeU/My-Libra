<script setup lang="ts">
import { ITEM_CONDITIONS, ITEM_STATUSES, type ItemQuery } from '~/types/api'
import { formatApiError } from '~/utils/api'
import { formatDate, formatYen } from '~/utils/format'

const api = useApi()
const query = reactive<ItemQuery>({ status: '保有中', ordering: '-purchase_date' })
const search = ref('')

// 検索欄は入力が止まってから反映する
let timer: ReturnType<typeof setTimeout> | undefined
watch(search, (value) => {
  clearTimeout(timer)
  timer = setTimeout(() => (query.search = value), 300)
})

const { data: categories } = useAsyncData('categories', () => api.listCategories())
const { data: items, error, pending } = useAsyncData('items', () => api.listItems({ ...query }), {
  watch: [query],
})
</script>

<template>
  <div>
    <h1>アイテム</h1>
    <div class="filters">
      <select v-model="query.status" aria-label="ステータス">
        <option :value="undefined">すべて</option>
        <option v-for="s in ITEM_STATUSES" :key="s" :value="s">{{ s }}</option>
      </select>
      <select v-model="query.category" aria-label="カテゴリー">
        <option :value="undefined">全カテゴリー</option>
        <option v-for="c in categories ?? []" :key="c.id" :value="c.name">{{ c.name }}</option>
      </select>
      <select v-model="query.condition" aria-label="状態">
        <option :value="undefined">全状態</option>
        <option v-for="c in ITEM_CONDITIONS" :key="c" :value="c">{{ c }}</option>
      </select>
      <select v-model="query.ordering" aria-label="並び替え">
        <option value="-purchase_date">購入日が新しい順</option>
        <option value="purchase_date">購入日が古い順</option>
        <option value="-purchase_price">価格が高い順</option>
        <option value="purchase_price">価格が安い順</option>
        <option value="name">名前順</option>
      </select>
      <input v-model="search" type="search" placeholder="商品名・メモで検索" aria-label="検索">
    </div>

    <p v-if="error" class="error">{{ formatApiError(error) }}</p>
    <p v-else-if="pending && !items" class="muted">読み込み中…</p>
    <p v-else-if="!items?.length" class="muted">
      アイテムがありません。<NuxtLink to="/items/new">新規登録</NuxtLink>
    </p>
    <div v-else class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>商品名</th><th>カテゴリー</th><th>状態</th><th>購入日</th>
            <th class="num">購入価格</th><th class="num">売却価格</th><th class="num">損益</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in items" :key="item.id">
            <td>
              <NuxtLink :to="`/items/${item.id}`">{{ item.name }}</NuxtLink>
              <span v-if="item.status === '売却済み'" class="badge">売却済み</span>
            </td>
            <td>{{ item.category }}</td>
            <td>{{ item.condition }}</td>
            <td>{{ formatDate(item.purchase_date) }}</td>
            <td class="num">{{ formatYen(item.purchase_price) }}</td>
            <td class="num">{{ formatYen(item.sale_price) }}</td>
            <td class="num"><ProfitText :value="item.profit" /></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
