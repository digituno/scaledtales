<template>
  <div>
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">사용자 관리</h1>
        <p class="text-gray-500 mt-1">회원 목록 조회 및 권한 관리</p>
      </div>
    </div>

    <!-- 검색 -->
    <div class="bg-white rounded-xl p-4 shadow-sm mb-6 flex gap-3">
      <UInput
        v-model="emailSearch"
        placeholder="이메일로 검색"
        icon="i-heroicons-envelope"
        class="flex-1"
        @input="debouncedFetch"
      />
      <UButton variant="outline" icon="i-heroicons-arrow-path" @click="fetchUsers">
        새로고침
      </UButton>
    </div>

    <!-- 테이블 -->
    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
      <UTable
        :rows="users"
        :columns="columns"
        :loading="loading"
      >
        <!-- 이메일 -->
        <template #email-data="{ row }">
          <div class="flex items-center gap-3">
            <UAvatar :alt="row.email" size="sm" />
            <span class="text-sm font-medium text-gray-900">{{ row.email }}</span>
          </div>
        </template>

        <!-- 역할 -->
        <template #role-data="{ row }">
          <UBadge
            :label="roleLabelMap[row.role] ?? row.role"
            :color="(roleColorMap[row.role] ?? 'gray') as any"
            variant="soft"
            size="sm"
          />
        </template>

        <!-- 가입일 -->
        <template #created_at-data="{ row }">
          <span class="text-sm text-gray-500">{{ formatDate(row.created_at) }}</span>
        </template>

        <!-- 최근 로그인 -->
        <template #last_sign_in_at-data="{ row }">
          <span class="text-sm text-gray-500">{{ row.last_sign_in_at ? formatDate(row.last_sign_in_at) : '-' }}</span>
        </template>

        <!-- 역할 변경 -->
        <template #actions-data="{ row }">
          <USelect
            :model-value="row.role"
            :options="roleOptions"
            option-attribute="label"
            value-attribute="value"
            size="xs"
            :ui="{ width: 'w-36' }"
            @update:model-value="(newRole) => changeRole(row, newRole)"
          />
        </template>
      </UTable>

      <!-- 페이지네이션 -->
      <div class="flex items-center justify-between px-4 py-3 border-t border-gray-200">
        <span class="text-sm text-gray-500">총 {{ pagination.total }}명</span>
        <UPagination
          v-model="pagination.page"
          :page-count="pagination.limit"
          :total="pagination.total"
          @update:model-value="fetchUsers"
        />
      </div>
    </div>

    <!-- 역할 변경 확인 모달 -->
    <UModal v-model="showRoleModal">
      <UCard>
        <template #header>
          <h3 class="font-semibold text-gray-900">역할 변경 확인</h3>
        </template>
        <p class="text-gray-600">
          <strong>{{ pendingChange?.email }}</strong>의 역할을<br />
          <strong>{{ roleLabelMap[pendingChange?.currentRole] }}</strong> →
          <strong class="text-primary-600">{{ roleLabelMap[pendingChange?.newRole] }}</strong>으로 변경하시겠습니까?
        </p>
        <template #footer>
          <div class="flex gap-3 justify-end">
            <UButton variant="outline" @click="cancelRoleChange">취소</UButton>
            <UButton :loading="changingRole" @click="confirmRoleChange">변경</UButton>
          </div>
        </template>
      </UCard>
    </UModal>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'default' })

const { $api } = useNuxtApp()
const toast = useToast()

const emailSearch = ref('')
const loading = ref(false)
const users = ref<any[]>([])
const pagination = ref({ page: 1, limit: 20, total: 0 })

const showRoleModal = ref(false)
const pendingChange = ref<any>(null)
const changingRole = ref(false)

const columns = [
  { key: 'email', label: '이메일' },
  { key: 'role', label: '역할' },
  { key: 'created_at', label: '가입일' },
  { key: 'last_sign_in_at', label: '최근 로그인' },
  { key: 'actions', label: '역할 변경' },
]

const roleLabelMap: Record<string, string> = {
  admin: '관리자',
  seller: '판매자',
  pro_breeder: '전문 브리더',
  user: '일반 사용자',
  suspended: '정지',
}

const roleColorMap: Record<string, string> = {
  admin: 'red',
  seller: 'blue',
  pro_breeder: 'purple',
  user: 'green',
  suspended: 'gray',
}

const roleOptions = [
  { label: '관리자', value: 'admin' },
  { label: '판매자', value: 'seller' },
  { label: '전문 브리더', value: 'pro_breeder' },
  { label: '일반 사용자', value: 'user' },
  { label: '정지', value: 'suspended' },
]

async function fetchUsers() {
  loading.value = true
  try {
    const res = await $api<any>('/admin/users', {
      query: {
        page: pagination.value.page,
        limit: pagination.value.limit,
        email: emailSearch.value || undefined,
      },
    })
    users.value = res.data
    pagination.value = { ...pagination.value, ...res.pagination }
  } catch {
    toast.add({ title: '사용자 목록 조회 실패', color: 'red' })
  } finally {
    loading.value = false
  }
}

let debounceTimer: ReturnType<typeof setTimeout>
function debouncedFetch() {
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(() => {
    pagination.value.page = 1
    fetchUsers()
  }, 400)
}

function changeRole(row: any, newRole: string) {
  if (newRole === row.role) return
  pendingChange.value = {
    id: row.id,
    email: row.email,
    currentRole: row.role,
    newRole,
  }
  showRoleModal.value = true
}

function cancelRoleChange() {
  pendingChange.value = null
  showRoleModal.value = false
  // 기존 데이터 재조회로 선택 롤백
  fetchUsers()
}

async function confirmRoleChange() {
  if (!pendingChange.value) return
  changingRole.value = true
  try {
    await $api(`/admin/users/${pendingChange.value.id}/role`, {
      method: 'PATCH',
      body: { role: pendingChange.value.newRole },
    })
    toast.add({ title: '역할이 변경되었습니다.', color: 'green' })
    showRoleModal.value = false
    fetchUsers()
  } catch {
    toast.add({ title: '역할 변경에 실패했습니다.', color: 'red' })
    fetchUsers()
  } finally {
    changingRole.value = false
  }
}

function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString('ko-KR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  })
}

onMounted(fetchUsers)
</script>
