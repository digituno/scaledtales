<template>
  <div>
    <NuxtLayout name="blank">
      <div class="w-full max-w-md">
        <div class="bg-white rounded-2xl shadow-lg p-8">
          <!-- 로고 -->
          <div class="text-center mb-8">
            <div class="text-4xl mb-3">🦎</div>
            <h1 class="text-2xl font-bold text-gray-900">ScaledTales</h1>
            <p class="text-sm text-gray-500 mt-1">관리자 콘솔</p>
          </div>

          <!-- 에러 메시지 -->
          <UAlert
            v-if="errorMessage"
            icon="i-heroicons-exclamation-triangle"
            color="red"
            variant="soft"
            :title="errorMessage"
            class="mb-6"
          />

          <!-- 로그인 폼 -->
          <UForm :state="form" class="space-y-4" @submit="handleSubmit">
            <UFormGroup label="이메일" name="email">
              <UInput
                v-model="form.email"
                type="email"
                placeholder="admin@example.com"
                size="lg"
                :disabled="loading"
              />
            </UFormGroup>

            <UFormGroup label="비밀번호" name="password">
              <UInput
                v-model="form.password"
                type="password"
                placeholder="비밀번호 입력"
                size="lg"
                :disabled="loading"
              />
            </UFormGroup>

            <UButton
              type="submit"
              block
              size="lg"
              :loading="loading"
              class="mt-6"
            >
              로그인
            </UButton>
          </UForm>
        </div>
      </div>
    </NuxtLayout>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: false })

const authStore = useAuthStore()
const router = useRouter()
const route = useRoute()

const form = reactive({ email: '', password: '' })
const loading = ref(false)
const errorMessage = ref('')

// forbidden 에러 표시
if (route.query.error === 'forbidden') {
  errorMessage.value = '관리자 권한이 없습니다.'
}

async function handleSubmit() {
  errorMessage.value = ''
  loading.value = true
  try {
    await authStore.signInWithEmail(form.email, form.password)
    if (!authStore.isAdmin) {
      await authStore.signOut()
      errorMessage.value = '관리자 권한이 없는 계정입니다.'
      return
    }
    router.push('/dashboard')
  } catch (err: any) {
    errorMessage.value = err?.message ?? '로그인에 실패했습니다.'
  } finally {
    loading.value = false
  }
}
</script>
