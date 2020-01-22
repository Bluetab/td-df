defmodule TdDf.Repo.Migrations.AddGroupToTemplatesContent do
  use Ecto.Migration

  import Ecto.Changeset

  alias TdDf.Repo
  alias TdDf.Templates
  alias TdDf.Templates.Template

  def up do
    Templates.list_templates()
    |> Enum.map(&group_content_by_group/1)
    |> Enum.each(fn {template, new_content} ->
      update_template(template, %{content: new_content})
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

  @doc false

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
      update_template(template, %{content: old_content})
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

  defp changeset_no_validation(%Template{} = template, attrs) do
    template
    |> cast(attrs, [:label, :name, :content, :scope])
  end

  defp update_template(%Template{} = template, attrs) do
    template
    |> changeset_no_validation(attrs)
    |> Repo.update()
  end
end
