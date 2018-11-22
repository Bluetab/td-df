use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :td_df, TdDfWeb.Endpoint,
  secret_key_base: "cY/PweEZ4hdpVM0gjUzWOltZLYeNdrFZK7BQD7/tPYFN9m2GAYhDaCJ4GnueSLNV"

# Configure your database
config :td_df, TdDf.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "${DB_USER}",
  password: "${DB_PASSWORD}",
  database: "${DB_NAME}",
  hostname: "${DB_HOST}",
  pool_size: 10

config :td_df, TdDf.Auth.Guardian,
  allowed_algos: ["HS512"], # optional
  issuer: "tdauth",
  ttl: { 1, :hours },
  secret_key: "${GUARDIAN_SECRET_KEY}"

config :td_df, :api_services_login,
  api_username: "${API_USER}",
  api_password: "${API_PASSWORD}"

config :td_perms, redis_host: "${REDIS_HOST}"
