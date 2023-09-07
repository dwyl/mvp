defmodule App.MixProject do
  use Mix.Project

  def project do
    [
      app: :app,
      version: "1.0.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        c: :test,
        coveralls: :test,
        "coveralls.json": :test,
        "coveralls.html": :test,
        t: :test
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
      # Phoenix deps:
      {:phoenix, "~> 1.7.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.18.3"},
      {:phoenix_view, "~> 2.0"},
      {:floki, ">= 0.30.0", only: :test},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},

      # Auth with ONE Environment Variable™: github.com/dwyl/auth_plug
      {:auth_plug, "~> 1.5.1"},

      # Check/get Environment Variables: github.com/dwyl/envar
      {:envar, "~> 1.1.0", override: true},

      # Universally Unique Deterministic Content IDs: github.com/dwyl/cid
      {:excid, "~> 1.0.1"},

      # Easily Encrypt Sensitive Data: github.com/dwyl/fields
      {:fields, "~> 2.10.3"},

      # Database changes tracking:
      # github.com/dwyl/phoenix-papertrail-demo
      {:paper_trail, "~> 1.0.0"},

      # Time string parsing: github.com/bitwalker/timex
      {:timex, "~> 3.7"},

      # Useful functions: github.com/dwyl/useful
      {:useful, "~> 1.12.1", override: true},

      # See: github.com/dwyl/useful/issues/17
      {:atomic_map, "~> 0.9.3"},

      # Decimal precision: github.com/ericmj/decimal
      {:decimal, "~> 2.0"},

      # Statuses: github.com/dwyl/statuses
      {:statuses, "~> 1.1.1"},

      # create docs on localhost by running "mix docs"
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      # Track test coverage: github.com/parroty/excoveralls
      {:excoveralls, "~> 0.15", only: [:test, :dev]},

      # Git pre-commit hook runs tests before allowing commits:
      # github.com/dwyl/elixir-pre-commit
      {:pre_commit, "~> 0.3.4", only: :dev},
      {:credo, "~> 1.7.0", only: [:dev, :test], runtime: false},

      # Ref: github.com/dwyl/learn-tailwind
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},
      {:petal_components, "~> 1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      seeds: ["run priv/repo/seeds.exs"],
      setup: ["deps.get", "ecto.reset", "tailwind.install"],
      "ecto.setup": [
        "ecto.create --quiet",
        "ecto.migrate --quiet",
        "run priv/repo/seeds.exs"
      ],
      "ecto.reset": ["ecto.drop --quiet", "ecto.setup"],
      "assets.deploy": [
        "tailwind default --minify",
        "esbuild default --minify",
        "phx.digest"
      ],
      test: ["ecto.reset", "test"],
      t: ["test"],
      c: ["coveralls.html"],
      s: ["phx.server"]
    ]
  end
end
