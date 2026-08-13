<script setup lang="ts">
import { useDev } from '~/store/dev'

const dev = useDev()
</script>

<template>
  <DevOnly>
    <div
      v-if="dev.showDevLogs"
      v-bind="$attrs"
      class="text-green-600 text-wrap"
    >
      <slot />
    </div>
  </DevOnly>
</template>

<style scoped>

</style>
