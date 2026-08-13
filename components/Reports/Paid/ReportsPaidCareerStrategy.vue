<script setup lang="ts">
import type { PaidReport } from '~/models/server/scoring'

interface Props {
  report: PaidReport
}

defineProps<Props>()
</script>

<template>
  <div>
    <h5>Career Strategy</h5>
    <div class="mt-1">
      {{ report.career_strategy.market_readiness }}
    </div>
    <div class="mt-4 grid xl:grid-cols-2 items-stretch gap-4">
      <div class="flex flex-col gap-2">
        <h5 class="!text-lg !font-medium">
          Application Advice
        </h5>

        <UCard
          class="grow"
        >
          <UTimeline
            :items="report.career_strategy.application_advice as any[]"
            size="3xs"
            :ui="{
              indicator: '!bg-primary/50',
            }"
          >
            <template #title="{ item }">
              <div class="sub-text font-normal">
                {{ item }}
              </div>
            </template>
          </UTimeline>
        </UCard>
      </div>
      <div class="flex flex-col gap-2">
        <h5 class="!text-lg  !font-medium">
          Role Targeting
        </h5>

        <UCard
          class="grow"
        >
          <UTimeline
            :items="report.career_strategy.role_targeting_advice as any[]"
            size="3xs"
            :ui="{
              indicator: '!bg-primary/50',
            }"
          >
            <template #title="{ item }">
              <div class="sub-text font-normal">
                {{ item }}
              </div>
            </template>
          </UTimeline>
        </UCard>
      </div>
    </div>
  </div>
</template>

<style scoped>

</style>
