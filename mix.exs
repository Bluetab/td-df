defmodule TdDf.Mixfile do
  use Mix.Project

  def project do
    [
      app: :td_df,
      version:
        case System.get_env("APP_VERSION") do
          nil -> "6.9.0-local"
          v -> v
        end,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers() ++ [:phoenix_swagger],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [
        td_df: [
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent],
          steps: [:assemble, &copy_bin_files/1, :tar]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {TdDf.Application, []},
      extra_applications: [:logger, :runtime_tools, :td_cache]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp copy_bin_files(release) do
    File.cp_r("rel/bin", Path.join(release.path, "bin"))
    release
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:assertions, "~> 0.10", only: :test},
      {:phoenix, "~> 1.6.0"},
      {:plug_cowboy, "~> 2.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.10"},
      {:jason, "~> 1.1"},
      {:postgrex, "~> 0.16.3"},
      {:gettext, "~> 0.20"},
      {:httpoison, "~> 1.6"},
      {:quantum, "~> 3.0"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:guardian, "~> 2.0"},
      {:canada, "~> 2.0"},
      {:ex_machina, "~> 2.3", only: :test},
      {:corsica, "~> 1.0"},
      {:phoenix_swagger, git: "https://github.com/Bluetab/phx_swagger.git", tag: "6.0.0"},
      {:ex_json_schema, "~> 0.7.3"},
      {:json_diff, "~> 0.1.0"},
      {:td_cache, git: "https://github.com/Bluetab/td-cache.git", tag: "6.9.1"},
      {:td_cluster, git: "https://github.com/Bluetab/td-cluster.git", tag: "5.17.0"},
      {:sobelow, "~> 0.11", only: [:dev, :test]}
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
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "run priv/repo/seeds.exs", "test"]
    ]
  end
end
