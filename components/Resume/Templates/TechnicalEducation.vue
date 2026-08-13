<script setup lang="ts">
import type { ExtResume } from '~/models/ext_resume'
import { formatDateString } from '~/composables/helpers'

interface Props {
  education: ExtResume['education']
  dateFormat: string
}

defineProps<Props>()
</script>

<template>
  <div>
    <h5 class="uppercase">
      Education
    </h5>
    <div class="border-b my-1" />
    <template
      v-for="edu in education || []"
      :key="edu.id"
    >
      <div class="mb-2">
        <div class="flex gap-2 justify-between">
          <div>
            <h5>
              {{ edu.institution }} | {{ edu.location }}
            </h5>
            <p class="italic">
              {{ edu.certification }}
            </p>
          </div>
          <div>
            <p>
              {{ formatDateString(edu.start_date, dateFormat) }} -
              {{ edu.end_date ? formatDateString(edu.end_date, dateFormat, true) : 'Present' }}
            </p>
          </div>
        </div>
        <ul class="pl-4 list-outside list-disc">
          <li v-if="edu.notable_courses.length">
            <span class="font-bold">Notable Courses:</span>
            {{ edu.notable_courses.map(course => course.text).join(', ') }}
          </li>
          <li v-if="edu.awards?.length">
            <span class="font-bold">Notable Courses:</span>
            {{ edu.awards.join(', ') }}
          </li>
        </ul>
      </div>
    </template>
  </div>
</template>

<style scoped>

</style>
