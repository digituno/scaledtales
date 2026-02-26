<template>
  <div class="min-h-screen bg-gray-50">
    <!-- 사이드바 + 콘텐츠 -->
    <div class="flex h-screen overflow-hidden">
      <!-- 사이드바 -->
      <aside class="w-64 bg-white border-r border-gray-200 flex flex-col">
        <!-- 로고 -->
        <div class="h-16 flex items-center px-6 border-b border-gray-200">
          <span class="text-xl font-bold text-primary-600">🦎 ScaledTales</span>
          <span class="ml-2 text-xs text-gray-400 font-medium">Admin</span>
        </div>

        <!-- 네비게이션 -->
        <nav class="flex-1 px-4 py-6 space-y-1 overflow-y-auto">
          <NuxtLink
            v-for="item in navItems"
            :key="item.to"
            :to="item.to"
            class="flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors"
            :class="isActive(item.to)
              ? 'bg-primary-50 text-primary-700'
              : 'text-gray-600 hover:bg-gray-100 hover:text-gray-900'"
          >
            <UIcon :name="item.icon" class="w-5 h-5 flex-shrink-0" />
            {{ item.label }}
          </NuxtLink>
        </nav>

        <!-- 하단 사용자 정보 -->
        <div class="border-t border-gray-200 p-4">
          <div class="flex items-center gap-3">
            <UAvatar :alt="authStore.user?.email ?? ''" size="sm" />
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-gray-900 truncate">
                {{ authStore.user?.email }}
              </p>
              <p class="text-xs text-gray-400">관리자</p>
            </div>
            <UButton
              icon="i-heroicons-arrow-right-on-rectangle"
              variant="ghost"
              color="gray"
              size="xs"
              @click="handleSignOut"
            />
          </div>
        </div>
      </aside>

      <!-- 메인 콘텐츠 -->
      <main class="flex-1 overflow-y-auto">
        <div class="max-w-7xl mx-auto px-6 py-8">
          <slot />
        </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const navItems = [
  { to: '/dashboard', label: '대시보드', icon: 'i-heroicons-home' },
  { to: '/species', label: '종 관리', icon: 'i-heroicons-beaker' },
  { to: '/taxonomy', label: '분류 트리', icon: 'i-heroicons-rectangle-group' },
  { to: '/users', label: '사용자 관리', icon: 'i-heroicons-users' },
]

function isActive(path: string) {
  return route.path.startsWith(path)
}

async function handleSignOut() {
  await authStore.signOut()
  router.push('/login')
}
</script>
