<script setup lang="ts">
import type { FreemiumReport } from '~/models/server/scoring'

interface Props {
  report: FreemiumReport
}

defineProps<Props>()
</script>

<template>
  <UCard>
    <div class="flex items-center gap-2">
      <UIcon
        name="i-lucide-briefcase"
        class="text-amber-500 size-6"
      />
      <p>Experience Gaps</p>
    </div>
    <ul class="mt-4 list-disc list-outside ml-4 space-y-1">
      <li
        v-for="exp_gap in report.top_issues"
        :key="exp_gap"
        class="text-sm"
      >
        {{ exp_gap }}
      </li>
    </ul>
  </UCard>
</template>
