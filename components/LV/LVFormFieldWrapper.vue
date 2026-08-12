<script setup lang="ts">
import type { LVFormFieldWrapperProps } from '~/models/components'

const props = withDefaults(defineProps<LVFormFieldWrapperProps>(), {
  label: '',
})
</script>

<template>
  <UFormField
    v-bind="props"
    :ui="ffUi"
  >
    <slot />
    <template
      v-if="$slots.hint"
      #hint
    >
      <slot name="hint" />
    </template>
  </UFormField>
</template>

<style scoped>

</style>
