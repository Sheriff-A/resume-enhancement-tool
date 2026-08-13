<template>
  <div>
    <NuxtLayout>
      <UApp :toaster="TOASTER_SETTINGS">
        <NuxtLoadingIndicator />
        <NuxtPage :key="$route.fullPath" />
      </UApp>
    </NuxtLayout>
  </div>
</template>

<script setup lang="ts">
import { SITE_NAME, TOASTER_DURATION } from '~/data/settings'
import { useResumeStore } from '~/store/resume'

useHead({
  titleTemplate(title) {
    return title ? `${title} - ${SITE_NAME}` : SITE_NAME
  },
})

const TOASTER_SETTINGS = {
  duration: TOASTER_DURATION,
}
</script>
