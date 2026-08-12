<script setup lang="ts">

</script>

<template>
  <div class="border-t border-slate-500/10 bg-slate-50 dark:bg-slate-950">
    <UContainer>
      <GeneralFooterBanner class="mt-8" />
    </UContainer>
    <footer class="border-t mt-8 border-slate-500/10 py-8">
      <UContainer>
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm">
              © {{ new Date().getFullYear() }} Sheriff A. All rights reserved
            </p>
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
        </div>
      </UContainer>
    </footer>
  </div>
</template>

<style scoped>

</style>
