use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :td_df, TdDfWeb.Endpoint, server: true

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :td_df, TdDf.Repo,
  username: "postgres",
  password: "postgres",
  database: "td_df_test",
  hostname: "postgres",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 1

config :td_df, permission_resolver: TdDf.Permissions.MockPermissionResolver

config :td_cache, redis_host: "redis"
