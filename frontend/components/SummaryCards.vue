<script setup lang="ts">
import type { Summary } from '~/types/api'
import { formatYen } from '~/utils/format'
import ProfitText from './ProfitText.vue'

defineProps<{ summary: Summary }>()
</script>

<template>
  <div class="cards">
    <div class="card">
      <div class="card-label">総購入額</div>
      <div class="card-value" data-test="total-purchase">{{ formatYen(summary.total_purchase) }}</div>
    </div>
    <div class="card">
      <div class="card-label">総売却額</div>
      <div class="card-value" data-test="total-sale">{{ formatYen(summary.total_sale) }}</div>
    </div>
    <div class="card">
      <div class="card-label">純損益</div>
      <div class="card-value" data-test="total-profit"><ProfitText :value="summary.total_profit" /></div>
    </div>
    <div class="card">
      <div class="card-label">保有中</div>
      <div class="card-value" data-test="owned-count">{{ summary.owned_count }} 件</div>
    </div>
    <div class="card">
      <div class="card-label">売却済み</div>
      <div class="card-value" data-test="sold-count">{{ summary.sold_count }} 件</div>
    </div>
  </div>
</template>
