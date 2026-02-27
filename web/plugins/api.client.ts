export default defineNuxtPlugin(() => {
  const config = useRuntimeConfig()
  const authStore = useAuthStore()

  const api = $fetch.create({
    baseURL: config.public.apiBase,
    async onRequest({ options }) {
      const session = authStore.session
      if (session?.access_token) {
        const headers = new Headers(options.headers as HeadersInit | undefined)
        headers.set('Authorization', `Bearer ${session.access_token}`)
        options.headers = headers
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
