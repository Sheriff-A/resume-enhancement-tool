<script setup lang="ts">
import type { ExtResume } from '~/models/ext_resume';
import type { FreemiumReport, PaidReport } from '~/models/server/scoring';
import {
  loadLatestReview,
  saveReview,
  type ReviewType,
} from '~/composables/reviews';
import { parseResumeForScoring } from '~/composables/resumes';
import { TOASTER_DURATION } from '~/data/settings';

const toast = useToast();
const user = useSupabaseUser();
const router = useRouter();
const route = useRoute('score-resumeId');
const resumeId: string = String(route.params.resumeId);

const resume = ref<ExtResume>();
const freemiumReport = ref<FreemiumReport>();
const paidReport = ref<PaidReport>();
const loadingReport = ref(false);

const targetRole = ref('Full Stack Developer');
const reviewType = ref<ReviewType>('freemium');

const activeReport = computed(() =>
  reviewType.value === 'paid' ? paidReport.value : freemiumReport.value,
);

const resumeDisplayName = computed(() => {
  if (!resume.value) return 'Resume';
  return resume.value.nickname || `${resume.value.name}'s Resume`;
});

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

async function generateReview() {
  const toastId = 'score-resume-toast';
  try {
    const resumeData = resume.value;
    const userId = user.value?.id;
    if (!resumeData || !userId) {
      toast.add({
        title: 'Error',
        color: 'error',
        description: 'Failed to load resume data. Please try again.',
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

    loadingReport.value = true;
    toast.add({
      id: toastId,
      color: 'info',
      title: 'Scoring Resume',
      description: 'Please wait while we analyze your resume...',
      progress: false,
      duration: 0,
    });

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
      paidReport.value = analysis;
    }
    else {
      analysis = (await $fetch('/api/openai/freemium/score_resume', {
        method: 'POST',
        body: {
          resume: resumeData,
          targetRole: targetRoleValue,
        },
      })) as unknown as FreemiumReport;
      freemiumReport.value = analysis;
    }

    await saveReview({
      userId,
      resumeId,
      type: reviewType.value,
      score: Math.round(analysis.overall_score.value),
      analysis,
    });

    toast.update(toastId, {
      title: 'Resume Scored',
      description: 'Your resume has been scored successfully.',
      color: 'success',
      progress: true,
      duration: TOASTER_DURATION,
    });
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
    loadingReport.value = false;
  }
}

onMounted(async () => {
  const userId = user.value?.id;
  if (!userId) {
    toast.add({
      title: 'Error',
      description: 'User not authenticated.',
      color: 'error',
    });

    return await router.push({
      name: 'login',
    });
  }

  if (!resumeId) {
    toast.add({
      title: 'Error',
      description: 'No resume ID provided.',
      color: 'error',
    });
    return await router.push({
      name: 'resume',
    });
  }

  try {
    const res = await loadResume(userId, resumeId);

    if (res.status !== 'success' || !res.data) {
      toast.add({
        title: 'Error',
        description: 'Failed to load resume.',
        color: 'error',
      });
      return await router.push({
        name: 'resume',
      });
    }

    resume.value = res.data;
  }
  catch (err) {
    console.error('Error loading resume:', err);
    toast.add({
      title: 'Error',
      description: 'Something went wrong loading resume.',
      color: 'error',
    });
    return router.push({
      name: 'resume',
    });
  }

  try {
    const [freemiumReview, paidReview] = await Promise.all([
      loadLatestReview(userId, resumeId, 'freemium'),
      loadLatestReview(userId, resumeId, 'paid'),
    ]);

    if (freemiumReview) {
      freemiumReport.value
        = freemiumReview.analysis as unknown as FreemiumReport;
      reviewType.value = 'freemium';
    }
    if (paidReview) {
      paidReport.value = paidReview.analysis as unknown as PaidReport;
      reviewType.value = 'paid';
    }
  }
  catch (err) {
    console.error('Error loading existing reviews:', err);
  }
});
</script>

<template>
  <div class="space-y-8">
    <ResumeSummaryCard
      v-if="resume"
      :resume="resume"
    />

    <UCard>
      <template #header>
        <h4>Generate a Review</h4>
        <p class="sub-text">
          Tell us the role you're targeting and choose how deep you want the
          review to go.
        </p>
      </template>

      <div class="space-y-6">
        <LVInput
          v-model="targetRole"
          label="Target Role"
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
          :loading="loadingReport"
          :disabled="loadingReport"
          icon="i-lucide-brain"
          :label="
            reviewType === 'paid'
              ? 'Generate Advanced Review'
              : 'Generate Basic Review'
          "
          @click="generateReview"
        />
      </div>
    </UCard>

    <div v-if="activeReport">
      <USeparator class="my-12" />
      <div class="mb-12 flex items-start justify-between gap-4">
        <div>
          <div class="flex items-center gap-2">
            <h4>Resume Audit Report</h4>
            <LVChip
              :label="reviewType === 'paid' ? 'PRO' : 'FREE'"
              :class="
                reviewType === 'paid'
                  ? ''
                  : 'text-slate-500! bg-slate-500/5! border-slate-500/20!'
              "
            />
          </div>
          <p class="sub-text">
            <span class="text-primary font-bold">
              {{ resumeDisplayName }}
            </span>
            analyzed for the role of
            <span class="text-primary font-bold">
              {{ activeReport.meta.role_targeted }} </span>.
          </p>
        </div>
        <div>
          <UButton
            variant="outline"
            icon="i-lucide-refresh-ccw"
            color="neutral"
            label="Generate New Review"
            :disabled="loadingReport"
            @click.stop
          />
          <UButton
            class="ml-2"
            icon="i-lucide-edit"
            label="Edit Resume"
            :to="{ name: 'resume-resumeId', params: { resumeId } }"
          />
        </div>
      </div>

      <div class="relative grid grid-cols-3 gap-4 lg:gap-8">
        <div class="sticky top-4 h-fit">
          <template v-if="reviewType === 'freemium' && freemiumReport">
            <ReportsFreeHero :report="freemiumReport" />
            <div class="mt-8 flex items-center gap-2">
              <UIcon
                class="text-emerald-300 dark:text-emerald-500 size-6"
                name="i-lucide-smile"
              />
              <h5>Confidence Note</h5>
            </div>
            <p class="mt-2">
              {{ freemiumReport.confidence_note }}
            </p>
          </template>
          <ReportsPaidHero
            v-else-if="paidReport"
            :report="paidReport"
          />
        </div>
        <div
          v-if="reviewType === 'freemium' && freemiumReport"
          class="space-y-8 col-span-2"
        >
          <ReportsFreeScores :report="freemiumReport" />
          <ReportsFreeTopIssues :report="freemiumReport" />
          <ReportsFreeCareerFitSignal :report="freemiumReport" />
        </div>
        <div
          v-else-if="paidReport"
          class="space-y-8 col-span-2"
        >
          <ReportsPaidGaps :report="paidReport" />
          <ReportsPaidImprovements :report="paidReport" />
          <ReportsPaidCareerStrategy :report="paidReport" />
          <ReportsPaidInterviewSignals :report="paidReport" />
        </div>
      </div>

      <template v-if="reviewType === 'paid' && paidReport">
        <div class="mt-8 flex items-center gap-2">
          <UIcon
            class="text-emerald-300 dark:text-emerald-500 size-6"
            name="i-lucide-smile"
          />
          <h5>Confidence Note</h5>
        </div>
        <p class="mt-2">
          {{ paidReport.confidence_note }}
        </p>
      </template>
    </div>
  </div>
</template>
