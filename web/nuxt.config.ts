// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },

  // SSR 비활성화 (SPA 모드)
  ssr: false,

  modules: [
    '@nuxt/ui',
    '@pinia/nuxt',
  ],

  // 런타임 환경 변수
  runtimeConfig: {
    public: {
      supabaseUrl: process.env.NUXT_PUBLIC_SUPABASE_URL || 'https://wawxltmniilnicrwvlar.supabase.co',
      supabaseAnonKey: process.env.NUXT_PUBLIC_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indhd3hsdG1uaWlsbmljcnd2bGFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzExMjY1OTcsImV4cCI6MjA4NjcwMjU5N30.sT1N78B4yHGt1nlsUnX1h8CLFJasmtd4k8MoW2MkItQ',
      apiBase: process.env.NUXT_PUBLIC_API_BASE || 'http://localhost:3000/v1',
    },
  },

  // 컬러 모드 설정
  colorMode: {
    preference: 'light',
  },

  typescript: {
    strict: true,
  },

  compatibilityDate: '2024-11-01',
})
