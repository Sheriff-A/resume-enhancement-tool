<script setup lang="ts">
import cn from 'clsx'

interface Props {
  label: string
  caption?: string
  value: string | number
  highlight?: boolean
  icon?: string
  iconClass?: string
  labelClass?: string
  valueClass?: string
  iconBgClass?: string
}

defineProps<Props>()
</script>

<template>
  <UCard
    :class="{
      'bg-primary !border-primary': highlight,
    }"
    :ui="{
      body: 'h-full',
    }"
  >
    <div class="flex flex-col justify-between h-full">
      <div class="flex justify-between items-start gap-2">
        <div>
          <p
            :class="cn(labelClass, highlight ? '!text-white dark:!text-slate-200' : '')"
          >
            {{ label }}
          </p>
          <p
            :class="cn('text-sm', highlight ? '!text-primary-200' : '!text-primary')"
          >
            {{ caption }}
          </p>
        </div>
        <UIcon
          v-if="icon"
          :class="cn('size-6', iconClass, highlight ? '!text-white dark:!text-slate-200' : '')"
          :name="icon"
        />
      </div>
      <h3
        :class="cn('mt-4', valueClass, highlight ? '!text-white' : '')"
      >
        {{ value }}
      </h3>
    </div>
  </UCard>
</template>

<style scoped>

</style>
