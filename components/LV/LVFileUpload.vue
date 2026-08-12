<template>
  <LVFormFieldWrapper
    :name="name"
    :label="label"
    :required="required"
    :help="help"
    :hint="hint"
    :description="description"
  >
    <UFileUpload
      v-if="variant === 'area'"
      v-model="model"
      dropzone
      :placeholder="placeholder"
      :label="uploadLabel"
      :description="uploadDescription"
      v-bind="$attrs"
    />
    <div
      v-else
      class="flex items-center gap-2 w-full border border-slate-300 rounded-lg p-2"
    >
      <div
        v-if="!$slots.preview"
        class="grow"
      >
        <div v-if="!model">
          <p>No File Selected.</p>
          <p>-</p>
        </div>
        <div v-else>
          <p class="truncate">
            {{ model.name }}
          </p>
          <p> {{ formatBytes(model.size) }} </p>
        </div>
      </div>
      <slot
        name="preview"
        :file="model"
      />
      <div>
        <UFileUpload
          v-model="model"
          variant="button"
          :loading="loading"
          class="w-full"
          :type="type"
          :placeholder="placeholder"
          v-bind="$attrs"
        />
      </div>
    </div>
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
import { formatBytes } from '~/composables/helpers'

interface Props extends LVFormFieldWrapperProps {
  type?: 'text' | 'number' | 'password' | 'file'
  placeholder?: string
  variant?: 'area' | 'button'
  uploadLabel?: string
  uploadDescription?: string
}

withDefaults(defineProps<Props>(), {
  type: 'text',
  description: '',
  variant: 'button',
})

const model = defineModel<File | null>({
  default: null,
  // required: true,
})

interface Slots {
  preview(props: { file: File | null }): any

  hint(): any
}

defineSlots<Slots>()
</script>
