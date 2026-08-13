<script setup lang="ts">
interface Props {
  label: string
  textClass?: string
}
defineProps<Props>()
</script>

<template>
  <div class="w-fit px-3 py-1 rounded-md border border-primary/20 bg-primary/5 text-xs text-primary">
    <span :class="textClass">
      {{ label }}
    </span>
  </div>
</template>

<style scoped>

</style>
