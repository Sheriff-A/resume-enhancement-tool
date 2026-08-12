import { defineStore } from 'pinia';
import type { Profile } from '~/models/database';

export const useProfileStore = defineStore('user', () => {
  const profile = ref<Profile>();
  const isSubscribed = ref(false);
  const { refresh, status } = useAsyncData('user', () => refreshBySession());

  async function fetchUserProfile() {
    const user = useSupabaseUser();
    if (!user.value) {
      console.warn('No authenticated user found.');
      return;
    }
    const userId = user.value.id;

    const supabase = useSupabaseClient();
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('user_id', userId)
      .select()
      .single();

    if (error) {
      throw error;
    }

    profile.value = data || undefined;
  }

  async function refreshBySession(force = false) {
    try {
      const session = useSupabaseSession();

      // If there is no active supabase session, clear the profile
      if (!session.value) {
        profile.value = undefined;
        return profile.value;
      }

      // If there is an active supabase session, fetch the user profile as needed
      if (force || !profile.value) {
        await fetchUserProfile();
      }

      return profile.value;
    } catch (err) {
      console.error('Error refreshing user data:', err);
    }
  }

  async function logout() {
    const supabase = useSupabaseClient();
    const { error } = await supabase.auth.signOut();
    if (error) {
      console.error('Error during logout:', error);
    }
    profile.value = undefined;
  }

  async function updateUserProfile(data: Partial<Profile>) {
    const supabase = useSupabaseClient();
    const user = useSupabaseUser();
    if (!user.value) {
      throw new Error('No authenticated user found.');
    }

    const userId = user.value.id;

    const { error } = await supabase
      .from('profiles')
      .upsert({
        ...data,
        user_id: user.value.id,
      })
      .eq('user_id', userId);

    if (error) {
      throw error;
    }
    // Refresh the profile after an update
    await fetchUserProfile();
  }

  return {
    profile,
    subscribed: readonly(isSubscribed),
    isRefreshing: computed(() => status.value === 'pending'),

    logout,
    updateUserProfile,
    refreshUserProfile: refresh,
  };
});
