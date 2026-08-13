<script setup lang="ts">
import { z } from 'zod'
import type { SignInData, ZodError } from '~/models/general'

interface Props {
  loading: boolean
}

interface Emits {
  (e: 'switch'): void

  (e: 'submit', data: SignInData): void
}

defineProps<Props>()
const emit = defineEmits<Emits>()

const toast = useToast()
const showPassword = ref(false)

// Default Model
const model = ref<SignInData>({
  email: '',
  password: '',
})

// Sign In Data
const schema = z.object({
  email: z.string().email(),
  password: z.string(),
})

const errors = ref<ZodError[]>([])

async function onSubmit() {
  try {
    const data: SignInData = {
      email: model.value.email,
      password: model.value.password,
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

async function onForgotPassword() {
  // TODO: Implement forgot password functionality
  alert('PENDING: Forgot Password Clicked')
}

function togglePasswordVisibility() {
  showPassword.value = !showPassword.value
}
</script>

<template>
  <div>
    <div class="mb-12">
      <h2 class="mb-2">
        Sign In
      </h2>
      <p>
        Don't have an account?
        <span
          class="text-primary underline cursor-pointer"
          :class="{
            'pointer-events-none opacity-50': loading,
          }"
          @click="$emit('switch')"
        >
          Create now
        </span>
      </p>
    </div>

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

    <!-- TODO: Implement This -->
    <p class="hover:!text-primary underline cursor-pointer w-fit mb-4">
      Forgot Password?
    </p>

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
      label="Sign In"
      @click="onSubmit"
    />
  </div>
</template>
