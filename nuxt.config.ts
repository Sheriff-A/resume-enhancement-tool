import tailwindcss from '@tailwindcss/vite';

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  modules: [
    '@nuxt/eslint',
    '@nuxt/ui',
    '@pinia/nuxt',
    '@nuxtjs/supabase',
    'nuxt-security',
    '@nuxt/image',
    '@vueuse/nuxt',
  ],
  devtools: {
    enabled: true,

    timeline: {
      enabled: true,
    },
  },
  app: {
    head: {
      // title: 'Job Board',
      meta: [
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { charset: 'utf-8' },
        // { name: 'description', content: 'AI-powered future trading assistant' },
        { name: 'theme-color', content: '#ffffff' },
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
        { rel: 'apple-touch-icon', href: '/apple-touch-icon.png' },
      ],
    },
  },
  css: ['~/assets/css/main.css'],
  ui: {
    theme: {
      colors: [
        'driftwood',
        'sunset',
        'primary',
        'secondary',
        'accent',
        'neutral',
        'info',
        'success',
        'warning',
        'error',
      ],
    },
  },
  runtimeConfig: {
    openaiApiKey: process.env.OPENAI_API_KEY,
  },
  build: {
    transpile: ['html2canvas-pro', 'jspdf'],
  },
  routeRules: {
    '/test/**': {
      ssr: false,
    },
    '/api/process_resume': {
      security: {
        enabled: false,
      },
    },
    '/api/openai/**': {
      security: {
        rateLimiter: {
          tokensPerInterval: 5,
          // 5 requests per hour
          interval: 5 * 60 * 60 * 1000,
        },
      },
    },
  },
  compatibilityDate: '2024-11-01',
  vite: {
    optimizeDeps: {
      include: ['pinia', 'zod'],
      // exclude: ['jspdf']
    },
    plugins: [tailwindcss()],
  },
  eslint: {
    config: {
      stylistic: true,
    },
  },
  icon: {
    clientBundle: {
      scan: true,
      sizeLimitKb: 256,
    },
  },
  image: {
    domains: ['*'],
    presets: {
      avatar: {
        modifiers: {
          // format: 'jpg',
          width: 50,
          height: 50,
        },
      },
    },
  },
  security: {
    headers: {
      permissionsPolicy: {
        geolocation: ['self'],
      },
    },
  },
  // ssr: false,
  supabase: {
    // Options
    types: '~/models/supabase/database.types.ts',
    redirect: false,
  },
});
