<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import type { SellInput } from '~/types/api'
import { todayISO } from '~/utils/format'
import { hasErrors, validateSellInput, type FieldErrors } from '~/utils/validation'
import ProfitText from './ProfitText.vue'

const props = withDefaults(
  defineProps<{ purchasePrice: number; purchaseDate: string; submitting?: boolean }>(),
  { submitting: false },
)
const emit = defineEmits<{ submit: [input: SellInput]; cancel: [] }>()

const form = reactive<{ sale_price: number | '' | null; sale_date: string }>({
  sale_price: null,
  sale_date: todayISO(),
})
const errors = ref<FieldErrors>({})

const salePrice = computed(() =>
  form.sale_price === '' || form.sale_price === null ? null : Number(form.sale_price),
)
/** 入力中の損益プレビュー */
const previewProfit = computed(() => (salePrice.value === null ? null : salePrice.value - props.purchasePrice))

function onSubmit() {
  const input: SellInput = { sale_price: salePrice.value, sale_date: form.sale_date }
  errors.value = validateSellInput(input, props.purchaseDate, todayISO())
  if (!hasErrors(errors.value)) emit('submit', input)
}
</script>

<template>
  <form class="form" novalidate @submit.prevent="onSubmit">
    <label>
      売却価格（円） <span class="required">*</span>
      <input v-model.number="form.sale_price" name="sale_price" type="number" min="0" step="1">
      <small v-if="errors.sale_price" class="error">{{ errors.sale_price }}</small>
    </label>
    <label>
      売却日 <span class="required">*</span>
      <input v-model="form.sale_date" name="sale_date" type="date">
      <small v-if="errors.sale_date" class="error">{{ errors.sale_date }}</small>
    </label>
    <p class="preview">損益: <ProfitText :value="previewProfit" /></p>
    <div class="actions">
      <button type="submit" :disabled="submitting">売却を記録</button>
      <button type="button" class="secondary" @click="emit('cancel')">キャンセル</button>
    </div>
  </form>
</template>
