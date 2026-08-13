<template>
  <div>
    <DevWrapper>
      <div>Resume ID: {{ model.id || 'N/A' }}</div>
      <div>Template Style: {{ model.style || 'N/A' }}</div>
      <div>Step: {{ step || 'N/A' }}</div>
    </DevWrapper>

    <UCard
      :variant="contained ? 'soft' : undefined"
      class="dark:bg-slate-950"
    >
      <!-- Header and Settings -->
      <template
        v-if="!contained"
        #header
      >
        <div class="flex items-center justify-between gap-4">
          <div class="grow">
            <h3>
              {{ title }}
            </h3>
            <p>
              {{ description }}
            </p>
          </div>
          <div>
            <UTooltip text="Toggle Visibility">
              <UButton
                :disabled="loadingToggleVisibility"
                :loading="loadingToggleVisibility"
                class="mr-2"
                :icon="model.is_public ? 'i-lucide-eye' : 'i-lucide-eye-closed'"
                :label="model.is_public ? 'Public' : 'Private'"
                :color="model.is_public ? 'primary' : 'neutral'"
                :variant="model.is_public ? 'subtle' : 'soft'"
                @click="onToggleVisibility"
              />
            </UTooltip>
            <!-- Todo: this should save as a preview preference in the database for when it's time to share the resume -->
            <UDropdownMenu
              class="mr-2"
              :items="templateOptions"
              :content="{
                align: 'end',
                side: 'bottom',
                sideOffset: 8,
              }"
              :ui="{
                content: 'w-72',
              }"
            >
              <UButton
                variant="subtle"
                label="Template"
                icon="i-lucide-layout-panel-top"
              />
              <template #item="{ item }">
                <div class="text-left">
                  <h6
                    :class="{
                      '!text-primary': model.style === item.value,
                    }"
                  >
                    {{ item.label }}
                  </h6>
                  <p
                    :class="{
                      '!text-primary-400': model.style === item.value,
                    }"
                  >
                    {{ item.description }}
                  </p>
                </div>
              </template>
            </UDropdownMenu>
            <slot name="header-controls" />
          </div>
        </div>
      </template>

      <!-- Content -->
      <UStepper
        ref="stepper"
        v-model="step"
        :items="steps"
      >
        <template #basic-info>
          <ResumeEditBasicInfo
            v-model="model"
            :error-paths="errorPaths"
            :update-data="updateData.summary"
          />
        </template>
        <template #experience>
          <ResumeEditExperience
            v-model="model"
            :error-paths="errorPaths"
            :update-data="updateData.experience"
          />
        </template>
        <template #education>
          <ResumeEditEducation
            v-model="model"
            :error-paths="errorPaths"
            :update-data="updateData.education"
          />
        </template>
        <template #projects>
          <div>
            <div class="flex justify-between gap-4 mb-2">
              <p>
                Fill in your project details to highlight your personal/working
                experience. Focus on relevant projects and contributions.
                <span
                  class="font-bold"
                  :class="{
                    'text-error':
                      (model.projects?.length ?? 0) > MAX_PROJECT_NUMBER,
                  }"
                >
                  Limit: {{ model.projects?.length ?? 0 }}/{{
                    MAX_PROJECT_NUMBER
                  }}
                </span>
              </p>
              <div>
                <UButton
                  :disabled="
                    (model.projects?.length ?? 0) >= MAX_PROJECT_NUMBER
                  "
                  icon="i-lucide-plus"
                  label="Add Project"
                  variant="subtle"
                  @click="appendProject"
                />
              </div>
            </div>
            <template
              v-for="(proj, idx) in model.projects"
              :key="idx"
            >
              <div
                class="mb-4 last:mb-0 p-4 transition-all"
                :class="{
                  'ring-2 ring-error bg-error/5 rounded-lg':
                    hoverTarget === `project-${idx}`,
                }"
              >
                <DevWrapper>
                  {{ proj.id ? `ID: ${proj.id}` : 'New Entry' }}
                </DevWrapper>

                <LVInput
                  v-model="proj.name"
                  class="mb-1.5"
                  label="Name"
                  required
                  :error="
                    errorPaths.includes(`project_${idx}_name`)
                      && 'Please enter a valid name'
                  "
                />
                <LVInput
                  v-model="proj.url"
                  class="mb-1.5"
                  label="Url"
                />
                <div class="flex justify-between gap-4">
                  <LVDatePicker
                    v-model="proj.start_date"
                    label="Start Date"
                    hint="Optional"
                  />
                  <LVDatePicker
                    v-model="proj.end_date"
                    label="End Date"
                    hint="Optional"
                  />
                </div>

                <USeparator
                  label="Highlights"
                  class="my-2"
                />
                <template
                  v-for="(highlight, jdx) in proj.highlights"
                  :key="jdx"
                >
                  <div class="flex gap-2 mb-1.5">
                    <div class="shrink-0">
                      <UButton
                        icon="i-lucide-x"
                        color="error"
                        variant="ghost"
                        class="mt-6"
                        @click="removeHighlight(idx, jdx)"
                      />
                    </div>
                    <div class="grow">
                      <LVTextArea
                        :label="`Item ${jdx + 1}`"
                        :model-value="highlight!.text"
                        :rows="1"
                        :help="`${highlight!.text?.length ?? 0}/${MAX_RESPONSIBILITY_LENGTH}`"
                        :error="
                          errorPaths.includes(
                            `project_${idx}_responsibilities_${jdx}_text`,
                          ) && 'Please enter a valid responsibility text'
                        "
                        :ff-ui="{
                          help:
                            (highlight!.text?.length ?? 0)
                            > MAX_RESPONSIBILITY_LENGTH
                              ? '!text-error'
                              : undefined,
                        }"
                        @update:model-value="updateHighlight($event, idx, jdx)"
                      >
                        <template
                          v-if="showEnhance"
                          #hint
                        >
                          <UButton
                            v-if="model.summary?.length"
                            size="xs"
                            variant="subtle"
                            label="Enhance"
                            color="accent"
                            icon="i-lucide-sparkles"
                          />
                        </template>
                      </LVTextArea>
                      <ResumeSuggestion
                        v-if="highlight.last_suggestion && !highlight.choice"
                        class="mb-2"
                        :text="highlight.last_suggestion"
                        @accept="
                          onUpdateEntryDetails(
                            'project',
                            highlight.last_suggestion,
                            proj.id!,
                            highlight,
                          )
                        "
                        @reject="
                          onRejectEntryDetails(
                            'project',
                            highlight.last_suggestion,
                            proj.id!,
                            highlight,
                          )
                        "
                      />
                    </div>
                  </div>
                </template>
                <div
                  v-if="
                    projectUpdates && proj.id && projectUpdates[proj.id]?.length
                  "
                >
                  <template
                    v-for="(highlight, newIdx) in projectUpdates[proj.id]"
                    :key="newIdx"
                  >
                    <ResumeSuggestion
                      new-suggestion
                      :text="highlight"
                      class="mb-1.5"
                      @accept="
                        onUpdateEntryDetails('project', highlight, proj.id)
                      "
                      @reject="
                        onRejectEntryDetails('project', highlight, proj.id)
                      "
                    />
                  </template>
                </div>
                <div class="flex justify-between gap-4 mt-4">
                  <UButton
                    icon="i-lucide-plus"
                    label="Add Highlight"
                    variant="subtle"
                    @click="appendHighlight(idx)"
                  />

                  <UButton
                    icon="i-lucide-x"
                    label="Remove Project"
                    color="error"
                    variant="ghost"
                    @click="removeProject(idx)"
                    @mouseenter="hoverTarget = `project-${idx}`"
                    @mouseleave="hoverTarget = ''"
                  />
                </div>
              </div>
              <USeparator class="my-4 last:hidden" />
            </template>
            <!--            <UButton icon="i-lucide-plus" label="Add Experience" variant="subtle" @click="appendExperience" /> -->
          </div>
        </template>
        <template #skills>
          <ResumeEditSkills
            v-model="model"
            :error-paths="errorPaths"
            :update-data="updateData.skills"
          />
        </template>
      </UStepper>

      <!-- Controls -->
      <template #footer>
        <div class="flex justify-between gap-4">
          <div>
            <UButton
              icon="i-lucide-save"
              label="Validate & Save"
              @click="onValidate"
            />
            <!--            TODO: Implement me? -->
            <UButton
              class="ml-4"
              icon="i-lucide-sparkles"
              label="Enhance"
              color="accent"
              variant="subtle"
              @click.stop="enhanceResumeDialog = true"
            />
          </div>
          <div class="flex gap-2">
            <UButton
              variant="subtle"
              leading-icon="i-lucide-arrow-left"
              label="Prev"
              :disabled="!stepper?.hasPrev"
              @click="onStepperChange(true)"
            />
            <UButton
              variant="subtle"
              trailing-icon="i-lucide-arrow-right"
              :disabled="!stepper?.hasNext"
              label="Next"
              @click="onStepperChange()"
            />
          </div>
        </div>
      </template>
    </UCard>

    <div
      v-if="model.is_public"
      class="mt-2"
    >
      <UButton
        class="hover:underline"
        label="Copy Public Link"
        variant="link"
        color="primary"
        @click="copyPublicLink"
      />
    </div>

    <div class="mt-4">
      <GeneralErrors :errors="errors" />
    </div>

    <UModal
      v-model:open="enhanceResumeDialog"
      title="Enhance Resume"
      description="Enhance with Job Description"
      :dismissible="false"
    >
      <template #body>
        <EnhanceResume :resume="model" />
      </template>
    </UModal>

    <DevWrapper>
      <pre>
        <code class="whitespace-break-spaces">
          {{ errorPaths }}
        </code>
      </pre>
      <pre>
        <code class="whitespace-break-spaces">
          {{ model }}
        </code>
      </pre>
      <pre>
        <code class="whitespace-break-spaces">
          {{ experienceUpdates }}
        </code>
      </pre>
      <pre>
        <code class="whitespace-break-spaces">
          {{ educationUpdates }}
        </code>
      </pre>
    </DevWrapper>
  </div>
