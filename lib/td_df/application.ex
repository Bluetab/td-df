defmodule TdDf.Application do
  @moduledoc false
  use Application
  alias TdDfWeb.Endpoint

  @impl true
  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    children = [
      TdDf.Repo,
      TdDfWeb.Endpoint,
      TdDf.Scheduler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TdDf.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
