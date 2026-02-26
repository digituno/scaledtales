<template>
  <div>
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">분류 트리 관리</h1>
        <p class="text-gray-500 mt-1">강 → 목 → 과 → 속 계층 구조를 관리합니다</p>
      </div>
      <UButton icon="i-heroicons-plus" @click="openCreateModal('class', null)">
        강(Class) 추가
      </UButton>
    </div>

    <!-- 로딩 -->
    <div v-if="loading" class="space-y-3">
      <div v-for="n in 3" :key="n" class="bg-white rounded-xl p-4 shadow-sm animate-pulse">
        <div class="h-4 bg-gray-200 rounded w-1/4" />
      </div>
    </div>

    <!-- 트리 -->
    <div v-else class="space-y-4">
      <div
        v-for="cls in tree"
        :key="cls.id"
        class="bg-white rounded-xl shadow-sm overflow-hidden"
      >
        <!-- 강 헤더 -->
        <div class="flex items-center justify-between px-5 py-4 border-b border-gray-100 bg-gray-50">
          <div class="flex items-center gap-3">
            <UButton
              variant="ghost"
              :icon="expandedClasses.has(cls.id) ? 'i-heroicons-chevron-down' : 'i-heroicons-chevron-right'"
              size="xs"
              color="gray"
              @click="toggleClass(cls.id)"
            />
            <span class="font-semibold text-gray-900">{{ cls.name_kr }}</span>
            <span class="text-sm text-gray-500">({{ cls.name_en }})</span>
            <UBadge :label="cls.code" color="gray" variant="soft" size="xs" />
          </div>
          <div class="flex gap-2">
            <UButton size="xs" variant="soft" icon="i-heroicons-plus" @click.stop="openCreateModal('order', cls)">
              목 추가
            </UButton>
            <UButton size="xs" variant="ghost" color="gray" icon="i-heroicons-pencil-square" @click.stop="openEditModal('class', cls)" />
            <UButton size="xs" variant="ghost" color="red" icon="i-heroicons-trash" @click.stop="confirmDelete('class', cls)" />
          </div>
        </div>

        <!-- 목 목록 -->
        <div v-if="expandedClasses.has(cls.id)">
          <div
            v-for="order in cls.orders"
            :key="order.id"
            class="border-b border-gray-50 last:border-b-0"
          >
            <!-- 목 -->
            <div class="flex items-center justify-between pl-10 pr-5 py-3 hover:bg-gray-50">
              <div class="flex items-center gap-3">
                <UButton
                  variant="ghost"
                  :icon="expandedOrders.has(order.id) ? 'i-heroicons-chevron-down' : 'i-heroicons-chevron-right'"
                  size="xs"
                  color="gray"
                  @click="toggleOrder(order.id)"
                />
                <span class="font-medium text-gray-800">{{ order.name_kr }}</span>
                <span class="text-sm text-gray-500">({{ order.name_en }})</span>
              </div>
              <div class="flex gap-2">
                <UButton size="xs" variant="soft" icon="i-heroicons-plus" @click.stop="openCreateModal('family', order)">
                  과 추가
                </UButton>
                <UButton size="xs" variant="ghost" color="gray" icon="i-heroicons-pencil-square" @click.stop="openEditModal('order', order)" />
                <UButton size="xs" variant="ghost" color="red" icon="i-heroicons-trash" @click.stop="confirmDelete('order', order)" />
              </div>
            </div>

            <!-- 과 목록 -->
            <div v-if="expandedOrders.has(order.id)">
              <div
                v-for="family in order.families"
                :key="family.id"
                class="border-b border-gray-50 last:border-b-0"
              >
                <!-- 과 -->
                <div class="flex items-center justify-between pl-20 pr-5 py-2 hover:bg-gray-50">
                  <div class="flex items-center gap-3">
                    <UButton
                      variant="ghost"
                      :icon="expandedFamilies.has(family.id) ? 'i-heroicons-chevron-down' : 'i-heroicons-chevron-right'"
                      size="xs"
                      color="gray"
                      @click="toggleFamily(family.id)"
                    />
                    <span class="text-gray-800">{{ family.name_kr }}</span>
                    <span class="text-sm text-gray-400">({{ family.name_en }})</span>
                  </div>
                  <div class="flex gap-2">
                    <UButton size="xs" variant="soft" icon="i-heroicons-plus" @click.stop="openCreateModal('genus', family)">
                      속 추가
                    </UButton>
                    <UButton size="xs" variant="ghost" color="gray" icon="i-heroicons-pencil-square" @click.stop="openEditModal('family', family)" />
                    <UButton size="xs" variant="ghost" color="red" icon="i-heroicons-trash" @click.stop="confirmDelete('family', family)" />
                  </div>
                </div>

                <!-- 속 목록 -->
                <div v-if="expandedFamilies.has(family.id)" class="pl-28 pr-5 py-2 space-y-1">
                  <div
                    v-for="genus in family.genera"
                    :key="genus.id"
                    class="flex items-center justify-between py-1.5 px-3 rounded-lg hover:bg-gray-50"
                  >
                    <div>
                      <span class="text-sm text-gray-700">{{ genus.name_kr }}</span>
                      <span class="text-xs text-gray-400 ml-2">({{ genus.name_en }})</span>
                    </div>
                    <div class="flex gap-1">
                      <UButton size="xs" variant="ghost" color="gray" icon="i-heroicons-pencil-square" @click.stop="openEditModal('genus', genus)" />
                      <UButton size="xs" variant="ghost" color="red" icon="i-heroicons-trash" @click.stop="confirmDelete('genus', genus)" />
                    </div>
                  </div>
                  <div v-if="!family.genera?.length" class="text-xs text-gray-400 py-1">속 없음</div>
                </div>
              </div>
              <div v-if="!order.families?.length" class="pl-20 pr-5 py-2 text-xs text-gray-400">과 없음</div>
            </div>
          </div>
          <div v-if="!cls.orders?.length" class="pl-10 pr-5 py-3 text-xs text-gray-400">목 없음</div>
        </div>
      </div>

      <div v-if="!tree.length && !loading" class="text-center py-12 text-gray-400">
        분류 데이터가 없습니다. 강(Class)을 먼저 추가해주세요.
      </div>
    </div>

    <!-- 생성/수정 모달 -->
    <TaxonomyNodeModal
      v-if="showModal"
      :type="modalType"
      :parent="modalParent"
      :node="editingNode"
      @close="showModal = false"
      @saved="onSaved"
    />

    <!-- 삭제 확인 -->
    <UModal v-model="showDeleteModal">
      <UCard>
        <template #header>
          <h3 class="font-semibold text-gray-900">삭제 확인</h3>
        </template>
        <p class="text-gray-600">
          <strong>{{ deletingNode?.name_kr }}</strong> ({{ typeLabel(deletingType) }})을(를) 삭제하시겠습니까?<br />
          <span class="text-sm text-red-500 mt-1 block">하위 항목이 있으면 함께 삭제됩니다.</span>
        </p>
        <template #footer>
          <div class="flex gap-3 justify-end">
            <UButton variant="outline" @click="showDeleteModal = false">취소</UButton>
            <UButton color="red" :loading="deleting" @click="doDelete">삭제</UButton>
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

