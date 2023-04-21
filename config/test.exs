import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :app, App.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "app_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :app, AppWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base:
    "aEkLhne04vW3X5PM63O85Ie57c+KoT1z5bl0TdtBE1veN8BbER7MpOgZ6FgD7dWu",
  # github.com/dwyl/mvp/issues/359
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Don't worry, this AUTH_API_KEY is NOT valid.
# It's just for ensuring it passes on GitHub CI
# see: github.com/dwyl/mvp/issues/258
config :auth_plug,
  api_key:
    "2PzB7PPnpuLsbWmWtXpGyI+kfSQSQ1zUW2Atz/+8PdZuSEJzHgzGnJWV35nTKRwx/authdemo.fly.dev"
