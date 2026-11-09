// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  // ローカルの Django API を直接呼ぶ SPA として動かす
  ssr: false,
  devtools: { enabled: false },
  app: {
    head: {
      title: 'My-Libra Web',
      htmlAttrs: { lang: 'ja' },
      meta: [{ name: 'viewport', content: 'width=device-width, initial-scale=1' }],
    },
  },
  runtimeConfig: {
    public: {
      // NUXT_PUBLIC_API_BASE で上書きできる
      apiBase: 'http://localhost:8000/api',
    },
  },
  typescript: { strict: true },
})
