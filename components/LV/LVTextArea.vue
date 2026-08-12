<template>
  <LVFormFieldWrapper
    :name="name"
    :label="label"
    :required="required"
    :help="help"
    :hint="hint"
    :description="description"
    :ff-ui="ffUi"
  >
    <UTextarea
      v-model="model"
      class="w-full"
      :rows="rows"
      :autoresize="autoresize"
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
  rows?: number
  placeholder?: string
  autoresize?: boolean
}

withDefaults(defineProps<Props>(), {
  rows: 5,
  autoresize: true,
})

const model = defineModel<string | null>({
  default: '',
  // required: true,
})
</script>
