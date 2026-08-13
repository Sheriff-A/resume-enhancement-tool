<script setup lang="ts">
import { useProfileStore } from '~/store/profile';
import type { Resume } from '~/models/database';
import { DateTime } from 'luxon';
import LVInfoCard from '~/components/LV/LVInfoCard.vue';

const toast = useToast();
const profileStore = useProfileStore();

const svgTool = useSvg();

const filter = ref('all');
const filters: {
  label: string
  value: string
}[] = [
  { label: 'All', value: 'all' },
  { label: 'Reviewed', value: 'reviewed' },
  { label: 'Unreviewed', value: 'unreviewed' },
];

function onSelectFilter(value: string) {
  filter.value = value;
}

const sampleResumeActivities: Partial<
  Pick<Resume, 'name' | 'updated_at'> & {
    id: number
    views: number
    downloads: number
    reviewed: boolean
    score: number | null
  }
>[] = [
  {
    id: 1,
    name: 'Registered Nurse',
    updated_at: undefined,
    reviewed: false,
    score: null,
    views: 0,
    downloads: 0,
  },
  {
    id: 2,
    name: 'Full Stack Developer',
    updated_at: '2026-08-09T15:00:00Z',
    reviewed: true,
    score: 9.7,
    views: 132,
    downloads: 86,
  },
  {
    id: 3,
    name: 'Elementary School Teacher',
    updated_at: '2026-08-04T09:15:00Z',
    reviewed: true,
    score: 9.1,
    views: 98,
    downloads: 61,
  },
  {
    id: 4,
    name: 'Financial Analyst',
    updated_at: '2026-07-28T13:45:00Z',
    reviewed: false,
    score: 7.8,
    views: 54,
    downloads: 33,
  },
  {
    id: 5,
    name: 'Civil Engineer',
    updated_at: '2026-07-19T10:30:00Z',
    reviewed: true,
    score: 8.9,
    views: 76,
    downloads: 47,
  },
  {
    id: 6,
    name: 'Restaurant General Manager',
    updated_at: '2026-07-10T08:20:00Z',
    reviewed: false,
    score: 6.4,
    views: 28,
    downloads: 12,
  },
  {
    id: 7,
    name: 'Corporate Paralegal',
    updated_at: '2026-06-30T17:05:00Z',
    reviewed: true,
    score: 8.5,
    views: 41,
    downloads: 19,
  },
];

function calculateTimePassed(startTime?: string | null): string {
  if (!startTime) return 'NEW';
  const now = DateTime.now();
  return (
    DateTime.fromISO(startTime).toRelative({
      base: now,
    }) || 'N/A'
  );
}

const sampleStats = [
  {
    label: 'Total Resumes',
    value: 12,
    caption: '9 Reviewed',
    highlight: true,
    icon: 'i-lucide-file-text',
    iconClass: '!text-blue-500 dark:!text-blue-300',
  },
  {
    label: 'Average Score',
    value: '89%',
    icon: 'i-lucide-star',
    iconClass: '!text-orange-400 dark:!text-orange-300',
  },
  {
    label: 'Total Views',
    value: 268,
    icon: 'i-lucide-eye',
    iconClass: '!text-primary-400 dark:!text-primary-300',
  },
];

function notifyOfSampleData() {
  toast.add({
    title: 'Sample Data',
    description:
      'Everything on this dashboard is placeholder data for preview purposes.',
    color: 'info',
    icon: 'i-lucide-flask-conical',
  });
}
</script>

