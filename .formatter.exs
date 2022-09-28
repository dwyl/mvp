[
  import_deps: [:ecto, :phoenix],
  inputs: [
    "*.{heex,ex,exs}",
    "priv/*/seeds.exs",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  subdirectories: ["priv/*/migrations"],
  line_length: 80
]
