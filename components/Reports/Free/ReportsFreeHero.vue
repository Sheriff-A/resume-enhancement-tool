<script setup lang="ts">
import type { PaidReport, FreemiumReport } from '~/models/server/scoring'

interface Props {
  report: FreemiumReport
}

const props = defineProps<Props>()
const scoreRating = computed(() => {
  const score = props.report.overall_score.value
  if (score >= 85) return 'Excellent'
  if (score >= 70) return 'Good'
  if (score >= 50) return 'Fair'
  return 'Poor'
})
</script>

<template>
  <UCard>
    <div class="relative z-10 flex flex-col items-center text-center">
      <div class="relative w-32 h-32 mb-4 flex items-center justify-center">
        <!-- Background Circle -->
        <svg class="w-full h-full transform -rotate-90">
          <circle
            cx="64"
            cy="64"
            r="56"
            stroke="currentColor"
            stroke-width="8"
            fill="transparent"
            class="text-slate-300 dark:text-slate-800"
          />
          <circle
            cx="64"
            cy="64"
            r="56"
            stroke="currentColor"
            stroke-width="8"
            fill="transparent"
            stroke-dasharray="350"
            :stroke-dashoffset="350 - (report.overall_score.value / 100) * 350"
            class="text-primary"
          />
        </svg>
        <div class="flex flex-col absolute top-0 right-0 bottom-0 left-0 items-center justify-center">
          <h2 class="">
            {{ report.overall_score.value }}
          </h2>
          <span class="text-xs text-primary uppercase font-bold tracking-widest mt-1">
            {{ scoreRating }}
          </span>
        </div>
      </div>
      <h4 class="mb-1 !font-medium">
        {{ report.overall_score.label }}
      </h4>
    </div>
  </UCard>
</template>
