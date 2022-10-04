// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
const colors = require("tailwindcss/colors");
module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex',
    '../lib/app_web/live/app_live.html.heex',
    "../deps/petal_components/**/*.*ex"
  ],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        primary: colors.blue,
        secondary: colors.pink,
      },
    },
  },
  plugins: [ // https://andrewbarr.io/posts/removing-npm/show
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/aspect-ratio')  ]
}
