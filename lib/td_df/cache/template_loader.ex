defmodule TdDf.Cache.TemplateLoader do
  @moduledoc """
  GenServer to load templates into Redis
  """

  use GenServer

  alias TdCache.TemplateCache
  alias TdDf.Templates

  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def refresh(id) do
    GenServer.call(__MODULE__, {:refresh, id})
  end

  def delete(id) do
    GenServer.call(__MODULE__, {:delete, id})
  end

  @impl true
  def init(state) do
    unless Application.get_env(:td_df, :env) == :test do
      schedule_work(:load_cache, 0)
    end

    {:ok, state}
  end

  @impl true
  def handle_call({:refresh, id}, _from, state) do
    put_template(id)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:delete, id}, _from, state) do
    {:ok, _} = TemplateCache.delete(id)
    {:reply, :ok, state}
  end

  @impl true
  def handle_info(:load_cache, state) do
    templates = Templates.list_templates()
    count = put_templates(templates)
    Logger.info("Put #{count} templates")
    {:noreply, state}
  end

  defp schedule_work(action, seconds) do
    Process.send_after(self(), action, seconds)
  end

  defp put_template(id) do
    {:ok, _} =
      id
      |> Templates.get_template!()
      |> TemplateCache.put()
  end

  defp put_templates(templates) do
    templates
    |> Enum.map(&TemplateCache.put/1)
    |> Enum.filter(& &1 != {:ok, []})
    |> Enum.count()
  end
end
