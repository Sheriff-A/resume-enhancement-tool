<script setup lang="ts">
import type { EnhanceResumeResults, UpdateAction } from '~/models/server/resume'
import type { ExtResume } from '~/models/ext_resume'
import type { NewEducation } from '~/models/database'
import { MAX_AWARD_LENGTH, MAX_EDUCATION_NUMBER, MAX_NOTABLE_COURSES_LENGTH } from '~/data/formSchemas'

interface Props {
  errorPaths?: string[]
  updateData?: EnhanceResumeResults['education']
}

const props = withDefaults(defineProps<Props>(), {
  errorPaths: () => [],
  updateData: undefined,
})

const model = defineModel<ExtResume>({
  required: true,
})

interface UpdateEntryDetails {
  [id: number]: {
    currents: {
      [idx: number]: {
        text: string
        action: UpdateAction
        reason?: string
        confidence: number
      }
    }
    new_suggestions: { text: string, confidence?: number, reason?: string }[]
  }
}

const processedUpdateData = ref<UpdateEntryDetails>({})

interface ResolveEntryUpdate {
  [id: number]: {
    currents: string[] // idx_<decision>
    new_suggestions: string[] // idx_<decision>
  }
}

const resolvedUpdateData = ref<ResolveEntryUpdate>({})

const hoverTarget = ref('')

function appendEduction() {
  const newEducation: NewEducation = {
    resume_id: model.value.id || (undefined as any),
    certification: '',
    institution: '',
    field_of_study: '',
    location: '',
    start_date: '',
    end_date: '',
    notable_courses: [],
    awards: [],
  }

  model.value.education.push(newEducation as any)
}

function removeEducation(index: number) {
  model.value.education.splice(index, 1)
}

function appendAward(eduIndex: number) {
  model.value.education[eduIndex].awards!.push('')
}

function removeAward(eduIndex: number, awardIndex: number) {
  model.value.education[eduIndex].awards!.splice(awardIndex, 1)
}

function updateAward(
  value: string | null,
  eduIndex: number,
  awardIndex: number,
) {
  model.value.education[eduIndex].awards![awardIndex] = value || ''
}

function appendNotableCourse(eduIndex: number) {
  model.value.education[eduIndex].notable_courses.push({
    text: '',
  })
}

function removeNotableCourse(eduIndex: number, courseIndex: number) {
  model.value.education[eduIndex].notable_courses.splice(courseIndex, 1)
}

function updateNotableCourse(
  value: string | null,
  eduIndex: number,
  courseIndex: number,
) {
  model.value.education[eduIndex].notable_courses[courseIndex].text
    = value || ''
}

function onDecideUpdate(target: ExtResume['education'][number], id: number, idx: number, type: 'currents' | 'new_suggestions', text?: string) {
  if (!resolvedUpdateData.value[id]) {
    resolvedUpdateData.value[id] = {
      currents: [],
      new_suggestions: [],
    }
  }
  const decision = text ? 'accept' : 'deny'
  if (decision === 'accept') {
    if (type === 'currents') {
      target.notable_courses[idx].last_suggestion = target.notable_courses[idx].text || ''
      target.notable_courses[idx].text = text || ''
      target.notable_courses[idx].choice = decision
    }
    else {
      target.notable_courses.push({ text: text || '', choice: 'new', last_suggestion: text || '' })
    }
  }
  else if (type === 'currents') {
    target.notable_courses[idx].text = text || ''
    target.notable_courses[idx].choice = decision
    target.notable_courses[idx].last_suggestion = ''
  }
  const key = `${idx}_${decision}`
  resolvedUpdateData.value[id][type].push(key)
}

function getDecision(edu: ExtResume['education'][number], id: number, idx: number, isNew = false): 'accept' | 'deny' | undefined {
  if (!resolvedUpdateData.value[id]) {
    return undefined
  }
  const type = isNew ? 'new_suggestions' : edu.notable_courses[idx].choice === 'new' ? 'new_suggestions' : 'currents'
  const target = resolvedUpdateData.value[id][type].find(key => key.startsWith(`${idx}_`))
  if (!target) {
    return undefined
  }
  return target.split('_')[1] as 'accept' | 'deny'
}

