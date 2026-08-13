<script setup lang="ts">
import { DASHBOARD_ROUTES } from '~/data/routes'
import { SITE_NAME } from '~/data/settings'
import { useDev } from '~/store/dev'
import { useProfileStore } from '~/store/profile'
import type { DropdownMenuItem } from '#ui/components/DropdownMenu.vue'
import { signOut } from '~/composables/auth'

const router = useRouter()
const dev = useDev()
const profile = useProfileStore()
const isDark = useDark({
  initialValue: 'light',
})
const toggleDark = useToggle(isDark)

function navigateToLanding() {
  router.push({ path: '/' })
}

const profileItems = computed((): DropdownMenuItem[][] => [
  [
    { label: profile.profile?.name || 'User', class: 'pointer-events-none' },
    { label: profile.profile?.email || 'Email', class: 'pointer-events-none text-xs text-slate-500' },
  ],
  [
    {
      label: 'Dashboard',
      to: 'dashboard',
      icon: 'i-lucide-layout-dashboard',
    },
    {
      label: 'Settings',
      to: 'settings',
      icon: 'i-lucide-cog',
    },
  ],
  [
    {
      label: 'Sign Out',
      icon: 'i-lucide-log-out',
      onSelect: async (e: Event) => {
        e.preventDefault()
        await signOut()
        await router.push({ path: '/' })
      },
    },
  ],
])
</script>

<template>
  <header
    class="px-6 py-4 border-b shadow bg-white border-white/10 dark:bg-slate-900 dark:border-slate-500/10"
  >
    <div class="flex items-center justify-between">
      <div
        class="text-2xl font-bold cursor-pointer text-primary-600 dark:text-primary-400 hover:text-primary-500"
        @click="navigateToLanding"
      >
        {{ SITE_NAME }}
      </div>
      <nav class="flex gap-4">
        <template
          v-for="route in DASHBOARD_ROUTES"
          :key="route.path"
        >
          <ULink
            view-transition
            :to="route.path"
            active-class="font-bold"
          >
            {{ route.label }}
          </ULink>
        </template>
      </nav>
      <div class="shrink-0 flex items-center gap-4">
        <DevOnly class="inline-block">
          <UButton
            :variant="dev.showDevLogs ? 'solid' : 'soft'"
            icon="i-lucide-code"
            @click="dev.toggleDevLogs()"
          />
        </DevOnly>
        <UButton
          variant="soft"
          :icon="isDark ? 'i-lucide-moon' : 'i-lucide-sun'"
          @click="toggleDark()"
        />
        <UDropdownMenu
          :items="profileItems"
          :ui="{
            content: 'w-48',
          }"
        >
          <UAvatar
            class="hover:ring-2 ring-primary cursor-pointer transition-shadow"
            :text="profile.profile?.name[0] || 'U'"
          />
        </UDropdownMenu>
      </div>
    </div>
  </header>
</template>
