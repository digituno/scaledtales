export default defineNuxtPlugin(() => {
  const config = useRuntimeConfig()
  const authStore = useAuthStore()

  const api = $fetch.create({
    baseURL: config.public.apiBase,
    async onRequest({ options }) {
      const session = authStore.session
      if (session?.access_token) {
        options.headers = {
          ...options.headers,
          Authorization: `Bearer ${session.access_token}`,
        }
      }
    },
    async onResponseError({ response }) {
      if (response.status === 401) {
        await authStore.signOut()
        navigateTo('/login')
      }
    },
  })

  return {
    provide: {
      api,
    },
  }
})
