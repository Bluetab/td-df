defmodule TdDf.Repo.Migrations.MigrateDependsValues do
  use Ecto.Migration

  import Ecto.Query
  alias TdDf.Repo

  def change do
    from(t in "templates")
    |> select([:id, :content])
    |> Repo.all()
    |> Enum.filter(&has_dependend_fields?/1)
    |> Enum.map(&update_fields/1)
  end

  defp has_dependend_fields?(template) do
    template
    |> Map.get(:content, [])
    |> Enum.any?(fn f -> Map.has_key?(f, "depends") end)
  end

  defp update_fields(%{id: id, content: content}) do
    content = update_content(content)

    from(t in "templates")
    |> where([t], t.id == ^id)
    |> update([t], set: [content: ^content])
    |> Repo.update_all([])
  end

  defp update_content(content) do
    Enum.map(content, fn f ->
      case Map.has_key?(f, "depends") do
        true -> update_field(f)
        _ -> f
      end
    end)
  end

  defp update_field(field) do
    depends = Map.get(field, "depends")
    on = Map.get(depends, "on")
    to_be = Map.get(depends, "to_be")

    case to_be do
      nil -> field
      _ -> Map.put(field, "depends", %{"on" => on, "to_be" => [to_be]})
    end
  end
end
