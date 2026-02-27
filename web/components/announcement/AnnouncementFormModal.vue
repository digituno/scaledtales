<template>
  <UModal v-model="open" :ui="{ width: 'sm:max-w-2xl' }">
    <UCard>
      <template #header>
        <h3 class="font-semibold text-gray-900">
          {{ isEdit ? '공지사항 수정' : '공지사항 등록' }}
        </h3>
      </template>

      <div class="space-y-5">
        <!-- 제목 -->
        <UFormGroup label="제목" required>
          <UInput
            v-model="form.title"
            placeholder="공지사항 제목을 입력하세요"
            :maxlength="200"
          />
        </UFormGroup>

        <!-- 내용 -->
        <UFormGroup label="내용" required>
          <UTextarea
            v-model="form.content"
            placeholder="공지사항 내용을 입력하세요"
            :rows="6"
          />
        </UFormGroup>

        <!-- 공지 기간 -->
        <div class="grid grid-cols-2 gap-4">
          <UFormGroup label="시작 일시" required>
            <UInput
              v-model="form.start_at"
              type="datetime-local"
            />
          </UFormGroup>
          <UFormGroup label="종료 일시" required>
            <UInput
              v-model="form.end_at"
              type="datetime-local"
            />
          </UFormGroup>
        </div>
      </div>

      <template #footer>
        <div class="flex gap-3 justify-end">
          <UButton variant="outline" @click="open = false">취소</UButton>
          <UButton :loading="saving" @click="submit">저장</UButton>
        </div>
      </template>
    </UCard>
  </UModal>
</template>

<script setup lang="ts">
interface Announcement {
  id?: string
  title: string
  content: string
  start_at: string
  end_at: string
  is_deleted?: boolean
}

const props = defineProps<{
  announcement?: Announcement | null
}>()

const emit = defineEmits<{
  close: []
  saved: []
}>()

const { $api } = useNuxtApp()
const toast = useToast()

const open = defineModel<boolean>('open', { default: false })

watch(open, (val) => {
  if (!val) emit('close')
})

const isEdit = computed(() => !!props.announcement?.id)

const form = reactive({
  title: '',
  content: '',
  start_at: '',
  end_at: '',
})

// 편집 모드 진입 시 데이터 채우기
watch(
  () => props.announcement,
  (val) => {
    if (val) {
      form.title = val.title
      form.content = val.content
      form.start_at = val.start_at ? toLocalDatetimeInput(val.start_at) : ''
      form.end_at = val.end_at ? toLocalDatetimeInput(val.end_at) : ''
    } else {
      form.title = ''
      form.content = ''
      form.start_at = ''
      form.end_at = ''
    }
  },
  { immediate: true },
)

function toLocalDatetimeInput(iso: string): string {
  const d = new Date(iso)
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`
}

const saving = ref(false)

async function submit() {
  if (!form.title.trim() || !form.content.trim() || !form.start_at || !form.end_at) {
    toast.add({ title: '필수 항목을 모두 입력해주세요', color: 'red' })
    return
  }

  saving.value = true
  try {
    const payload = {
      title: form.title.trim(),
      content: form.content.trim(),
      start_at: new Date(form.start_at).toISOString(),
      end_at: new Date(form.end_at).toISOString(),
    }

    if (isEdit.value) {
      await $api(`/admin/announcements/${props.announcement!.id}`, {
        method: 'PATCH',
        body: payload,
      })
      toast.add({ title: '공지사항이 수정되었습니다', color: 'green' })
    } else {
      await $api('/admin/announcements', {
        method: 'POST',
        body: payload,
      })
      toast.add({ title: '공지사항이 등록되었습니다', color: 'green' })
    }

    emit('saved')
    open.value = false
  } catch {
    toast.add({ title: '저장에 실패했습니다', color: 'red' })
  } finally {
    saving.value = false
  }
}
</script>
