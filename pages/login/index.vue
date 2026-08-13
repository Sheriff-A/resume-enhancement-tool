<template>
  <UContainer class="h-full flex items-center justify-center py-8">
    <div class="w-full max-w-5xl grid grid-cols-1 md:grid-cols-2 rounded-2xl overflow-hidden border border-default bg-elevated shadow-2xl">
      <div class="hidden md:flex items-center justify-center relative overflow-hidden bg-linear-to-br from-primary-600 via-primary-800 to-secondary-950 p-10">
        <div class="absolute inset-0 opacity-40 bg-[radial-gradient(circle_at_20%_20%,white,transparent_40%)]" />
        <img
          :src="loginImage"
          alt="Illustration of a person leaping across a resume checklist toward a star"
          class="relative w-full max-w-sm drop-shadow-2xl"
        >
      </div>

      <div class="p-8 sm:p-12 flex flex-col justify-center">
        <Transition
          name="fade"
          mode="out-in"
        >
          <FormsSignIn
            v-if="showSignIn"
            :loading="loading"
            @switch="showSignIn = false"
            @submit="handleSignInReq"
          />
          <FormsSignUp
            v-else
            :loading="loading"
            @switch="showSignIn = true"
            @submit="handleSignUpReq"
          />
        </Transition>
      </div>
    </div>
  </UContainer>
</template>

<script setup lang="ts">
import { signInWithEmail, signUpWithEmail } from '~/composables/auth';
import type { SignInData, SignUpData } from '~/models/general';
import loginImage from '~/assets/images/login-vector-image.png';

definePageMeta({
  layout: 'auth',
});

useHead({
  title: 'Sign In',
  meta: [
    {
      name: 'description',
      content: 'Sign in to your account',
    },
  ],
});

const router = useRouter();
const toast = useToast();

const showSignIn = ref(true);
const loading = ref(false);

async function handleSignInReq(data: SignInData) {
  try {
    loading.value = true;
    const { email, password } = data;
    await signInWithEmail(email, password);

    toast.add({
      title: 'Sign In Successful',
      color: 'success',
    });

    await router.push({
      name: 'dashboard',
    });
  }
  catch (err) {
    console.error(err);
    const errorMessage
      = err instanceof Error
        ? err.message
        : 'An error occurred while signing in. Please try again.';
    toast.add({
      title: 'Sign In Failed',
      description: errorMessage,
      color: 'error',
    });
  }
  finally {
    loading.value = false;
  }
}

// TODO: Type this and implement
async function handleSignUpReq(data: SignUpData) {
  try {
    loading.value = true;

    const { email, password, name } = data;
    await signUpWithEmail(email, password, name);

    toast.add({
      title: 'Sign Up Successful',
      description:
        'Check your email for a verification link before signing in.',
      color: 'success',
    });
  }
  catch (err) {
    console.error(err);
    const errorMessage
      = err instanceof Error
        ? err.message
        : 'An error occurred while signing up. Please try again.';
    toast.add({
      title: 'Sign Up Failed',
      description: errorMessage,
      color: 'error',
    });
  }
  finally {
    loading.value = false;
  }
}
</script>

<style lang="css" scoped>
.fade-enter-active,
.fade-leave-active {
  transition: all 0.5s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateX(-5%);
}
</style>
