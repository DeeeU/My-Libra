<script setup lang="ts">
import { formatSignedYen, profitClass } from '~/utils/format'

defineProps<{ value: number | null | undefined }>()
</script>

<template>
  <span :class="profitClass(value)">{{ formatSignedYen(value) }}</span>
</template>
