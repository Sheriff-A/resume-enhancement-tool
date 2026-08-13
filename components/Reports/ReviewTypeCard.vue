<script setup lang="ts">
interface Props {
  title: string
  badge: string
  icon: string
  description: string
  features: string[]
  selected?: boolean
}

defineProps<Props>()
defineEmits<{ select: [] }>()
</script>

<template>
  <div
    class="p-4 border rounded-lg flex flex-col gap-3 cursor-pointer transition-all"
    :class="selected
      ? 'border-primary ring-2 ring-primary bg-primary/5'
      : 'border-primary/20 hover:border-primary/50'"
    @click="$emit('select')"
  >
    <div class="flex items-center justify-between gap-2">
      <div class="flex items-center gap-2">
        <UIcon
          :name="icon"
          class="size-5 text-primary"
        />
        <h5 class="font-bold">
          {{ title }}
        </h5>
      </div>
      <LVChip
        :label="badge"
        :class="badge === 'PRO' ? '' : 'text-slate-500! bg-slate-500/5! border-slate-500/20!'"
      />
    </div>
    <p class="text-sm! text-slate-500!">
      {{ description }}
    </p>
    <ul class="text-sm space-y-1">
      <li
        v-for="feature in features"
        :key="feature"
        class="flex items-start gap-2"
      >
        <UIcon
          name="i-lucide-check"
          class="size-4 text-primary mt-0.5 shrink-0"
        />
        <span>{{ feature }}</span>
      </li>
    </ul>
  </div>
</template>
