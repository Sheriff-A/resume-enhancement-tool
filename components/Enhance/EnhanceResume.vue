<script setup lang="ts">
import {
  enhanceResumeSchema,
  MAX_JOB_DESCRIPTION_LENGTH,
} from '~/data/formSchemas'
import type { ZodError } from '~/models/general'
import type { ExtResume } from '~/models/ext_resume'
import type { EnhanceResumeResults } from '~/models/server/resume'
import { TOASTER_DURATION } from '~/data/settings'

interface Props {
  resume: ExtResume
}

interface Emits {
  (e: 'on-enhancement-processed', data: EnhanceResumeResults): void
}

const props = defineProps<Props>()
const emits = defineEmits<Emits>()

const toast = useToast()

const jobDescription = ref<string>('')
const errors = ref<ZodError[]>([])
const loading = ref(false)

const parsedResume = parseResumeForEnhancement(props.resume)

function pasteFromClipboard(): void {
  navigator.clipboard
    .readText()
    .then((text) => {
      jobDescription.value = text
    })
    .catch((err) => {
      console.error('Failed to read clipboard contents: ', err)
    })
}

async function enhanceResume() {
  const toastId = 'enhance-resume-loading'
  try {
    loading.value = true
    toast.add({
      id: toastId,
      color: 'info',
      title: 'Enhancement in Progress...',
      description:
        'Your resume is being enhanced. This may take a few minutes.',
      duration: 0,
      progress: false,
    })

    const data = await $fetch('/api/openai/enhance_resume_with_job', {
      method: 'POST',
      body: {
        resume: parsedResume,
        description: jobDescription.value,
      },
    })

    console.log(data)
    toast.update(toastId, {
      color: 'success',
      title: 'Resume Enhancements Ready!',
      description:
        'Your resume has been enhanced. Please review and accept or decline the suggestions.',
      duration: TOASTER_DURATION,
      progress: true,
    })
    emits('on-enhancement-processed', data)
  }
  catch (err) {
    console.error('Error enhancing resume:', err)
    toast.remove(toastId)
    toast.add({
      title: 'Error',
      description: 'Something went wrong enhancing resume.',
      color: 'error',
    })
  }
  finally {
    loading.value = false
  }
}

function onValidate() {
  const err = useZodCheck(enhanceResumeSchema, {
    job_description: jobDescription.value,
    resume: parsedResume,
  })
  console.log(err)
  if (err) {
    errors.value = err
    return
  }
  errors.value = []
  enhanceResume()
}
</script>

<template>
  <div>
    <p class="mb-2">
      Please provide a job description to help enhance your resume towards. Be
      sure to focus on the responsibilities and skills that are relevant to the
      job.
    </p>
    <p class="mb-4 text-sm !text-primary">
      You can copy and paste a description from a job posting/application board
      for best results.
    </p>
    <LVTextArea
      v-model="jobDescription"
      class="mb-2"
      label="Job Description"
      :rows="5"
      :help="`${jobDescription.length}/${MAX_JOB_DESCRIPTION_LENGTH}`"
      :error="jobDescription.length > MAX_JOB_DESCRIPTION_LENGTH"
      :ff-ui="{
        help:
          (jobDescription.length ?? 0) > MAX_JOB_DESCRIPTION_LENGTH
            ? '!text-error'
            : undefined,
      }"
    >
      <template #hint>
        <UButton
          label="Paste"
          icon="i-lucide-clipboard"
          variant="soft"
          @click="pasteFromClipboard"
        >
          Paste from Clipboard
        </UButton>
      </template>
    </LVTextArea>

    <div class="mt-8 flex items-center justify-between gap-4">
      <UButton
        :loading="loading"
        :disabled="loading"
        label="Enhance"
        icon="i-lucide-sparkles"
        @click="onValidate"
      />
      <p v-if="parsedResume">
        Resume Provided
        <UIcon
          name="i-lucide-check"
          class="text-success -mb-0.5"
        />
      </p>
    </div>

    <div
      v-if="errors.length"
      class="mt-4"
    >
      <GeneralErrors :errors="errors" />
    </div>
  </div>
</template>

<style scoped></style>
