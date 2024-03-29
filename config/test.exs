import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :td_df, TdDfWeb.Endpoint, server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Track all Plug compile-time dependencies
config :phoenix, :plug_init_mode, :runtime

# Configure your database
config :td_df, TdDf.Repo,
  username: "postgres",
  password: "postgres",
  database: "td_df_test",
  hostname: "postgres",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 1

config :td_cache, redis_host: "redis", port: 6380
