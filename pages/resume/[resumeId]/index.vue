<template>
  <div>
    <div class="grid lg:grid-cols-2 gap-4 relative">
      <div>
        <ResumeEditNew
          v-if="resume"
          v-model="resume"
          show-enhance
          :update-data="sampleEnhancements"
          @upsert-resume="onResumeChange"
        />
      </div>
      <div class="sticky top-4 h-fit">
        <div
          class="flex items-center justify-between gap-4 mb-4 border rounded-xl p-4 border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-950"
        >
          <div>
            <h3 class="capitalize">
              Preview ({{ resume?.style || 'modern' }})
            </h3>
            <p class="text-xs !text-primary">
              *Not to scale
            </p>
          </div>
          <div>
            <UButton
              label="Download"
              icon="i-lucide-download"
            />
          </div>
        </div>
        <ResumePreview
          v-if="resume"
          :resume="resume"
        />
      </div>
    </div>
    <DevWrapper>
      <pre>
    <code>
      Resume: {{ resume }}
    </code>
  </pre>
    </DevWrapper>
  </div>
</template>

<script setup lang="ts">
import type { ExtResume } from '~/models/ext_resume'
import { sampleEnhancements } from '~/data/examples'

const toast = useToast()
const user = useSupabaseUser()
const router = useRouter()
const route = useRoute('resume-resumeId')
const resumeId: string | 'new' = String(route.params.resumeId)

const resume = ref<ExtResume>()

async function onResumeChange() {
  const userId = user.value?.id
  if (!userId) {
    toast.add({
      title: 'Error',
      description: 'User not authenticated.',
      color: 'error',
    })
    return
  }
  const rsm = resume.value
  if (!rsm) {
    toast.add({
      title: 'Error',
      description: 'No resume data to save.',
      color: 'error',
    })
    return
  }

  const resumeData = {
    ...rsm,
    user_id: userId,
  }

  await upsertResume(resumeData).then(() => {
    toast.add({
      title: 'Success',
      description: 'Resume Saved Successfully.',
      color: 'success',
    })

    router.push({
      name: 'resume',
    })
  }).catch(console.error)
}

onMounted(async () => {
  const userId = user.value?.id

  // TODO: If no user id, redirect to login
  if (!userId) return null

  if (!resumeId) {
    toast.add({
      title: 'Error',
      description: 'No resume ID provided.',
      color: 'error',
    })
    return await router.push({
      name: 'resume',
    })
  }

  if (resumeId === 'new') {
    // TODO: Fetch data for presetting
    // Preset is_active, name, email, phone, location from user profile
    resume.value = {
      user_id: userId,
      name: '',
      nickname: '',
      email: '',
      summary: '',
      location: '',
      phone: '',
      github: '',
      linkedin: '',
      portfolio: '',
      education: [],
      experience: [],
      projects: [],
      skills: [],
      is_public: false,
      style: 'modern',
    }
    return
  }

  try {
    const res = await loadResume(userId, resumeId)

    if (res.status !== 'success' || !res.data) {
      toast.add({
        title: 'Error',
        description: 'Failed to load resume.',
        color: 'error',
      })
      return await router.push({
        name: 'resume',
      })
    }

    resume.value = res.data
  }
  catch (err) {
    console.error('Error loading resume:', err)
    toast.add({
      title: 'Error',
      description: 'Something went wrong loading resume.',
      color: 'error',
    })
    return router.push({
      name: 'resume',
    })
  }
})
</script>
