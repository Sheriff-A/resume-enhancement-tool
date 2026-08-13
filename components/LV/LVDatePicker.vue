<script setup lang="ts">
import { CalendarDate, DateFormatter, type DateValue, getLocalTimeZone } from '@internationalized/date'
import type { LVFormFieldWrapperProps } from '~/models/components'
import { DateTime } from 'luxon'
import type { DateRange } from 'reka-ui'

interface Props extends LVFormFieldWrapperProps {
  minDate?: string
  maxDate?: string
  dateStyle?: 'full' | 'long' | 'medium' | 'short'
}

const props = withDefaults(defineProps<Props>(), {
  dateStyle: 'medium',
})

// Date String
const model = defineModel<string | null>({
  default: '',
  // required: true,
})

const df = new DateFormatter('en-US', {
  dateStyle: props.dateStyle,
})

const tDate = computed(() => {
  if (!model.value) {
    return undefined
  }
  const dt = DateTime.fromISO(model.value)
  const year = dt.year
  const month = dt.month
  const day = dt.day
  return new CalendarDate(year, month, day)
})

function formatLabel(date?: CalendarDate) {
  if (!date) {
    return 'Select a date'
  }
  return df.format(date.toDate(getLocalTimeZone()))
}

// TODO: Implement all these
function onUpdateDate(date?: DateValue | DateRange | DateValue[] | null) {
  function instanceOfDateRange(object: any): object is DateRange {
    return 'start' in object && 'end' in object
  }

  // console.log('date', date);
  if (!date) {
    model.value = null
    return
  }
  if (Array.isArray(date)) {
    model.value = date[0].toString()
    return
  }
  if (instanceOfDateRange(date)) {
    model.value = date.start?.toString() || ''
    return
  }
  model.value = date.toString()
}
</script>

<template>
  <LVFormFieldWrapper
    :name="name"
    :label="label"
    :required="required"
    :help="help"
    :hint="hint"
    :description="description"
  >
    <UPopover>
      <UButton
        color="neutral"
        variant="subtle"
        icon="i-lucide-calendar"
      >
        {{ formatLabel(tDate) }}
      </UButton>

      <template #content>
        <UCalendar
          :model-value="tDate"
          v-bind="$attrs"
          class="p-2"
          @update:model-value="onUpdateDate"
        />
      </template>
    </UPopover>
  </LVFormFieldWrapper>
</template>

<style scoped>

</style>
