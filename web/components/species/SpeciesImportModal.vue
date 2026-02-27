<template>
  <UModal v-model="open" :ui="{ width: 'sm:max-w-3xl' }" @close="$emit('close')">
    <UCard>
      <template #header>
        <div class="flex items-center gap-3">
          <UIcon name="i-heroicons-arrow-up-tray" class="w-5 h-5 text-primary-500" />
          <h3 class="font-semibold text-gray-900">CSV 종 대량 임포트</h3>
        </div>
      </template>

      <!-- 스텝 1: 파일 업로드 / 직접 입력 -->
      <div v-if="step === 'input'" class="space-y-5">
        <!-- CSV 형식 안내 -->
        <UAlert
          icon="i-heroicons-information-circle"
          color="blue"
          variant="soft"
          title="CSV 형식 안내"
        >
          <template #description>
            <div class="text-xs space-y-1 mt-1">
              <p>첫 번째 행은 헤더(건너뜀). 열 순서:</p>
              <code class="block bg-blue-50 rounded px-2 py-1 font-mono">
                genus_name, species_kr, species_en, scientific_name, common_name_kr, common_name_en, is_cites, cites_level, is_whitelist
              </code>
              <ul class="list-disc list-inside mt-1 space-y-0.5">
                <li><strong>genus_name</strong>: 속의 영명 (예: Python, Eublepharis)</li>
                <li><strong>is_cites / is_whitelist</strong>: true 또는 false</li>
                <li><strong>cites_level</strong>: APPENDIX_I / APPENDIX_II / APPENDIX_III (is_cites=true 시 필수)</li>
                <li>common_name_kr, common_name_en, cites_level은 선택 입력</li>
              </ul>
            </div>
          </template>
        </UAlert>

        <!-- 파일 업로드 -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">CSV 파일 업로드</label>
          <div
            class="border-2 border-dashed border-gray-300 rounded-xl p-6 text-center hover:border-primary-400 transition-colors cursor-pointer"
            @click="triggerFileInput"
            @dragover.prevent
            @drop.prevent="onFileDrop"
          >
            <UIcon name="i-heroicons-document-arrow-up" class="w-10 h-10 text-gray-400 mx-auto mb-2" />
            <p class="text-sm text-gray-600">CSV 파일을 여기에 드래그하거나 <span class="text-primary-500 font-medium">클릭하여 선택</span></p>
            <p v-if="fileName" class="text-xs text-primary-600 mt-2 font-medium">{{ fileName }}</p>
            <input ref="fileInput" type="file" accept=".csv,text/csv" class="hidden" @change="onFileSelect" />
          </div>
        </div>

        <!-- OR 구분선 -->
        <UDivider label="또는 직접 붙여넣기" />

        <!-- 텍스트 직접 입력 -->
        <UFormGroup label="CSV 텍스트">
          <UTextarea
            v-model="rawCsv"
            placeholder="Python,볼파이썬,Ball Python,Python regius,,,false,,true"
            :rows="8"
            class="font-mono text-xs"
          />
        </UFormGroup>

        <p class="text-xs text-gray-400">입력된 행 수: {{ previewRows.length }}행</p>
      </div>

      <!-- 스텝 2: 미리보기 -->
      <div v-else-if="step === 'preview'" class="space-y-4">
        <div class="flex items-center gap-3 mb-2">
          <UBadge :label="`총 ${previewRows.length}행`" color="blue" variant="soft" />
          <UBadge v-if="parseErrors.length" :label="`파싱 오류 ${parseErrors.length}행`" color="red" variant="soft" />
        </div>

        <!-- 파싱 오류 -->
        <div v-if="parseErrors.length" class="bg-red-50 rounded-lg p-3 text-xs text-red-700 space-y-1 max-h-24 overflow-y-auto">
          <p v-for="e in parseErrors" :key="e.row" class="font-mono">행 {{ e.row }}: {{ e.reason }}</p>
        </div>

        <!-- 미리보기 테이블 -->
        <div class="overflow-x-auto border border-gray-200 rounded-lg max-h-72 overflow-y-auto">
          <table class="min-w-full text-xs divide-y divide-gray-200">
            <thead class="bg-gray-50 sticky top-0">
              <tr>
                <th class="px-3 py-2 text-left font-medium text-gray-500">#</th>
                <th class="px-3 py-2 text-left font-medium text-gray-500">속</th>
                <th class="px-3 py-2 text-left font-medium text-gray-500">한국명</th>
                <th class="px-3 py-2 text-left font-medium text-gray-500">영명</th>
                <th class="px-3 py-2 text-left font-medium text-gray-500">학명</th>
                <th class="px-3 py-2 text-left font-medium text-gray-500">CITES</th>
                <th class="px-3 py-2 text-left font-medium text-gray-500">백색목록</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-100 bg-white">
              <tr v-for="(row, i) in previewRows" :key="i" class="hover:bg-gray-50">
                <td class="px-3 py-1.5 text-gray-400">{{ i + 1 }}</td>
                <td class="px-3 py-1.5 text-gray-700">{{ row.genus_name }}</td>
                <td class="px-3 py-1.5 text-gray-900 font-medium">{{ row.species_kr }}</td>
                <td class="px-3 py-1.5 text-gray-600">{{ row.species_en }}</td>
                <td class="px-3 py-1.5 text-gray-500 italic">{{ row.scientific_name }}</td>
                <td class="px-3 py-1.5">
                  <UBadge v-if="row.is_cites" :label="row.cites_level?.replace('APPENDIX_', 'App.') ?? 'CITES'" color="orange" variant="soft" size="xs" />
                  <span v-else class="text-gray-300">-</span>
                </td>
                <td class="px-3 py-1.5">
                  <UBadge v-if="row.is_whitelist" label="백색목록" color="green" variant="soft" size="xs" />
                  <span v-else class="text-gray-300">-</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- 스텝 3: 결과 -->
      <div v-else-if="step === 'result'" class="space-y-4">
        <div class="flex items-center gap-4">
          <div class="text-center">
            <p class="text-3xl font-bold text-green-600">{{ result?.success ?? 0 }}</p>
            <p class="text-xs text-gray-500 mt-1">성공</p>
          </div>
          <div class="text-center">
            <p class="text-3xl font-bold text-red-500">{{ result?.failed ?? 0 }}</p>
            <p class="text-xs text-gray-500 mt-1">실패</p>
          </div>
        </div>

        <div v-if="result?.errors?.length" class="bg-red-50 rounded-lg p-3 space-y-1 max-h-48 overflow-y-auto">
          <p class="text-xs font-medium text-red-700 mb-2">실패 상세:</p>
          <div v-for="e in result.errors" :key="e.row" class="text-xs text-red-600 font-mono">
            행 {{ e.row }} ({{ e.genus_name }}): {{ e.reason }}
          </div>
        </div>
      </div>

      <template #footer>
        <div class="flex gap-3 justify-between">
          <UButton v-if="step === 'preview'" variant="outline" icon="i-heroicons-arrow-left" @click="step = 'input'">
            다시 입력
          </UButton>
          <div v-else />

          <div class="flex gap-3">
            <UButton variant="outline" @click="$emit('close')">
              {{ step === 'result' ? '닫기' : '취소' }}
            </UButton>
            <UButton
              v-if="step === 'input'"
              :disabled="previewRows.length === 0"
              icon="i-heroicons-eye"
              @click="goPreview"
            >
              미리보기 ({{ previewRows.length }}행)
            </UButton>
            <UButton
              v-else-if="step === 'preview'"
              color="primary"
              :loading="importing"
              icon="i-heroicons-arrow-up-tray"
              @click="doImport"
            >
              임포트 실행
            </UButton>
            <UButton
              v-else-if="step === 'result' && result?.success"
              icon="i-heroicons-check"
              @click="$emit('saved')"
            >
              완료
            </UButton>
          </div>
        </div>
      </template>
    </UCard>
  </UModal>