</template>

<script setup lang="ts">
import type { ExtResume } from '~/models/ext_resume'
import type {
  NewEducation,
  NewExperience,
  NewProject,
  SkillType,
} from '~/models/database'
import type { ZodError } from '~/models/general'
import {
  editResumeSchema,
  MAX_AWARD_LENGTH,
  MAX_EDUCATION_NUMBER,
  MAX_EXPERIENCE_NUMBER,
  MAX_NOTABLE_COURSES_LENGTH,
  MAX_PROJECT_NUMBER,
  MAX_RESPONSIBILITY_LENGTH,
  MAX_SKILLS_NUMBER,
  MAX_SUMMARY_LENGTH,
} from '~/data/formSchemas'
import type { StepperItem } from '#ui/components/Stepper.vue'
import type { DropdownMenuItem } from '#ui/components/DropdownMenu.vue'
import { SkillTypeLabels } from '~/data/labels'
import { toggleResumeVisibility } from '~/composables/resumes'
import { TOGGLE_PRIVATE_MESSAGE, TOGGLE_PUBLIC_MESSAGE } from '~/data/settings'
import { copyToClipboard } from '~/composables/helpers'
import type { ButtonProps } from '#ui/components/Button.vue'
import type { EnhanceResumeResults } from '~/models/server/resume'
import ResumeEditExperience from '~/components/Resume/Edit/ResumeEditExperience.vue'
import ResumeEditSkills from '~/components/Resume/Edit/ResumeEditSkills.vue'

