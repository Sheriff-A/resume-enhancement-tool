<script setup lang="ts">
import { SITE_NAME } from '~/data/settings'
import { useDev } from '~/store/dev'

const dev = useDev()
const isDark = useDark()
const toggleDark = useToggle(isDark)

function navigateToLanding() {
  const router = useRouter()
  router.push({ path: '/' })
}
</script>

<template>
  <header
    class="px-6 py-4 border-b shadow bg-white border-white/10 dark:bg-slate-900 dark:border-slate-500/10"
  >
    <div class="flex items-center justify-between ">
      <div
        class="text-2xl font-bold cursor-pointer text-primary-600 dark:text-primary-400 hover:text-primary-500"
        @click="navigateToLanding"
      >
        {{ SITE_NAME }}
      </div>
      <div>
        <DevOnly>
          <UButton
            :variant="dev.showDevLogs ? 'solid' : 'soft'"
            icon="i-lucide-code"
            @click="dev.toggleDevLogs()"
          />
        </DevOnly>
        <!-- TODO: User Component -->
        <UButton
          variant="soft"
          :icon="isDark ? 'i-lucide-moon' : 'i-lucide-sun'"
          @click="toggleDark()"
        />
      </div>
    </div>
  </header>
</template>
