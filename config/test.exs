use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :td_df, TdDfWeb.Endpoint,
  http: [port: 3001],
  server: true

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

config :td_df, :auth_service, api_service: TdDfWeb.ApiServices.MockTdAuthService

config :td_df, permission_resolver: TdDf.Permissions.MockPermissionResolver
config :td_df, acl_cache_resolver: TdDf.AclLoader.MockAclLoaderResolver
config :td_df, user_cache_resolver: TdDf.AclLoader.MockAclLoaderResolver
config :td_df, taxonomy_cache_resolver: TdDf.MockTaxonomyResolver

config :td_df, cache_templates_on_startup: false
config :td_df, df_cache: TdPerms.MockDynamicFormCache

config :td_perms, redis_host: "redis"
