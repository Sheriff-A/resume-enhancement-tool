<script setup lang="ts">
interface Props {
  title: string
  subtitle?: string
  description?: string
}

defineProps<Props>()
</script>

<template>
  <div class="mt-12">
    <h1>
      {{ title }}
    </h1>
    <h5 class="!text-primary-600 dark:!text-primary-400">
      {{ subtitle }}
    </h5>
    <p
      v-if="description"
      class="my-4"
    >
      {{ description }}
    </p>
  </div>
</template>

<style scoped>

</style>
