/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        bg: '#0B0F14',
        card: '#111827',
        border: 'rgba(255,255,255,.08)',
        muted: '#A1A1AA',
        accent: {
          DEFAULT: '#FF9900',
          bright: '#FFB84D',
        },
        blue: {
          accent: '#3B82F6',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'Menlo', 'monospace'],
      },
      boxShadow: {
        soft: '0 4px 24px -8px rgba(0,0,0,0.5)',
        'soft-lg': '0 20px 46px -16px rgba(0,0,0,0.65)',
        glow: '0 0 0 1px rgba(255,153,0,0.25), 0 16px 44px -14px rgba(255,153,0,0.25)',
      },
      borderRadius: {
        xl2: '1.25rem',
      },
      maxWidth: {
        content: '1180px',
      },
    },
  },
  plugins: [],
};
