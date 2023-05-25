defmodule TdDf.Repo.Migrations.MigrateHierarchyValues do
  use Ecto.Migration

  import Ecto.Query
  alias TdDf.Repo

  def down do
  end

  def up do
    from(t in "templates")
    |> select([:id, :content])
    |> Repo.all()
    |> Enum.filter(fn template ->
      template
      |> Map.get(:content, [])
      |> Enum.any?(fn %{"fields" => fields} ->
        Enum.any?(fields, &(Map.get(&1, "type") == "hierarchy"))
      end)
    end)
    |> Enum.map(&update_fields/1)
  end

  def has_hierarchy_fields?(template) do
    template
    |> Map.get(:content, [])
    |> Enum.any?(fn %{"fields" => fields} ->
      Enum.any?(fields, &(Map.get(&1, "type") == "hierarchy"))
    end)
  end

  defp update_fields(%{id: id, content: content}) do
    content = update_content(content)

    from(t in "templates")
    |> where([t], t.id == ^id)
    |> update([t], set: [content: ^content])
    |> Repo.update_all([])
  end

  defp update_content(content) do
    Enum.map(content, fn %{"fields" => fields} = group ->
      Map.put(group, "fields", update_fields(fields))
    end)
  end

  defp update_fields(fields) do
    Enum.map(fields, fn
      %{"type" => "hierarchy", "values" => %{"hierarchy" => hierarchy_id}} = field ->
        Map.put(field, "values", %{
          "hierarchy" => %{
            "id" => hierarchy_id,
            "min_depth" => 0
          }
        })

      field ->
        field
    end)
  end
end
