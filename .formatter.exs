[
  import_deps: [:ecto, :phoenix],
  subdirectories: ["priv/*/migrations"],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: [
    "*.{heex,ex,exs}",
    "{config,lib}/**/*.{heex,ex,exs}",
    "priv/*/seeds.exs"
  ],
  line_length: 80
]
