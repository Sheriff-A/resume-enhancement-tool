<script setup lang="ts">
import type { ExtResume } from '~/models/ext_resume';
import type { ResumeImport } from '#components';
import { TOASTER_DURATION } from '~/data/settings';
import type { ResumeReport } from '~/models/server/scoring';

const client = useSupabaseClient();
const user = useSupabaseUser();
const toast = useToast();

const resumeSearchByName = ref('');
const sorting = ref('newest');
const sortOptions: { label: string, value: string }[] = [
  { label: 'Newest', value: 'newest' },
  { label: 'Oldest', value: 'oldest' },
  { label: 'A-Z', value: 'az' },
  { label: 'Z-A', value: 'za' },
];

const resumeImportForm = ref<InstanceType<typeof ResumeImport>>();

function getLatestReviewScore(
  reviews?: Array<{ analysis: ResumeReport }> | null,
) {
  return reviews?.[0]?.analysis.overall_score.value ?? null;
}

const { data, error, status, refresh } = useAsyncData(
  'load-resumes',
  async () => {
    const userId = user.value?.id;
    if (!userId) {
      throw new Error('User not authenticated');
    }

    // Load resumes for the authenticated user
    const { data, error } = await client
      .from('resumes')
      .select('*, reviews(analysis)')
      .eq('user_id', userId)
      .order('created_at', {
        ascending: false,
        referencedTable: 'reviews',
      })
      .limit(1, {
        referencedTable: 'reviews',
      })
      .order('updated_at', {
        ascending: false,
        nullsFirst: false,
      });

    if (error) {
      throw new Error(`Error loading resumes: ${error.message}`);
    }

    return (data || []).map(resume => ({
      ...resume,
      score: getLatestReviewScore(
        resume.reviews as (Array<{ analysis: ResumeReport }> | null),
      ),
    }));
  },
);

const newResumeData = ref<ExtResume>();
const uploadResumeDialog = ref(false);
const finalizeResumeDialog = ref(false);
const TEMP_RESUME_STORAGE_KEY = 'new-resume';

function handleNewResume(data: ExtResume) {
  // Store in local storage just in case of error
  useLocalStorage(TEMP_RESUME_STORAGE_KEY, data);
  newResumeData.value = data;
  uploadResumeDialog.value = false;
  finalizeResumeDialog.value = true;
}

async function handleUpsertResume() {
  const resume = newResumeData.value;
  if (!resume) {
    toast.add({
      color: 'error',
      title: 'Missing resume data',
      description: 'Please contact developer for support.',
    });
    return;
  }

  const userId = user.value?.id;
  if (!userId) {
    toast.add({
      title: 'Error',
      description: 'User not authenticated.',
      color: 'error',
    });
    return;
  }

  try {
    const toastId = 'upload-resume-toast';
    toast.add({
      id: toastId,
      color: 'info',
      title: 'Saving Resume...',
      progress: false,
      duration: 0,
    });

    const resumeData = {
      ...resume,
      user_id: userId,
    };
    const {
      status,
      errors,
      data: uploadedResume,
    } = await upsertResume(resumeData);
    if (!uploadedResume || status !== 'success') {
      errors?.forEach((err: string) =>
        toast.add({
          color: 'error',
          title: err,
        }),
      );
      return;
    }
    // TODO: Upsert the resume and open the preview page in a new tab?
    await refresh();

    // Clear temp storage
    localStorage.removeItem(TEMP_RESUME_STORAGE_KEY);
    toast.update(toastId, {
      color: 'success',
      title: 'Resume Saved',
      description: 'Your resume has been saved successfully.',
      progress: true,
      duration: TOASTER_DURATION,
    });
    finalizeResumeDialog.value = false;
  }
  catch (err) {
    console.error(err);
    toast.add({
      color: 'error',
      title: 'Failed to save resume',
      description:
        (err as Error).message || (err as string) || 'An error occurred.',
    });
  }
}

function setSortingOption(option: string) {
  sorting.value = option;
}

function closeResumeDialog() {
  finalizeResumeDialog.value = false;
  newResumeData.value = undefined;
  localStorage.removeItem(TEMP_RESUME_STORAGE_KEY);
}
</script>

<template>
  <div>
    <div class="flex items-center justify-between gap-4 mb-4">
      <div>
        <h2>My Resumes</h2>
      </div>
      <div>
        <UModal
          v-model:open="uploadResumeDialog"
          :close="!resumeImportForm?.loading"
          :dismissible="!resumeImportForm?.loading"
          title="Upload Resume"
          description="Upload your resume to get started."
        >
          <UButton
            label="Import Existing Resume"
            icon="i-lucide-upload"
            class="mr-2"
            variant="subtle"
          />
          <template #body>
            <ResumeImport
              ref="resumeImportForm"
              @on-processed-resume="handleNewResume"
            />
          </template>
        </UModal>
        <UButton
          to="/resume/new"
          label="New Resume from Scratch"
          icon="i-lucide-plus"
        />
      </div>
    </div>

    <div class="mt-4 mb-8">
      <div class="mb-4">
        <LVInput
          v-model="resumeSearchByName"
          label="Search My Resumes"
          placeholder="Resume Name..."
        />
      </div>
      <div>
        <UIcon
          class="text-primary -mb-0.5 mr-2"
          name="i-lucide-arrow-down-up"
        />
        <UButtonGroup>
          <UButton
            v-for="option in sortOptions"
            :key="option.value"
            :label="option.label"
            :variant="sorting === option.value ? 'subtle' : 'outline'"
            @click="setSortingOption(option.value)"
          />
        </UButtonGroup>
      </div>
    </div>

    <GeneralAsyncWrapper
      :data="data"
      :status="status"
      :error="error"
    >
      <template #data="{ data: resumes }">
        <p class="mb-2 text-sm text-slate-500!">
          You have {{ resumes!.length }} resume{{
            resumes!.length === 1 ? '' : 's'
          }}
        </p>
        <div
          class="grid sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-4 mb-4"
        >
          <template
            v-for="resume in resumes"
            :key="resume.id"
          >
            <ResumeCard :resume="resume" />
          </template>
        </div>
      </template>
    </GeneralAsyncWrapper>

    <UModal
      v-model:open="finalizeResumeDialog"
      title="Finalize Resume"
      description="Make final edits to your resume before saving."
      fullscreen
    >
      <template #body>
        <ResumeEditNew
          v-model="newResumeData"
          contained
          @upsert-resume="handleUpsertResume"
        >
          <template #header-controls>
            <UButton
              color="neutral"
              icon="i-lucide-x"
              variant="ghost"
              @click="closeResumeDialog"
            />
          </template>
        </ResumeEditNew>
      </template>
    </UModal>
  </div>
</template>
