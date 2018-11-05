defmodule TdDf.TemplateLoader do
  @moduledoc """
  GenServer to load acl into Redis
  """

  use GenServer

  alias TdDf.Templates
  alias TdPerms.DynamicFormCache

  require Logger

  @cache_templates_on_startup Application.get_env(:td_df, :cache_templates_on_startup)

  def start_link(name \\ nil) do
    GenServer.start_link(__MODULE__, nil, [name: name])
  end

  def refresh(template_name) do
    GenServer.call(TdDf.TemplateLoader, {:refresh, template_name})
  end

  def delete(template_name) do
    GenServer.call(TdDf.TemplateLoader, {:delete, template_name})
  end

  @impl true
  def init(state) do
    if @cache_templates_on_startup, do: schedule_work(:load_cache, 0)
    {:ok, state}
  end

  @impl true
  def handle_call({:refresh, template_name}, _from, state) do
    put_template(template_name)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:delete, template_name}, _from, state) do
    {:ok, _} = DynamicFormCache.delete_template(template_name)
    {:reply, :ok, state}
  end

  @impl true
  def handle_info(:load_cache, state) do
    Templates.list_templates |> put_templates
    {:noreply, state}
  end

  defp schedule_work(action, seconds) do
    Process.send_after(self(), action, seconds)
  end

  defp put_templates(templates) do
    Enum.each(templates, fn template ->
      DynamicFormCache.put_template(template)
    end)
  end
  defp put_template(template_name) do
    template = Templates.get_template_by_name!(template_name)
    {:ok, _} = DynamicFormCache.put_template(template)
  end
end
