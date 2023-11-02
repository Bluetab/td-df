defmodule TdDf.Application do
  @moduledoc false
  use Application
  alias TdDfWeb.Endpoint

  @impl true
  def start(_type, _args) do
    env = Application.get_env(:td_df, :env)
    # Define workers and child supervisors to be supervised
    children =
      [
        TdDf.Repo,
        TdDfWeb.Endpoint
      ] ++ workers(env)

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

  defp workers(:test), do: []

  defp workers(_env) do
    [TdDf.Scheduler]
  end
end