</template>

<script setup lang="ts">
const emit = defineEmits(['close', 'saved'])

const { $api } = useNuxtApp()
const toast = useToast()

const open = ref(true)
const step = ref<'input' | 'preview' | 'result'>('input')
const importing = ref(false)

const fileName = ref('')
const rawCsv = ref('')
const fileInput = ref<HTMLInputElement | null>(null)

interface ParsedRow {
  genus_name: string
  species_kr: string
  species_en: string
  scientific_name: string
  common_name_kr?: string
  common_name_en?: string
  is_cites: boolean
  cites_level?: string
  is_whitelist: boolean
}

interface ParseError {
  row: number
  reason: string
}

const parseErrors = ref<ParseError[]>([])
const previewRows = ref<ParsedRow[]>([])

interface ImportResult {
  success: number
  failed: number
  errors: { row: number; genus_name: string; reason: string }[]
}

const result = ref<ImportResult | null>(null)

// backdrop close
watch(open, (val) => { if (!val) emit('close') })

function triggerFileInput() {
  fileInput.value?.click()
}

function onFileSelect(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  fileName.value = file.name
  const reader = new FileReader()
  reader.onload = (ev) => {
    rawCsv.value = ev.target?.result as string
  }
  reader.readAsText(file, 'utf-8')
}

