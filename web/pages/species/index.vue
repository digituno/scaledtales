<template>
  <div>
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">종 관리</h1>
        <p class="text-gray-500 mt-1">등록된 파충류/양서류 종 정보를 관리합니다</p>
      </div>
      <UButton
        icon="i-heroicons-plus"
        @click="openCreateModal"
      >
        종 추가
      </UButton>
    </div>

    <!-- 검색 -->
    <div class="bg-white rounded-xl p-4 shadow-sm mb-6 flex gap-3">
      <UInput
        v-model="search"
        placeholder="한국명, 영명, 학명으로 검색"
        icon="i-heroicons-magnifying-glass"
        class="flex-1"
        @input="debouncedFetch"
      />
      <UButton variant="outline" icon="i-heroicons-arrow-path" @click="fetchSpecies">
        새로고침
      </UButton>
    </div>

    <!-- 테이블 -->
    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
      <UTable
        :rows="species"
        :columns="columns"
        :loading="loading"
      >
        <!-- 종명 -->
        <template #species_kr-data="{ row }">
          <div>
            <p class="font-medium text-gray-900">{{ row.species_kr }}</p>
            <p class="text-xs text-gray-400">{{ row.scientific_name }}</p>
          </div>
        </template>

        <!-- 영명 -->
        <template #species_en-data="{ row }">
          <span class="text-sm text-gray-600">{{ row.species_en }}</span>
        </template>

        <!-- 속 -->
        <template #genus-data="{ row }">
          <span class="text-sm text-gray-600">{{ row.genus?.name_en ?? '-' }}</span>
        </template>

        <!-- CITES -->
        <template #is_cites-data="{ row }">
          <UBadge
            v-if="row.is_cites"
            :label="row.cites_level?.replace('APPENDIX_', 'App. ') ?? 'CITES'"
            color="orange"
            variant="soft"
            size="xs"
          />
          <span v-else class="text-xs text-gray-400">-</span>
        </template>

        <!-- 백색목록 -->
        <template #is_whitelist-data="{ row }">
          <UBadge
            v-if="row.is_whitelist"
            label="백색목록"
            color="green"
            variant="soft"
            size="xs"
          />
          <span v-else class="text-xs text-gray-400">-</span>
        </template>

        <!-- 액션 -->
        <template #actions-data="{ row }">
          <div class="flex gap-2">
            <UButton
              icon="i-heroicons-pencil-square"
              size="xs"
              variant="ghost"
              color="gray"
              @click="openEditModal(row)"
            />
            <UButton
              icon="i-heroicons-trash"
              size="xs"
              variant="ghost"
              color="red"
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
          @update:model-value="fetchSpecies"
        />
      </div>
    </div>

    <!-- 생성/수정 모달 -->
    <SpeciesFormModal
      v-if="showModal"
      :species="editingSpecies"
      @close="showModal = false"
      @saved="onSaved"
    />

    <!-- 삭제 확인 -->
    <UModal v-model="showDeleteModal">
      <UCard>
        <template #header>
          <h3 class="font-semibold text-gray-900">종 삭제 확인</h3>
        </template>
        <p class="text-gray-600">
          <strong>{{ deletingSpecies?.species_kr }}</strong>을(를) 삭제하시겠습니까?<br />
          <span class="text-sm text-red-500 mt-1 block">이 작업은 되돌릴 수 없습니다.</span>
        </p>
        <template #footer>
          <div class="flex gap-3 justify-end">
            <UButton variant="outline" @click="showDeleteModal = false">취소</UButton>
            <UButton color="red" :loading="deleting" @click="deleteSpecies">삭제</UButton>
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

const search = ref('')
const loading = ref(false)
const species = ref<any[]>([])
const pagination = ref({ page: 1, limit: 20, total: 0 })

const showModal = ref(false)
const editingSpecies = ref<any>(null)
const showDeleteModal = ref(false)
const deletingSpecies = ref<any>(null)
const deleting = ref(false)

const columns = [
  { key: 'species_kr', label: '종명 (한국어)' },
  { key: 'species_en', label: '영명' },
  { key: 'genus', label: '속(Genus)' },
  { key: 'is_cites', label: 'CITES' },
  { key: 'is_whitelist', label: '백색목록' },
  { key: 'actions', label: '' },
]

async function fetchSpecies() {
  loading.value = true
  try {
    const res = await $api<any>('/admin/species', {
      query: {
        page: pagination.value.page,
        limit: pagination.value.limit,
        search: search.value || undefined,
      },
    })
    species.value = res.data
    pagination.value = { ...pagination.value, ...res.pagination }
  } catch (e) {
    toast.add({ title: '종 목록 조회 실패', color: 'red' })
  } finally {
    loading.value = false
  }
}

// 디바운스 검색
let debounceTimer: ReturnType<typeof setTimeout>
function debouncedFetch() {
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(() => {
    pagination.value.page = 1
    fetchSpecies()
  }, 400)
}

function openCreateModal() {
  editingSpecies.value = null
  showModal.value = true
}

function openEditModal(row: any) {
  editingSpecies.value = row
  showModal.value = true
}

function confirmDelete(row: any) {
  deletingSpecies.value = row
  showDeleteModal.value = true
}

async function deleteSpecies() {
  if (!deletingSpecies.value) return
  deleting.value = true
  try {
    await $api(`/admin/species/${deletingSpecies.value.id}`, { method: 'DELETE' })
    toast.add({ title: '종이 삭제되었습니다.', color: 'green' })
    showDeleteModal.value = false
    fetchSpecies()
  } catch {
    toast.add({ title: '삭제에 실패했습니다.', color: 'red' })
  } finally {
    deleting.value = false
  }
}

function onSaved() {
  showModal.value = false
  fetchSpecies()
}

onMounted(fetchSpecies)
</script>
