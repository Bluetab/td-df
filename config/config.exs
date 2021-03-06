# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Environment
config :td_df, :env, Mix.env()

# General application configuration
config :td_df,
  ecto_repos: [TdDf.Repo]

# Configures the endpoint
config :td_df, TdDfWeb.Endpoint,
  http: [port: 4013],
  url: [host: "localhost"],
  render_errors: [view: TdDfWeb.ErrorView, accepts: ~w(json)]

config :td_df, TdDf.Repo,
  username: "postgres",
  password: "postgres",
  database: "td_df_dev",
  hostname: "localhost",
  pool_size: 4

# Configures Elixir's Logger
# set EX_LOGGER_FORMAT environment variable to override Elixir's Logger format
# (without the 'end of line' character)
# EX_LOGGER_FORMAT='$date $time [$level] $message'
config :logger, :console,
  format:
    (System.get_env("EX_LOGGER_FORMAT") || "$date\T$time\Z [$level]$levelpad $metadata$message") <>
      "\n",
  level: :info,
  metadata: [:pid, :module],
  utc_log: true

# Configuration for Phoenix
config :phoenix, :json_library, Jason
config :phoenix_swagger, :json_library, Jason

config :td_df, TdDf.Auth.Guardian,
  # optional
  allowed_algos: ["HS512"],
  issuer: "tdauth",
  ttl: {1, :hours},
  secret_key: "SuperSecretTruedat"

config :td_df, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [router: TdDfWeb.Router]
  }

config :td_df, permission_resolver: TdCache.Permissions

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
