import type { Session, User } from '@supabase/supabase-js'

export const useAuthStore = defineStore('auth', () => {
  const session = ref<Session | null>(null)
  const user = ref<User | null>(null)
  const isAdmin = ref(false)
  const loading = ref(true)

  const isAuthenticated = computed(() => !!session.value)

  async function init() {
    const { $supabase } = useNuxtApp()
    loading.value = true

    const { data } = await $supabase.auth.getSession()
    session.value = data.session
    user.value = data.session?.user ?? null

    if (data.session) {
      await checkAdminRole()
    }

    // 세션 변경 리스너
    $supabase.auth.onAuthStateChange(async (_event, newSession) => {
      session.value = newSession
      user.value = newSession?.user ?? null
      if (newSession) {
        await checkAdminRole()
      } else {
        isAdmin.value = false
      }
    })

    loading.value = false
  }

  async function checkAdminRole() {
    try {
      const config = useRuntimeConfig()
      const data = await $fetch<{ success: boolean; data: { role: string } }>(
        `${config.public.apiBase}/auth/me`,
        {
          headers: {
            Authorization: `Bearer ${session.value?.access_token}`,
          },
        },
      )
      isAdmin.value = data?.data?.role === 'admin'
    } catch {
      isAdmin.value = false
    }
  }

  async function signInWithEmail(email: string, password: string) {
    const { $supabase } = useNuxtApp()
    const { data, error } = await $supabase.auth.signInWithPassword({
      email,
      password,
    })
    if (error) throw error
    session.value = data.session
    user.value = data.user
    await checkAdminRole()
    return data
  }

  async function signOut() {
    const { $supabase } = useNuxtApp()
    await $supabase.auth.signOut()
    session.value = null
    user.value = null
    isAdmin.value = false
  }

  return {
    session,
    user,
    isAdmin,
    loading,
    isAuthenticated,
    init,
    signInWithEmail,
    signOut,
    checkAdminRole,
  }
})