type NodeType = 'class' | 'order' | 'family' | 'genus'

const loading = ref(false)
const tree = ref<any[]>([])

const expandedClasses = ref(new Set<string>())
const expandedOrders = ref(new Set<string>())
const expandedFamilies = ref(new Set<string>())

const showModal = ref(false)
const modalType = ref<NodeType>('class')
const modalParent = ref<any>(null)
const editingNode = ref<any>(null)

const showDeleteModal = ref(false)
const deletingType = ref<NodeType>('class')
const deletingNode = ref<any>(null)
const deleting = ref(false)

function toggleClass(id: string) {
  if (expandedClasses.value.has(id)) expandedClasses.value.delete(id)
  else expandedClasses.value.add(id)
}

function toggleOrder(id: string) {
  if (expandedOrders.value.has(id)) expandedOrders.value.delete(id)
  else expandedOrders.value.add(id)
}

function toggleFamily(id: string) {
  if (expandedFamilies.value.has(id)) expandedFamilies.value.delete(id)
  else expandedFamilies.value.add(id)
}

async function loadTree() {
  loading.value = true
  try {
    const res = await $api<any>('/admin/taxonomy/tree')
    tree.value = res.data
  } catch {
    toast.add({ title: '분류 트리 로딩 실패', color: 'red' })
  } finally {
    loading.value = false
  }
}

function openCreateModal(type: NodeType, parent: any) {
  modalType.value = type
  modalParent.value = parent
  editingNode.value = null
  showModal.value = true
}

function openEditModal(type: NodeType, node: any) {
  modalType.value = type
  modalParent.value = null
  editingNode.value = node
  showModal.value = true
}

function confirmDelete(type: NodeType, node: any) {
  deletingType.value = type
  deletingNode.value = node
  showDeleteModal.value = true
}

const endpointMap: Record<NodeType, string> = {
  class: 'classes',
  order: 'orders',
  family: 'families',
  genus: 'genera',
}

async function doDelete() {
  if (!deletingNode.value) return
  deleting.value = true
  try {
    await $api(`/admin/taxonomy/${endpointMap[deletingType.value]}/${deletingNode.value.id}`, {
      method: 'DELETE',
    })
    toast.add({ title: '삭제되었습니다.', color: 'green' })
    showDeleteModal.value = false
    loadTree()
  } catch {
    toast.add({ title: '삭제에 실패했습니다.', color: 'red' })
  } finally {
    deleting.value = false
  }
}

function typeLabel(type: NodeType): string {
  const map: Record<NodeType, string> = { class: '강', order: '목', family: '과', genus: '속' }
  return map[type]
}

function onSaved() {
  showModal.value = false
  loadTree()
}

onMounted(loadTree)
</script>
