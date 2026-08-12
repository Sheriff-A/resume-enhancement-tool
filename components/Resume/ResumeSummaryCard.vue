<script setup lang="ts">
import type { ExtResume } from '~/models/ext_resume'
import { formatDateString } from '~/composables/helpers'

interface Props {
  resume: ExtResume
}

const props = defineProps<Props>()

const displayName = computed(() => props.resume.nickname || props.resume.name)
</script>

<template>
  <UCard :ui="{ body: 'flex items-center justify-between gap-4 flex-wrap' }">
    <div class="flex items-center gap-4">
      <div class="flex items-center justify-center size-12 rounded-lg bg-primary/10 text-primary shrink-0">
        <UIcon
          name="i-lucide-file-text"
          class="size-6"
        />
      </div>
      <div>
        <div class="flex items-center gap-2 flex-wrap">
          <h5 class="font-bold">
            {{ displayName }}
          </h5>
          <LVChip
            v-if="resume.is_public"
            label="Public"
          />
        </div>
        <p class="text-sm! text-slate-500!">
          {{ resume.name }} &bull; {{ resume.email }}
        </p>
      </div>
    </div>
    <div class="text-right shrink-0">
      <p class="text-xs text-slate-500!">
        Last updated {{ formatDateString(resume.updated_at || resume.created_at, 'yyyy-LL-dd') }}
      </p>
      <UButton
        class="mt-2"
        size="xs"
        variant="soft"
        icon="i-lucide-edit"
        label="Edit Resume"
        :to="{ name: 'resume-resumeId', params: { resumeId: resume.id } }"
      />
    </div>
  </UCard>
</template>
