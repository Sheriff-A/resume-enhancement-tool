<script setup lang="ts">
import type { Resume } from '~/models/database'
import { formatDateString } from '~/composables/helpers'

interface Props {
  resume: Resume & { score: number }
}

const props = defineProps<Props>()
const router = useRouter()

const isReviewed = computed(() => {
  return props.resume.score !== null
})

function goToResume() {
  const resumeId = props.resume.id
  router.push({
    name: 'resume-resumeId',
    params: { resumeId },
  })
}

function goToReview() {
  const resumeId = props.resume.id
  router.push({
    name: 'score-resumeId',
    params: { resumeId },
  })
}

function goToPublicResume() {
  const resumeId = props.resume.id
  router.push({
    name: 'resume-public-resumeId',
    params: { resumeId },
  })
}
</script>

<template>
  <div
    class="aspect-8/11 p-4 border rounded-lg border-primary/20 flex flex-col justify-between gap-4 cursor-pointer transition-all hover:border-primary hover:ring-2 ring-primary hover:bg-linear-to-b from-primary/20 to-primary/10 group"
    @click.stop="goToResume"
  >
    <div class="grow">
      <div class="flex items-center justify-between flex-wrap gap-x-2 w-full">
        <div>
          <p class="inline-block w-fit text-lg font-bold">
            <UIcon
              size="1.2rem"
              name="i-lucide-file-text"
              class="inline-block -mb-1 mr-1 group-hover:text-primary"
            />
            {{ resume.nickname || resume.name }}
          </p>
        </div>
        <p class="text-xs">
          {{
            formatDateString(
              resume.updated_at || resume.created_at,
              'yyyy-LL-dd',
            )
          }}
        </p>
      </div>
      <div class="mt-4">
        <p>{{ resume.name }}</p>
        <p class="text-sm! text-slate-500!">
          {{ resume.email }}
        </p>
        <p class="mt-4 text-sm! text-slate-500! line-clamp-5">
          {{ resume.summary }}
        </p>
        <p
          v-if="resume.is_public"
          class="text-sm! text-primary!"
        >
          (Public)
        </p>
      </div>
    </div>
    <div class="">
      <div class="grid grid-cols-2 gap-2">
        <UButton
          label="Preview"
          icon="i-lucide-eye"
          variant="soft"
          color="neutral"
          class="col-span-2"
          @click.stop="goToPublicResume"
        />
        <UButton
          label="Edit"
          icon="i-lucide-edit"
          variant="soft"
          @click.stop="goToResume"
        />

        <!-- TODO: Implement Functionality -->
        <UButton
          :variant="isReviewed ? 'soft' : 'subtle'"
          label="Review"
          icon="i-lucide-brain"
          :trailing-icon="isReviewed ? 'i-lucide-check' : undefined"
          color="accent"
          @click.stop="goToReview"
        />
      </div>
    </div>
    <div
      class="flex items-center justify-between gap-2 w-full -mb-2 border-t border-primary/20 pt-2 mr-4"
    >
      <div>
        <UTooltip :text="isReviewed ? 'Reviewed' : 'Unreviewed'">
          <UIcon
            name="i-lucide-brain"
            class="-mb-0.5"
            :class="isReviewed ? 'text-primary' : ''"
          />
          <template v-if="isReviewed">
            <span class="subtle-text mx-1"> &bull; </span>
            <UIcon
              name="i-lucide-star"
              class="-mb-0.5 mr-1 text-orange-600 dark:text-orange-400"
            />
            <span class="text-orange-600 dark:text-orange-400">
              {{ resume.score || 0 }}
            </span>
          </template>
        </UTooltip>
      </div>

      <!-- TODO: Delete resume functionality -->
      <UButton
        color="error"
        variant="ghost"
        size="xs"
        label="Delete"
        icon="i-lucide-trash"
        @click.stop
      />
    </div>
  </div>
</template>
