<script setup lang="ts">
import { reactive, ref } from 'vue'
import { ITEM_CONDITIONS, type Category, type ItemInput } from '~/types/api'
import { todayISO } from '~/utils/format'
import { hasErrors, validateItemInput, type FieldErrors } from '~/utils/validation'

const props = withDefaults(
  defineProps<{
    categories: Category[]
    initial?: Partial<ItemInput>
    submitLabel?: string
    submitting?: boolean
  }>(),
  { initial: () => ({}), submitLabel: '保存', submitting: false },
)

const emit = defineEmits<{ submit: [input: ItemInput]; cancel: [] }>()

const form = reactive<ItemInput>({
  name: props.initial.name ?? '',
  category: props.initial.category ?? '',
  purchase_price: props.initial.purchase_price ?? null,
  purchase_date: props.initial.purchase_date ?? todayISO(),
  condition: props.initial.condition ?? '新品',
  memo: props.initial.memo ?? '',
})
const errors = ref<FieldErrors>({})

function onSubmit() {
  // 空欄の number 入力は '' になるので null に揃える
  const price = form.purchase_price as unknown
  const input: ItemInput = {
    ...form,
    name: form.name.trim(),
    purchase_price: price === '' || price === null ? null : Number(price),
  }
  errors.value = validateItemInput(input, todayISO())
  if (!hasErrors(errors.value)) emit('submit', input)
}
</script>

<template>
  <form class="form" novalidate @submit.prevent="onSubmit">
    <label>
      商品名 <span class="required">*</span>
      <input v-model="form.name" name="name" type="text" maxlength="200">
      <small v-if="errors.name" class="error">{{ errors.name }}</small>
    </label>

    <label>
      カテゴリー <span class="required">*</span>
      <select v-model="form.category" name="category">
        <option value="" disabled>選択してください</option>
        <option v-for="c in categories" :key="c.id" :value="c.name">{{ c.name }}</option>
      </select>
      <small v-if="errors.category" class="error">{{ errors.category }}</small>
    </label>

    <label>
      購入価格（円） <span class="required">*</span>
      <input v-model.number="form.purchase_price" name="purchase_price" type="number" min="0" step="1">
      <small v-if="errors.purchase_price" class="error">{{ errors.purchase_price }}</small>
    </label>

    <label>
      購入日 <span class="required">*</span>
      <input v-model="form.purchase_date" name="purchase_date" type="date">
      <small v-if="errors.purchase_date" class="error">{{ errors.purchase_date }}</small>
    </label>

    <label>
      状態 <span class="required">*</span>
      <select v-model="form.condition" name="condition">
        <option v-for="c in ITEM_CONDITIONS" :key="c" :value="c">{{ c }}</option>
      </select>
      <small v-if="errors.condition" class="error">{{ errors.condition }}</small>
    </label>

    <label>
      メモ
      <textarea v-model="form.memo" name="memo" rows="3" />
    </label>

    <div class="actions">
      <button type="submit" :disabled="submitting">{{ submitLabel }}</button>
      <button type="button" class="secondary" @click="emit('cancel')">キャンセル</button>
    </div>
  </form>
</template>
