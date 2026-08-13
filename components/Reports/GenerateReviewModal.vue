<script setup lang="ts">
import type { FreemiumReport, PaidReport } from '~/models/server/scoring';
import {
  loadResume,
  listResumesForSelect,
  parseResumeForScoring,
  type ResumeSelectOption,
} from '~/composables/resumes';
import { saveReview, type ReviewType } from '~/composables/reviews';
import { TOASTER_DURATION } from '~/data/settings';

interface Props {
  initialResumeId?: string
}

const props = defineProps<Props>();
const emit = defineEmits<{ generated: [reviewId: string] }>();

const toast = useToast();
const user = useSupabaseUser();

const resumes = ref<ResumeSelectOption[]>([]);
const loadingResumes = ref(false);
const selectedResumeId = ref(props.initialResumeId || '');
const targetRole = ref('');
const reviewType = ref<ReviewType>('freemium');
const generating = ref(false);

const resumeItems = computed(() =>
  resumes.value.map(resume => ({
    label: resume.nickname || resume.name,
    value: resume.id,
  })),
);

const basicReviewFeatures = [
  'Overall match score with a plain-language rating',
  'ATS, role alignment & clarity ratings (Low / Medium / High)',
  'Top 3 issues holding your resume back',
  'A one-line career fit signal',
];

const advancedReviewFeatures = [
  'Detailed score breakdown with an explanation for each metric',
  'Missing skills & experience gaps specific to the role',
  '3-5 prioritized improvements ranked by estimated impact',
  'Career strategy: application & role-targeting advice',
  'Interview readiness: strengths & risk areas',
];

async function loadResumeOptions() {
  const userId = user.value?.id;
  if (!userId) return;

  loadingResumes.value = true;
  try {
    resumes.value = await listResumesForSelect(userId);
    if (!selectedResumeId.value && resumes.value.length === 1) {
      selectedResumeId.value = resumes.value[0].id;
    }
  }
  catch (err) {
    console.error('Error loading resumes:', err);
    toast.add({
      title: 'Error',
      color: 'error',
      description: 'Failed to load your resumes.',
    });
  }
  finally {
    loadingResumes.value = false;
  }
}

watch(
  () => props.initialResumeId,
  (value) => {
    if (value) selectedResumeId.value = value;
  },
);

onMounted(loadResumeOptions);

async function generateReview() {
  const toastId = 'generate-review-toast';
  try {
    const userId = user.value?.id;
    if (!userId) {
      toast.add({
        title: 'Error',
        color: 'error',
        description: 'User not authenticated.',
      });
      return;
    }

    const resumeId = selectedResumeId.value;
    if (!resumeId) {
      toast.add({
        title: 'Error',
        color: 'error',
        description: 'Please select a resume to review.',
      });
      return;
    }

    const targetRoleValue = targetRole.value;
    if (!targetRoleValue) {
      toast.add({
        title: 'Error',
        color: 'error',
        description: 'Please provide a target role for evaluation.',
      });
      return;
    }

    generating.value = true;
    toast.add({
      id: toastId,
      color: 'info',
      title: 'Scoring Resume',
      description: 'Please wait while we analyze your resume...',
      progress: false,
      duration: 0,
    });

    const res = await loadResume(userId, resumeId);
    if (res.status !== 'success' || !res.data) {
      toast.remove(toastId);
      toast.add({
        title: 'Error',
        color: 'error',
        description: 'Failed to load resume data. Please try again.',
      });
      return;
    }
    const resumeData = res.data;

    let analysis: FreemiumReport | PaidReport;

    if (reviewType.value === 'paid') {
      const parsedForScore = parseResumeForScoring(resumeData);
      if (!parsedForScore) {
        toast.remove(toastId);
        toast.add({
          title: 'Error',
          color: 'error',
          description: 'Failed to read resume for scoring. Please try again.',
        });
        return;
      }

      analysis = (await $fetch('/api/openai/paid/score_resume', {
        method: 'POST',
        body: {
          resume: parsedForScore,
          targetRole: targetRoleValue,
        },
      })) as unknown as PaidReport;
    }
    else {
      analysis = (await $fetch('/api/openai/freemium/score_resume', {
        method: 'POST',
        body: {
          resume: resumeData,
          targetRole: targetRoleValue,
        },
      })) as unknown as FreemiumReport;
    }

    const review = await saveReview({
      userId,
      resumeId,
      type: reviewType.value,
      analysis,
    });

    toast.update(toastId, {
      title: 'Resume Scored',
      description: 'Your resume has been scored successfully.',
      color: 'success',
      progress: true,
      duration: TOASTER_DURATION,
    });

    emit('generated', review.id);
  }
  catch (err) {
    console.error('Error scoring resume:', err);
    toast.remove(toastId);
    toast.add({
      title: 'Error',
      description: 'Something went wrong scoring resume.',
      color: 'error',
    });
  }
  finally {
    generating.value = false;
  }
}
</script>

<template>
  <div class="space-y-6">
    <LVSelect
      v-model="selectedResumeId"
      label="Resume"
      placeholder="Select a resume to review"
      :items="resumeItems"
      :disabled="loadingResumes || generating"
    />

    <p
      v-if="!loadingResumes && resumes.length === 0"
      class="text-sm text-slate-500!"
    >
      You don't have any resumes yet.
      <NuxtLink
        to="/resume"
        class="text-primary underline"
      >
        Create one
      </NuxtLink>
      to get started.
    </p>

    <LVInput
      v-model="targetRole"
      label="Target Role"
      placeholder="e.g. Full Stack Developer"
      :disabled="generating"
    />

    <div class="grid sm:grid-cols-2 gap-4">
      <ReportsReviewTypeCard
        title="Basic Review"
        badge="FREE"
        icon="i-lucide-gauge"
        description="A quick, high-level snapshot of how your resume reads against the target role."
        :features="basicReviewFeatures"
        :selected="reviewType === 'freemium'"
        @select="reviewType = 'freemium'"
      />
      <ReportsReviewTypeCard
        title="Advanced Review"
        badge="PRO"
        icon="i-lucide-microscope"
        description="An in-depth, personalized breakdown with a prioritized action plan."
        :features="advancedReviewFeatures"
        :selected="reviewType === 'paid'"
        @select="reviewType = 'paid'"
      />
    </div>

    <UButton
      block
      :loading="generating"
      :disabled="generating"
      icon="i-lucide-brain"
      :label="
        reviewType === 'paid'
          ? 'Generate Advanced Review'
          : 'Generate Basic Review'
      "
      @click="generateReview"
    />
  </div>
</template>