interface Props {
  showEnhance?: boolean
  contained?: boolean
  title?: string
  description?: string
  updateData?: EnhanceResumeResults
}

interface Emits {
  (e: 'upsert-resume'): void
}

const router = useRouter()

const props = withDefaults(defineProps<Props>(), {
  showEnhance: false,
  contained: false,
  title: 'Edit Resume',
  description: undefined,
  updateData: undefined,
})
const emits = defineEmits<Emits>()

const enhanceResumeDialog = ref(false)
const hoverTarget = ref<string>('')
const toast = useToast()
const loadingToggleVisibility = ref<boolean>(false)

const model = defineModel<ExtResume>({
  default: () => ({
    name: '',
    summary: '',
    email: '',
    location: '',
    phone: '',
    portfolio: '',
    github: '',
    linkedin: '',
    skills: [],
    experience: [],
    education: [],
  }),
})

const errors = ref<ZodError[]>([])
const errorPaths = ref<string[]>([])

const templateOptions: DropdownMenuItem[] = [
  {
    label: 'Modern',
    description: 'Modern style with clean lines and a professional look.',
    value: 'modern',
    onSelect: () => {
      model.value.style = 'modern'
    },
  },
  {
    label: 'Technical',
    description: 'Technical style with emphasis on skills and experience.',
    value: 'technical',
    onSelect: () => {
      model.value.style = 'technical'
    },
  },
]

