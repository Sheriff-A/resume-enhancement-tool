<script setup lang="ts">
import { LANDING_ROUTES } from '~/data/routes'
import type { NavigationMenuItem } from '#ui/components/NavigationMenu.vue'

const items: NavigationMenuItem[] = [
  ...LANDING_ROUTES,
  {
    label: 'Sheriff-A',
    to: 'https://sheriff-a.com/',
    target: '_blank',
  },
]
</script>

<template>
  <div class="border-t border-white/5 bg-neutral-900/30">
    <UContainer>
      <GeneralFooterBanner class="mt-8" />
    </UContainer>
    <UContainer class="mt-8">
      <footer class="flex items-center justify-between">
        <div>
          <p class="text-sm">
            © {{ new Date().getFullYear() }} Sheriff A. All rights reserved
          </p>
        </div>
        <div>
          <UNavigationMenu
            :items="items"
            variant="link"
          />
        </div>
        <div>
          <UButton
            icon="i-simple-icons-github"
            color="neutral"
            variant="ghost"
            to="https://github.com/Sheriff-A"
            target="_blank"
            aria-label="GitHub"
          />
        </div>
      </footer>
    </UContainer>
  </div>
</template>

<style scoped>

</style>
