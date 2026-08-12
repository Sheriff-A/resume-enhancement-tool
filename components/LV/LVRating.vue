<script setup lang="ts">
interface Props {
  rating: number
  maxRating?: number
}

const props = withDefaults(defineProps<Props>(), {
  maxRating: 10,
})
type Threshold = 'low' | 'medium' | 'high'
const threshold: Threshold
  = props.rating <= props.maxRating! / 3
    ? 'low'
    : props.rating <= (props.maxRating! * 2) / 3
      ? 'medium'
      : 'high'
</script>

<template>
  <!--  TODO: Add tooltip -->
  <div
    class="border-2 rounded-full aspect-square w-14 flex items-center justify-center"
    :class="{
      'border-error bg-error/10 text-error': threshold === 'low',
      'border-sunset-500 bg-sunset-100 text-sunset-700': threshold === 'medium',
      'border-success bg-success/10 text-success': threshold === 'high',
    }"
  >
    <h4>
      {{ rating }}
    </h4>
  </div>
</template>