function onClearDecision(edu: ExtResume['education'][number], id: number, idx: number) {
  if (!resolvedUpdateData.value[id]) {
    return
  }
  const type = edu.notable_courses[idx].choice === 'new' ? 'new_suggestions' : 'currents'
  const key = `${idx}_${getDecision(edu, id, idx)}`
  if (type === 'currents') {
    edu.notable_courses[idx].text = edu.notable_courses[idx].last_suggestion || ''
    edu.notable_courses[idx].choice = undefined
  }
  else {
    edu.notable_courses.splice(idx, 1)
  }
  resolvedUpdateData.value[id][type] = resolvedUpdateData.value[id][type].filter(k => k !== key)
}

function processUpdateData() {
  if (!props.updateData) return
  for (const update of props.updateData) {
    const { id, notable_courses } = update
    if (!processedUpdateData.value[id]) {
      processedUpdateData.value[id] = {
        currents: {},
        new_suggestions: [],
      }
    }

    if (!notable_courses) continue

    for (const resp of notable_courses) {
      const { idx, text, confidence, reason, action } = resp
      if (action === 'add' && text && (!idx || idx < 0)) {
        processedUpdateData.value[id].new_suggestions.push({
          text,
          confidence,
          reason,
        })
        continue
      }
      if (!idx) {
        console.log(`Missing idx for notable_courses update for education ID ${id}`)
        continue
      }
      const current = processedUpdateData.value[id].currents[idx]
      if (!current) {
        processedUpdateData.value[id].currents[idx] = {
          text: '',
          action: 'update',
          confidence: 0,
          reason: '',
        }
      }

      processedUpdateData.value[id].currents[idx].text = text || ''
      processedUpdateData.value[id].currents[idx].confidence = confidence || 0
      processedUpdateData.value[id].currents[idx].reason = reason
      processedUpdateData.value[id].currents[idx].action = action

      if (!text && action === 'update') {
        processedUpdateData.value[id].currents[idx].action = 'remove'
      }
    }
  }
}

watch(() => props.updateData, processUpdateData, { immediate: true })
</script>

