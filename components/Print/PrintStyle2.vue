<script setup lang="ts">
import type { ExtResume } from '~/models/ext_resume';

interface Props {
  resume: ExtResume;
}

function parseDate(dateStr?: string | null, format = 'MMMM, yyyy'): string | null {
  if (!dateStr) return null;
  return formatDateString(dateStr, format);
}

defineProps<Props>();
</script>

<template>
  <div class="border aspect-[8.5/11] max-w-5xl mx-auto">
    <div class="p-12 ff-font-serif">
      <h4 class="text-center">
        {{ resume.name }}
      </h4>
      <div class="flex gap-6 justify-center">
        <p class="">{{ resume.phone }}</p>
        <p class="">{{ resume.email }}</p>
        <p v-if="resume.portfolio" class="">{{ resume.portfolio }}</p>
        <p v-if="resume.linkedin" class="">{{ resume.linkedin }}</p>
        <p v-if="resume.github" class="">{{ resume.github }}</p>
      </div>

      <div>
        <h5 class="uppercase">Education</h5>
        <div class="border-b my-1"></div>
        <template v-for="(edu, idx) in resume.education" :key="idx">
          <div class="mb-2">
            <div class="flex gap-2 justify-between">
              <div>
                <h5>{{ edu.institution }} | {{ edu.location }}</h5>
                <p>{{ edu.certification }}</p>
              </div>
              <div>
                <p>
                  {{ parseDate(edu.start_date) }} -
                  {{ edu.end_date ? parseDate(edu.end_date) : 'Present' }}
                </p>
              </div>
            </div>
            <ul class="pl-4 list-outside list-disc">
              <li v-if="edu.notable_courses.length">
                <span class="font-bold">Notable Courses:</span>
                {{ edu.notable_courses.join(', ') }}
              </li>
              <li v-if="edu.awards.length">
                <span class="font-bold">Awards:</span>
                {{ edu.awards.join(', ') }}
              </li>
            </ul>
          </div>
        </template>
      </div>

      <!--      TODO: Split into technical skills, frameworks, interpersonal skills-->
      <!--      TODO: Future plan: People can create their own skill groups-->
      <div class="mt-6">
        <h5 class="uppercase">Skills</h5>
        <div class="border-b my-1"></div>
        <p>{{ resume.skills.map(skill => skill.name).join(', ') }}</p>
      </div>

      <div class="mt-6">
        <h5 class="uppercase">Relevant Experience</h5>
        <div class="border-b my-1"></div>
        <template v-for="(exp, idx) in resume.experience" :key="idx">
          <div class="mb-2">
            <div class="flex gap-2 justify-between">
              <div>
                <h5>{{ exp.company }} | {{ exp.location }}</h5>
                <p>{{ exp.position }}</p>
              </div>
              <div>
                <p>
                  {{ parseDate(exp.start_date) }} -
                  {{ exp.end_date ? parseDate(exp.end_date) : 'Present' }}
                </p>
              </div>
            </div>
            <ul class="pl-4 list-outside list-disc">
              <template v-for="(desc, jdx) in exp.responsibilities" :key="jdx">
                <li>{{ desc.text }}</li>
              </template>
            </ul>
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<style scoped>

</style>