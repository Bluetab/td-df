defmodule TdDf.Cache.TemplateLoader do
  @moduledoc """
  Provides functionality to load templates into distributed cache
  """

  alias TdCache.TemplateCache
  alias TdDf.Templates

  require Logger

  def reload do
    Logger.info("Reloading templates")
    templates = Templates.list_templates()
    count = put_templates(templates, force: true, publish: false)
    Logger.info("Put #{count} templates")
    {:ok, count}
  end

  def refresh(id) do
    put_template(id)
  end

  def delete(id) do
    {:ok, _} = TemplateCache.delete(id)
  end

  defp put_template(id) do
    {:ok, _} =
      id
      |> Templates.get_template!()
      |> TemplateCache.put()
  end

  defp put_templates(templates, opts) do
    templates
    |> Enum.map(&TemplateCache.put(&1, opts))
    |> Enum.filter(&(&1 != {:ok, []}))
    |> Enum.count()
  end
end
