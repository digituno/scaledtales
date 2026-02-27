<template>
  <div>
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">공지사항 관리</h1>
        <p class="text-gray-500 mt-1">앱 공지사항을 등록하고 관리합니다</p>
      </div>
      <UButton icon="i-heroicons-plus" @click="openCreateModal">
        공지사항 등록
      </UButton>
    </div>

    <!-- 테이블 -->
    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
      <UTable
        :rows="announcements"
        :columns="columns"
        :loading="loading"
      >
        <!-- 제목 -->
        <template #title-data="{ row }">
          <span class="font-medium text-gray-900">{{ row.title }}</span>
        </template>

        <!-- 시작일시 -->
        <template #start_at-data="{ row }">
          <span class="text-sm text-gray-600">{{ formatDatetime(row.start_at) }}</span>
        </template>

        <!-- 종료일시 -->
        <template #end_at-data="{ row }">
          <span class="text-sm text-gray-600">{{ formatDatetime(row.end_at) }}</span>
        </template>

        <!-- 등록일 -->
        <template #created_at-data="{ row }">
          <span class="text-sm text-gray-400">{{ formatDatetime(row.created_at) }}</span>
        </template>

        <!-- 상태 -->
        <template #is_deleted-data="{ row }">
          <UBadge
            v-if="row.is_deleted"
            label="삭제됨"
            color="red"
            variant="soft"
            size="xs"
          />
          <UBadge
            v-else-if="isActive(row)"
            label="공지 중"
            color="green"
            variant="soft"
            size="xs"
          />
          <UBadge
            v-else
            label="비활성"
            color="gray"
            variant="soft"
            size="xs"
          />
        </template>

        <!-- 액션 -->
        <template #actions-data="{ row }">
          <div class="flex gap-2">
            <UButton
              icon="i-heroicons-pencil-square"
              size="xs"
              variant="ghost"
              color="gray"
              :disabled="row.is_deleted"
              @click="openEditModal(row)"
            />
            <UButton
              icon="i-heroicons-trash"
              size="xs"
              variant="ghost"
              color="red"
              :disabled="row.is_deleted"
              @click="confirmDelete(row)"
            />
          </div>
        </template>
      </UTable>

      <!-- 페이지네이션 -->
      <div class="flex items-center justify-between px-4 py-3 border-t border-gray-200">
        <span class="text-sm text-gray-500">총 {{ pagination.total }}개</span>
        <UPagination
          v-model="pagination.page"
          :page-count="pagination.limit"
          :total="pagination.total"
          @update:model-value="fetchAnnouncements"
        />
      </div>
    </div>

    <!-- 생성/수정 모달 -->
    <AnnouncementFormModal
      v-model:open="showModal"
      :announcement="editingAnnouncement"
      @close="showModal = false"
      @saved="onSaved"
    />

    <!-- 삭제 확인 -->
    <UModal v-model="showDeleteModal">
      <UCard>
        <template #header>
          <h3 class="font-semibold text-gray-900">공지사항 삭제 확인</h3>
        </template>
        <p class="text-gray-600">
          <strong>{{ deletingAnnouncement?.title }}</strong>을(를) 삭제하시겠습니까?<br />
          <span class="text-sm text-orange-500 mt-1 block">공지사항은 소프트 삭제됩니다 (데이터 보존).</span>
        </p>
        <template #footer>
          <div class="flex gap-3 justify-end">
            <UButton variant="outline" @click="showDeleteModal = false">취소</UButton>
            <UButton color="red" :loading="deleting" @click="deleteAnnouncement">삭제</UButton>
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

const loading = ref(false)
const announcements = ref<any[]>([])
const pagination = ref({ page: 1, limit: 20, total: 0 })

const showModal = ref(false)
const editingAnnouncement = ref<any>(null)
const showDeleteModal = ref(false)
const deletingAnnouncement = ref<any>(null)
const deleting = ref(false)

const columns = [
  { key: 'title', label: '제목' },
  { key: 'start_at', label: '시작 일시' },
  { key: 'end_at', label: '종료 일시' },
  { key: 'created_at', label: '등록일' },
  { key: 'is_deleted', label: '상태' },
  { key: 'actions', label: '' },
]

function formatDatetime(iso: string): string {
  if (!iso) return '-'
  const d = new Date(iso)
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`
}

function isActive(row: any): boolean {
  const now = new Date()
  return !row.is_deleted && new Date(row.start_at) <= now && new Date(row.end_at) >= now
}

async function fetchAnnouncements() {
  loading.value = true
  try {
    const res = await $api<any>('/admin/announcements', {
      query: {
        page: pagination.value.page,
        limit: pagination.value.limit,
      },
    })
    announcements.value = res.data
    pagination.value = { ...pagination.value, ...res.pagination }
  } catch {
    toast.add({ title: '공지사항 목록 조회 실패', color: 'red' })
  } finally {
    loading.value = false
  }
}

function openCreateModal() {
  editingAnnouncement.value = null
  showModal.value = true
}

function openEditModal(row: any) {
  editingAnnouncement.value = row
  showModal.value = true
}

function confirmDelete(row: any) {
  deletingAnnouncement.value = row
  showDeleteModal.value = true
}

async function deleteAnnouncement() {
  if (!deletingAnnouncement.value) return
  deleting.value = true
  try {
    await $api(`/admin/announcements/${deletingAnnouncement.value.id}`, {
      method: 'DELETE',
    })
    toast.add({ title: '공지사항이 삭제되었습니다', color: 'green' })
    showDeleteModal.value = false
    await fetchAnnouncements()
  } catch {
    toast.add({ title: '삭제에 실패했습니다', color: 'red' })
  } finally {
    deleting.value = false
  }
}

function onSaved() {
  fetchAnnouncements()
}

onMounted(() => {
  fetchAnnouncements()
})
</script>
