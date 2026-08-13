<script setup lang="ts">
import { SITE_NAME } from '~/data/settings'

definePageMeta({
  public: true,
  layout: 'landing',
})

useHead({
  title: SITE_NAME,
  meta: [
    {
      name: 'description',
      content: `Welcome to ${SITE_NAME}`,
    },
  ],
})
</script>

<template>
  <div>
    <LandingHero />
    <LandingFeatures />
    <LandingRecruiters />
    <LandingTestimonials />
    <LandingCta />
  </div>
</template>
