<script setup lang="ts">

</script>

<template>
  <!-- Recruiter Section -->
  <section class="py-24 relative overflow-hidden">
    <div class="absolute inset-0 bg-neutral-900/20" />
    <div class="max-w-7xl mx-auto px-6 relative z-10">
      <div
        class="glass-panel rounded-3xl p-8 md:p-12 border border-white/10 flex flex-col md:flex-row gap-12 items-center"
      >
        <div class="md:w-1/2 space-y-6">
          <div
            class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-indigo-500/10 text-xs font-medium text-indigo-400 border border-indigo-500/20"
          >
            <span>For Recruiters</span>
          </div>
          <h2 class="text-3xl md:text-4xl font-medium text-white tracking-tight">
            Find talent that isn't on LinkedIn.
          </h2>
          <p class="text-neutral-400 leading-relaxed">
            Access our database of active job seekers. Filter by AI-verified skills, experience, and specific technical
            requirements. Connect directly with candidates who are ready to move.
          </p>
          <ul class="space-y-3 pt-2">
            <li class="flex items-center gap-3 text-sm text-neutral-300">
              <UIcon
                name="i-lucide-check"
                class="text-indigo-500 size-4"
              />
              Semantic search powered by LLMs
            </li>
            <li class="flex items-center gap-3 text-sm text-neutral-300">
              <UIcon
                name="i-lucide-check"
                class="text-indigo-500 size-4"
              />
              Direct messaging integration
            </li>
            <li class="flex items-center gap-3 text-sm text-neutral-300">
              <UIcon
                name="i-lucide-check"
                class="text-indigo-500 size-4"
              />
              View verification status
            </li>
          </ul>
          <div class="pt-4">
            <a
              href="#"
              class="inline-flex items-center gap-2 text-white font-medium border-b border-white pb-0.5 hover:text-neutral-300 hover:border-neutral-300 transition-colors"
            >
              Start Searching Talent
              <UIcon
                name="i-lucide-arrow-right"
                class="text-white size-4"
              />
            </a>
          </div>
        </div>

        <!-- Recruiter UI Mockup -->
        <div class="md:w-1/2 w-full">
          <div class="bg-neutral-950 rounded-xl border border-white/10 p-4 shadow-2xl">
            <!-- Search Bar -->
            <div class="flex items-center gap-3 bg-neutral-900 p-3 rounded-lg border border-white/5 mb-4">
              <span
                class="iconify text-neutral-500"
                data-icon="lucide:search"
                data-width="18"
              />
              <input
                type="text"
                placeholder="Senior Product Designer with AI experience..."
                class="bg-transparent border-none outline-none text-sm text-white w-full placeholder:text-neutral-600"
              >
            </div>

            <!-- Candidate Card -->
            <div class="space-y-3">
              <div
                class="p-4 rounded-lg border border-white/5 hover:bg-white/5 transition-colors cursor-pointer flex gap-4 items-start"
              >
                <div
                  class="w-10 h-10 rounded-full bg-neutral-800 flex items-center justify-center text-xs font-medium text-white"
                >
                  JD
                </div>
                <div class="flex-1">
                  <div class="flex justify-between items-start">
                    <div>
                      <h4 class="text-sm font-medium text-white">
                        Jane Doe
                      </h4>
                      <p class="text-xs text-neutral-500">
                        Senior UX Engineer • 5y Exp
                      </p>
                    </div>
                    <span
                      class="text-[10px] text-green-400 bg-green-400/10 px-2 py-0.5 rounded-full border border-green-400/20"
                    >Open to work</span>
                  </div>
                  <div class="flex gap-2 mt-3">
                    <span class="text-[10px] text-neutral-400 bg-neutral-800 px-2 py-1 rounded">Figma</span>
                    <span class="text-[10px] text-neutral-400 bg-neutral-800 px-2 py-1 rounded">React</span>
                    <span class="text-[10px] text-neutral-400 bg-neutral-800 px-2 py-1 rounded">System Design</span>
                  </div>
                </div>
              </div>
              <div
                class="p-4 rounded-lg border border-white/5 hover:bg-white/5 transition-colors cursor-pointer flex gap-4 items-start opacity-60"
              >
                <div
                  class="w-10 h-10 rounded-full bg-neutral-800 flex items-center justify-center text-xs font-medium text-white"
                >
                  MK
                </div>
                <div class="flex-1">
                  <div class="flex justify-between items-start">
                    <div>
                      <h4 class="text-sm font-medium text-white">
                        Marcus Kane
                      </h4>
                      <p class="text-xs text-neutral-500">
                        Full Stack Developer • 3y Exp
                      </p>
                    </div>
                  </div>
                  <div class="flex gap-2 mt-3">
                    <span class="text-[10px] text-neutral-400 bg-neutral-800 px-2 py-1 rounded">Node.js</span>
                    <span class="text-[10px] text-neutral-400 bg-neutral-800 px-2 py-1 rounded">Postgres</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>

</style>
