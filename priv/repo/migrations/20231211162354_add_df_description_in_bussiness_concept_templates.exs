defmodule TdDf.Repo.Migrations.AddDfDescriptionInBussinessConceptTemplates do
  use Ecto.Migration

  import Ecto.Query
  alias TdDf.Repo

  @desc_group "            "

  def down do
    templates = get_templates_with_new_group
    Enum.map(templates, &remove_field_template/1)
  end

  def up do
    templates = get_templates_without_new_group()
    Enum.map(templates, &add_field_template/1)
  end

  defp get_templates_with_new_group() do
    "templates"
    |> get_templates()
    |> Enum.filter(fn template ->
      template
      |> Map.get(:content, [])
      |> Enum.any?(fn %{"name" => name} ->
        name == @desc_group
      end)
    end)
  end

  defp get_templates_without_new_group() do
    processed = get_templates_with_new_group()

    "templates"
    |> get_templates()
    |> Enum.filter(fn template ->
      template
      |> Map.get(:content, [])
      |> Enum.any?(fn %{"name" => name} ->
        name != @desc_group
      end)
    end)
    |> Enum.reject(fn element -> Enum.any?(processed, &(&1.id == element.id)) end)
  end

  defp get_templates(table) do
    from(t in table)
    |> where(scope: ^"bg")
    |> select([:id, :content])
    |> Repo.all()
  end

  defp add_field_template(%{id: id, content: content}) do
    df_description_group_migrate = %{
      "name" => @desc_group,
      "fields" => [
        %{
          "name" => "df_description",
          "type" => "enriched_text",
          "label" => "Descripción",
          "values" => nil,
          "widget" => "enriched_text",
          "default" => "",
          "cardinality" => "?",
          "subscribable" => false,
          "ai_suggestion" => false
        }
      ]
    }

    updated_content = [df_description_group_migrate] ++ content

    do_update(id, updated_content)
  end

  defp remove_field_template(%{id: id, content: content}) do
    updated_content =
      Enum.filter(content, fn %{"name" => name} ->
        name != @desc_group
      end)

    do_update(id, updated_content)
  end

  defp do_update(id, content) do
    from(t in "templates")
    |> where([t], t.id == ^id)
    |> update([t], set: [content: ^content])
    |> Repo.update_all([])
  end
end
