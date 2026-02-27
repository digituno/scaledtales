<template>
  <UModal v-model="open" :ui="{ width: 'sm:max-w-2xl' }">
    <UCard>
      <template #header>
        <h3 class="font-semibold text-gray-900">
          {{ isEdit ? '종 수정' : '종 추가' }}
        </h3>
      </template>

      <div class="space-y-5">
        <!-- 분류 계층 선택 -->
        <div class="grid grid-cols-2 gap-4">
          <!-- 강 선택 -->
          <UFormGroup label="강 (Class)">
            <USelect
              v-model="selectedClassId"
              :options="classOptions"
              option-attribute="label"
              value-attribute="value"
              placeholder="강 선택"
              @change="onClassChange"
            />
          </UFormGroup>

          <!-- 목 선택 -->
          <UFormGroup label="목 (Order)">
            <USelect
              v-model="selectedOrderId"
              :options="orderOptions"
              option-attribute="label"
              value-attribute="value"
              placeholder="목 선택"
              :disabled="!selectedClassId"
              @change="onOrderChange"
            />
          </UFormGroup>

          <!-- 과 선택 -->
          <UFormGroup label="과 (Family)">
            <USelect
              v-model="selectedFamilyId"
              :options="familyOptions"
              option-attribute="label"
              value-attribute="value"
              placeholder="과 선택"
              :disabled="!selectedOrderId"
              @change="onFamilyChange"
            />
          </UFormGroup>

          <!-- 속 선택 (필수) -->
          <UFormGroup label="속 (Genus)" required>
            <USelect
              v-model="form.genusId"
              :options="genusOptions"
              option-attribute="label"
              value-attribute="value"
              placeholder="속 선택"
              :disabled="!selectedFamilyId"
            />
          </UFormGroup>
        </div>

        <UDivider />

        <!-- 종명 -->
        <div class="grid grid-cols-2 gap-4">
          <UFormGroup label="한국명" required>
            <UInput v-model="form.species_kr" placeholder="예: 볼파이썬" />
          </UFormGroup>
          <UFormGroup label="영명" required>
            <UInput v-model="form.species_en" placeholder="예: Ball Python" />
          </UFormGroup>
          <UFormGroup label="학명" required class="col-span-2">
            <UInput v-model="form.scientific_name" placeholder="예: Python regius" />
          </UFormGroup>
          <UFormGroup label="일반명 (한국어)">
            <UInput v-model="form.common_name_kr" placeholder="선택 입력" />
          </UFormGroup>
          <UFormGroup label="일반명 (영어)">
            <UInput v-model="form.common_name_en" placeholder="선택 입력" />
          </UFormGroup>
        </div>

        <UDivider />

        <!-- CITES / 백색목록 -->
        <div class="space-y-3">
          <div class="flex items-center gap-3">
            <UToggle v-model="form.is_cites" />
            <span class="text-sm font-medium text-gray-700">CITES 등재</span>
          </div>
          <div v-if="form.is_cites" class="ml-10">
            <UFormGroup label="CITES 부속서 등급" required>
              <USelect
                v-model="form.cites_level"
                :options="citesOptions"
                option-attribute="label"
                value-attribute="value"
              />
            </UFormGroup>
          </div>
          <div class="flex items-center gap-3">
            <UToggle v-model="form.is_whitelist" />
            <span class="text-sm font-medium text-gray-700">백색목록 등재</span>
          </div>
        </div>
      </div>

      <template #footer>
        <div class="flex gap-3 justify-end">
          <UButton variant="outline" @click="$emit('close')">취소</UButton>
          <UButton :loading="saving" @click="handleSave">
            {{ isEdit ? '수정' : '추가' }}
          </UButton>
        </div>
      </template>
    </UCard>
  </UModal>
</template>

<script setup lang="ts">
const props = defineProps<{
  species?: any
}>()

const emit = defineEmits(['close', 'saved'])

const { $api } = useNuxtApp()
const toast = useToast()

const open = ref(true)
const saving = ref(false)
const isEdit = computed(() => !!props.species)

// backdrop 클릭으로 모달이 닫힐 때 부모에게 알림
watch(open, (val) => {
  if (!val) emit('close')
})

// 분류 계층 데이터
const taxonomyTree = ref<any[]>([])
const selectedClassId = ref('')
const selectedOrderId = ref('')
const selectedFamilyId = ref('')

