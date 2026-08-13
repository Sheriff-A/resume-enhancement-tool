<script setup lang="ts">
import type { FreemiumReport, PaidReport } from '~/models/server/scoring';
import { loadReviewById } from '~/composables/reviews';
import type { Resume, Review } from '~/models/database';

const user = useSupabaseUser();
const router = useRouter();
const route = useRoute('score-reviewId');
const reviewId = computed(() => String(route.params.reviewId));

const { data, error, status } = useAsyncData(
  () => `load-review-${reviewId.value}`,
  async (): Promise<{ review: Review & { resume: Resume } }> => {
    const userId = user.value?.id;
    if (!userId) {
      throw new Error('User not authenticated');
    }

    const review = await loadReviewById(userId, reviewId.value);
    if (!review) {
      throw new Error('Review not found');
    }

    return { review: review as unknown as Review & { resume: Resume } };
  },
  { watch: [reviewId] },
);

const reviewType = computed(() =>
  data.value?.review.type === 'paid' ? 'paid' : 'freemium',
);
const freemiumReport = computed(() =>
  reviewType.value === 'freemium'
    ? (data.value?.review.analysis as unknown as FreemiumReport | undefined)
    : undefined,
);
const paidReport = computed(() =>
  reviewType.value === 'paid'
    ? (data.value?.review.analysis as unknown as PaidReport | undefined)
    : undefined,
);
const activeReport = computed(() =>
  reviewType.value === 'paid' ? paidReport.value : freemiumReport.value,
);

const resumeDisplayName = computed(() => {
  const resume = data.value?.review.resume;
  if (!resume) return 'Resume';
  return resume.nickname || `${resume.name}'s Resume`;
});

const generateModalOpen = ref(false);

function handleReviewGenerated(newReviewId: string) {
  generateModalOpen.value = false;
  router.push({
    name: 'score-reviewId',
    params: { reviewId: newReviewId },
  });
}
</script>

<template>
  <div class="space-y-8">
    <GeneralAsyncWrapper
      :data="data"
      :status="status"
      :error="error"
    >
      <template #data="{ data: loaded }">
        <div class="space-y-8">
          <ResumeSummaryCard :resume="loaded!.review.resume" />

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
                <UDrawer
                  v-model:open="generateModalOpen"
                  title="Generate a Review"
                  description="Pick a resume, tell us the role you're targeting, and choose how deep you want the review to go."
                  direction="right"
                >
                  <UButton
                    variant="outline"
                    icon="i-lucide-refresh-ccw"
                    color="neutral"
                    label="Generate New Review"
                  />
                  <template #body>
                    <ReportsGenerateReviewModal
                      :initial-resume-id="loaded!.review.resume.id"
                      @generated="handleReviewGenerated"
                    />
                  </template>
                </UDrawer>
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
    </GeneralAsyncWrapper>
  </div>
</template>
