<script generic="T" lang="ts" setup>
import type { FetchError } from 'ofetch'

type Error = FetchError | null
type Status = 'idle' | 'pending' | 'success' | 'error'

interface Props {
  data: T
  error: Error
  status: Status
  loadingMessage?: string
}

interface Slots {
  data(props: { data: T }): any

  error(props: { error: Error }): any

  status(props: { status: Status }): any

  fallback(): any
}

defineProps<Props>()
defineSlots<Slots>()
</script>

<template>
  <div>
    <template v-if="status === 'pending'">
      <slot
        :status="status"
        name="status"
      />
      <LVSpinner
        v-if="!$slots.status"
        :message="loadingMessage"
        size="1rem"
      />
    </template>
    <template v-else-if="error">
      <slot
        :error="error"
        name="error"
      />
      <div v-if="!$slots.error">
        <UAlert
          color="error"
          title="An error occurred"
          :description="error.statusMessage"
          icon="i-lucide-circle-alert"
        >
          <template #actions>
            <UButton
              color="error"
              to="/"
              label="Return Home"
            />
          </template>
        </UAlert>
        <DevWrapper>
          {{ error }}
        </DevWrapper>
      </div>
    </template>
    <template v-else-if="data">
      <slot
        :data="data"
        name="data"
      />
    </template>
    <template v-else>
      <slot name="fallback" />
      <UAlert
        v-if="!$slots.fallback"
        color="error"
        title="Something went wrong, please try again later."
        icon="i-lucide-circle-alert"
      />
    </template>
  </div>
</template>
