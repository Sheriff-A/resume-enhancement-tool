<template>
  <LVFormFieldWrapper
    :name="name"
    :label="label"
    :required="required"
    :help="help"
    :hint="hint"
    :description="description"
  >
    <USelectMenu
      v-model="model"
      class="w-full"
      :items="items"
      :placeholder="placeholder"
      v-bind="$attrs"
    />
    <template
      v-if="$slots.hint"
      #hint
    >
      <slot name="hint" />
    </template>
  </LVFormFieldWrapper>
</template>

<script setup generic="T extends {label: string, value: string}" lang="ts">
import type { LVFormFieldWrapperProps } from '~/models/components'

interface Props extends LVFormFieldWrapperProps {
  items: string[] | T[]
  placeholder?: string
}

withDefaults(defineProps<Props>(), {
  placeholder: '',
})

const model = defineModel<string | T>({
  default: [],
})
</script>

<style scoped>

</style>
