<script setup lang="ts">
import { SITE_NAME, SITE_SHORT_NAME } from '~/data/settings'
</script>

<template>
  <div class="sm:flex items-center justify-between gap-8">
    <div class="flex items-center gap-4">
      <div class="text-sm text-white bg-primary-500 size-6 flex items-center justify-center p-4 font-bold rounded-lg">
        {{ SITE_SHORT_NAME }}
      </div>
      <h4 class="">
        {{ SITE_NAME }}
      </h4>
    </div>
    <p class="text-sm mt-2">
      Empowering careers with artificial intelligence. <br class="md:hidden">
      Built for the modern job market.
    </p>
  </div>
</template>

<style scoped>

</style>
