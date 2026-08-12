<script setup lang="ts">
import type { PaidReport } from '~/models/server/scoring'

interface Props {
  report: PaidReport
}

const props = defineProps<Props>()
const sortedMissingSkills = computed(() =>
  [...props.report.key_gaps.missing_skills].sort((a, b) => a.length - b.length),
)
</script>

<template>
  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
    <UCard>
      <div class="flex items-center gap-2">
        <UIcon
          name="i-lucide-cpu"
          class="text-error size-6"
        />
        <p>Missing Skills</p>
      </div>
      <div class="mt-4 flex flex-wrap gap-2">
        <LVChip
          v-for="skill in sortedMissingSkills"
          :key="skill"
          :label="skill"
          class="!border-error-500/20 !bg-error-500/5 !text-error-700 dark:!text-error-200"
          text-class="normal-case font-normal"
        />
      </div>
    </UCard>
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
          v-for="exp_gap in report.key_gaps.experience_gaps"
          :key="exp_gap"
          class="text-sm"
        >
          {{ exp_gap }}
        </li>
      </ul>
    </UCard>
  </div>
</template>