<template>
  <div>
    <div class="flex justify-between gap-4 mb-2">
      <p>
        Fill in your education details to highlight your academic
        background. Focus on relevant degrees and certifications.
        <span
          class="font-bold"
          :class="{
            'text-error':
              (model.education?.length ?? 0) > MAX_EDUCATION_NUMBER,
          }"
        >
          Limit: {{ model.education?.length ?? 0 }}/{{
            MAX_EDUCATION_NUMBER
          }}
        </span>
      </p>
      <div>
        <UButton
          :disabled="
            (model.education?.length ?? 0) >= MAX_EDUCATION_NUMBER
          "
          icon="i-lucide-plus"
          label="Add Education"
          variant="subtle"
          @click="appendEduction"
        />
      </div>
    </div>

    <template
      v-for="(edu, idx) in model.education"
      :key="idx"
    >
      <div
        class="mb-4 last:mb-0 p-4 transition-all"
        :class="{
          'ring-2 ring-error bg-error/5 rounded-lg':
            hoverTarget === `education-${idx}`,
        }"
      >
        <DevWrapper>
          {{ edu.id ? `ID: ${edu.id}` : 'New Entry' }}
        </DevWrapper>

        <LVInput
          v-model="edu.field_of_study"
          required
          class="mb-1.5"
          label="Field of Study"
        />
        <LVInput
          v-model="edu.certification"
          required
          class="mb-1.5"
          label="Certification"
        />
        <LVInput
          v-model="edu.institution"
          required
          class="mb-1.5"
          label="Institution"
        />
        <LVInput
          v-model="edu.location"
          required
          class="mb-1.5"
          label="Location"
        />
        <div class="flex justify-between gap-4">
          <LVDatePicker
            v-model="edu.start_date"
            label="Start Date"
            required
          />
          <LVDatePicker
            v-model="edu.end_date"
            label="End Date"
            hint="Optional"
          />
        </div>

        <!-- Education Awards -->
        <USeparator
          label="Awards"
          class="my-2"
        />
        <template
          v-for="(award, jdx) in edu.awards"
          :key="jdx"
        >
          <div class="flex gap-2 mb-1.5">
            <div class="shrink-0">
              <UButton
                icon="i-lucide-x"
                color="error"
                variant="ghost"
                class="mt-6"
                @click="removeAward(idx, jdx)"
              />
            </div>
            <div class="grow">
              <LVTextArea
                :label="`Item ${jdx + 1}`"
                :model-value="award!"
                :rows="1"
                :error="
                  errorPaths.includes(
                    `education_${idx}_awards_${jdx}`,
                  ) && 'Please enter a valid award'
                "
                :help="`${award!?.length ?? 0}/${MAX_AWARD_LENGTH}`"
                :ff-ui="{
                  help:
                    (award!?.length ?? 0) > MAX_AWARD_LENGTH
                      ? '!text-error'
                      : undefined,
                }"
                @update:model-value="updateAward($event, idx, jdx)"
              />
            </div>
          </div>
        </template>
        <div class="mt-4">
          <UButton
            icon="i-lucide-plus"
            label="Add Award"
            variant="subtle"
            @click="appendAward(idx)"
          />
        </div>

        <!-- Notable Courses -->
        <USeparator
          label="Notable Courses"
          class="my-2"
        />
        <template
          v-for="(course, jdx) in edu.notable_courses"
          :key="jdx"
        >
          <div class="flex gap-2 mb-1.5">
            <div class="shrink-0">
              <UButton
                icon="i-lucide-x"
                color="error"
                variant="ghost"
                class="mt-6"
                @click="removeNotableCourse(idx, jdx)"
              />
            </div>
            <div class="grow">
              <LVTextArea
                :label="`Item ${jdx + 1}`"
                :model-value="course!.text"
                :rows="1"
                :error="
                  errorPaths.includes(
                    `education_${idx}_notable_courses_${jdx}_text`,
                  ) && 'Please enter a valid course name'
                "
                :help="`${course!.text?.length ?? 0}/${MAX_NOTABLE_COURSES_LENGTH}`"
                :ff-ui="{
                  help:
                    (course!.text?.length ?? 0)
                    > MAX_NOTABLE_COURSES_LENGTH
                      ? '!text-error'
                      : undefined,
                }"
                @update:model-value="
                  updateNotableCourse($event, idx, jdx)
                "
              />
              <ResumeSuggestion
                v-if="edu.id && processedUpdateData[edu.id]?.currents[jdx] && !getDecision(edu, edu.id, jdx)"
                class="mb-2"
                :text="processedUpdateData[edu.id]?.currents[jdx].text"
                :reason="processedUpdateData[edu.id]?.currents[jdx].reason"
                :action="processedUpdateData[edu.id]?.currents[jdx].action"
                :confidence="processedUpdateData[edu.id]?.currents[jdx].confidence"
                :raw="processedUpdateData[edu.id]?.currents[jdx]"
                @accept="onDecideUpdate(edu, edu.id, jdx, 'currents', $event)"
                @reject="onDecideUpdate(edu, edu.id, jdx, 'currents')"
              />
            </div>
          </div>
        </template>
        <div
          v-if="edu.id && processedUpdateData[edu.id]?.new_suggestions.length"
        >
          <template
            v-for="(suggestion, newIdx) in processedUpdateData[edu.id].new_suggestions"
            :key="newIdx"
          >
            <ResumeSuggestion
              v-if="!getDecision(edu, edu.id, newIdx, true)"
              class="mb-2"
              :text="suggestion.text"
              :reason="suggestion.reason"
              :action="'add'"
              :confidence="suggestion.confidence"
              :raw="suggestion"
              @accept="onDecideUpdate(edu, edu.id, newIdx, 'new_suggestions', $event)"
              @reject="onDecideUpdate(edu, edu.id, newIdx, 'new_suggestions')"
            />
          </template>
        </div>
        <div class="flex justify-between gap-4 mt-4">
          <UButton
            icon="i-lucide-plus"
            label="Add Notable Course"
            variant="subtle"
            @click="appendNotableCourse(idx)"
          />

          <UButton
            icon="i-lucide-x"
            label="Remove Education"
            color="error"
            variant="ghost"
            @click="removeEducation(idx)"
            @mouseenter="hoverTarget = `education-${idx}`"
            @mouseleave="hoverTarget = ''"
          />
        </div>
      </div>
      <USeparator class="my-4 last:hidden" />
    </template>
  </div>
</template>

<style scoped>

</style>
