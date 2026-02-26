export default defineNuxtRouteMiddleware(async (to) => {
  const authStore = useAuthStore()

  // 최초 1회 초기화
  if (authStore.loading) {
    await authStore.init()
  }

  // 로그인 페이지는 통과
  if (to.path === '/login') {
    if (authStore.isAuthenticated && authStore.isAdmin) {
      return navigateTo('/dashboard')
    }
    return
  }

  // 미인증 → 로그인
  if (!authStore.isAuthenticated) {
    return navigateTo('/login')
  }

  // 인증됐지만 관리자 아님
  if (!authStore.isAdmin) {
    return navigateTo('/login?error=forbidden')
  }
})
