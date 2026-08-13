<script setup lang="ts">
import type { FreemiumReport } from '~/models/server/scoring'

interface Props {
  report: FreemiumReport
}

defineProps<Props>()
</script>

<template>
  <UCard>
    <h5>Career Strategy</h5>
    <div class="mt-1">
      {{ report.career_fit_signal.summary }}
    </div>
  </UCard>
</template>

<style scoped>

</style>
