// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex',
    '../lib/app_web/live/app_live.html.heex'
  ],
  theme: {
    extend: {},
  },
  plugins: [ // https://andrewbarr.io/posts/removing-npm/show
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/aspect-ratio')  ]
}
