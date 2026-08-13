<script setup lang="ts">
import { SITE_NAME } from '~/data/settings'
import { useDev } from '~/store/dev'

const user = useSupabaseUser()

const dev = useDev()

function handleReqAuth() {
  const router = useRouter()
  router.push({ path: '/login' })
}
</script>

<template>
  <header class="absolute top-0 left-0 w-full z-10 bg-slate-800/10 backdrop-blur-md border-b border-white/5">
    <div class="flex items-center justify-between px-6 py-4">
      <NuxtLink href="/">
        <div class="text-2xl font-bold text-primary-300">
          {{ SITE_NAME }}
        </div>
      </NuxtLink>
      <!--      <nav class="flex gap-4"> -->
      <!--        <template -->
      <!--          v-for="route in LANDING_ROUTES" -->
      <!--          :key="route.path" -->
      <!--        > -->
      <!--          <ULink -->
      <!--            view-transition -->
      <!--            :to="route.path" -->
      <!--            :active="false" -->
      <!--            exact -->
      <!--            exact-hash -->
      <!--            class="text-slate-500 hover:!text-primary-400 transition-colors" -->
      <!--          > -->
      <!--            {{ route.label }} -->
      <!--          </ULink> -->
      <!--        </template> -->
      <!--      </nav> -->
      <div class="flex gap-2 items-center">
        <DevOnly>
          <UButton
            :variant="dev.showDevLogs ? 'solid' : 'soft'"
            icon="i-lucide-code"
            @click="dev.toggleDevLogs()"
          />
        </DevOnly>
        <UButton
          v-if="!user"
          label="Log In"
          icon="i-lucide-log-in"
          @click="handleReqAuth"
        />
        <UButton
          variant="subtle"
          label="Dashboard"
          to="/dashboard"
        />
      </div>
    </div>
  </header>
</template>

<style scoped>

</style>
