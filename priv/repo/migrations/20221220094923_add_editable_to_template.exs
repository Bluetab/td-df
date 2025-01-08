defmodule TdDf.Repo.Migrations.AddEditableToTemplate do
  use Ecto.Migration

  alias TdDf.Repo

  def up, do: update_editable_all(:put)
  def down, do: update_editable_all(:drop)

  def update_editable_all(operation) do
    TdDf.Templates.Template
    |> Repo.all()
    |> Enum.map(&update_editable(&1, operation))
    |> insert_all
  end

  defp insert_all(templates) do
    Repo.insert_all(TdDf.Templates.Template, templates,
      conflict_target: [:id],
      on_conflict: {:replace, [:content]}
    )
  end

  defp update_editable(%{content: content} = template, operation) do
    content
    |> Enum.map(fn group ->
      update_group_content(group, operation)
    end)
    |> update_template_content(template)
    |> Map.take([:id, :name, :content, :label, :scope, :subscope, :inserted_at, :updated_at])
  end

  def update_group_content(%{"fields" => fields} = group, :put) do
    %{group | "fields" => Enum.map(fields, &Map.put(&1, "editable", true))}
  end

  def update_group_content(%{"fields" => fields} = group, :drop) do
    %{group | "fields" => Enum.map(fields, &Map.drop(&1, ["editable"]))}
  end

  defp update_template_content(content, template) do
    %{template | content: content}
  end
end
