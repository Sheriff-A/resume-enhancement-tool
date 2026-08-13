<script setup lang="ts">
import { useProfileStore } from '~/store/profile'
import type { Profile, UpdateProfile } from '~/models/database'
import type { ZodError } from '~/models/general'
import { profileSettingsSchema } from '~/data/formSchemas'
import { TOASTER_DURATION } from '~/data/settings'

const profileStore = useProfileStore()
const toast = useToast()

const loading = ref(false)
const errors = ref<ZodError[]>([])

const model = ref<UpdateProfile>({
  name: '',
  email: '',
  phone: '',
  location: '',
  portfolio: '',
  linkedin: '',
  github: '',
})

function syncModelFromProfile(profile?: Profile) {
  model.value = {
    name: profile?.name ?? '',
    email: profile?.email ?? '',
    phone: profile?.phone ?? '',
    location: profile?.location ?? '',
    portfolio: profile?.portfolio ?? '',
    linkedin: profile?.linkedin ?? '',
    github: profile?.github ?? '',
  }
}

watch(
  () => profileStore.profile,
  profile => syncModelFromProfile(profile),
  { immediate: true },
)

function errorFor(path: string) {
  return errors.value.find(error => error.path === path)?.message
}

async function onSubmit() {
  const err = useZodCheck(profileSettingsSchema, model.value)
  if (err) {
    errors.value = err
    return
  }
  errors.value = []

  loading.value = true
  try {
    await profileStore.updateUserProfile(model.value)
    toast.add({
      title: 'Profile Updated',
      description: 'Your profile has been updated successfully.',
      color: 'success',
      duration: TOASTER_DURATION,
    })
  }
  catch (err) {
    console.error(err)
    toast.add({
      title: 'Error',
      description:
        (err as Error).message || 'Failed to update your profile.',
      color: 'error',
    })
  }
  finally {
    loading.value = false
  }
}

function onReset() {
  syncModelFromProfile(profileStore.profile)
  errors.value = []
}

useHead({
  title: 'Settings',
})
</script>

<template>
  <div>
    <GeneralPageHeading
      title="Account Settings"
      subtitle="Profile"
      description="Update your personal and contact information."
    />

    <UCard class="mt-4">
      <LVInput
        v-model="model.name"
        class="mb-1.5"
        label="Name"
        required
        :error="errorFor('name')"
      />
      <LVInput
        v-model="model.email"
        class="mb-1.5"
        label="Email"
        type="text"
        required
        :error="errorFor('email')"
      />
      <LVInput
        v-model="model.phone"
        class="mb-1.5"
        label="Phone"
        :error="errorFor('phone')"
      />
      <LVInput
        v-model="model.location"
        class="mb-1.5"
        label="Location"
        :error="errorFor('location')"
      />

      <USeparator
        class="my-4"
        label="Links"
      />

      <LVInput
        v-model="model.portfolio"
        class="mb-1.5"
        label="Portfolio"
        :error="errorFor('portfolio')"
      />
      <LVInput
        v-model="model.linkedin"
        class="mb-1.5"
        label="LinkedIn"
        :error="errorFor('linkedin')"
      />
      <LVInput
        v-model="model.github"
        class="mb-1.5"
        label="Github"
        :error="errorFor('github')"
      />

      <GeneralErrors
        v-if="errors.length"
        class="mt-4"
        :errors="errors"
      />

      <div class="flex justify-end gap-2 mt-6">
        <UButton
          label="Reset"
          color="neutral"
          variant="ghost"
          :disabled="loading"
          @click="onReset"
        />
        <UButton
          label="Save Changes"
          :loading="loading"
          :disabled="loading"
          @click="onSubmit"
        />
      </div>
    </UCard>
  </div>
</template>

<style scoped>

</style>
