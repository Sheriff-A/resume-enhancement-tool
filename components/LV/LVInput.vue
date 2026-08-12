<template>
  <LVFormFieldWrapper
    :name="name"
    :label="label"
    :required="required"
    :help="help"
    :hint="hint"
    :description="description"
  >
    <UInput
      v-model="model"
      :loading="loading"
      class="w-full"
      :type="type"
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

<script setup lang="ts">
import type { LVFormFieldWrapperProps } from '~/models/components'

interface Props extends LVFormFieldWrapperProps {
  type?: 'text' | 'number' | 'password' | 'file'
  placeholder?: string
}

withDefaults(defineProps<Props>(), {
  type: 'text',
  description: '',
})

const model = defineModel<string | number | null>({
  default: '',
  // required: true,
})
</script>