function onFileDrop(e: DragEvent) {
  const file = e.dataTransfer?.files?.[0]
  if (!file || !file.name.endsWith('.csv')) return
  fileName.value = file.name
  const reader = new FileReader()
  reader.onload = (ev) => {
    rawCsv.value = ev.target?.result as string
  }
  reader.readAsText(file, 'utf-8')
}

// CSV 파싱
function parseCsv(text: string): void {
  const lines = text.trim().split(/\r?\n/).filter((l) => l.trim())
  parseErrors.value = []
  previewRows.value = []

  // 첫 행이 헤더인지 확인 (genus_name 또는 속 으로 시작하면 헤더)
  let startIdx = 0
  if (lines[0]?.toLowerCase().includes('genus') || lines[0]?.toLowerCase().includes('속')) {
    startIdx = 1
  }

  for (let i = startIdx; i < lines.length; i++) {
    const cols = lines[i].split(',').map((c) => c.trim().replace(/^"|"$/g, ''))
    if (cols.length < 4) {
      parseErrors.value.push({ row: i + 1, reason: `열 수 부족 (${cols.length}개)` })
      continue
    }

    const [genus_name, species_kr, species_en, scientific_name, common_name_kr, common_name_en, is_cites_str, cites_level, is_whitelist_str] = cols

    if (!genus_name || !species_kr || !species_en || !scientific_name) {
      parseErrors.value.push({ row: i + 1, reason: '필수 열(속명, 한국명, 영명, 학명) 누락' })
      continue
    }

    const is_cites = is_cites_str?.toLowerCase() === 'true'
    const is_whitelist = is_whitelist_str?.toLowerCase() === 'true'

    const parsedCitesLevel = cites_level?.trim() || undefined
    if (is_cites && !parsedCitesLevel) {
      parseErrors.value.push({ row: i + 1, reason: 'is_cites=true이지만 cites_level 누락' })
      continue
    }

    previewRows.value.push({
      genus_name,
      species_kr,
      species_en,
      scientific_name,
      common_name_kr: common_name_kr || undefined,
      common_name_en: common_name_en || undefined,
      is_cites,
      cites_level: is_cites ? parsedCitesLevel : undefined,
      is_whitelist,
    })
  }
}

// rawCsv 변경 시 파싱
watch(rawCsv, (val) => {
  if (val.trim()) parseCsv(val)
  else {
    previewRows.value = []
    parseErrors.value = []
  }
})

function goPreview() {
  if (previewRows.value.length === 0) {
    toast.add({ title: 'CSV 데이터가 없습니다.', color: 'orange' })
    return
  }
  step.value = 'preview'
}

async function doImport() {
  if (previewRows.value.length === 0) return
  importing.value = true
  try {
    const res = await $api<{ success: boolean; data: ImportResult }>('/admin/species/bulk-import', {
      method: 'POST',
      body: { rows: previewRows.value },
    })
    result.value = res.data
    step.value = 'result'
    if (res.data.success > 0) {
      toast.add({ title: `${res.data.success}개 종을 임포트했습니다.`, color: 'green' })
    }
  } catch (e: any) {
    toast.add({ title: '임포트 실패', description: e?.data?.error?.message ?? e.message, color: 'red' })
  } finally {
    importing.value = false
  }
}
</script>
