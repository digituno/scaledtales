<template>
  <UModal v-model="open">
    <UCard>
      <template #header>
        <h3 class="font-semibold text-gray-900">{{ title }}</h3>
      </template>

      <div class="space-y-4">
        <!-- 부모 정보 표시 (생성 모드) -->
        <div v-if="!isEdit && parent" class="text-sm text-gray-500 bg-gray-50 rounded-lg p-3">
          상위 {{ parentTypeLabel }}: <strong>{{ parent.name_kr }} ({{ parent.name_en }})</strong>
        </div>

        <!-- 강 고유 필드: code -->
        <UFormGroup v-if="type === 'class'" label="코드 (고유값)" required>
          <UInput v-model="form.code" placeholder="예: REPTILIA" class="uppercase" />
        </UFormGroup>

        <div class="grid grid-cols-2 gap-4">
          <UFormGroup label="한국명" required>
            <UInput v-model="form.name_kr" :placeholder="namePlaceholder.kr" />
          </UFormGroup>
          <UFormGroup label="영명" required>
            <UInput v-model="form.name_en" :placeholder="namePlaceholder.en" />
          </UFormGroup>
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
type NodeType = 'class' | 'order' | 'family' | 'genus'

const props = defineProps<{
  type: NodeType
  parent?: any
  node?: any
}>()

const emit = defineEmits(['close', 'saved'])

const { $api } = useNuxtApp()
const toast = useToast()

const open = ref(true)
const saving = ref(false)
const isEdit = computed(() => !!props.node)

// backdrop 클릭으로 모달이 닫힐 때 부모에게 알림
watch(open, (val) => {
  if (!val) emit('close')
})

const form = reactive({ name_kr: '', name_en: '', code: '' })

const typeLabels: Record<NodeType, string> = { class: '강', order: '목', family: '과', genus: '속' }
const parentTypeLabels: Record<NodeType, string> = { class: '-', order: '강', family: '목', genus: '과' }
const endpointMap: Record<NodeType, string> = { class: 'classes', order: 'orders', family: 'families', genus: 'genera' }

const title = computed(() =>
  isEdit.value ? `${typeLabels[props.type]} 수정` : `${typeLabels[props.type]} 추가`,
)
const parentTypeLabel = computed(() => parentTypeLabels[props.type])

const namePlaceholder = computed(() => {
  const map: Record<NodeType, { kr: string; en: string }> = {
    class: { kr: '파충류', en: 'Reptilia' },
    order: { kr: '유린목', en: 'Squamata' },
    family: { kr: '비단뱀과', en: 'Pythonidae' },
    genus: { kr: '비단뱀속', en: 'Python' },
  }
  return map[props.type]
})

function buildPayload() {
  const base: any = { name_kr: form.name_kr, name_en: form.name_en }
  if (props.type === 'class') base.code = form.code.toUpperCase()
  if (props.type === 'order' && props.parent) base.classId = props.parent.id
  if (props.type === 'family' && props.parent) base.orderId = props.parent.id
  if (props.type === 'genus' && props.parent) base.familyId = props.parent.id
  return base
}

async function handleSave() {
  if (!form.name_kr || !form.name_en) {
    toast.add({ title: '이름을 입력해주세요.', color: 'orange' })
    return
  }
  if (props.type === 'class' && !form.code) {
    toast.add({ title: '코드를 입력해주세요.', color: 'orange' })
    return
  }

  saving.value = true
  try {
    const endpoint = `/admin/taxonomy/${endpointMap[props.type]}`
    if (isEdit.value) {
      await $api(`${endpoint}/${props.node.id}`, { method: 'PATCH', body: buildPayload() })
    } else {
      await $api(endpoint, { method: 'POST', body: buildPayload() })
    }
    toast.add({ title: `${typeLabels[props.type]} ${isEdit.value ? '수정' : '추가'} 완료`, color: 'green' })
    emit('saved')
  } catch (e: any) {
    toast.add({ title: '저장 실패', description: e?.data?.error?.message ?? e.message, color: 'red' })
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  if (isEdit.value && props.node) {
    form.name_kr = props.node.name_kr
    form.name_en = props.node.name_en
    form.code = props.node.code ?? ''
  }
})
</script>
