<script setup lang="ts">
import type { ResumeStyle } from '~/models/database'
import Modern from '~/components/Resume/Templates/Modern.vue'
import Technical from '~/components/Resume/Templates/Technical.vue'

interface Props {
  resume: any
  style?: ResumeStyle
}

const resumeStyles: Record<ResumeStyle, any> = {
  // TODO: Modern needs to be implemented
  modern: Technical,
  technical: Technical,
}

const props = defineProps<Props>()
const resumeComponent = computed(() => {
  const style: ResumeStyle = props.style || props.resume.style || 'modern'
  return resumeStyles[style]
})
</script>

<template>
  <div
    class="border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 rounded-xl aspect-[8.5 / 11] max-w-5xl mx-auto print:border-0 print:bg-white"
  >
    <div
      id="resume-preview"
    >
      <component
        :is="resumeComponent"
        :resume="resume"
      />
    </div>
  </div>
</template>

<style scoped>

</style>
