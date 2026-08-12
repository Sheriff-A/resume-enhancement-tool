<script setup lang="ts">
interface Props {
  message?: string // Optional message to display
  size?: string // e.g., '1rem', '16px', etc.
}

defineProps<Props>()
</script>

<template>
  <span
    class="text-neutral-500"
    :class="{
      'flex items-center gap-xs': message,
    }"
  >
    <UIcon
      :size="size"
      class="animate-spin"
      name="i-lucide-loader-circle"
    />
    <span>
      {{ message }}
    </span>
  </span>
</template>

<style scoped>

</style>
