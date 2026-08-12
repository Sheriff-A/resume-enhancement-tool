import type { ComposableReturn } from '~/models/general'

const REDIRECT_URL = 'http://localhost:3000/confirm'
const RESET_PASSWORD_URL = 'http://localhost:3000/reset-password'

export async function signOut(): Promise<void> {
  const supabase = useSupabaseClient()
  const { error } = await supabase.auth.signOut()

  if (error) {
    throw new Error(`Failed to sign out: ${error.message}`)
  }
}

export async function signUpWithEmail(email: string, password: string, name: string): Promise<ComposableReturn<boolean>> {
  const supabase = useSupabaseClient()
  const { error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        name: name,
      },
      emailRedirectTo: REDIRECT_URL,
    },
  })

  if (error) {
    throw new Error(`Failed to sign up: ${error.message}`)
  }

  return {
    status: 'success',
    data: true,
  }
}

export async function signInWithEmail(email: string, password: string): Promise<ComposableReturn<boolean>> {
  const supabase = useSupabaseClient()
  const { error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })

  if (error) {
    throw new Error(`Failed to sign in: ${error.message}`)
  }

  return {
    status: 'success',
    data: true,
  }
}

export async function resetPassword(email: string): Promise<ComposableReturn<boolean>> {
  const supabase = useSupabaseClient()
  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: RESET_PASSWORD_URL,
  })

  if (error) {
    throw new Error(`Failed to send password reset email: ${error.message}`)
  }

  return {
    status: 'success',
    data: true,
  }
}
