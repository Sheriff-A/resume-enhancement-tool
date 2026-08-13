<script setup lang="ts">

</script>

<template>
  <main
    id="#hero"
    class="relative pt-32 pb-16 sm:pt-40 sm:pb-24 overflow-hidden"
  >
    <!-- Background Glows -->
    <div
      class="absolute top-0 left-1/2 -translate-x-1/2 w-[1000px] h-[500px] bg-indigo-500/10 rounded-full blur-[100px] -z-10 pointer-events-none"
    />
    <div
      class="absolute top-20 left-1/2 -translate-x-1/2 w-[800px] h-[300px] bg-violet-500/10 rounded-full blur-[80px] -z-10 pointer-events-none"
    />

    <div class="max-w-7xl mx-auto px-6 flex flex-col items-center text-center">
      <div
        class="inline-flex items-center gap-2 px-3 py-1 rounded-full border border-white/10 bg-white/5 text-xs font-medium text-indigo-300 mb-8"
      >
        <UIcon
          name="i-lucide-wand-2"
          class="size-4"
        />
        <span>GPT-4 Powered Analysis</span>
      </div>

      <h1 class="text-5xl sm:text-7xl font-medium text-white tracking-tight mb-6 max-w-4xl mx-auto leading-[1.1]">
        Your resume, <br class="hidden sm:block">
        <span class="bg-gradient-to-b from-white via-white to-white/50 bg-clip-text text-transparent">perfected by intelligence.</span>
      </h1>

      <p class="text-lg text-neutral-400 max-w-2xl mx-auto mb-10 font-light leading-relaxed">
        Upload your current resume and let our AI rewrite, format, and optimize it for ATS. Unlock interviews with a CV
        that recruiters actually want to read.
      </p>

      <div class="flex flex-col sm:flex-row items-center gap-4 w-full justify-center">
        <button
          class="w-full sm:w-auto px-8 py-3.5 bg-white text-black rounded-full font-medium text-sm flex items-center justify-center gap-2 hover:bg-neutral-200 transition-all"
        >
          <UIcon
            name="i-lucide-upload-cloud"
            class="size-6"
          />
          Upload Resume
        </button>
        <button
          class="w-full sm:w-auto px-8 py-3.5 bg-transparent border border-neutral-800 text-white rounded-full font-medium text-sm hover:bg-neutral-900 transition-all"
        >
          View Examples
        </button>
      </div>

      <!-- Dashboard Preview -->
      <div class="mt-20 relative w-full max-w-5xl mx-auto perspective-1000">
        <div class="glass-panel rounded-xl p-2 shadow-2xl shadow-indigo-500/10">
          <div class="bg-neutral-900 rounded-lg border border-white/5 overflow-hidden relative">
            <!-- Top Bar -->
            <div class="h-10 border-b border-white/5 flex items-center px-4 gap-2">
              <div class="flex gap-1.5">
                <div class="w-3 h-3 rounded-full bg-red-500/20 border border-red-500/50" />
                <div class="w-3 h-3 rounded-full bg-yellow-500/20 border border-yellow-500/50" />
                <div class="w-3 h-3 rounded-full bg-green-500/20 border border-green-500/50" />
              </div>
              <div class="ml-auto flex items-center gap-2 text-xs text-neutral-500">
                <UIcon
                  name="i-lucide-circle-check"
                  class="size-4"
                />
                ATS Compatible
              </div>
            </div>

            <!-- Main Interface Grid -->
            <div class="grid grid-cols-1 md:grid-cols-12 min-h-[500px]">
              <!-- Left Sidebar (Editor) -->
              <div class="md:col-span-8 p-8 border-r border-white/5 bg-neutral-925 relative">
                <!-- Scan Effect Overlay -->
                <div class="absolute inset-0 z-10 pointer-events-none overflow-hidden opacity-30">
                  <div
                    class="absolute w-full h-px bg-gradient-to-r from-transparent via-indigo-500 to-transparent scan-line shadow-[0_0_15px_rgba(99,102,241,1)]"
                  />
                </div>

                <div class="space-y-6 opacity-80 blur-[0.5px]">
                  <!-- Header Mockup -->
                  <div class="space-y-3">
                    <div class="h-8 w-1/3 bg-neutral-800 rounded" />
                    <div class="h-4 w-1/4 bg-neutral-800 rounded" />
                  </div>
                  <!-- Content Mockup -->
                  <div class="space-y-4 pt-4">
                    <div class="flex gap-4">
                      <div class="w-12 h-12 bg-neutral-800 rounded-lg shrink-0" />
                      <div class="space-y-2 w-full">
                        <div class="h-4 w-3/4 bg-neutral-800 rounded" />
                        <div class="h-4 w-1/2 bg-neutral-800 rounded" />
                      </div>
                    </div>
                    <div class="space-y-2 pt-2">
                      <div class="h-3 w-full bg-neutral-800/50 rounded" />
                      <div class="h-3 w-full bg-neutral-800/50 rounded" />
                      <div class="h-3 w-5/6 bg-neutral-800/50 rounded" />
                    </div>
                  </div>
                </div>

                <!-- AI Suggestion Popover -->
                <div
                  class="absolute top-1/3 right-12 w-64 glass-panel p-4 rounded-xl border-l-2 border-indigo-500 shadow-xl z-20 animate-pulse"
                >
                  <div class="flex items-start gap-3">
                    <span
                      class="iconify text-indigo-400 mt-1"
                      data-icon="lucide:sparkles"
                      data-width="16"
                    />
                    <div class="space-y-1">
                      <p class="text-xs font-semibold text-white">
                        Enhancement Found
                      </p>
                      <p class="text-xs text-neutral-400 leading-relaxed">
                        Rephrased "Managed team" to "Orchestrated cross-functional team of 10..."
                      </p>
                      <div class="pt-2 flex gap-2">
                        <button
                          class="text-[10px] bg-indigo-600 hover:bg-indigo-500 text-white px-2 py-1 rounded transition-colors"
                        >
                          Apply
                        </button>
                        <button class="text-[10px] text-neutral-500 hover:text-neutral-300 px-2 py-1 transition-colors">
                          Dismiss
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Right Sidebar (Score) -->
              <div class="hidden md:block md:col-span-4 bg-neutral-950 p-6 space-y-6">
                <div class="text-center p-6 rounded-2xl bg-neutral-900 border border-white/5">
                  <div class="text-5xl font-medium text-white mb-2">
                    94
                  </div>
                  <div class="text-xs text-neutral-500 uppercase tracking-wider font-medium">
                    Resume Score
                  </div>
                </div>

                <div class="space-y-4">
                  <div class="flex justify-between items-center text-sm">
                    <span class="text-neutral-400">Impact</span>
                    <span class="text-green-400">High</span>
                  </div>
                  <div class="w-full bg-neutral-800 h-1.5 rounded-full overflow-hidden">
                    <div class="bg-green-500 h-full w-[90%] rounded-full" />
                  </div>

                  <div class="flex justify-between items-center text-sm">
                    <span class="text-neutral-400">Brevity</span>
                    <span class="text-indigo-400">Perfect</span>
                  </div>
                  <div class="w-full bg-neutral-800 h-1.5 rounded-full overflow-hidden">
                    <div class="bg-indigo-500 h-full w-[95%] rounded-full" />
                  </div>

                  <div class="flex justify-between items-center text-sm">
                    <span class="text-neutral-400">Keywords</span>
                    <span class="text-yellow-400">Good</span>
                  </div>
                  <div class="w-full bg-neutral-800 h-1.5 rounded-full overflow-hidden">
                    <div class="bg-yellow-500 h-full w-[75%] rounded-full" />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<style scoped>

</style>
