<script setup lang="ts">
import { renderResumeHtml, RNDRTechnicalResumeHtml } from '~/composables/resumeTemplates'
import type { ResumeStyle } from '~/models/database'

interface Props {
  resume: any
  style?: ResumeStyle
}

const props = withDefaults(defineProps<Props>(), {
  style: 'modern',
})
const resumeHtml = computed(() => {
  switch (props.style) {
    case 'technical':
      return RNDRTechnicalResumeHtml(props.resume)
    case 'modern':
    default:
      return renderResumeHtml(props.resume)
  }
})
</script>

<template>
  <div
    class="border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 rounded-xl aspect-[8.5/11] max-w-5xl mx-auto"
  >
    <div v-html="resumeHtml" />
  </div>
</template>

<style scoped>

</style>