<template>
  <div>
    <h2>Hello, {{ profileStore.profile?.name }}! 👋</h2>
    <p>
      Welcome back to your dashboard. Here’s a quick overview of your resume
      reviews and recent activity.
    </p>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-8 mb-8">
      <LVInfoCard
        v-for="stat in sampleStats"
        :key="stat.label"
        :icon="stat.icon"
        :icon-class="stat.iconClass"
        :value="stat.value"
        :label="stat.label"
        :caption="stat.caption"
        :highlight="stat.highlight"
      />
    </div>

    <UCard>
      <div class="flex justify-between items-center gap-4 mb-4">
        <div class="flex items-center gap-4">
          <LVIconWrapper class="bg-primary/30! text-primary!">
            <UIcon name="i-lucide-activity" />
          </LVIconWrapper>
          <div>
            <h5>Recent Activity</h5>
            <p class="text-xs font-bold">
              Last 90 Days
            </p>
          </div>
        </div>
        <div class="flex items-center gap-2">
          <UButtonGroup>
            <UButton
              v-for="filterBtn in filters"
              :key="filterBtn.value"
              :variant="filter === filterBtn.value ? 'subtle' : 'outline'"
              @click.stop="onSelectFilter(filterBtn.value)"
            >
              {{ filterBtn.label }}
            </UButton>
          </UButtonGroup>
          <UButton
            variant="ghost"
            trailing-icon="i-lucide-arrow-right"
            to="/resume"
          >
            View All
          </UButton>
        </div>
      </div>
      <div>
        <div
          v-for="activity in sampleResumeActivities"
          :key="activity.id"
          class="border border-slate-300/20 hover:border-primary rounded-lg mb-4 last:mb-0 p-2 pl-4"
        >
          <div class="w-full grid grid-cols-3 gap-4">
            <div class="flex items-center gap-2 max-sm:col-span-2">
              <div>
                <UTooltip :text="activity.reviewed ? 'Reviewed' : 'Unreviewed'">
                  <UIcon
                    class="-mb-0.5"
                    :class="activity.reviewed ? 'text-primary' : ''"
                    name="i-lucide-brain"
                  />
                </UTooltip>
              </div>
              <p>{{ activity.name }}</p>
            </div>
            <div class="text-center max-sm:hidden">
              <span class="mx-1">
                <UIcon
                  class="-mb-0.5 text-orange-400 dark:text-orange-300"
                  name="i-lucide-star"
                />
                {{ activity.score ? `${activity.score * 10}%` : '-' }}
              </span>
              <span class="subtle-text"> &bull; </span>
              <span class="mx-1">
                <UIcon
                  class="-mb-0.5 text-primary-400 dark:text-primary-300"
                  name="i-lucide-eye"
                />
                {{ activity.views || '-' }}
              </span>
              <span class="subtle-text">&bull;</span>
              <span class="mx-1">
                <UIcon
                  class="-mb-0.5 text-emerald-400 dark:text-emerald-300"
                  name="i-lucide-download"
                />
                {{ activity.downloads || '-' }}
              </span>
            </div>
            <div class="flex items-center gap-2 justify-end">
              <p class="text-sm text-center max-sm:hidden">
                {{ calculateTimePassed(activity.updated_at) }}
              </p>
              <UButton
                variant="soft"
                icon="i-lucide-brain"
                size="sm"
                label="Review"
                color="accent"
                @click="notifyOfSampleData"
              />
              <UButton
                icon="i-lucide-edit"
                size="sm"
                label="Edit"
                @click="notifyOfSampleData"
              />
            </div>
          </div>
        </div>
      </div>
    </UCard>

    <div class="grid grid-cols-3 gap-4 mt-8 mb-8">
      <UCard class="">
        <div class="flex items-start justify-between gap-4 mb-8">
          <div>
            <p>Recent Review Scores</p>
            <p class="text-sm text-primary!">
              Last 30 days
            </p>
          </div>
          <h3 class="text-success!">
            +15%
          </h3>
        </div>
        <svg
          class="w-full aspect-2/1"
          viewBox="-1 -1 121 61"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            :d="
              svgTool.getSvgPath([
                [0, 60 - 5],
                [20, 60 - 25],
                [40, 60 - 15],
                [60, 60 - 40],
                [80, 60 - 35],
                [100, 60 - 20],
                [120, 60 - 45],
              ])
            "
            fill="none"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="stroke-primary"
          />
        </svg>
      </UCard>
      <UCard class="">
        <div class="flex items-start justify-between gap-4 mb-8">
          <div>
            <p>Recent Downloads</p>
            <p class="text-sm text-primary!">
              Last 30 days
            </p>
          </div>
          <h3 class="text-success!">
            +123
          </h3>
        </div>
        <svg
          class="w-full aspect-2/1"
          viewBox="0 0 300 150"
          xmlns="http://www.w3.org/2000/svg"
        >
          <rect
            v-for="(n, index) in [
              15, 5, 6, 8, 5, 2, 7, 4, 4, 2, 9, 10, 5, 6, 10, 4, 7, 9, 8, 6, 9,
              10, 5, 6, 10, 4, 7, 9, 8, 15,
            ]"
            :key="index"
            :x="index * 10"
            :y="150 - n * 8"
            :width="8"
            :height="n * 10"
            :rx="2"
            :ry="2"
            :class="index % 2 === 0 ? 'fill-primary-400' : 'fill-primary-600'"
          />
        </svg>
      </UCard>
      <UCard class="">
        <div class="flex items-start justify-between gap-4 mb-8">
          <div>
            <p>Credit Usage</p>
            <p class="text-sm text-primary!">
              Last 30 days
            </p>
          </div>
          <h3 class="text-success!">
            6500
            <span class="text-sm text-slate-500"> /10000 </span>
          </h3>
        </div>
        <svg
          class="w-full aspect-2/1"
          viewBox="0 0 20 20"
          xmlns="http://www.w3.org/2000/svg"
        >
          <!--          Inner Circle -->
          <circle
            r="5"
            cx="10"
            cy="10"
            class="fill-primary-200"
          />
          <circle
            r="5"
            cx="10"
            cy="10"
            fill="transparent"
            class="stroke-primary"
            stroke-width="10"
            stroke-dasharray="20 31.4"
          />
        </svg>
      </UCard>
    </div>

    <UAlert
      color="info"
      variant="subtle"
      icon="i-lucide-flask-conical"
      title="Sample Data"
      description="Everything on this dashboard is placeholder data for preview purposes."
      class="mt-8"
    />
  </div>
</template>
