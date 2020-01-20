defmodule TdDf.Repo.Migrations.AddGroupToTemplatesContent do
  use Ecto.Migration

  alias TdDf.Templates

  def up do
    Templates.list_templates()
    |> Enum.map(&group_content_by_group/1)
    |> Enum.each(fn {template, new_content} -> 
      Templates.update_template_no_cache(template, %{content: new_content})
    end)
  end

  defp group_content_by_group(%{content: content} = template) do
    new_content = content
      |> Enum.chunk_by(&(Map.get(&1, "group")))
      |> Enum.map(fn [%{"group" => name} | _] = fields -> 
        %{
          "name" => name,
          "fields" => clean_fields(fields)
        }
      end)
    {template, new_content}
  end

  defp clean_fields(fields) do
    Enum.map(fields, &(Map.take(&1, [
        "cardinality",
        "default",
        "label",
        "name",
        "type",
        "values",
        "widget",
        "depends",
    ])))
  end

  def down do
    Templates.list_templates()
    |> Enum.map(&unwind_content_by_group/1)
    |> Enum.each(fn {template, old_content} -> 
      Templates.update_template_no_cache(template, %{content: old_content})
    end)
  end

  defp unwind_content_by_group(%{content: content} = template) do
    old_content = content
      |> Enum.map(fn %{"name" => name, "fields" => fields} -> 
        Enum.map(fields, &(Map.put(&1, "group", name)))
      end)
      |> Enum.concat
    {template, old_content}
  end
end
