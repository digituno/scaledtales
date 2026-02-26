<template>
  <div>
    <div class="mb-8">
      <h1 class="text-2xl font-bold text-gray-900">대시보드</h1>
      <p class="text-gray-500 mt-1">ScaledTales 서비스 현황</p>
    </div>

    <!-- 로딩 -->
    <div v-if="pending" class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
      <div
        v-for="n in 4"
        :key="n"
        class="bg-white rounded-xl p-6 shadow-sm animate-pulse"
      >
        <div class="h-4 bg-gray-200 rounded w-1/2 mb-3" />
        <div class="h-8 bg-gray-200 rounded w-1/3" />
      </div>
    </div>

    <!-- 통계 카드 -->
    <div v-else-if="stats" class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
      <StatsCard
        title="전체 개체"
        :value="stats.animals.total"
        :sub="`생존 ${stats.animals.alive}마리`"
        icon="i-heroicons-bug-ant"
        color="green"
      />
      <StatsCard
        title="이번 달 신규 개체"
        :value="stats.animals.newThisMonth"
        icon="i-heroicons-plus-circle"
        color="blue"
      />
      <StatsCard
        title="전체 케어로그"
        :value="stats.careLogs.total"
        icon="i-heroicons-clipboard-document-list"
        color="purple"
      />
      <StatsCard
        title="등록 종 수"
        :value="stats.species.total"
        icon="i-heroicons-beaker"
        color="yellow"
      />
    </div>

    <!-- 사용자 통계 -->
    <div v-if="stats" class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
      <!-- 사용자 요약 -->
      <div class="bg-white rounded-xl p-6 shadow-sm">
        <h2 class="text-base font-semibold text-gray-900 mb-4">
          <UIcon name="i-heroicons-users" class="inline mr-2 text-primary-500" />
          사용자 현황
        </h2>
        <div class="space-y-3">
          <div class="flex justify-between items-center py-2 border-b border-gray-100">
            <span class="text-sm text-gray-600">전체 사용자</span>
            <span class="font-semibold text-gray-900">{{ stats.users.total.toLocaleString() }}명</span>
          </div>
          <div class="flex justify-between items-center py-2">
            <span class="text-sm text-gray-600">이번 달 신규 가입</span>
            <span class="font-semibold text-primary-600">+{{ stats.users.newThisMonth }}명</span>
          </div>
        </div>
      </div>

      <!-- 케어로그 타입별 통계 -->
      <div class="bg-white rounded-xl p-6 shadow-sm">
        <h2 class="text-base font-semibold text-gray-900 mb-4">
          <UIcon name="i-heroicons-chart-bar" class="inline mr-2 text-purple-500" />
          케어로그 타입별 현황
        </h2>
        <div class="space-y-2">
          <div
            v-for="item in stats.careLogs.byType"
            :key="item.type"
            class="flex items-center gap-3"
          >
            <span class="text-xs text-gray-500 w-28 flex-shrink-0">{{ logTypeLabel(item.type) }}</span>
            <div class="flex-1 bg-gray-100 rounded-full h-2">
              <div
                class="h-2 rounded-full bg-primary-500"
                :style="{ width: `${Math.min(100, (item.count / stats.careLogs.total) * 100)}%` }"
              />
            </div>
            <span class="text-xs font-medium text-gray-700 w-8 text-right">{{ item.count }}</span>
          </div>
          <div v-if="stats.careLogs.byType.length === 0" class="text-sm text-gray-400 text-center py-4">
            데이터 없음
          </div>
        </div>
      </div>
    </div>

    <!-- 에러 -->
    <UAlert
      v-if="error"
      icon="i-heroicons-exclamation-triangle"
      color="red"
      variant="soft"
      title="통계 데이터를 불러오지 못했습니다."
      :description="error.message"
    />
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'default' })

const { $api } = useNuxtApp()

interface StatsData {
  animals: { total: number; alive: number; newThisMonth: number }
  careLogs: { total: number; byType: { type: string; count: number }[] }
  species: { total: number }
  users: { total: number; newThisMonth: number }
}

const { data: statsResponse, pending, error } = await useAsyncData('stats', () =>
  $api<{ success: boolean; data: StatsData }>('/admin/stats'),
)

const stats = computed(() => statsResponse.value?.data ?? null)

const LOG_TYPE_LABELS: Record<string, string> = {
  FEEDING: '급이',
  SHEDDING: '탈피',
  DEFECATION: '배변',
  MATING: '교미',
  EGG_LAYING: '산란',
  CANDLING: '검란',
  HATCHING: '부화',
}

function logTypeLabel(type: string): string {
  return LOG_TYPE_LABELS[type] ?? type
}
</script>
