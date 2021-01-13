defmodule TdDf.Mixfile do
  use Mix.Project

  def project do
    [
      app: :td_df,
      version:
        case System.get_env("APP_VERSION") do
          nil -> "4.11.0-local"
          v -> v
        end,
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers() ++ [:phoenix_swagger],
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
      {:phoenix, "~> 1.5.0"},
      {:plug_cowboy, "~> 2.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.1"},
      {:jason, "~> 1.0"},
      {:postgrex, ">= 0.0.0"},
      {:gettext, "~> 0.11"},
      {:httpoison, "~> 1.6"},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:guardian, "~> 2.0"},
      {:canada, "~> 2.0"},
      {:ex_machina, "~> 2.3", only: :test},
      {:corsica, "~> 1.0"},
      {:phoenix_swagger, "~> 0.8"},
      {:ex_json_schema, "~> 0.7.3"},
      {:json_diff, "~> 0.1.0"},
      {:td_cache, git: "https://github.com/Bluetab/td-cache.git", tag: "4.12.1"}
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
      test: ["ecto.create --quiet", "ecto.migrate", "run priv/repo/seeds.exs", "test"]
    ]
  end
end
