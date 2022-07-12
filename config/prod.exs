import Config

config :td_df, TdDfWeb.Endpoint, server: true

config :td_df, TdDf.Scheduler,
  jobs: [
    template_loader: [
      schedule: "@reboot",
      task: {TdDf.Cache.TemplateLoader, :reload, []},
      run_strategy: Quantum.RunStrategy.Local
    ]
  ]
