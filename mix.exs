defmodule App.MixProject do
  use Mix.Project

  def project do
    [
      app: :app,
      version: "1.0.3",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        c: :test,
        coveralls: :test,
        "coveralls.json": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {App.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.5"},
      {:phoenix_pubsub, "~> 2.0.0"},
      {:phoenix_ecto, "~> 4.2.1"},
      {:ecto_sql, "~> 3.4.5"},
      {:postgrex, ">= 0.15.6"},
      {:phoenix_html, "~> 2.14.2"},
      {:phoenix_live_reload, "~> 1.2.4", only: :dev},
      {:gettext, "~> 0.18.2"},
      {:jason, "~> 1.2.2"},
      {:plug_cowboy, "~> 2.3.0"},

      # Easily Encrypt Senstive Data: github.com/dwyl/fields
      {:fields, "~> 2.7.1"},
      # Auth with ONE Environment Variable: github.com/dwyl/auth_plug
      {:auth_plug, "~> 1.2.3"},

      # create docs on localhost by running "mix docs"
      {:ex_doc, "~> 0.22.6", only: :dev, runtime: false},
      # track test coverage
      {:excoveralls, "~> 0.13.2", only: [:test, :dev]},
      # git pre-commit hook runs tests before allowing commits
      {:pre_commit, "~> 0.3.4"},
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      # cors #56
      {:cors_plug, "~> 2.0.2"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create --quiet", "ecto.migrate --quiet", "seeds"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      seeds: ["run priv/repo/seeds.exs"],
      test: ["ecto.reset", "test"],
      c: ["coveralls.html"]
    ]
  end
end
