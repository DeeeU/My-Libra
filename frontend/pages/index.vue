<script setup lang="ts">
import { PERIODS, type Period } from '~/types/api'
import { formatApiError } from '~/utils/api'
import { formatYen } from '~/utils/format'

const api = useApi()
const period = ref<Period>('all')

const { data: summary, error, pending } = useAsyncData('summary', () => api.getSummary(period.value), {
  watch: [period],
})

const maxCategory = computed(() => Math.max(1, ...(summary.value?.by_category.map((c) => c.amount) ?? [])))
const maxMonthly = computed(() => Math.max(1, ...(summary.value?.monthly.map((m) => m.purchase) ?? [])))
</script>

<template>
  <div>
    <h1>損益の集計</h1>
    <div class="filters">
      <label>
        期間
        <select v-model="period">
          <option v-for="p in PERIODS" :key="p.value" :value="p.value">{{ p.label }}</option>
        </select>
      </label>
    </div>

    <p v-if="error" class="error">{{ formatApiError(error) }}</p>
    <p v-else-if="pending && !summary" class="muted">読み込み中…</p>
    <template v-else-if="summary">
      <SummaryCards :summary="summary" />

      <section>
        <h2>カテゴリー別の購入額</h2>
        <p v-if="!summary.by_category.length" class="muted">データがありません</p>
        <div v-else class="table-wrap">
          <table>
            <tbody>
              <tr v-for="c in summary.by_category" :key="c.category">
                <td>{{ c.category }}</td>
                <td style="width: 50%"><div class="bar" :style="{ width: `${(c.amount / maxCategory) * 100}%` }" /></td>
                <td class="num">{{ formatYen(c.amount) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <section>
        <h2>月別の推移</h2>
        <p class="muted">購入額は購入月、損益は売却月で集計しています。</p>
        <p v-if="!summary.monthly.length" class="muted">データがありません</p>
        <div v-else class="table-wrap">
          <table>
            <thead>
              <tr><th>月</th><th /><th class="num">購入額</th><th class="num">損益</th></tr>
            </thead>
            <tbody>
              <tr v-for="m in summary.monthly" :key="m.month">
                <td>{{ m.month }}</td>
                <td style="width: 40%"><div class="bar" :style="{ width: `${(m.purchase / maxMonthly) * 100}%` }" /></td>
                <td class="num">{{ formatYen(m.purchase) }}</td>
                <td class="num"><ProfitText :value="m.profit" /></td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
    </template>
  </div>
</template>
