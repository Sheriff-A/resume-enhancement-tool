<script setup lang="ts">
import { MAX_SKILLS_NUMBER } from '~/data/formSchemas'
import type { EnhanceResumeResults } from '~/models/server/resume'
import type { ExtResume } from '~/models/ext_resume'
import type { SkillType } from '~/models/database'
import { SkillTypeLabels } from '~/data/labels'

interface Props {
  errorPaths?: string[]
  updateData?: EnhanceResumeResults['skills']
}

const props = withDefaults(defineProps<Props>(), {
  errorPaths: () => [],
  updateData: undefined,
})

const model = defineModel<ExtResume>({
  required: true,
})

const skillInput = ref<string>('')

function appendSkill() {
  const skillName = skillInput.value.trim()
  if (!skillName) {
    return
  }
  skillInput.value = ''
  if (!model.value.skills) {
    model.value.skills = []
  }
  model.value.skills.push({
    name: skillName,
    type: 'hard',
  })
}

function removeSkill(index: number) {
  model.value.skills.splice(index, 1)
}

function toggleSkillType(skill: { name: string, type: SkillType }) {
  skill.type = skill.type === 'hard' ? 'soft' : 'hard'
}

function onDecideUpdate(skillName: string, type: SkillType, idx: number, reject = false) {
  if (!reject) {
    model.value.skills.push({
      name: skillName,
      type: type,
    })
  }
  props.updateData!.splice(idx, 1)
}
</script>

<template>
  <div>
    <p class="mb-2">
      List your skills to highlight your expertise. Focus on relevant
      skills that match the jobs you're applying for.
      <span
        class="font-bold"
        :class="{
          'text-error': (model.skills?.length ?? 0) > MAX_SKILLS_NUMBER,
        }"
      >
        Limit: {{ model.skills?.length ?? 0 }}/{{ MAX_SKILLS_NUMBER }}
      </span>
    </p>

    <div class="flex items-center justify-between gap-4 mb-2">
      <div class="grow">
        <LVInput
          v-model="skillInput"
          required
          label="New Skill"
          @keyup.enter="appendSkill"
        />
      </div>
      <div>
        <UButton
          class="mt-6"
          :disabled="
            !skillInput
              || (model.skills?.length ?? 0) >= MAX_SKILLS_NUMBER
          "
          icon="i-lucide-plus"
          label="Add Skill"
          variant="subtle"
          @click="appendSkill"
        />
      </div>
    </div>

    <USeparator class="my-4" />

    <div class="flex justify-between gap-4">
      <h5>Skills</h5>
      <p>
        <span>
          {{ SkillTypeLabels['hard'] }}: <UBadge color="primary" />
        </span>
        <span class="ml-4">
          {{ SkillTypeLabels['soft'] }}: <UBadge color="secondary" />
        </span>
      </p>
    </div>
    <p class="mb-2">
      Click skill to toggle.
    </p>

    <div class="flex flex-wrap gap-2">
      <template
        v-for="(skill, idx) in model.skills"
        :key="idx"
      >
        <div
          class="cursor-pointer flex items-center gap-2 pl-4 pr-3 py-1 border rounded-lg"
          :class="{
            'bg-primary/10 text-primary border-primary/20':
              skill.type === 'hard',
            'bg-secondary/10 text-secondary border-secondary/20':
              skill.type === 'soft',
          }"
          @click="toggleSkillType(skill)"
        >
          <span>
            {{ skill.name }}
          </span>
          <UIcon
            name="i-lucide-x"
            @click.stop="removeSkill(idx)"
          />
        </div>
      </template>
    </div>

    <template v-if="updateData?.length">
      <USeparator class="my-4" />

      <p class="mb-4">
        Skill Suggestions:
      </p>
      <template
        v-for="(suggestion, nIdx) in updateData"
        :key="suggestion.name"
      >
        <ResumeSuggestion
          :text="suggestion.name || 'Unknown Skill'"
          :confidence="suggestion.confidence"
          :reason="suggestion.reason"
          :raw="suggestion"
          action="add"
          @accept="onDecideUpdate(suggestion.name || 'Unknown Skill', suggestion.type || 'hard', nIdx)"
          @reject="onDecideUpdate(suggestion.name || 'Unknown Skill', suggestion.type || 'hard', nIdx, true)"
        />
      </template>
    </template>
  </div>
</template>

<style scoped>

</style>
