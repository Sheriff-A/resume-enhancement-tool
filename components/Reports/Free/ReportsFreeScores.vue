<script setup lang="ts">
import type { FreemiumReport } from '~/models/server/scoring'

interface Props {
  report: FreemiumReport
}

defineProps<Props>()
</script>

<template>
  <div class="grid gap-4 md:grid-cols-3">
    <LVInfoCard
      label="ATS Compatibility"
      :value="report.subscores.ats_match"
      icon="i-lucide-circle-check"
      icon-class="text-success"
      label-class="font-medium"
      value-class="uppercase font-bold !text-success"
      icon-bg-class="bg-success/5"
    />
    <LVInfoCard
      label="Role Alignment"
      :value="report.subscores.role_alignment"
      icon="i-lucide-circle-check"
      icon-class="text-warning"
      label-class="font-medium"
      value-class="uppercase font-bold !text-warning"
      icon-bg-class="bg-warning/5"
    />
    <LVInfoCard
      label="Clarity & Impact"
      :value="report.subscores.clarity_impact"
      icon="i-lucide-circle-check"
      icon-class="text-info"
      label-class="font-medium"
      value-class="uppercase font-bold !text-info"
      icon-bg-class="bg-info/5"
    />
  </div>
</template>
