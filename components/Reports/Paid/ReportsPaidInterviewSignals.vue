<script setup lang="ts">
import type { PaidReport } from '~/models/server/scoring'
import type { AccordionItem } from '#ui/components/Accordion.vue'

interface Props {
  report: PaidReport
}

const props = defineProps<Props>()
const items: AccordionItem[] = [
  {
    label: 'Strengths',
    value: 'strengths',
    details: props.report.interview_signals.strengths,
  },
  {
    label: 'Risk Areas',
    value: 'risk_areas',
    details: props.report.interview_signals.risk_areas,
  },
]

const active = ref<string[]>(items.map(item => item.value!))
</script>

<template>
  <div>
    <h5>Interview Signals</h5>
    <UCard class="mt-4">
      <UAccordion
        v-model="active"
        type="multiple"
        :items="items"
      >
        <template #body="{ item }">
          <ul class="mt-2 list-disc list-outside ml-[18px] space-y-1">
            <li
              v-for="signal in item.details"
              :key="signal"
              class="text-sm"
            >
              {{ signal }}
            </li>
          </ul>
        </template>
      </UAccordion>
    </UCard>
  </div>
</template>

<style scoped>

</style>
