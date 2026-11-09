<script setup lang="ts">
import type { ItemInput, SellInput } from '~/types/api'
import { formatApiError } from '~/utils/api'
import { formatDate, formatYen } from '~/utils/format'

const route = useRoute()
const id = route.params.id as string
const api = useApi()

const { data: item, error, refresh } = useAsyncData(`item-${id}`, () => api.getItem(id))
const { data: categories } = useAsyncData('categories', () => api.listCategories())

const mode = ref<'view' | 'edit' | 'sell'>('view')
const submitting = ref(false)
const errorMessage = ref('')

async function run(action: () => Promise<unknown>) {
  submitting.value = true
  errorMessage.value = ''
  try {
    await action()
    await refresh()
    mode.value = 'view'
  } catch (e) {
    errorMessage.value = formatApiError(e)
  } finally {
    submitting.value = false
  }
}

const onEdit = (input: ItemInput) => run(() => api.updateItem(id, input))
const onSell = (input: SellInput) => run(() => api.sellItem(id, input))
const onUnsell = () => {
  if (confirm('売却記録を取り消して「保有中」に戻しますか？')) run(() => api.unsellItem(id))
}
async function onDelete() {
  if (!confirm('このアイテムを削除しますか？この操作は取り消せません。')) return
  try {
    await api.deleteItem(id)
    await navigateTo('/items')
  } catch (e) {
    errorMessage.value = formatApiError(e)
  }
}
</script>

<template>
  <div>
    <NuxtLink to="/items" class="muted">← 一覧に戻る</NuxtLink>
    <p v-if="error" class="error">{{ formatApiError(error) }}</p>
    <template v-else-if="item">
      <h1>{{ item.name }}</h1>
      <p v-if="errorMessage" class="error">{{ errorMessage }}</p>

      <template v-if="mode === 'view'">
        <dl class="detail">
          <dt>ステータス</dt><dd>{{ item.status }}</dd>
          <dt>カテゴリー</dt><dd>{{ item.category }}</dd>
          <dt>状態</dt><dd>{{ item.condition }}</dd>
          <dt>購入価格</dt><dd>{{ formatYen(item.purchase_price) }}</dd>
          <dt>購入日</dt><dd>{{ formatDate(item.purchase_date) }}</dd>
          <template v-if="item.status === '売却済み'">
            <dt>売却価格</dt><dd>{{ formatYen(item.sale_price) }}</dd>
            <dt>売却日</dt><dd>{{ formatDate(item.sale_date) }}</dd>
            <dt>損益</dt><dd><ProfitText :value="item.profit" /></dd>
          </template>
          <dt>メモ</dt><dd style="white-space: pre-line">{{ item.memo || '-' }}</dd>
        </dl>
        <section class="actions">
          <button type="button" class="secondary" @click="mode = 'edit'">編集</button>
          <button v-if="item.status === '保有中'" type="button" @click="mode = 'sell'">売却を記録</button>
          <button v-else type="button" class="secondary" :disabled="submitting" @click="onUnsell">売却を取り消す</button>
          <button type="button" class="danger" @click="onDelete">削除</button>
        </section>
      </template>

      <section v-else-if="mode === 'edit'">
        <h2>編集</h2>
        <ItemForm
          :categories="categories ?? []"
          :initial="item"
          :submitting="submitting"
          @submit="onEdit"
          @cancel="mode = 'view'"
        />
      </section>

      <section v-else>
        <h2>売却を記録</h2>
        <SellForm
          :purchase-price="item.purchase_price"
          :purchase-date="item.purchase_date"
          :submitting="submitting"
          @submit="onSell"
          @cancel="mode = 'view'"
        />
      </section>
    </template>
  </div>
</template>
