<script setup lang="ts">
import { z } from 'zod'
import type { SignUpData, ZodError } from '~/models/general'
import { RGX_PASSWORD } from '~/data/regex'

interface Props {
  loading: boolean
}

interface Emits {
  (e: 'switch'): void

  (e: 'submit', data: SignUpData): void
}

defineProps<Props>()
const emit = defineEmits<Emits>()

const toast = useToast()
const showPassword = ref(false)

// Default Model
const model = ref<SignUpData>({
  email: '',
  password: '',
  name: '',
})

// Sign In Data
const schema = z.object({
  name: z.string().min(1, 'First name is required'),
  email: z.string().email(),
  password: z.string().regex(RGX_PASSWORD, {
    message: 'Password must be 8-64 characters long, contain at least one uppercase letter, one lowercase letter, one number and one special character.',
  }),
})

const passwordChecklist = computed(() => {
  const checklist = {
    length: false,
    uppercase: false,
    lowercase: false,
    number: false,
    special: false,
  }
  const password = model.value.password || ''

  checklist.length = password.length >= 8 && password.length <= 64
  checklist.uppercase = /[A-Z]/.test(password)
  checklist.lowercase = /[a-z]/.test(password)
  checklist.number = /[0-9]/.test(password)
  checklist.special = /[!@#$%^&*(),.?":{}|<>]/.test(password)

  return checklist
})

const errors = ref<ZodError[]>([])

async function onSubmit() {
  try {
    const data: SignUpData = {
      email: model.value.email,
      password: model.value.password,
      name: model.value.name,
    }
    const err = useZodCheck(schema, data)
    if (err) {
      errors.value = err
      return
    }

    errors.value = []
    // Emit the submitted event with the model data
    emit('submit', data)
  }
  catch (err) {
    console.error(err)
    toast.add({
      title: 'Validation Error',
      description: 'An unexpected error occurred during validation.',
      color: 'error',
    })
  }
}

function togglePasswordVisibility() {
  showPassword.value = !showPassword.value
}
</script>

<template>
  <div>
    <div class="mb-12">
      <h2 class="mb-2">
        Sign Up
      </h2>
      <p>
        Already have an account?
        <span
          class="text-primary underline cursor-pointer"
          :class="{
            'pointer-events-none opacity-50': loading,
          }"
          @click="$emit('switch')"
        >
          Sign in
        </span>
      </p>
    </div>

    <UFormField
      class="mb-4"
      label="Name"
      required
    >
      <UInput
        v-model="model.name"
        type="text"
        name="name"
        :loading="loading"
        :disabled="loading"
        placeholder="Enter your name"
        class="w-full"
      />
    </UFormField>
    <UFormField
      class="mb-4"
      label="Email"
      required
    >
      <UInput
        v-model="model.email"
        name="email"
        type="email"
        :loading="loading"
        :disabled="loading"
        placeholder="Enter your email"
        class="w-full"
      />
    </UFormField>
    <UFormField
      class="mb-4"
      label="Password"
      required
    >
      <UInput
        v-model="model.password"
        name="password"
        :type="showPassword ? 'text' : 'password'"
        :loading="loading"
        :disabled="loading"
        placeholder="Enter your password"
        class="w-full"
        :ui="{ trailing: 'pe-1' }"
      >
        <template #trailing>
          <UButton
            color="neutral"
            variant="link"
            size="sm"
            :icon="showPassword ? 'i-lucide-eye-off' : 'i-lucide-eye'"
            :aria-label="showPassword ? 'Hide password' : 'Show password'"
            :aria-pressed="showPassword"
            aria-controls="password"
            @click="togglePasswordVisibility"
          />
        </template>
      </UInput>
    </UFormField>

    <ul class="list-disc list-inside mb-4">
      <li
        class="text-sm"
        :class="{
          'text-green-500': passwordChecklist.length,
        }"
      >
        Must be at least 8-64 characters long ({{ model.password.length }})
      </li>
      <li
        class="text-sm"
        :class="{
          'text-green-500': passwordChecklist.uppercase,
        }"
      >
        Must contain at least one uppercase letter
      </li>
      <li
        class="text-sm"
        :class="{
          'text-green-500': passwordChecklist.lowercase,
        }"
      >
        Must contain at least one lowercase letter
      </li>
      <li
        class="text-sm"
        :class="{
          'text-green-500': passwordChecklist.number,
        }"
      >
        Must contain at least one number
      </li>
      <li
        class="text-sm"
        :class="{
          'text-green-500': passwordChecklist.special,
        }"
      >
        Must contain at least one special character
      </li>
    </ul>

    <GeneralErrors
      :errors="errors"
    />

    <UButton
      class="w-full mt-8"
      :ui="{
        base: ['justify-center'],
      }"
      size="lg"
      :loading="loading"
      :disabled="loading"
      label="Sign Up"
      @click="onSubmit"
    />
  </div>
</template>
