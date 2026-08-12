<template>
  <div class="">
    <template v-if="action && action === 'add'">
      <div class="flex gap-2">
        <div class="shrink flex flex-col items-center gap-1 mt-6">
          <UButton
            color="success"
            icon="i-lucide-check"
            variant="ghost"
            @click="onAccept"
          />
          <UButton
            color="error"
            icon="i-lucide-x"
            variant="ghost"
            @click="onReject"
          />
        </div>
        <div class="flex flex-col gap-1 w-full">
          <p class="!text-accent font-medium">
            *New Item
          </p>
          <div
            class="border border-dashed px-2 py-1 rounded-md border-accent/30 text-sm grow"
          >
            <p class="!text-accent">
              <span class="underline">Suggestion:</span> {{ text }}
            </p>
            <p
              v-if="reason"
              class="text-sm mt-1 !text-accent"
            >
              <span class="underline">Reasoning:</span> {{ reason }}
            </p>
          </div>
          <UTooltip
            v-if="confidence"
            text="The confidence score represents how certain the system is about this suggestion. A higher score indicates greater confidence in the accuracy of the suggestion."
            :delay-duration="500"
          >
            <p
              class="mt-1 text-xs font-bold !text-slate-500"
            >
              Confidence: {{ confidence }}%
            </p>
          </UTooltip>
        </div>
      </div>
    </template>

    <template v-else>
      <p class="text-sm !text-accent">
        <span class="underline">Suggestion:</span> {{ text }}
      </p>
      <p
        v-if="reason"
        class="text-sm mt-1 !text-accent"
      >
        <span class="underline">Reasoning:</span> {{ reason }}
      </p>
      <div class="mt-3 flex items-center justify-between gap-4">
        <div>
          <UButton
            label="Accept Change"
            color="success"
            size="sm"
            variant="subtle"
            @click="onAccept"
          />
          <UButton
            class="ml-2"
            label="Reject"
            color="error"
            size="sm"
            variant="ghost"
            @click="onReject"
          />
        </div>
        <UTooltip
          v-if="confidence"
          text="The confidence score represents how certain the system is about this suggestion. A higher score indicates greater confidence in the accuracy of the suggestion."
          :delay-duration="500"
        >
          <p
            class="text-xs font-bold !text-slate-500"
          >
            Confidence: {{ confidence }}%
          </p>
        </UTooltip>
      </div>
    </template>
    <DevWrapper>
      <pre class="max-w-xl">
        <code class="break-words text-wrap">
        Raw: {{ raw }}
      </code>
      </pre>
    </DevWrapper>
  </div>
</template>

<script setup lang="ts">
import type { UpdateAction } from '~/models/server/resume'

interface Props {
  text: string
  reason?: string
  confidence?: number
  action?: UpdateAction
  raw?: any
}

interface Emits {
  (e: 'accept', value: string, action?: UpdateAction): void

  (e: 'reject'): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

function onAccept() {
  emit('accept', props.text)
}

function onReject() {
  emit('reject')
}
</script>
