import Config

config :app,
  ecto_repos: [App.Repo],
  # rickaard.se/blog/how-to-only-run-some-code-in-production-with-phoenix-and-elixir
  env: config_env()

# Configures the endpoint
config :app, AppWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: AppWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: App.PubSub,
  live_view: [signing_salt: "IJG3BS8I"],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Configure PaperTrail
config :paper_trail, repo: App.Repo

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# https://hexdocs.pm/joken/introduction.html#usage
config :joken, default_signer: System.get_env("SECRET_KEY_BASE")

# https://github.com/dwyl/auth_plug
config :auth_plug,
  api_key: System.get_env("AUTH_API_KEY")

# https://github.com/dwyl/cid#how
config :excid, base: :base58
