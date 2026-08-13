<template>
  <div>
    <GeneralAsyncWrapper
      :data="data"
      :error="error"
      :status="status"
    >
      <template #data="{data: resume}">
        <div v-if="resume!.data" class="no-print max-w-5xl mx-auto mb-4 w-full flex items-center justify-between gap-4">
          <div>
            <NuxtLink v-if="(user?.id === resume!.data.user_id)"
                      :to="{
              name: 'resume-resumeId',
              params: { resumeId: resume!.data.id }
              }"
            >
              <UButton
                label="Edit Resume"
                icon="i-lucide-edit"
                variant="soft"
                class="mr-4"
              />
            </NuxtLink>
          </div>
          <div class="flex items-center gap-4">
            <UButton
              v-if="resume!.data.is_public"
              class="hover:underline"
              label="Copy Public Link"
              variant="link"
              @click="copyPublicLink"
            />
            <!--              label="Download Resume"-->
            <UTooltip arrow :open="isDark" text="Print works best in light mode"
                      :ui="{
              text: 'text-warning-400',
              content: 'bg-warning-800/30 ring-warning-600',
              arrow: 'fill-warning-600'
              }"
            >
              <UButton
                :loading="loadingDownload"
                label="Print Resume"
                icon="i-lucide-printer"
                @click="downloadResume"
              />
            </UTooltip>
          </div>
        </div>

        <UAlert
          v-if="resume!.message"
          color="info"
          :title="resume!.message"
          icon="i-lucide-circle-alert"
        />
        <ResumePreview
          v-else
          :resume="resume!.data"
          :style="resume!.data?.style || 'technical'"
        />
      </template>
    </GeneralAsyncWrapper>

    {{ data }}

  </div>
</template>

<script setup lang="ts">
import type { Resume } from '~/models/database';
import { copyToClipboard } from '~/composables/helpers';

definePageMeta({
  layout: 'print',
  public: true
});

const route = useRoute('resume-public-resumeId');
const router = useRouter();
const resumeId: string = String(route.params.resumeId);

const toast = useToast();
const user = useSupabaseUser();

const loadingDownload = ref(false);
const isDark = useDark();

const { data, error, status } = useAsyncData(
  `public-resume-${resumeId}`,
  async (): Promise<{
    message: string;
    data: Resume | null
  }> => {
    return await $fetch<{
      message: string;
      data: Resume | null
    }>(`/api/resume/public/${resumeId}`, {
      headers: useRequestHeaders(['cookie'])
    });
  }
);

function downloadResume() {
  window.print();
}

async function copyPublicLink() {
  if (!resumeId) {
    toast.add({
      title: 'Error',
      description: 'Invalid Resume ID.',
      color: 'error'
    });
    return;
  }

  const route = router.resolve({
    name: 'resume-public-resumeId',
    params: { resumeId }
  });

  const url = new URL(route.href, import.meta.url);
  copyToClipboard(url.href, 'Public URL Copied to Clipboard').catch(console.error);
}

</script>