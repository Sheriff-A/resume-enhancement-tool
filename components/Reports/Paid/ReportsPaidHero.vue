<script setup lang="ts">
import type { PaidReport } from '~/models/server/scoring'

interface Props {
  report: PaidReport
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
  <div class="space-y-4">
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
        <div class="text-xs max-w-md">
          {{ report.overall_score.explanation }}
        </div>
      </div>
    </UCard>

    <UCard>
      <div>
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2">
            <UIcon
              class="text-success size-6"
              name="i-lucide-circle-check"
            />
            <p class="font-medium">
              ATS Compatibility
            </p>
          </div>
          <p class="font-bold !text-success">
            {{ report.subscores.ats_match.value }}%
          </p>
        </div>
        <UProgress
          class="mt-4 mb-2"
          :model-value="report.subscores.ats_match.value"
          :max="100"
          color="success"
          size="sm"
        />
        <p class="text-xs !text-slate-500">
          {{ report.subscores.ats_match.summary }}
        </p>
      </div>
    </UCard>
    <UCard>
      <div>
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2">
            <UIcon
              class="text-warning size-6"
              name="i-lucide-crosshair"
            />
            <p class="font-medium">
              Role Alignment
            </p>
          </div>
          <p class="font-bold !text-warning">
            {{ report.subscores.role_alignment.value }}%
          </p>
        </div>
        <UProgress
          class="mt-4 mb-2"
          :model-value="report.subscores.role_alignment.value"
          :max="100"
          color="warning"
          size="sm"
        />
        <p class="text-xs !text-slate-500">
          {{ report.subscores.role_alignment.summary }}
        </p>
      </div>
    </UCard>
    <UCard>
      <div>
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2">
            <UIcon
              class="text-info size-6"
              name="i-lucide-zap"
            />
            <p class="font-medium">
              Clarity & Impact
            </p>
          </div>
          <p class="font-bold !text-info">
            {{ report.subscores.clarity_impact.value }}%
          </p>
        </div>
        <UProgress
          class="mt-4 mb-2"
          :model-value="report.subscores.clarity_impact.value"
          :max="100"
          color="info"
          size="sm"
        />
        <p class="text-xs !text-slate-500">
          {{ report.subscores.clarity_impact.summary }}
        </p>
      </div>
    </UCard>
  </div>
</template>