const form = reactive({
  genusId: '',
  species_kr: '',
  species_en: '',
  scientific_name: '',
  common_name_kr: '',
  common_name_en: '',
  is_cites: false,
  cites_level: 'APPENDIX_I',
  is_whitelist: false,
})

const citesOptions = [
  { label: '부속서 I', value: 'APPENDIX_I' },
  { label: '부속서 II', value: 'APPENDIX_II' },
  { label: '부속서 III', value: 'APPENDIX_III' },
]

const classOptions = computed(() =>
  taxonomyTree.value.map((c: any) => ({ label: `${c.name_kr} (${c.name_en})`, value: c.id })),
)

const orderOptions = computed(() => {
  if (!selectedClassId.value) return []
  const cls = taxonomyTree.value.find((c: any) => c.id === selectedClassId.value)
  return (cls?.orders ?? []).map((o: any) => ({ label: `${o.name_kr} (${o.name_en})`, value: o.id }))
})

const familyOptions = computed(() => {
  if (!selectedOrderId.value) return []
  const cls = taxonomyTree.value.find((c: any) => c.id === selectedClassId.value)
  const order = (cls?.orders ?? []).find((o: any) => o.id === selectedOrderId.value)
  return (order?.families ?? []).map((f: any) => ({ label: `${f.name_kr} (${f.name_en})`, value: f.id }))
})

const genusOptions = computed(() => {
  if (!selectedFamilyId.value) return []
  const cls = taxonomyTree.value.find((c: any) => c.id === selectedClassId.value)
  const order = (cls?.orders ?? []).find((o: any) => o.id === selectedOrderId.value)
  const family = (order?.families ?? []).find((f: any) => f.id === selectedFamilyId.value)
  return (family?.genera ?? []).map((g: any) => ({ label: `${g.name_kr} (${g.name_en})`, value: g.id }))
})

function onClassChange() {
  selectedOrderId.value = ''
  selectedFamilyId.value = ''
  form.genusId = ''
}

function onOrderChange() {
  selectedFamilyId.value = ''
  form.genusId = ''
}

function onFamilyChange() {
  form.genusId = ''
}

async function loadTaxonomyTree() {
  try {
    const res = await $api<any>('/admin/taxonomy/tree')
    taxonomyTree.value = res.data
  } catch {
    toast.add({ title: '분류 트리 로딩 실패', color: 'red' })
  }
}

// 편집 모드 초기화
function initEditMode() {
  if (!props.species) return
  const s = props.species
  form.species_kr = s.species_kr
  form.species_en = s.species_en
  form.scientific_name = s.scientific_name
  form.common_name_kr = s.common_name_kr ?? ''
  form.common_name_en = s.common_name_en ?? ''
  form.is_cites = s.is_cites
  form.cites_level = s.cites_level ?? 'APPENDIX_I'
  form.is_whitelist = s.is_whitelist
  form.genusId = s.genusId

  // 분류 계층 역추적
  if (s.genus) {
    const genus = s.genus
    const family = genus?.family
    const order = family?.order
    const cls = order?.taxonomyClass
    if (cls) selectedClassId.value = cls.id
    if (order) selectedOrderId.value = order.id
    if (family) selectedFamilyId.value = family.id
  }
}

async function handleSave() {
  if (!form.genusId || !form.species_kr || !form.species_en || !form.scientific_name) {
    toast.add({ title: '필수 항목을 모두 입력해주세요.', color: 'orange' })
    return
  }

  saving.value = true
  try {
    const payload = {
      ...form,
      cites_level: form.is_cites ? form.cites_level : undefined,
    }

    if (isEdit.value) {
      await $api(`/admin/species/${props.species.id}`, {
        method: 'PATCH',
        body: payload,
      })
      toast.add({ title: '종이 수정되었습니다.', color: 'green' })
    } else {
      await $api('/admin/species', {
        method: 'POST',
        body: payload,
      })
      toast.add({ title: '종이 추가되었습니다.', color: 'green' })
    }
    emit('saved')
  } catch (e: any) {
    toast.add({ title: '저장 실패', description: e?.data?.error?.message ?? e.message, color: 'red' })
  } finally {
    saving.value = false
  }
}

onMounted(async () => {
  await loadTaxonomyTree()
  if (isEdit.value) initEditMode()
})
</script>
