<script setup lang="ts">

</script>

<template>
  <!-- Features Grid -->
  <section
    id="#about"
    class="py-24 border-t border-white/5 bg-neutral-950"
  >
    <div class="max-w-7xl mx-auto px-6">
      <div class="mb-16">
        <h2 class="text-3xl font-medium text-white tracking-tight mb-4">
          Everything you need to get hired.
        </h2>
        <p class="text-neutral-500 max-w-xl">
          Our platform goes beyond simple editing. We analyze market trends to position you as the top candidate.
        </p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <!-- Card 1 -->
        <div
          class="group p-8 rounded-2xl bg-neutral-900/50 border border-white/5 hover:border-white/10 hover:bg-neutral-900 transition-all duration-300"
        >
          <div
            class="w-10 h-10 rounded-lg bg-neutral-800 flex items-center justify-center mb-6 group-hover:scale-110 transition-transform"
          >
            <UIcon
              name="i-lucide-file-check-2"
              class="text-white size-6"
            />
          </div>
          <h3 class="text-lg font-medium text-white mb-2">
            ATS Compliance
          </h3>
          <p class="text-sm text-neutral-500 leading-relaxed">
            Algorithms reject 75% of resumes. Ours are built with structure and keywords that pass automated screenings
            every time.
          </p>
        </div>

        <!-- Card 2 -->
        <div
          class="group p-8 rounded-2xl bg-neutral-900/50 border border-white/5 hover:border-white/10 hover:bg-neutral-900 transition-all duration-300"
        >
          <div
            class="w-10 h-10 rounded-lg bg-neutral-800 flex items-center justify-center mb-6 group-hover:scale-110 transition-transform"
          >
            <UIcon
              name="i-lucide-pen-tool"
              class="text-white size-6"
            />
          </div>
          <h3 class="text-lg font-medium text-white mb-2">
            AI Rewriting
          </h3>
          <p class="text-sm text-neutral-500 leading-relaxed">
            Turn bullet points into achievements. Our AI suggests powerful action verbs and quantifiable metrics for
            your role.
          </p>
        </div>

        <!-- Card 3 -->
        <div
          class="group p-8 rounded-2xl bg-neutral-900/50 border border-white/5 hover:border-white/10 hover:bg-neutral-900 transition-all duration-300"
        >
          <div
            class="w-10 h-10 rounded-lg bg-neutral-800 flex items-center justify-center mb-6 group-hover:scale-110 transition-transform"
          >
            <UIcon
              name="i-lucide-download"
              class="text-white size-6"
            />
          </div>
          <h3 class="text-lg font-medium text-white mb-2">
            Multi-Format Export
          </h3>
          <p class="text-sm text-neutral-500 leading-relaxed">
            Download as PDF, DOCX, or share a live web link. Your formatting stays pixel-perfect across all devices.
          </p>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>

</style>