type ResumeStep
  = | 'basic-info'
    | 'experience'
    | 'education'
    | 'projects'
    | 'skills'

const stepper = useTemplateRef('stepper')
const step = ref<ResumeStep>('skills')

const steps: StepperItem[] = [
  {
    title: 'Basic Info',
    value: 'basic-info',
    slot: 'basic-info' as const,
    icon: 'i-lucide-user',
  },
  {
    title: 'Experience',
    value: 'experience',
    slot: 'experience' as const,
    icon: 'i-lucide-briefcase',
  },
  {
    title: 'Education',
    value: 'education',
    slot: 'education' as const,
    icon: 'i-lucide-book-open',
  },
  // 2026-01-20: Most ppl dont really do projects... this is more a student/specific job thing maybe?
  // TODO: Re-enable Projects section when ready
  // {
  //   title: 'Projects',
  //   value: 'projects',
  //   slot: 'projects' as const,
  //   icon: 'i-lucide-folder',
  // },
  {
    title: 'Skills',
    value: 'skills',
    slot: 'skills' as const,
    icon: 'i-lucide-award',
  },
]

function appendProject() {
  const newProject: NewProject = {
    resume_id: model.value.id || (undefined as any),
    highlights: [{ text: '' }],
    name: '',
    url: '',
    start_date: '',
    end_date: '',
  }
  if (!model.value.projects) {
    model.value.projects = []
  }
  model.value.projects.push(newProject as any)
}

function removeProject(index: number) {
  model.value.projects.splice(index, 1)
}

function appendHighlight(index: number) {
  model.value.projects[index].highlights.push({
    text: '',
  })
}

function removeHighlight(index: number, highlightIndex: number) {
  model.value.projects[index].highlights.splice(highlightIndex, 1)
}

function updateHighlight(
  value: string | null,
  index: number,
  highlightIndex: number,
) {
  model.value.projects[index].highlights[highlightIndex].text = value || ''
}

function onValidate() {
  const err = useZodCheck(editResumeSchema, model.value)
  if (err) {
    errors.value = err
    errorPaths.value = err.map(e => e.path)
    return
  }
  console.log('Valid', model.value)
  errors.value = []
  errorPaths.value = []
  emits('upsert-resume')
}

// ///////////////////////////////////////
// Update Highlights
// ///////////////////////////////////////
const updateTokens = ref<string[]>([])

interface EntryUpdate {
  [entry_id: number]: string[]
}

interface EntryUpdateNew {
  [entry_id: number]: {
    [entry_idx: number]: {
      text: string
      reason: string
      confidence: number
      // Type This properly
      action: string
    }
    new_entries?: {
      text: string
      reason: string
      confidence: number
    }[]
  }
}

const experienceUpdates = ref<EntryUpdate>()
const projectUpdates = ref<EntryUpdate>()
const educationUpdates = ref<EntryUpdate>()

function onUpdateBaseField(field: keyof ExtResume, data: string) {
  if (!data || !model.value) {
    return
  }
  // @ts-expect-error: Assign the updated data to the model
  model.value[field] = data
  if (!updateTokens.value.includes(field)) {
    updateTokens.value.push(field)
  }
}

function onRejectBaseField(field: keyof ExtResume) {
  if (!model.value) {
    return
  }
  if (!updateTokens.value.includes(field)) {
    updateTokens.value.push(field)
  }
}

