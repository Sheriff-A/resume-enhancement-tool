<script setup lang="ts">
import GeneralLoader from '~/components/General/GeneralLoader.vue'
import { useInterfaceStore } from '~/store/interface'

const useInterface = useInterfaceStore()
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
  <div
    class="bg-slate-50 dark:bg-slate-950"
  >
    <PublicHeader class="no-print" />
    <GeneralLoader
      v-if="useInterface.loaderMsg"
      :message="useInterface.loaderMsg"
    />
    <UContainer class="min-h-[83vh] py-4">
      <slot />
    </UContainer>
    <GeneralFooter class="no-print mt-32" />
    <div
      v-if="showScrollTop"
      class="fixed bottom-6 right-6"
    >
      <UButton
        aria-label="Scroll to top"
        icon="i-lucide-arrow-up"
        variant="outline"
        class="opacity-40 hover:opacity-100 cursor-pointer  transition-opacity"
        @click="scrollToTop"
      />
    </div>
  </div>
</template>
