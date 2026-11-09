<script setup lang="ts">
import type { ItemInput } from '~/types/api'
import { formatApiError } from '~/utils/api'

const api = useApi()
const { data: categories } = useAsyncData('categories', () => api.listCategories())
const submitting = ref(false)
const errorMessage = ref('')

async function onSubmit(input: ItemInput) {
  submitting.value = true
  errorMessage.value = ''
  try {
    const item = await api.createItem(input)
    await navigateTo(`/items/${item.id}`)
  } catch (e) {
    errorMessage.value = formatApiError(e)
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div>
    <h1>アイテムを登録</h1>
    <p v-if="errorMessage" class="error">{{ errorMessage }}</p>
    <ItemForm
      :categories="categories ?? []"
      submit-label="登録"
      :submitting="submitting"
      @submit="onSubmit"
      @cancel="navigateTo('/items')"
    />
  </div>
</template>
