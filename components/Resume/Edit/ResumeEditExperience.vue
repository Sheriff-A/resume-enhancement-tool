<script setup lang="ts">
import { MAX_EXPERIENCE_NUMBER, MAX_RESPONSIBILITY_LENGTH } from '~/data/formSchemas'
import type { EnhanceResumeResults, UpdateAction } from '~/models/server/resume'
import type { ExtResume } from '~/models/ext_resume'
import type { NewExperience } from '~/models/database'

interface Props {
  errorPaths?: string[]
  updateData?: EnhanceResumeResults['experience']
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

function appendExperience() {
  const newExperience: NewExperience = {
    resume_id: model.value.id || (undefined as never),
    position: '',
    company: '',
    location: '',
    start_date: '',
    end_date: '',
    responsibilities: [{ text: '' }],
    is_current: false,
  }
  if (!model.value.experience) {
    model.value.experience = []
  }
  model.value.experience.push(newExperience as never)
}

function removeExperience(index: number) {
  model.value.experience.splice(index, 1)
}

function appendResponsibility(index: number) {
  if (!model.value.experience[index].responsibilities) {
    model.value.experience[index].responsibilities = []
  }
  model.value.experience[index].responsibilities.push({
    text: '',
  })
}

function removeResponsibility(index: number, descIndex: number) {
  model.value.experience[index].responsibilities.splice(descIndex, 1)
}

function updateResponsibility(
  value: string | null,
  index: number,
  descIndex: number,
) {
  model.value.experience[index].responsibilities[descIndex].text = value || ''
}

function onDecideUpdate(target: ExtResume['experience'][number], id: number, idx: number, type: 'currents' | 'new_suggestions', text?: string) {
  if (!resolvedUpdateData.value[id]) {
    resolvedUpdateData.value[id] = {
      currents: [],
      new_suggestions: [],
    }
  }
  const decision = text ? 'accept' : 'deny'
  if (decision === 'accept') {
    if (type === 'currents') {
      target.responsibilities[idx].last_suggestion = target.responsibilities[idx].text || ''
      target.responsibilities[idx].text = text || ''
      target.responsibilities[idx].choice = decision
    }
    else {
      target.responsibilities.push({ text: text || '', choice: 'new', last_suggestion: text || '' })
    }
  }
  else if (type === 'currents') {
    target.responsibilities[idx].text = text || ''
    target.responsibilities[idx].choice = decision
    target.responsibilities[idx].last_suggestion = ''
  }
  const key = `${idx}_${decision}`
  resolvedUpdateData.value[id][type].push(key)
}

function getDecision(exp: ExtResume['experience'][number], id: number, idx: number, isNew = false): 'accept' | 'deny' | undefined {
  if (!resolvedUpdateData.value[id]) {
    return undefined
  }
  const type = isNew ? 'new_suggestions' : exp.responsibilities[idx].choice === 'new' ? 'new_suggestions' : 'currents'
  const target = resolvedUpdateData.value[id][type].find(key => key.startsWith(`${idx}_`))
  if (!target) {
    return undefined
  }
  return target.split('_')[1] as 'accept' | 'deny'
}

function onClearDecision(exp: ExtResume['experience'][number], id: number, idx: number) {
  if (!resolvedUpdateData.value[id]) {
    return
  }
  const type = exp.responsibilities[idx].choice === 'new' ? 'new_suggestions' : 'currents'
  const key = `${idx}_${getDecision(exp, id, idx)}`
  if (type === 'currents') {
    exp.responsibilities[idx].text = exp.responsibilities[idx].last_suggestion || ''
    exp.responsibilities[idx].choice = undefined
  }
  else {
    exp.responsibilities.splice(idx, 1)
  }
  resolvedUpdateData.value[id][type] = resolvedUpdateData.value[id][type].filter(k => k !== key)
}

function processUpdateData() {
  if (!props.updateData) return
  for (const update of props.updateData) {
    const { id, responsibilities } = update
    if (!processedUpdateData.value[id]) {
      processedUpdateData.value[id] = {
        currents: {},
        new_suggestions: [],
      }
    }

    if (!responsibilities) continue

    for (const resp of responsibilities) {
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
        console.log(`Missing idx for responsibility update for experience ID ${id}`)
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
      <div>
        <p>
          Fill in your work experience to showcase your professional
          background. Try to be concise and focus on relevant roles.
          <span
            class="font-bold"
            :class="{
              'text-error':
                (model.experience?.length ?? 0) > MAX_EXPERIENCE_NUMBER,
            }"
          >
            Limit: {{ model.experience?.length ?? 0 }}/{{
              MAX_EXPERIENCE_NUMBER
            }}
          </span>
        </p>
        <p class="mt-1 text-xs !text-primary font-bold">
          Don't worry about sorting by date, we will do that for you
          afterwards!
        </p>
      </div>
      <div>
        <UButton
          :disabled="
            (model.experience?.length ?? 0) >= MAX_EXPERIENCE_NUMBER
          "
          icon="i-lucide-plus"
          label="Add Experience"
          variant="subtle"
          @click="appendExperience"
        />
      </div>
    </div>
    <template
      v-for="(exp, idx) in model.experience"
      :key="idx"
    >
      <div
        class="mb-4 last:mb-0 p-4 transition-all"
        :class="{
          'ring-2 ring-error bg-error/5 rounded-lg':
            hoverTarget === `experience-${idx}`,
        }"
      >
        <!--                <div class="flex justify-between gap-4"> -->
        <!--                  <h5> -->
        <!--                    Overview -->
        <DevWrapper>
          {{ exp.id ? `ID: ${exp.id}` : 'New Entry' }}
        </DevWrapper>
        <!--                  </h5> -->
        <!--                  <UButton icon="i-lucide-x" label="Remove Experience" color="error" variant="ghost" -->
        <!--                           @click="removeExperience(idx)" @mouseenter="hoverTarget = `experience-${idx}`" -->
        <!--                           @mouseleave="hoverTarget = ''" /> -->
        <!--                </div> -->
        <LVInput
          v-model="exp.position"
          class="mb-1.5"
          label="Position"
          required
          :error="
            errorPaths.includes(`experience_${idx}_position`)
              && 'Please enter a valid position'
          "
        />
        <LVInput
          v-model="exp.company"
          class="mb-1.5"
          label="Company"
          required
        />
        <LVInput
          v-model="exp.location"
          class="mb-1.5"
          label="Location"
        />
        <div class="flex justify-between gap-4">
          <LVDatePicker
            v-model="exp.start_date"
            label="Start Date"
            required
          />
          <LVDatePicker
            v-model="exp.end_date"
            label="End Date"
            hint="Optional"
          />
        </div>

        <USeparator
          label="Responsibilities"
          class="my-2"
        />
        <template
          v-for="(desc, jdx) in exp.responsibilities"
          :key="jdx"
        >
          <div class="flex gap-2 mb-1.5">
            <div class="shrink-0">
              <UButton
                icon="i-lucide-x"
                color="error"
                variant="ghost"
                class="mt-6"
                @click="removeResponsibility(idx, jdx)"
              />
            </div>
            <div class="grow">
              <LVTextArea
                :label="`Item ${jdx + 1}`"
                :model-value="desc!.text"
                :rows="1"
                :help="`${desc!.text?.length ?? 0}/${MAX_RESPONSIBILITY_LENGTH}`"
                :error="
                  errorPaths.includes(
                    `experience_${idx}_responsibilities_${jdx}_text`,
                  ) && 'Please enter a valid responsibility text'
                "
                :ff-ui="{
                  help:
                    (desc!.text?.length ?? 0)
                    > MAX_RESPONSIBILITY_LENGTH
                      ? '!text-error'
                      : undefined,
                }"
                @update:model-value="
                  updateResponsibility($event, idx, jdx)
                "
              >
                <template
                  v-if="getDecision(exp, exp.id!, jdx)"
                  #hint
                >
                  <UButton
                    size="xs"
                    variant="subtle"
                    label="Undo"
                    color="info"
                    icon="i-lucide-undo"
                    @click="onClearDecision(exp, exp.id!, jdx)"
                  />
                </template>
              </LVTextArea>
              <ResumeSuggestion
                v-if="exp.id && processedUpdateData[exp.id]?.currents[jdx] && !getDecision(exp, exp.id, jdx)"
                class="mb-2"
                :text="processedUpdateData[exp.id]?.currents[jdx].text"
                :reason="processedUpdateData[exp.id]?.currents[jdx].reason"
                :action="processedUpdateData[exp.id]?.currents[jdx].action"
                :confidence="processedUpdateData[exp.id]?.currents[jdx].confidence"
                :raw="processedUpdateData[exp.id]?.currents[jdx]"
                @accept="onDecideUpdate(exp, exp.id, jdx, 'currents', $event)"
                @reject="onDecideUpdate(exp, exp.id, jdx, 'currents')"
              />
            </div>
          </div>
        </template>
        <div
          v-if="exp.id && processedUpdateData[exp.id]?.new_suggestions.length"
        >
          <template
            v-for="(suggestion, newIdx) in processedUpdateData[exp.id].new_suggestions"
            :key="newIdx"
          >
            <ResumeSuggestion
              v-if="!getDecision(exp, exp.id, newIdx, true)"
              class="mb-2"
              :text="suggestion.text"
              :reason="suggestion.reason"
              :action="'add'"
              :confidence="suggestion.confidence"
              :raw="suggestion"
              @accept="onDecideUpdate(exp, exp.id, newIdx, 'new_suggestions', $event)"
              @reject="onDecideUpdate(exp, exp.id, newIdx, 'new_suggestions')"
            />
          </template>
        </div>
        <div class="flex justify-between gap-4 mt-4">
          <UButton
            icon="i-lucide-plus"
            label="Add Responsibility"
            variant="subtle"
            @click="appendResponsibility(idx)"
          />

          <UButton
            icon="i-lucide-x"
            label="Remove Experience"
            color="error"
            variant="ghost"
            @click="removeExperience(idx)"
            @mouseenter="hoverTarget = `experience-${idx}`"
            @mouseleave="hoverTarget = ''"
          />
        </div>
      </div>
      <DevWrapper>
        <pre>
          <code>
            Raw Exp Updates {{ processedUpdateData[exp.id ?? -1] }}
          </code>
        </pre>
      </DevWrapper>
      <USeparator class="my-4 last:hidden" />
    </template>
    <!--            <UButton icon="i-lucide-plus" label="Add Experience" variant="subtle" @click="appendExperience" /> -->
  </div>
</template>

<style scoped>

</style>
