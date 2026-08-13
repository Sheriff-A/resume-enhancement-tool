<script setup lang="ts">
import type { z } from 'zod';
import {
  ACCEPTED_RESUME_UPLOAD_FILE_STRINGS,
  ACCEPTED_RESUME_UPLOAD_FILE_TYPES,
  MAX_RESUME_UPLOAD_FILE_SIZE,
  uploadResumeSchema,
} from '~/data/formSchemas';

import LVFileUpload from '~/components/LV/LVFileUpload.vue';
import type { ZodError } from '~/models/general';
import { useInterfaceStore } from '~/store/interface';
import { formatBytes } from '~/composables/helpers';
import type { ExtResume } from '~/models/ext_resume';

interface Emits {
  (e: 'on-processed-resume', data: ExtResume): void;
}

const emit = defineEmits<Emits>();

const toast = useToast();
const useInterface = useInterfaceStore();
const loading = ref(false);

const uploadRules = `Accepts: ${ACCEPTED_RESUME_UPLOAD_FILE_STRINGS.join(', ')} (Max. ${formatBytes(MAX_RESUME_UPLOAD_FILE_SIZE)})`;
type Schema = z.output<typeof uploadResumeSchema>;
const state = reactive<Schema>({
  file: undefined as any,
});
const errors = ref<ZodError[]>([]);
const parsedFile = ref<string>('');

async function onProcessResume() {
  // TODO: Validate enough credits before sending off
  // TODO: Implement credit check in server
  const parsed = parsedFile.value;
  if (!parsed.trim()) {
    toast.add({
      title: 'Error',
      color: 'error',
      description: 'Please upload a file',
    });
    return;
  }

  const creditsNeeded = Math.ceil(parsed.length / 2);
  const userCredits = 5000; // TODO: Fetch from user profile
  if (creditsNeeded > userCredits) {
    toast.add({
      title: 'Insufficient Credits',
      color: 'error',
      description: `You need ${creditsNeeded} credits to process this resume, but you only have ${userCredits} credits. Please purchase more credits to proceed.`,
    });
    // TODO: Maybe pop up a dialog to purchase credits?
    return;
  }

  try {
    loading.value = true;

    const data = await $fetch('/api/openai/parse_resume', {
      method: 'POST',
      body: {
        text: parsed,
      },
    });

    console.log('Resume processed:', data);

    toast.add({
      title: 'Resume Processed',
      color: 'success',
      description: `Successfully processed resume.`,
    });

    emit('on-processed-resume', data);
  } catch (err) {
    console.error('Error processing resume:', err);
    toast.add({
      title: 'Error',
      color: 'error',
      description: 'An error occurred while processing the resume',
    });
  } finally {
    loading.value = false;
  }
}

async function parseResumeUpload(file: File) {
  const err = useZodCheck(uploadResumeSchema, { file });
  if (err) {
    errors.value = err;
    return;
  }
  errors.value = [];

  // Proceed with file upload logic here
  useInterface.showLoader('Parsing Resume...');
  loading.value = true;
  const formData = new FormData();
  formData.append('resume', file, file.name);

  try {
    const data = await $fetch('/api/process_resume', {
      method: 'POST',
      body: formData,
    });

    parsedFile.value = data || '';
  } catch (err) {
    console.error('Error during form submission:', err);
    toast.add({
      title: 'Error',
      color: 'error',
      description: 'An error occurred while processing the form',
    });
  } finally {
    useInterface.hideLoader();
    loading.value = false;
  }
}

watch(
  () => state.file,
  (newFile) => {
    if (newFile) {
      parseResumeUpload(newFile);
      return;
    }
    parsedFile.value = '';
    errors.value = [];
  },
);

defineExpose({
  loading,
});
</script>

<template>
  <div>
    <LVFileUpload
      v-model="state.file"
      :variant="state.file ? 'button' : 'area'"
      label=""
      :accept="ACCEPTED_RESUME_UPLOAD_FILE_TYPES.join(',')"
      :loading="loading"
      :disabled="loading"
      upload-label="Click here to add your resume"
      :upload-description="uploadRules"
    />

    <div v-if="state.file" class="flex justify-between gap-4 items-end my-2">
      <UButton
        :loading="loading"
        :disabled="!!errors.length || loading"
        label="Process Resume"
        @click="onProcessResume"
      />
      <p v-if="!loading && parsedFile.length" class="text-sm">
        Credits: {{ Math.ceil(parsedFile.length / 2) }} (Remaining: {{ 5000 }})
      </p>
    </div>

    <div class="my-2">
      <GeneralErrors :errors="errors" />
    </div>

    <DevWrapper>
      File: {{ state.file ? state.file.name : 'No file uploaded' }} <br />
      Character Count: {{ parsedFile.length }}
      <UButton label="Trigger Emit" @click="onTriggerEmit" />
    </DevWrapper>
  </div>
</template>
