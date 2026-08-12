<script setup lang="ts">
import type { ZodError } from '~/models/general'

interface Props {
  errors: ZodError[]
}

defineProps<Props>()
</script>

<template>
  <UAlert
    v-for="(error, idx) in errors"
    :key="idx"
    class="mb-2"
    :title="error.message"
    icon="i-lucide-circle-alert"
    color="error"
    variant="subtle"
  />
</template>
