defmodule TdDf.TemplateLoader do
  @moduledoc """
  GenServer to load acl into Redis
  """

  use GenServer

  alias TdDf.Templates
  @df_cache Application.get_env(:td_df, :df_cache)

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
    {:ok, _} = @df_cache.delete_template(template_name)
    {:reply, :ok, state}
  end

  @impl true
  def handle_info(:load_cache, state) do
    IO.puts "Cleaning cache"
    @df_cache.clean_cache()
    templates = Templates.list_templates
    put_templates(templates)
    IO.puts "Added #{length(templates)} templates."
    {:noreply, state}
  end

  defp schedule_work(action, seconds) do
    Process.send_after(self(), action, seconds)
  end

  defp put_templates(templates) do
    Enum.each(templates, fn template ->
      @df_cache.put_template(template)
    end)
  end
  defp put_template(template_name) do
    template = Templates.get_template_by_name!(template_name)
    {:ok, _} = @df_cache.put_template(template)
  end
end
