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

config :codepagex, :encodings, [
  :ascii,
  ~r[iso8859]i,
  "VENDORS/MICSFT/WINDOWS/CP1252"
]

# Configures the endpoint
config :td_df, TdDfWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tOxTkbz1LLqsEmoRRhSorwFZm35yQbVPP/gdU3cFUYV5IdcoIRNroCeADl4ysBBg",
  render_errors: [view: TdDfWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: TdDf.PubSub, adapter: Phoenix.PubSub.PG2]

config :td_df, TdDf.Repo,
  username: "postgres",
  password: "postgres",
  database: "td_df_dev",
  hostname: "localhost",
  pool_size: 10

# Configures Elixir's Logger
# set EX_LOGGER_FORMAT environment variable to override Elixir's Logger format
# (without the 'end of line' character)
# EX_LOGGER_FORMAT='$date $time [$level] $message'
config :logger, :console,
  format: (System.get_env("EX_LOGGER_FORMAT") || "$time $metadata[$level] $message") <> "\n",
  metadata: [:request_id]

# Configuration for Phoenix
config :phoenix, :json_library, Jason

config :td_df, TdDf.Auth.Guardian,
  # optional
  allowed_algos: ["HS512"],
  issuer: "tdauth",
  ttl: {1, :hours},
  secret_key: "SuperSecretTruedat"

config :td_df, :auth_service,
  protocol: "http",
  users_path: "/api/users/",
  sessions_path: "/api/sessions/",
  groups_path: "/api/groups"

config :td_df, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [router: TdDfWeb.Router]
  }

config :td_df, permission_resolver: TdCache.Permissions
config :td_df, acl_cache: TdCache.AclCache

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
"#{Mix.env()}.exs"
