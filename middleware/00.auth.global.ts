import { useProfileStore } from '~/store/profile'

export default defineNuxtRouteMiddleware(async (to, _) => {
  // FIXME: Temp bypass for development
  if (process.env.NODE_ENV === 'development') {
    return
  }

  // Public pages have no requirements
  const isPublic = to.meta.public || false
  // console.log('Route Middleware: isPublic=', isPublic, ' from.path=', from.path, ' to.path=', to.path);
  if (isPublic) {
    return
  }

  // Get session from supabase
  const session = useSupabaseSession()
  if (!session.value && !to.path.startsWith('/login')) {
    const toast = useToast()
    toast.add({
      title: 'Not Authenticated',
      description: 'You need to be logged in to access this page.',
      color: 'warning',
    })
    // If not authenticated, redirect to the login page
    return navigateTo('/login')
  }
  else if (session.value && to.path.startsWith('/login')) {
    // If authenticated and trying to access the login page, redirect to dashboard
    return navigateTo('/dashboard')
  }

  const profileStore = useProfileStore()
  await profileStore.refreshUserProfile().catch(console.error)
})
