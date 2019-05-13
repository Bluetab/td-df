defmodule TdDf.Repo.Migrations.MigrateToNewContentModel do
  use Ecto.Migration

  alias TdDf.Templates

  def change do
    Templates.list_templates()
    |> Enum.map(&convert_template/1)
    |> Enum.each(fn {template, content} ->
      Templates.update_template_no_cache(template, %{content: content})
    end)
  end

  defp convert_template(%{content: content} = template) do
    content =
      content
      |> Enum.map(&join_description_tooltip/1)
      |> Enum.map(&convert_field/1)

    {template, content}
  end

  defp convert_field(%{"meta" => %{"role" => role}} = field) do
    field
    |> add_single_cardinality
    |> Map.put("type", "user")
    |> Map.put("values", %{"role_users" => role})
    |> Map.drop(["required", "meta"])
  end

  defp convert_field(%{"switch_values" => switch} = field) do
    field
    |> add_single_cardinality
    |> Map.put("type", "string")
    |> Map.put("values", %{"switch" => switch})
    |> Map.drop(["required", "switch_values"])
  end

  defp convert_field(%{"type" => "variable_list", "widget" => "dropdown"} = field) do
    values = Map.get(field, "values", [])

    field
    |> add_variable_cardinality
    |> Map.put("type", "string")
    |> Map.put("values", %{"fixed" => values})
    |> Map.drop(["required"])
  end

  defp convert_field(%{"type" => "variable_list", "widget" => "multiple_input"} = field) do
    field
    |> add_variable_cardinality
    |> Map.put("type", "string")
    |> Map.drop(["values", "required", "widget"])
  end

  defp convert_field(%{"type" => "variable_map_list"} = field) do
    field
    |> add_variable_cardinality
    |> Map.put("type", "url")
    |> Map.drop(["required"])
  end

  defp convert_field(%{"type" => "list"} = field) do
    values = Map.get(field, "values", [])

    field
    |> add_single_cardinality
    |> Map.put("type", "string")
    |> Map.put("values", %{"fixed" => values})
    |> Map.drop(["required"])
  end

  defp convert_field(%{"type" => "string"} = field) do
    field
    |> add_single_cardinality
    |> Map.drop(["required"])
  end

  defp convert_field(field), do: field

  defp join_description_tooltip(field) do
    description = Map.get(field, "description", Map.get(field, "tooltip"))

    field
    |> Map.put("description", description)
    |> Map.drop(["tooltip"])
  end

  defp add_variable_cardinality(%{"required" => true} = field),
    do: Map.put(field, "cardinality", "+")

  defp add_variable_cardinality(field), do: Map.put(field, "cardinality", "*")

  defp add_single_cardinality(%{"required" => true} = field),
    do: Map.put(field, "cardinality", "1")

  defp add_single_cardinality(field), do: Map.put(field, "cardinality", "?")
end