function parseExperienceUpdate() {
  if (!props.updateData?.experience) {
    return
  }
  const experienceUpdateData = props.updateData.experience
  const expUpdates: EntryUpdateNew = {}
  for (const expUpdateData of experienceUpdateData) {
    if (!expUpdateData.id) {
      continue
    }
    const originalExp = model.value.experience.find(
      e => e.id === expUpdateData.id,
    )
    if (!originalExp) {
      continue
    }
    expUpdates[expUpdateData.id] = []
    const responsibilities = expUpdateData.responsibilities || []
    const originalResponsibilities = originalExp.responsibilities || []
    for (const resp of responsibilities) {
      const respIdx = resp.idx
      const respText = resp.text
      if (respIdx !== undefined && originalResponsibilities[respIdx]) {
        originalResponsibilities[respIdx].last_suggestion = respText
      }
      else {
        expUpdates[expUpdateData.id].push(respText)
      }
    }
  }
  experienceUpdates.value = expUpdates
}

function parseExperienceUpdateNew() {
  if (!props.updateData?.experience) {
    return
  }
  const experienceUpdateData = props.updateData.experience
  const expUpdates: EntryUpdate = {}
}

function parseProjectUpdate() {
  if (!props.updateData?.projects) {
    return
  }
  const projectUpdateData = props.updateData.projects
  const projUpdates: EntryUpdate = {}
  for (const projUpdateData of projectUpdateData) {
    if (!projUpdateData.id) {
      continue
    }
    const originalProj = model.value.projects.find(
      e => e.id === projUpdateData.id,
    )
    if (!originalProj) {
      continue
    }
    projUpdates[projUpdateData.id] = []
    const highlights = projUpdateData.highlights || []
    const originalHighlights = originalProj.highlights || []
    for (const highlight of highlights) {
      const highlightIdx = highlight.idx
      const highlightText = highlight.text
      if (highlightIdx !== undefined && originalHighlights[highlightIdx]) {
        originalHighlights[highlightIdx].last_suggestion = highlightText
      }
      else {
        projUpdates[projUpdateData.id].push(highlightText)
      }
    }
  }
  projectUpdates.value = projUpdates
}

function parseEducationUpdate() {
  if (!props.updateData?.education) {
    return
  }
  const educationUpdateData = props.updateData.education
  const eduUpdates: EntryUpdate = {}
  for (const eduUpdateData of educationUpdateData) {
    if (!eduUpdateData.id) {
      continue
    }
    const originalEdu = model.value.education.find(
      e => e.id === eduUpdateData.id,
    )
    if (!originalEdu) {
      continue
    }
    eduUpdates[eduUpdateData.id] = []
    const notable_courses = eduUpdateData.notable_courses || []
    const originalNotableCourses = originalEdu.notable_courses || []
    for (const course of notable_courses) {
      const courseIdx = course.idx
      const courseText = course.text
      if (courseIdx !== undefined && originalNotableCourses[courseIdx]) {
        originalNotableCourses[courseIdx].last_suggestion = courseText
      }
      else {
        eduUpdates[eduUpdateData.id].push(courseText)
      }
    }
  }
  educationUpdates.value = eduUpdates
}

onMounted(() => {
  parseExperienceUpdate()
  parseProjectUpdate()
  parseEducationUpdate()
})

type Section = 'experience' | 'education' | 'project'
type Element
  = | ExtResume['experience'][0]['responsibilities'][0]
    | ExtResume['education'][0]['notable_courses'][0]
    | ExtResume['projects'][0]['highlights'][0]

