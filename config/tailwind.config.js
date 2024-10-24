const colors = require('tailwindcss/colors')
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './app/models/form_builders/tailwind_form_builder.rb',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          '50': '#F2FBFF',
          '100': '#E6F7FF',
          '200': '#BFE8FF',
          '300': '#99D5FF',
          '400': '#4DA6FF',
          '500': '#0069ff',
          '600': '#005CE6',
          '700': '#0046BF',
          '800': '#003399',
          '900': '#002273',
          '950': '#00144A'
        },
      },
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
