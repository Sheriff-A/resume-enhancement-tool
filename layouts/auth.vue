<script setup lang="ts">
import GeneralLoader from '~/components/General/GeneralLoader.vue'
import { useInterfaceStore } from '~/store/interface'
import { SITE_NAME } from '~/data/settings'

const useInterface = useInterfaceStore()
</script>

<template>
  <div
    class="relative dark h-screen overflow-hidden"
  >
    <header
      class="px-6 py-4 absolute top-0 left-0 w-fit"
    >
      <!-- TODO: Consider Logo Here -->
      <NuxtLink to="/">
        <div
          class="text-2xl font-bold cursor-pointer text-primary-600 dark:text-primary-400 hover:text-primary-500"
        >
          {{ SITE_NAME }}
        </div>
      </NuxtLink>
    </header>
    <GeneralLoader
      v-if="useInterface.loaderMsg"
      :message="useInterface.loaderMsg"
    />
    <slot />
  </div>
</template>
