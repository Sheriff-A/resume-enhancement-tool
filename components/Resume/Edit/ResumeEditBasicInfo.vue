<script setup lang="ts">
import { MAX_SUMMARY_LENGTH } from '~/data/formSchemas'
import type { ExtResume } from '~/models/ext_resume'
import type { EnhanceResumeResults } from '~/models/server/resume'
import type { UpdateDecision } from '~/models/general'

interface Props {
  errorPaths?: string[]
  updateData?: EnhanceResumeResults['summary']
}

withDefaults(defineProps<Props>(), {
  errorPaths: () => [],
  updateData: undefined,
})

const model = defineModel<ExtResume>({
  required: true,
})

const decision = ref<UpdateDecision>()

function onAcceptUpdate(text: string) {
  model.value.summary = text
  decision.value = 'accepted'
}

function onRejectUpdate() {
  decision.value = 'rejected'
}
</script>

<template>
  <div>
    <p class="mb-4">
      Fill in your basic information to get started with your resume.
    </p>
    <LVInput
      v-model="model.nickname"
      class="mb-1"
      label="Resume Nickname"
      required
    />
    <LVInput
      v-model="model.name"
      class="mb-1"
      label="Name"
      required
    />
    <LVTextArea
      v-model="model.summary"
      label="Summary"
      :help="`${model.summary?.length ?? 0}/${MAX_SUMMARY_LENGTH}`"
      :ui="{
        base: decision === 'accepted'
          ? '!ring-accent'
          : undefined,
      }"
      :ff-ui="{
        help:
          (model.summary?.length ?? 0) > MAX_SUMMARY_LENGTH
            ? '!text-error'
            : undefined,
      }"
    />

    <ResumeSuggestion
      v-if="updateData && !decision"
      class="mt-1"
      :text="updateData.text"
      :confidence="updateData.confidence"
      :raw="updateData"
      @accept="onAcceptUpdate"
      @reject="onRejectUpdate"
    />

    <USeparator
      class="my-4"
      label="Contact"
    />
    <LVInput
      v-model="model.email"
      class="mb-1.5"
      label="Email"
      required
    />
    <LVInput
      v-model="model.phone"
      class="mb-1.5"
      label="Phone"
    />
    <LVInput
      v-model="model.location"
      class="mb-1.5"
      label="Location"
    />
    <LVInput
      v-model="model.portfolio"
      class="mb-1.5"
      label="Portfolio"
      :error="
        errorPaths.includes(`portfolio`)
          && 'Please enter a valid portfolio url'
      "
    />
    <LVInput
      v-model="model.linkedin"
      class="mb-1.5"
      label="LinkedIn"
      :error="
        errorPaths.includes(`linkedin`)
          && 'Please enter a valid LinkedIn url'
      "
    />
    <LVInput
      v-model="model.github"
      class="mb-1.5"
      label="Github"
      :error="
        errorPaths.includes(`github`)
          && 'Please enter a valid Github url'
      "
    />
  </div>
</template>

<style scoped>

</style>
