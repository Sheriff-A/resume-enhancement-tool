<script setup lang="ts">
interface Props {
  message?: string
}

const props = defineProps<Props>()
</script>

<template>
  <div class="general-loader">
    <div class="spinner" />
    <p class="pointer-events-none mt-2">
      {{ message }}
    </p>
  </div>
</template>

<style lang="css" scoped>
</style>
