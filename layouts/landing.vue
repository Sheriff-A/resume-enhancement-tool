<script setup lang="ts">
import LandingFooter from '~/components/Landing/LandingFooter.vue'

const showScrollTop = ref(false)
const handleScroll = () => {
  showScrollTop.value = window.scrollY > 200
}

onMounted(() => {
  window.addEventListener('scroll', handleScroll)
})
onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})

const scrollToTop = () => {
  window.scrollTo({ top: 0, behavior: 'smooth' })
}
</script>

<template>
  <div class="relative dark">
    <LandingHeader />
    <div class="min-h-[83vh]">
      <slot />
    </div>
    <LandingFooter class="mt-32" />
    <div
      v-if="showScrollTop"
      class="fixed w-fit bottom-6 right-6"
    >
      <UButton
        class="opacity-40 hover:opacity-100 cursor-pointer  transition-opacity"
        aria-label="Scroll to top"
        icon="i-lucide-arrow-up"
        variant="outline"
        @click="scrollToTop"
      />
    </div>
  </div>
</template>
