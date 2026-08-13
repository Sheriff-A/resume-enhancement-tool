import type { Profile } from '~/models/database'

export const useResumeStore = defineStore('resume', () => {
  const profile = ref<Profile>()

  async function initResumeStore() {
    const user = useSupabaseUser()
    const userId = user.value?.id
    if (!userId) {
      console.warn(`User not authenticated`)
      return
    }
    const supabase = useSupabaseClient()

    const { data: profileData, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('user_id', userId)
      .single()

    if (profileError || !profileData) {
      throw profileError
    }

    profile.value = profileData
  }

  return {
    // Properties
    activeResume: activeResume,

    // Functions
    initResumeStore,
  }
})
