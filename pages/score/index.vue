<script setup lang="ts">
import type { TableColumn } from '@nuxt/ui'
import type { Review } from '~/models/database'
import { formatDateString } from '~/composables/helpers'

type ReviewRow = Review & {
  resume_name: string | null
}

const client = useSupabaseClient()
const user = useSupabaseUser()
const router = useRouter()

const reviewSearch = ref('')
const sorting = ref('newest')
const sortOptions: { label: string, value: string }[] = [
  { label: 'Newest', value: 'newest' },
  { label: 'Oldest', value: 'oldest' },
  { label: 'Highest Score', value: 'highest' },
  { label: 'Lowest Score', value: 'lowest' },
]

const typeFilter = ref('all')
const typeFilterOptions: { label: string, value: string }[] = [
  { label: 'All Types', value: 'all' },
  { label: 'Free', value: 'freemium' },
  { label: 'Pro', value: 'paid' },
]

function setSortingOption(option: string) {
  sorting.value = option
}

const { data, error, status } = useAsyncData('load-reviews', async () => {
  const userId = user.value?.id
  if (!userId) {
    throw new Error('User not authenticated')
  }

  const { data, error } = await client
    .from('reviews')
    .select('*, resumes(nickname, name)')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })

  if (error) {
    throw new Error(`Error loading reviews: ${error.message}`)
  }

  return (data || []).map(({ resumes, ...review }) => ({
    ...review,
    score: review.analysis?.overall_score?.value ?? null,
    resume_name: resumes?.nickname || resumes?.name || null,
  })) as ReviewRow[]
})

const columns: TableColumn<ReviewRow>[] = [
  {
    accessorKey: 'resume_name',
    header: 'Resume',
  },
  {
    accessorKey: 'type',
    header: 'Report Type',
  },
  {
    accessorKey: 'score',
    header: 'Score',
  },
  {
    accessorKey: 'created_at',
    header: 'Date',
  },
]

function goToReview(row: { original: ReviewRow }) {
  const resumeId = row.original.resume_id
  router.push({
    name: 'score-resumeId',
    params: { resumeId },
  })
}
</script>

<template>
  <div>
    <div class="flex items-center justify-between gap-4 mb-4">
      <div>
        <h2>My Reviews</h2>
      </div>
      <div>
        <UButton
          to="/resume"
          label="Review a Resume"
          icon="i-lucide-brain"
        />
      </div>
    </div>

    <div class="mt-4 mb-8">
      <div class="mb-4">
        <LVInput
          v-model="reviewSearch"
          label="Search My Reviews"
          placeholder="Resume Name..."
        />
      </div>
      <div class="flex flex-wrap items-center gap-4">
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
        <div>
          <UIcon
            class="text-primary -mb-0.5 mr-2"
            name="i-lucide-filter"
          />
          <UButtonGroup>
            <UButton
              v-for="option in typeFilterOptions"
              :key="option.value"
              :label="option.label"
              :variant="typeFilter === option.value ? 'subtle' : 'outline'"
              @click="typeFilter = option.value"
            />
          </UButtonGroup>
        </div>
      </div>
    </div>

    <GeneralAsyncWrapper
      :data="data"
      :status="status"
      :error="error"
    >
      <template #data="{ data: reviews }">
        <p class="mb-2 text-sm text-slate-500!">
          You have {{ reviews!.length }} review{{
            reviews!.length === 1 ? '' : 's'
          }}
        </p>
        <UTable
          :data="reviews"
          :columns="columns"
          class="border border-primary/20 rounded-lg"
          :ui="{ tr: 'cursor-pointer hover:bg-primary/5' }"
          @select="goToReview"
        >
          <template #resume_name-cell="{ row }">
            <span class="font-medium">
              {{ row.original.resume_name || 'Untitled Resume' }}
            </span>
          </template>
          <template #type-cell="{ row }">
            <LVChip
              v-if="row.original.type === 'paid'"
              label="PRO"
            />
            <LVChip
              v-else
              label="FREE"
              class="!text-slate-500 !bg-slate-500/5 !border-slate-500/20"
            />
          </template>
          <template #score-cell="{ row }">
            <div class="flex items-center gap-1 text-orange-600 dark:text-orange-400">
              <UIcon
                name="i-lucide-star"
                class="-mb-0.5"
              />
              <span>{{ row.original.score }}</span>
            </div>
          </template>
          <template #created_at-cell="{ row }">
            {{ formatDateString(row.original.created_at, 'yyyy-LL-dd') }}
          </template>
        </UTable>
      </template>
    </GeneralAsyncWrapper>
  </div>
</template>
