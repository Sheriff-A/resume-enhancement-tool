<script setup lang="ts">
import type { ExtResume } from '~/models/ext_resume'
import { formatDateString } from '~/composables/helpers'

interface Props {
  resume: ExtResume
}

defineProps<Props>()

const DATE_FORMAT = 'MMM yyyy'
</script>

<template>
  <div class="p-4 md:p-12 ff-font-serif text-sm md:text-base">
    <h4 class="text-center">
      {{ resume.name }}
    </h4>
    <div class="flex gap-2 justify-center flex-wrap">
      <span class="shrink-0">
        {{ resume.phone }}
      </span>
      |
      <span class="shrink-0">
        {{ resume.email }}
      </span>
      <template v-if="resume.portfolio">
        |
        <span class="shrink-0">
          {{ resume.portfolio }}
        </span>
      </template>
      <template v-if="resume.linkedin">
        |
        <span class="shrink-0">
          {{ resume.linkedin }}
        </span>
      </template>
      <template v-if="resume.github">
        |
        <span class="shrink-0">
          {{ resume.github }}
        </span>
      </template>
    </div>

    <div
      v-if="resume.summary"
      class="mb-6"
    >
      <h5 class="uppercase">
        Summary
      </h5>
      <div class="border-b my-1" />
      <p>{{ resume.summary }}</p>
    </div>

    <ResumeTemplatesTechnicalEducation
      :education="resume.education"
      :date-format="DATE_FORMAT"
    />

    <div class="mt-6">
      <h5 class="uppercase">
        Relevant Experience
      </h5>
      <div class="border-b my-1" />
      <template
        v-for="exp in resume.experience || []"
        :key="exp.id"
      >
        <div class="mb-2">
          <div class="flex gap-2 justify-between">
            <div>
              <h5>
                {{ exp.company }}
                <span v-if="exp.location">
                  | {{ exp.location }}
                </span>
              </h5>
              <p class="italic">
                {{ exp.position }}
              </p>
            </div>
            <div>
              <p>
                {{ formatDateString(exp.start_date, DATE_FORMAT) }} -
                {{ exp.end_date ? formatDateString(exp.end_date, DATE_FORMAT, true) : 'Present' }}
              </p>
            </div>
          </div>
          <ul class="pl-4 list-outside list-disc">
            <li
              v-for="(resp, idx) in exp.responsibilities"
              :key="idx"
            >
              {{ resp.text }}
            </li>
          </ul>
        </div>
      </template>
    </div>

    <!-- TODO: Add Projects -->

    <div class="mt-6">
      <h5 class="uppercase">
        Skills
      </h5>
      <div class="border-b my-1" />
      <p>{{ resume.skills.map(skill => skill.name).join(', ') }}</p>
    </div>
  </div>
</template>

<style scoped>

</style>
