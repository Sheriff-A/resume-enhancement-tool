<script setup lang="ts">
import type { PaidReport, PrioritizedImprovement } from '~/models/server/scoring'

interface Props {
  report: PaidReport
}

defineProps<Props>()

function getImprovementIcon(improvement: PrioritizedImprovement['priority']) {
  switch (improvement) {
    case 'high':
      return 'i-lucide-alert-circle'
    case 'medium':
      return 'i-lucide-alert-triangle'
    case 'low':
      return 'i-lucide-info'
    default:
      return 'i-lucide-info'
  }
}
</script>

<template>
  <div>
    <h5 class="mb-4 !font-medium">
      Areas for Improvement
    </h5>

    <UCard
      v-for="(improvement, idx) in report.prioritized_improvements"
      :key="idx"
      class="mb-4 last:mb-0 rounded-s-none border-s-2"
      :class="{
        'border-s-error': improvement.priority === 'high',
        'border-s-warning': improvement.priority === 'medium',
        'border-s-info': improvement.priority === 'low',
      }"
    >
      <div class="flex items-start gap-4">
        <UIcon
          class="shrink-0 size-6 mt-1"
          :class="{
            'text-error': improvement.priority === 'high',
            'text-warning': improvement.priority === 'medium',
            'text-info': improvement.priority === 'low',
          }"
          :name="getImprovementIcon(improvement.priority)"
        />
        <div>
          <p class="font-medium">
            {{ improvement.title }}
          </p>
          <div class="text-sm mt-1">
            {{ improvement.reason }}
          </div>
          <p class="mt-2 text-xs subtle-text shrink-0">
            Est. Score Gain: {{ improvement.impact_score_gain_estimate }}
          </p>
        </div>
      </div>
    </UCard>
  </div>
</template>

<style scoped>

</style>