function onUpdateEntryDetails(
  section: Section,
  data: string,
  id: number,
  element?: Element,
) {
  if (!data || !model.value) {
    return
  }

  if (element) {
    element.text = data
    element.choice = 'accept'
    return
  }

  let sectionList
  switch (section) {
    case 'experience':
      sectionList = model.value.experience
      break
    case 'education':
      sectionList = model.value.education
      break
    case 'project':
      sectionList = model.value.projects
      break
    default:
      break
  }
  if (!sectionList) {
    return
  }

  const entryIdx = sectionList.findIndex(e => e.id === id)
  if (entryIdx === -1) {
    return
  }
  switch (section) {
    case 'experience':
      (
        sectionList[entryIdx] as ExtResume['experience'][0]
      ).responsibilities.push({
        text: data,
      })
      // Remove from updates
      if (experienceUpdates.value && experienceUpdates.value[id]) {
        const updateIdx = experienceUpdates.value[id].indexOf(data)
        if (updateIdx !== -1) {
          experienceUpdates.value[id].splice(updateIdx, 1)
        }
      }
      break
    case 'education':
      (sectionList[entryIdx] as ExtResume['education'][0]).notable_courses.push(
        {
          text: data,
        },
      )
      // Remove from updates
      if (educationUpdates.value && educationUpdates.value[id]) {
        const updateIdx = educationUpdates.value[id].indexOf(data)
        if (updateIdx !== -1) {
          educationUpdates.value[id].splice(updateIdx, 1)
        }
      }
      break
    case 'project':
      (sectionList[entryIdx] as ExtResume['projects'][0]).highlights.push({
        text: data,
      })
      // Remove from updates
      if (educationUpdates.value && educationUpdates.value[id]) {
        const updateIdx = educationUpdates.value[id].indexOf(data)
        if (updateIdx !== -1) {
          educationUpdates.value[id].splice(updateIdx, 1)
        }
      }
      break
    default:
      console.warn('Unsupported section')
  }
}

function onRejectEntryDetails(
  section: Section,
  data: string,
  id: number,
  element?: Element,
) {
  if (!model.value) {
    return
  }

  if (element) {
    element.choice = 'deny'
    return
  }

  switch (section) {
    case 'experience':
      if (experienceUpdates.value && experienceUpdates.value[id]) {
        const updateIdx = experienceUpdates.value[id].indexOf(data)
        if (updateIdx !== -1) {
          experienceUpdates.value[id].splice(updateIdx, 1)
        }
      }
      break
    case 'education':
      if (educationUpdates.value && educationUpdates.value[id]) {
        const updateIdx = educationUpdates.value[id].indexOf(data)
        if (updateIdx !== -1) {
          educationUpdates.value[id].splice(updateIdx, 1)
        }
      }
      break
    case 'project':
      if (projectUpdates.value && projectUpdates.value[id]) {
        const updateIdx = projectUpdates.value[id].indexOf(data)
        if (updateIdx !== -1) {
          projectUpdates.value[id].splice(updateIdx, 1)
        }
      }
      break
    default:
      console.warn('Unsupported section')
  }
}

async function onToggleVisibility() {
  const resumeId = model.value.id
  const toastActions: ButtonProps[] = []
  if (resumeId) {
    const viewResumeAction: ButtonProps = {
      label: 'Copy Link',
      variant: 'link',
      onClick: (e) => {
        e.preventDefault()
        const route = router.resolve({
          name: 'resume-public-resumeId',
          params: { resumeId },
        })
        copyToClipboard(route.href).catch(console.error)
      },
    }
    toastActions.push(viewResumeAction)
  }
  try {
    loadingToggleVisibility.value = true
    const newVisibility = !model.value.is_public
    if (resumeId) {
      await toggleResumeVisibility(resumeId, newVisibility)
      toast.add({
        title: 'Resume visibility updated',
        description: newVisibility
          ? TOGGLE_PUBLIC_MESSAGE
          : TOGGLE_PRIVATE_MESSAGE,
        color: 'success',
        actions: newVisibility ? toastActions : undefined,
      })
    }
    model.value.is_public = newVisibility
  }
  catch (err) {
    console.error('Failed to toggle resume visibility', err)
    toast.add({
      title: 'Error',
      description: 'Failed to toggle resume visibility',
      color: 'error',
    })
  }
  finally {
    loadingToggleVisibility.value = false
  }
}

async function copyPublicLink() {
  const resumeId = model.value.id
  if (!resumeId) {
    toast.add({
      title: 'Error',
      description: 'Resume must be saved before copying public link',
      color: 'error',
    })
    return
  }

  const route = router.resolve({
    name: 'resume-public-resumeId',
    params: { resumeId },
  })

  const url = new URL(route.href, import.meta.url)
  copyToClipboard(url.href, 'Public URL Copied to Clipboard').catch(
    console.error,
  )
}

function onStepperChange(prev = false) {
  if (prev) {
    stepper.value?.prev()
  }
  else {
    stepper.value?.next()
  }

  // Scroll to the top of the page
  window.scrollTo({ top: 0, behavior: 'smooth' })
}
</script>
