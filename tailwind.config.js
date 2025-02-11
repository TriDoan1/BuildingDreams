/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        coral: {
          500: '#F47458',
          600: '#E86346'
        },
        navy: {
          700: '#1B3B5C',
          800: '#162F49',
          900: '#112236'
        }
      },
      fontFamily: {
        sans: ['Mona Sans', 'system-ui', 'sans-serif']
      }
    },
  },
  plugins: [],
};